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
from pprint import pprint
from email.Header import decode_header

#############
# Constants #
#############

'''These are fields that are multi-select fields, so when somebody
   adds something to them, the verbs "added to " or "removed from" should 
   be used instead of the verb "changed" or "set".

   The fields are named as they appear in the "What" part of a bugmail 
   "changes" table.'''
MULTI_FIELDS = ['CC', 'Group', 'Keywords', 'Blocks', 'Depends on']

'''Some fields have such long names for the "What" column that their 
   names wrap. Normally, our code would think that those fields were
   two different fields. So, instead, we store a list of strings to use
   as an argument to "grep" for the field names that we need to "unwrap."'''
UNWRAP_WHAT = [re.compile('^Attachment .\d+$'), re.compile('^OtherBugsDep'),
               re.compile('^Attachment .\d+ is')]

'''Should be whatever Bugzilla::Util::find_wrap_point (or FindWrapPoint) 
   breaks on, in Bugzilla.'''
BREAKING_CHARACTERS = [' ',',','-']

# The maximum width, in characters, of each field of the "diffs" table.
WIDTH_WHAT    = 19
WIDTH_REMOVED = 28
WIDTH_ADDED   = 28

##############################
# Diff-Table Parsing Helpers #
##############################

diff_re = re.compile('(?P<what>.{%d})\|(?P<removed>.{%d})\|(?P<added>.*)' \
                     % (WIDTH_WHAT, WIDTH_REMOVED))

def _parseDiffs(changesPart):
    diffTableMatches = diff_re.finditer(changesPart)
    if not diffTableMatches: return []
    diffTable = [line.group() for line in diffTableMatches]
    if not diffTable: return [] 
    # Remove the "What/Removed/Added" line.
    del diffTable[0];
    diffs = [];
    # We use "while" instead of a list comprehension because the function
    # modifies diffTable.
    while (diffTable): 
        line = _getNextDiffLine(diffTable)
        diffs.append(line);

    diffArray = _normalizeDiffs(diffs)
    return _fixFlags(diffArray)

def _getNextDiffLine(diffTable):
    diffLine = diffTable.pop(0)
    lineMatch = diff_re.match(diffLine)
    what    = lineMatch.group('what').strip()
    removed = lineMatch.group('removed').strip()
    added   = lineMatch.group('added').strip()
    # Check if it's a two-line What
    twoLineMatch = False
    for r in UNWRAP_WHAT:
        if r.search(what): twoLineMatch = True
    if (twoLineMatch):
        nextLine = _getNextDiffLine(diffTable)
        what     = _appendDiffLine(what, what, nextLine['what'], WIDTH_WHAT)
        if nextLine['removed']:
            removed = _appendDiffLine(removed, removed, nextLine['removed'],
                                      WIDTH_REMOVED)
        if nextLine['added']:
            added = _appendDiffLine(added, added, nextLine['added'],
                                    WIDTH_ADDED)

    return { 'what' : what, 'removed': removed, 'added': added }

def _normalizeDiffs(diffs):
    returnDiffs = []
    while (diffs):
        diff    = diffs.pop(0)
        what    = diff['what']
        removed = diff['removed']
        added   = diff['added']
        while (diffs and not diffs[0]['what']):
            nextDiff = diffs.pop(0)
            removed  = _appendDiffLine(removed, removed, nextDiff['removed'],
                                       WIDTH_REMOVED)
            added    = _appendDiffLine(added, added, nextDiff['added'],
                                       WIDTH_ADDED)

        normalized = { 'what' : what, 'removed' : removed, 'added': added }
        match = re.match('Attachment #(\d+)(.*)', what)
        if match:
            normalized['what'] = 'Attachment' + match.group(2)
            normalized['attachment'] = match.group(1)
        
        returnDiffs.append(normalized)
    return returnDiffs

def _fixFlags(diffs):
    returnDiffs = []
    for diff in diffs:
        if diff['what'].find('Flag') == -1:
            returnDiffs.append(diff)
        else:
            returnDiffs.append(_parseFlagEntry(diff))

    return returnDiffs

# This is a little fancy because we have to support multiplicable flags.
def _parseFlagEntry(diff):
    # Get a list of all the flag names that have been modified,
    # and parse each individual flag string into an object,
    # putting them into arrays for whether they've been added or removed.
    flags = { 'added' : {}, 'removed' : {} }
    flag_names = []
    for type in ['removed', 'added']:
        if diff[type]:
            flag_list = diff[type].split(',')
            for text_flag in flag_list:
                flag = _parseFlag(text_flag)
                name = flag['name']
                if name not in flags[type]: flags[type][name] = []
                flags[type][name].append(flag)
                if name not in flag_names: flag_names.append(name)

    # Now make a hash that says, for each flag, what that flag moved to,
    # from what.
    flag_from_to = {}
    for name in flag_names:
        flag_from_to[name] = []
        added   = flags['added'].get(name, [])
        removed = flags['removed'].get(name, [])
        for flag in removed:
            to = None
            if len(added): to = added.pop(0)
            flag_from_to[name].append({ 'from' : flag, 'to' : to })
        for flag in added:
            flag_from_to[name].append({ 'from' : None, 'to' : flag })

    status    = { '+' : [], '-' : [], '?' : [], 'cancelled': [] }
    for name, changes in flag_from_to.iteritems():
        for change in changes:
            to_flag   = change['to']
            from_flag = change['from']

            # Possible ways a flag can be cancelled: We simply removed
            # the flag, we changed the requestee (meaning both flags will be 
            # '?', or we moved from granted/denied to '?'. That means
            # if from_flag exists and to_flag is ever set to '?', we
            # cancelled something.
            if (from_flag and (not to_flag or to_flag['status'] == '?')):
                status['cancelled'].append(from_flag)

            # And append the flag we're moving to into its correct status
            if to_flag:
                status[to_flag['status']].append(to_flag)

    diff['flags'] = status
    return diff

def _parseFlag(flagString):
    match = re.search('\s*(?P<name>[^\?]+)(?P<status>\+|-|\?)'
                      + '(?:\((?P<requestee>.*)\))?$', flagString.strip())
    if match:
        flag = match.groupdict()
    else:
        # A hack for bugzilla.gnome.org
        flag = { 'name' : flagString, 'status' : '+', 'requestee' : None }
    return flag


#####################
# Utility Functions #
#####################        

# existing string.
def _appendDiffLine (append_to, prev_line, append_line, max_width):
    '''When processing the "diffs" table in a bug, some lines wrap. This
       function properly appends the "next" line for unwrapping to an 
       existing string.'''
    ret_line = append_to;

    # If the previous line is the width of the entire column, we
    # assume that we were forcibly wrapped in the middle of a word,
    # and no space is needed. We only add the space if we were actually
    # given a non-empty string to append.
    if (append_line and len(prev_line) != max_width):
        # However, sometimes even if we have a very short line, if it ended
        # in a "breaking character" like '-' then we also don't need a space.
        if prev_line[-1] not in BREAKING_CHARACTERS: ret_line += " "
    ret_line += append_line
    return ret_line

def _get_header(str):
   '''Get the full text of a header and remove newlines.'''
   list = decode_header(str)
   retString = ''
   for string, charset in list:
       retString += string.replace("\n", '').replace("\r", '')
   return retString

class BugmailParseError(Exception):
    pass

class NotBugmailException(BugmailParseError):
    pass

class Bugmail:

    # Constants
    '''These are fields that are multi-select fields, so when somebody
       adds something to them, the verbs "added to " or "removed from" should 
       be used instead of the verb "changed" or "set".

       The fields are named as they appear in the "What" part of a bugmail 
       "changes" table.'''
    MULTI_FIELDS = ['CC', 'Group', 'Keywords', 'BugsThisDependsOn', 
                    'OtherBugsDependingOnThis']

    '''Some fields have such long names for the "What" column that their 
       names wrap. Normally, our code would think that those fields were
       two different fields. So, instead, we store a list of strings to use
       as an argument to "grep" for the field names that we need to
       "unwrap."'''
    UNWRAP_WHAT = [re.compile('^Attachment .\d+$'), 
                   re.compile('^Attachment .\d+ is'), 
                   re.compile('^OtherBugsDep')]

    '''Should be whatever Bugzilla::Util::find_wrap_point (or FindWrapPoint) 
       breaks on, in Bugzilla.'''
    BREAKING_CHARACTERS = [' ',',','-']

    # The maximum width, in characters, of each field of the "diffs" table.
    WIDTH_WHAT    = 19
    WIDTH_REMOVED = 28
    WIDTH_ADDED   = 28

    def __init__(self, message):
        # Make sure this is actually a bug mail
        if not message['X-Bugzilla-Product']:
            raise NotBugmailException, 'Email lacks X-Bugzilla-Product header'
        # Initialize fields used lower that aren't always set
        self.dupe_of = None
        self.attach_id = None

        # Basic Header Fields
        self.changer   = _get_header(message['X-Bugzilla-Who'])
        self.product   = _get_header(message['X-Bugzilla-Product'])
        self.component = _get_header(message['X-Bugzilla-Component'])
        self.status    = _get_header(message['X-Bugzilla-Status'])
        self.severity  = _get_header(message['X-Bugzilla-Severity'])
        self.priority  = _get_header(message['X-Bugzilla-Priority'])
        self.assignee  = _get_header(message['X-Bugzilla-Assigned-To'])
        
        # Get the urlbase of the installation
        if 'In-Reply-To' in message:
            baseHeader = _get_header(message['In-Reply-To'])
        else:
            baseHeader = _get_header(message['Message-ID'])
        baseMatch = re.search('@((?P<scheme>https?)\.)?(?P<url>.+)>$',
                              baseHeader, re.I)
        if baseMatch.group('scheme'):
            self.urlbase = "%s://%s" % (baseMatch.group('scheme'),
                                        baseMatch.group('url'))
        else:
            # This is a hack to support bugzilla.gnome.org.
            self.urlbase = 'http://%s/' % baseMatch.group('url')

        # Subject Data
        subjectMatch = re.search('\s*\[\w+ (?P<bug_id>\d+)\]\s+(?P<new>New:)?',
                                 _get_header(message['Subject']))
        if not subjectMatch:
            raise NotBugmailException, 'Subject does not contain [Bug #]'
        self.bug_id = int(subjectMatch.group('bug_id'))
        self.new    = bool(subjectMatch.group('new'))

        messageBody = message.get_payload(decode=True)
        # Normalize newlines
        messageBody = messageBody.replace("\r\n", "\n")

        if self.new:
            diffStartMatch = re.search('^-{30,}$', messageBody, re.M)
            # In new bugmails, if there is an attachment or some flags,
            # there can be a diff table and then a comment below it. The
            # diff table is separated from the bug fields by \n\n, and the
            # comment is separated from the diff table by \n\n.
            if diffStartMatch:
                diffStart = diffStartMatch.start()
            else:
                diffStartMatch = re.search(r"\n\n\n", messageBody)
                diffStart = diffStartMatch.start()

            commentStartMatch = re.search(r"\n\n\n", messageBody[diffStart:])
            if commentStartMatch:
                commentStart = commentStartMatch.start();
            else:
                commentStart = diffStart

            if self.changer == 'None':
                whoMatch = re.search('ReportedBy: (?P<who>.*)', messageBody)
                self.changer = whoMatch.group('who')
        else:
            commentLineMatch = re.search(\
                '^-+.*Comment.*From (?P<who>.*)\s+\d{4}-\d\d-\d\d .*---$',
                messageBody, re.I | re.M)
            commentStart = len(messageBody) - 1
            if commentLineMatch:
                commentStart = commentLineMatch.start()
                # This is pre-3.0 support for changer
                if self.changer == 'None':
                    self.changer = commentLineMatch.group('who').strip()
            if self.changer == 'None':
                whoMatch = re.search('^(?P<who>.*)\s+changed:$', messageBody, 
                                     re.M)
                # whoMatch can be None, in a dependency change.
                if whoMatch: self.changer = whoMatch.group('who')
       
        # Diff Table
        changesPart = messageBody[:commentStart].strip()
        self.diffPart = changesPart # For debugging
        # Check if this is a dependency change
        if re.search('^Bug \d+ depends on bug \d+, which changed state',
                     changesPart, re.M):
            raise NotBugmailException, 'Dependency change.'

        commentEnd = None
        sig = re.search("^-- $", messageBody, re.M)
        if sig: commentEnd = sig.start() - 1
        
        self.comment = messageBody[commentStart:commentEnd].strip()

        self._diffArray = []
        changesPart = messageBody[:commentStart]
        self._diffArray = _parseDiffs(changesPart)

        if not self.new:
            # Duplicate ID
            dupMatch = re.search('marked as a duplicate of (?:bug\s)?(\d+)',
                                 self.comment)
            if dupMatch and self.changed('Resolution'): self.dupe_of = int(dupMatch.group(1))

        # Attachment ID, which lives in the comment.
        attachMatch = re.search('^Created an attachment \(id=(\d+)\)',
                                self.comment, re.M)
        if attachMatch: self.attach_id = int(attachMatch.group(1))

    def changed(self, field):
        return filter(lambda i: i['what'] == field, self._diffArray)

    def diffs(self):
        return self._diffArray

    def fields(self):
        # These should be kept in order of what will override what, in terms
        # of watchedItems configuration.
        return {
            'product'   : self.product,
            'component' : self.component,
            'status'    : self.status,
            'severity'  : self.severity,
            'priority'  : self.priority,
            'assignee'  : self.assignee,
            'changer'   : self.changer,
            'bug_id'    : self.bug_id,
            'attach_id' : self.attach_id,
        }
