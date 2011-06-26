<?php
/**
* Sticky Notes pastebin
* @ver 0.2
* @license BSD License - www.opensource.org/licenses/bsd-license.php
*
* Copyright (c) 2011 Sayak Banerjee <sayakb@kde.org>
* All rights reserved. Do not remove this copyright notice.
*/

class core
{
    // Global vars
    var $build;
    var $build_num;

    // Constructor
    function __construct()
    {
        // Define globals
        global $gsod;
        
        // Get the version number       
        if (file_exists('VERSION'))
        {
            $data = file_get_contents('VERSION');
        }
        else if (file_exists('../VERSION'))
        {
            $data = file_get_contents('../VERSION');
        }
        else
        {
            $gsod->trigger('<b>Sticky Notes fatal error</b><br /><br />' .
                           'Version file not found');
        }
        
        $data = explode("\n", $data);
        $this->build = $data[0];
        $this->build_num = $data[1];
    }

    // Function to return root path
    function path()
    {
        $path = $_SERVER['PHP_SELF'];
        $snip = strrpos($path, '/');
        $path = substr($path, 0, $snip + 1);

        return $path;
    }
    
    // Function to return root path
    function root_path()
    {
        $path = $this->path();
        
        if (strpos($path, 'admin') !== false)
        {
            return substr($path, 0, strrpos($path, 'admin'));
        }
        else
        {
            return $path;
        }
    }

    // Function to return remote IP
    function remote_ip()
    {
        return $_SERVER['REMOTE_ADDR'];
    }

    // Function to set a cookie
    function set_cookie($name, $value, $expire = 0)
    {
        setcookie('stickynotes_' . $name, $value, $expire, $this->root_path());
    }
    
    // Function to expire a cookie
    function unset_cookie($name)
    {
        setcookie('stickynotes_' . $name, null, time() - 3600, $this->root_path());
    }

    // Function to fetch query strings / post data
    function variable($name, $default, $is_cookie = false)
    {
        if (gettype($default) == "integer")
        {
            settype($default, "double");
        }

        if ($is_cookie && isset($_COOKIE['stickynotes_' . $name]))
        {
            $cookie_data = $_COOKIE['stickynotes_' . $name];
            settype($cookie_data, gettype($default));

            return $cookie_data;
        }
        else if (isset($_POST[$name]))
        {
            $post_data = $_POST[$name];
            settype($post_data, gettype($default));

            return $post_data;
        }
        else if (isset($_GET[$name]))
        {
            $get_data = $_GET[$name];
            settype($get_data, gettype($default));

            return $get_data;
        }
        else
        {
            return $default;
        }

    }

    // Function to return the script name
    function script_name()
    {
        return $_SERVER['SCRIPT_NAME'];
    }

    // Get the request URI
    function request_uri()
    {
        return $_SERVER['REQUEST_URI'];
    }

    // Get the base URI
    function base_uri()
    {
        $protocol = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') ? 'https' : 'http';
        $uri = $protocol . '://' . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'];
        $lindex = strrpos($uri, '/');
        $uri = substr($uri, 0, $lindex + 1);

        return $uri;
    }

    // Get the full address
    function rss_uri()
    {
        $protocol = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') ? 'https' : 'http';
        $uri = $protocol . '://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];

        return preg_replace("/rss\/?/", '', $uri);
    }
    
    // Method to replace square brackets with normal braces
    function rss_encode(&$data)
    {
        $data = str_replace('[', '(', $data);
        $data = str_replace(']', ')', $data);
        $data = str_replace('{', '(', $data);
        $data = str_replace('}', ')', $data);
        $data = str_replace(chr(0), '', $data);
    }
    
    // Method to redirect to a specified URL
    function redirect($url)
    {
        header("Location: {$url}");
    }
 
    // Method to return the server load
    function server_load() 
    {
        $os = strtolower(PHP_OS);
        
        if (strpos($os, "win") === false) 
        {
            if(file_exists("/proc/loadavg")) 
            {
                $load = file_get_contents("/proc/loadavg");
                $load = explode(' ', $load);
                return $load[0];
            }
            else if (function_exists("shell_exec")) 
            {
                $load = explode(' ', 'uptime');
                return $load[count($load) - 1];
            }
            else 
            {
                return false;
            }
        }
        else if ($windows) 
        {
            if (class_exists("COM")) 
            {
                $wmi = new COM("WinMgmts:\\\\.");
                $cpus = $wmi->InstancesOf("Win32_Processor");
         
                $cpuload = 0;
                $i = 0;
         
                while ($cpu = $cpus->Next()) 
                {
                    $cpuload += $cpu->LoadPercentage;
                    $i++;
                }
         
                $cpuload = round($cpuload / $i, 2);
         
                return "$cpuload%";
            }
            else 
            {
                return false;
            }
        }
    }    
}

?>