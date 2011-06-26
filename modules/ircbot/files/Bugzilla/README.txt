This plugin supports querying Bugzilla installations, showing details about
bugs, and reading bugmails sent from Bugzilla to show updates in an IRC
channel. It supports working with multiple Bugzilla installations and can
work across many channels and networks.

The main commands you'll be interested in at first are "Bugzilla add", and
then "query" and "bug". Then you should set the
plugins.Bugzilla.defaultBugzilla configuration parameter.

You will probably also want to enable plugins.Bugzilla.bugSnarfer, which
catches the words "bug" and "attachment" in regular IRC conversation and
displays details about that bug or attachment.

The plugin has lots and lots of configuration options, and all the
configuration options have help, so feel free to read up after loading
the plugin itself, using the "config help" command.
