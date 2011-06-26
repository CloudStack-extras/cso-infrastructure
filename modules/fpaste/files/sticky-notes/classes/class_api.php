<?php
/**
* Sticky Notes pastebin
* @ver 0.2
* @license BSD License - www.opensource.org/licenses/bsd-license.php
*
* Copyright (c) 2011 Sayak Banerjee <sayakb@kde.org>
* All rights reserved. Do not remove this copyright notice.
*/

class api
{
    // Function to add an XML/JSON element
    function parse($format, $count, $value, $last_entry = false)
    {
        $element = 'paste_' . $count;

        if ($format == 'xml')
        {
            return ($count > 1 ? "\t\t" : "") . "<{$element}>{$value}</{$element}>" . (!$last_entry ? "\n" : "");
        }
        else if ($format == 'json')
        {
            return ($count > 1 ? "\t\t\t" : "") . "\"{$element}\": \"{$value}\"" . (!$last_entry ? ",\n" : "");
        }
    }
}

?>