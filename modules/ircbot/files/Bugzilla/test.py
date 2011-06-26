###
# Copyright (c) 2007, Max Kanat-Alexander
# All rights reserved.
#
#
###

from supybot.test import *

class BugzillaTestCase(ChannelPluginTestCase):
    plugins = ('Bugzilla')
    config = {'supybot.plugins.Bugzilla.mbox': 'test/mbox'
              'supybot.plugins.Bugzilla.reportedChanges': ['All', 'newBug', 
                                                           'newAttach']}


# vim:set shiftwidth=4 tabstop=4 expandtab textwidth=79:
