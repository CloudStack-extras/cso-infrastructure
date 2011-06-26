###
# Copyright (c) 2007, Max Kanat-Alexander
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions, and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions, and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#   * Neither the name of the author of this software nor the name of
#     contributors to this software may be used to endorse or promote products
#     derived from this software without specific prior written consent.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

###


import re

BIN_REGEX   = re.compile(r"(Backtrace|Core) was generated (from|by) (`|')(?P<bin>.+)'")
FRAME_REGEX = re.compile(r"#(?P<level>\d+)\s+(?P<loc>0x[A-Fa-f0-9]+)\s+in\s+"
                         + r"(?P<func>[^@\s]+)(@+(?P<libTag>GLIBC_2.3.2))?\s*"
                         + r"\((?P<args>[^\)]*)\)\s*(from (?P<library>\S+))?"
                         + r"\s*(at (?P<file>[^:]+):(?P<line>\d+))?")
IGNORE_LINES = ('No symbol table info available.', 'No locals.')

class TraceParseException(Exception):
    pass

class NoTrace(TraceParseException):
    pass

class FrameParseError(TraceParseException):
    pass

class StackFrame:
    def __init__(self, string):
        match  = FRAME_REGEX.match(string)
        signal = string.find('<signal handler called>')
        if signal > -1:
            self.signalHandled = True
        else:
            self.signalHandled = False
    
        if match:
            self.fields = match.groupdict()
        else:
            if signal == -1:
                raise FrameParseError, "Couldn't parse %s" % string
            self.fields = { 'args' : '', 'func' : '' }
        
        self.args = {}
        argsString = self.fields['args']
        if argsString:
            argsList = argsString.split(',')
            for arg in argsList:
                items = arg.split('=', 1)
                try:
                    self.args[items[0]] = items[1]
                # Sometimes the split doesn't work perfectly, and we
                # end up with weird stuff. We should just pass it by.
                except IndexError:
                    pass
        self.asString = string
        
    def function(self):
        return self.fields['func']
    
class StackThread(list):
    def __init__(self, number=0, desc='', *args, **kwargs):
        self.threadNumber = number
        self.threadDesc   = desc
        self.__parent = super(list, self)
        self.__parent.__init__(*args, **kwargs)
    
    def functionIndex(self, funcName):
        """Searches this thread for a stack frame that contains a function
        with a specific name (case-insensitive). Returns the index of the
        frame containing the function, or -1 if the frame is not found."""
        
        for index, frame in enumerate(self):
            if frame.fields['func'].lower() == funcName.lower():
                return index
        return -1
    
    def signalHandlerIndex(self):
        """Searches this thread for a place where a signal handler was
        called. In most stack traces, this indicates where we crashed.
        Returns -1 if this thread doesn't contain a signal handler."""
        
        for index, frame in enumerate(self):
            if frame.signalHandled: return index
        return -1
        

traceRe  = re.compile(r"^#(\d+)\s+(0x[A-Fa-f0-9]+ in \w+)|(<signal handler called>)", re.M)
threadRe = re.compile("^Thread (?P<num>\d+) \((?P<desc>.*)\):$")

def _getNextTraceLine(lines):
    line = lines.pop(0)

    if traceRe.search(line):
        while lines:
            nextLine = _getNextFrameLine(lines)
            if nextLine is None: break
            line = "%s %s" % (line, nextLine)
            
    return line

def _getNextFrameLine(lines):
    line = lines[0]
    if (line.strip() == '' or line in IGNORE_LINES
        or traceRe.search(line) or threadRe.search(line)):
        return None
    else:
        return lines.pop(0)

class Trace:
    def __init__(self, string):
        if not traceRe.search(string):
            raise NoTrace, "This doesn't look like a stack trace."

        binMatch = BIN_REGEX.search(string)
        if binMatch:
            self.bin = binMatch.group('bin')
        else:
            self.bin = ''

        lines = string.split("\n")
        for count, line in enumerate(lines):
            if traceRe.search(line):
                if count == 0: count = 1
                break
        
        # We include the prior line because it could contain "Thread X"
        traceLines = lines[count - 1:]
        firstLine = traceLines.pop(0)
        threads = {}
        threadMatch = threadRe.search(firstLine)
        if threadMatch:
            currentThread = int(threadMatch.group('num'))
            threads[currentThread]  = StackThread(threadMatch.group('num'),
                                                  threadMatch.group('desc'))
        else:
            currentThread = 0
            threads[0] = StackThread(0)
            
        currentFrame  = 0
        lastLineWasBlank = False
        while traceLines:
            line = _getNextTraceLine(traceLines)
            
            if line.strip() == '':
                lastLineWasBlank = True
                continue
            elif line in IGNORE_LINES:
                continue
            
            threadMatch = threadRe.search(line)
            traceMatch  = traceRe.search(line)
            if threadMatch:
                currentThread = int(threadMatch.group('num'))
                threads[currentThread] = StackThread(threadMatch.group('num'),
                                                     threadMatch.group('desc'))
            elif traceMatch:
                threads[currentThread].append(StackFrame(line))

            lastLineWasBlank = False
            
        self.threads = []
        threadNums = threads.keys()
        threadNums.sort()
        for num in threadNums:
            self.threads.append(threads[num])
            
