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


import supybot.conf as conf
import supybot.registry as registry
import supybot.ircutils as ircutils

def configure(advanced):
    # This will be called by supybot to configure this module.  advanced is
    # a bool that specifies whether the user identified himself as an advanced
    # user or not.  You should effect your configuration by manipulating the
    # registry as appropriate.
    from supybot.questions import expect, anything, something, yn
    conf.registerPlugin('Bugzilla', True)
    if yn("""This plugin can show data about bug URLs and numbers mentioned
             in the channel. Do you want this bug snarfer enabled by 
             default?""", default=False):
        conf.supybot.plugins.Bugzilla.bugSnarfer.setValue(True)


class ColorString(registry.OnlySomeStrings):
    """That is not a valid color/format string."""
    validStrings = ircutils.mircColors.keys()
    validStrings.extend(['bold', 'reverse', 'underlined', ''])

class FormatString(registry.CommaSeparatedListOfStrings):
    Value = ColorString
    
class ValidInstall(registry.String):
    """You must pick the name of a group from the list of bugzillas."""
    
    def setValue(self, v):
        names  = conf.supybot.plugins.Bugzilla.bugzillas()[:]
        names.append('')
        if v not in names:
            self.error()
        registry.String.setValue(self, v)

Bugzilla = conf.registerPlugin('Bugzilla')
# This is where your configuration variables (if any) should go.  For example:
# conf.registerGlobalValue(Bugzilla, 'someConfigVariableName',
#     registry.Boolean(False, """Help for someConfigVariableName."""))
conf.registerChannelValue(Bugzilla, 'bugSnarfer',
    registry.Boolean(False, """Determines whether the bug snarfer will be
    enabled, such that any Bugzilla URLs and bug ### seen in the channel
    will have their information reported into the channel."""))
conf.registerGlobalValue(Bugzilla, 'bugSnarferTimeout',
    registry.PositiveInteger(300, 
    """Users often say "bug XXX" several times in a row, in a channel.
    If "bug XXX" has been said in the last (this many) seconds, don't
    fetch its data again. If you change the value of this variable, you
    must reload this plugin for the change to take effect."""))

conf.registerChannelValue(Bugzilla, 'bugFormat',
    registry.SpaceSeparatedListOfStrings(['bug_severity', 'priority',
        'target_milestone', 'assigned_to', 'bug_status', 'short_desc'],
    """The fields to list when describing a bug, after the URL."""))
conf.registerChannelValue(Bugzilla, 'attachFormat',
    registry.SpaceSeparatedListOfStrings(['type', 'desc', 'filename'],
    """The fields to list when describing an attachment after announcing
    a change to that attachment."""))

conf.registerGroup(Bugzilla, 'format',
    help="""How various messages should be formatted in terms of bold, colors,
         etc.""")
conf.registerChannelValue(Bugzilla.format, 'change',
    FormatString(['teal'], 
    """When the plugin reports that something has changed on a
                        bug, how should that string be formatted?"""))
conf.registerChannelValue(Bugzilla.format, 'attachment',
    FormatString(['green'], 
    """When the plugin reports the details of an attachment, how should we
    format that string?"""))
conf.registerChannelValue(Bugzilla.format, 'bug',
    FormatString(['red'], 
   """When the plugin reports the details of a bug, how should we format 
   that string?"""))

conf.registerChannelValue(Bugzilla, 'queryResultLimit',
    registry.PositiveInteger(5, 
    """The number of results to show when using the "query" command."""))

conf.registerGlobalValue(Bugzilla, 'mbox', 
    registry.String('', """A path to the mbox that we should be watching for
    bugmail.""", private=True))
conf.registerGlobalValue(Bugzilla, 'mboxPollTimeout',
    registry.PositiveInteger(10, """How many seconds should we wait between
    polling the mbox?"""))

conf.registerGroup(Bugzilla, 'messages', orderAlphabetically=True, 
    help="""Various messages that can be re-formatted as you wish. If a message
            takes a format string, the available format variables are:
            product, component, bug_id, attach_id, and changer)""")

conf.registerChannelValue(Bugzilla.messages, 'newBug',
    registry.String("New %(product)s bug %(bug_id)d filed by %(changer)s.",
    """What the bot will say when a new bug is filed."""))
conf.registerChannelValue(Bugzilla.messages, 'newAttachment',
    registry.String("%(changer)s added attachment %(attach_id)d to bug %(bug_id)d",
    """What the bot will say when somebody adds a new attachment to a bug."""))
conf.registerChannelValue(Bugzilla.messages, 'noRequestee',
    registry.String('from the wind',
    """How should we describe it when somebody requests a flag without
    specifying a requestee? This should probably start with "from." It
    can also be entirely empty, if you want."""))

conf.registerGlobalValue(Bugzilla, 'bugzillas',
    registry.SpaceSeparatedListOfStrings([],
    """The various Bugzilla installations that have been created
    with the 'add' command."""))
conf.registerChannelValue(Bugzilla, 'defaultBugzilla',
        ValidInstall('', """If commands don't specify what installation to use,
        then which installation should we use?"""))

# vim:set shiftwidth=4 tabstop=4 expandtab textwidth=79:
