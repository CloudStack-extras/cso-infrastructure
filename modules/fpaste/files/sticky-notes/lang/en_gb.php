<?php
/**
* Sticky Notes pastebin
* @ver 0.2
* @license BSD License - www.opensource.org/licenses/bsd-license.php
*
* Copyright (c) 2011 Sayak Banerjee <sayakb@kde.org>
* All rights reserved. Do not remove this copyright notice.
*/

$lang_data = array(
    /* Page: index.php */
    'your_alias'	=> 'Your alias',
    'language'		=> 'Language',
    'private_paste'	=> 'Mark as private',
    'paste'		=> 'Paste',
    'create_new'	=> 'New paste',
    'author_numeric'	=> 'Your alias must be alphanumeric',
    'nothing_to_do'	=> 'Nothing to do',
    'password'		=> 'Password',
    'paste_saved'	=> 'Your paste has been saved: __url__', // Do not change __url__
    'paste_error'	=> 'An error occurred while saving your paste',
    'del_30min'		=> 'Delete after 30 minutes',
    'del_6hrs'		=> 'Delete after 6 hours',
    'del_1day'		=> 'Delete after 1 day',
    'del_1week'		=> 'Delete after 1 week',
    'del_1month'	=> 'Delete after 1 month',
    'keep_forever'	=> 'Keep paste forever',


    /* Page: show.php */
    'posted_info'	=> 'Posted by __user__ at __time__', // Do not change __user__ and __time__
    'error_404'		=> 'The paste you are looking for does not exist',
    'error_hash'	=> 'The contents of this paste have been hidden',
    'error'		=> 'Error',
    'view_raw'		=> 'Raw code',
    'pass_protect'	=> 'This paste is password protected',
    'submit'		=> 'Submit',
    'invalid_password'	=> 'You have entered an incorrect password',
    'share'		=> 'Share',
    'anonymous'         => 'Anonymous',


    /* Page: list.php */
    'paste_archive'	=> 'Paste archive',
    'no_pastes'		=> 'No pastes found',
    'view_paste'	=> 'View paste &raquo;',
    'pages'		=> 'Pages',


    /* RSS */
    'feed'		=> 'Recent pastes',
    
    
    /* Antispam */
    'sg_error_stealth'  => 'Your paste triggered our spam filter and has been dropped',
    'sg_error_php'      => 'Your IP address is listed as a malicious IP',
    'sg_error_ipban'    => 'Your IP address has been banned',


    /* Global */
    'sticky_notes'	=> 'Sticky Notes',
    'sticky_notes_pb'	=> 'Sticky Notes pastebin',
    'version'		=> 'Version 0.2',
    'home'		=> 'Home',
    'archives'		=> 'Archives',
    'rss'		=> 'Feed',
    'api'		=> 'API',
    'about'		=> 'About',
    'help'		=> 'Help',
    'admin'             => 'Admin',


    /* Documentation: api */
    'doc_api_title'	=> 'API',
    'xml_caption'	=> 'XML Output',
    'json_caption'	=> 'JSON Output',
    'api_lcase'		=> 'api',
    'create_lcase'	=> 'create',
    'show_lcase'	=> 'show',
    'list_lcase'	=> 'list',
    'create'		=> 'Create',
    'show'		=> 'Show',
    'list'		=> 'List',
    'mandatory_params'	=> 'Mandatory parameters',
    'optional_params'	=> 'Optional parameters',
    'paste_text'	=> 'The text to be pasted',
    'paste_text_exp'	=> 'The paste data',
    'paste_language'	=> 'The development language used',
    'paste_lang_exp'	=> 'Language of the paste data',
    'language_list_exp'	=> 'For a list of supported language codes ' .
			   'for the <i>paste_lang</i> parameter, see <a href="' .
			   '[[host]]doc/lang">[[host]]doc/lang</a>.',
    'paste_author'	=> 'An alphanumeric username of the paste author',
    'paste_author_exp'	=> 'Author of the paste',
    'paste_timestamp'	=> 'UNIX timestamp representing paste creation time',
    'paste_pwd'		=> 'A password string to protect the paste',
    'paste_pvt'		=> 'Private post flag, having the values: <i>yes</i> or <i>no</i>',
    'paste_proj'	=> 'Whether to associate a project with the paste',
    'paste_proj_exp'	=> 'Project that the paste collection belongs to',
    'paste_page'	=> 'The list page to be fetched',
    'paste_list_exp'	=> 'Contains sub-elements like paste1, paste2 etc. each of which ' .
			       'have a paste ID',
    'paste_count'	=> 'Number of paste elements enclosed within <i>pastes</i>',
    'paste_pages'	=> 'Total number of pages',
    'paste_exptime'	=> 'Time in seconds after which paste will be deleted from server. ' .
			   'Set this value to 0 to disable this feature.',

    'return_success'	=> 'Return values on success',
    'return_error'	=> 'Return values on error',
    'id_of_paste'	=> 'ID of the paste',
    'hash_of_paste'	=> 'Hash/key for the paste (only for private pastes)',
    'password_of_paste' => 'Password to unlock the paste (only for protected pastes)',
    'url_format_exp'	=> 'URLs can be framed as <a>[[host]]&lt;id&gt;</a> for public pastes ' .
			   'and <a>[[host]]&lt;id&gt;/&lt;hash&gt;</a> for private pastes.',
    'result_format_exp'	=> 'The format (xml or json) in which you want the result',
    'error_ret_exp'	=> 'A parameter <i>error</i> with one of these error codes ' .
			   'is returned:',
    'set_this_value'	=> 'Set this parameter to true',
    'mode_xml_json'	=> 'Pass <i>xml</i> or <i>json</i> to this parameter',
    'err_ntd'		=> 'When no POST request was received by the create API',
    'err_anum'		=> 'The paste author\'s alias should be alphanumeric',
    'err_save'		=> 'Indicates that an error occurred while saving the paste',
    'err_404'		=> 'Paste not found',
    'err_invhash'	=> 'Invalid hash code',
    'err_passreqd'	=> 'Password required to view the paste',
    'err_passwrng'	=> 'Incorrect password entered',
    'err_nopastes'	=> 'No pastes found',

    'doc_api_para1'
	    =>
    'This pastebin API provides the following functions ' .
    'that can be hit by a <a href="http://en.wikipedia.org/wiki/GET_(HTTP)" rel="nofollow">' .
    'GET</a> or a <a href="http://en.wikipedia.org/wiki/POST_(HTTP)" rel="nofollow">POST' .
    '</a> request.',

    'doc_api_para2'
	    =>
    'The functions return the result in XML/JSON format ' .
    'depending upon the page to which the HTTP request is made.',

    'doc_api_para3'
	    =>
    'To create a new paste, you need to send a GET or POST request with certain ' .
    'parameters to <a>[[host]]</a>',

    'doc_api_para4'
	    =>
    'The paste show API listens to both GET and POST requests and returns XML/JSON data. '.
    'Even though you can use both methods to retrieve all information, we strongly recommend ' .
    'that you use POST when sending password over to the pastebin server.',

    'doc_api_para5'
	    =>
    'You can send the http GET request in the following format: <a>[[host]]api/&lt;format&gt;/&lt;id&gt;/' .
    '&lt;hash&gt;/&lt;password&gt;</a>.',

    'doc_api_para6'
	    =>
    'You may send a POST request to <a>[[host]]show.php</a>',

    'doc_api_para7'
	    =>
    'For getting a list of paste IDs, send a GET request to <a>[[host]]api/&lt;format&gt;/all</a> or ' .
    '<a>[[host]]api/&lt;format&gt;/all/&lt;page&gt;</a>.<br />For project specific data, use <a>[[host]]~' .
    '&lt;project&gt;/api/&lt;format&gt;/all/&lt;page&gt;</a> (page is optional).',


    /* Documentation: Language list */
    'doc_lang_title'		=> 'Languages supported',
    'languages_supported'	=> 'Languages supported',
    'languages_supported_exp'	=> 'Following are the language codes (shown in italics) '.
				       'supported by Sticky Notes pastebin',


    /* Documentation: About */
    'doc_about_title'		=> 'About',
    'powered_by'		=> 'This pastebin is powered by the Sticky Notes paste engine.',
    'paste_engine'		=> 'Paste engine:',
    'project_home'		=> 'Project page:',
    'developed_by'		=> 'Developed by:',
    'build'			=> 'Build:',
    'license'			=> 'License:',
    'bsd_license'		=> 'BSD License',
    'theme_name'		=> 'Theme name:',
    'theme_author'		=> 'Theme author:',

    /* Documentation: Help */
    'doc_help_title'		=> 'Help',
    'help'			=> 'Help',
    'create_new_paste'		=> 'Create new paste',
    'marking_private'		=> 'Marking pastes as private',
    'password_protection'	=> 'Password protection',
    'view_a_paste'		=> 'Viewing a paste',
    'copying_code'		=> 'Copying code',
    'rss_feed'			=> 'RSS Feed',
    'pastebin_projects'		=> 'Pastebin projects',

    'doc_help_para1'
	    =>
    'Creating a paste is a one-click job. Simply visit <a>[[host]]</a> and paste your text inside ' .
    'the resizable text area. Select the paste language from a wide range of available options ' .
    'and optionally add you username in the alias box. Click on the <i>Paste</i> button to create ' .
    'your paste.',

    'doc_help_para2'
	    =>
    'You can mark a paste as private by clicking on the <i>Mark as private</i> button or checkbox. ' .
    'Marking a paste as private does not password protect it. Private pastes do not appear in the paste ' .
    'list or in search results. They have a <i>hash</i> code in their URLs that must be supplied in order ' .
    'to view the paste. A misplaced hash code will lead to the paste being lost permanently.',

    'doc_help_para3'
	    =>
    'You can password protect your pastes by providing a password at the appropriate textbox. The ' .
    'password is encrypted and securely stored, while the post is automatically marked as private. ' .
    'Passwords cannot be reset by site administrators.',

    'doc_help_para4'
	    =>
    'To view a paste, simply visit <a>[[host]]&lt;id&gt;</a>, where <i>id</i> is the paste ID. For private pastes, ' .
    'you also need to provide the paste hash code in the URL: <a>[[host]]&lt;id&gt;/&lt;hash&gt;</a>. Password ' .
    'protected pastes will take you to the password entry form, where you can enter the password and click on ' .
    '<i>Submit</i> to view the paste.',

    'doc_help_para5'
	    =>
    'You can copy the code from the view page directly. You can also request for a raw version of the code (without ' .
    'styling) by clicking on the <i>Raw code</i> link or visiting <a>[[host]]&lt;id&gt;/raw</a> directly.',

    'doc_help_para6'
	    =>
    'The paste archive shows you a list of all posts with a given set of parameters. You can navigate through the ' .
    'archives by clicking on the page numbers listed on the archive page. Clicking on the <i>View paste</i> link will ' .
    'open the specific post. Private and password protected posts do not appear on the post archive.',

    'doc_help_para7'
	    =>
    'You can get a list of recent pastes via RSS to your favourite feed reader. Feeds can be also added to IRC bots ' .
    'in order to announce new pastes in project channels. To view the RSS feed, click on the <i>Feed</i> icon or ' .
    'open <a>[[host]]rss</a> in your browser.',

    'doc_help_para8'
	    =>
    'You can create your very own project pastebin by simply visiting <a>[[host]]~myproject</a> (where <i>myproject</i> ' .
    'is the project name). Project names can contain letters (a-z) and period (.) and are case insensitive. Once a project ' .
    'is created, all URLs point to the dedicated pastebin pages (For example, the feed link changes to <a>[[host]]~myproject/rss' .
    '</a> for your project specific pastebin and shows only pastes belonging to your project). Pastes made within a project ' .
    'are not listed in other projects\' archives.',
);

?>