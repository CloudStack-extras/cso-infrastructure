<?php
/**
* Sticky Notes pastebin
* @ver 0.2
* @license BSD License - www.opensource.org/licenses/bsd-license.php
*
* Copyright (c) 2011 Sayak Banerjee <sayakb@kde.org>
* All rights reserved. Do not remove this copyright notice.
*/

class spamguard
{
    // Class wide variables;
    var $registered_services;
    
    // Class constructor
    function __construct()
    {
        $this->registered_services = array();
        
        // Register services
        $this->register('ipban');
        $this->register('stealth');
        $this->register('php');
    }
    
    // Function to register services
    function register($service)
    {
        array_push($this->registered_services, $service);
    }
    
    // Function to check if a service is registered
    function is_registered($service)
    {
        return in_array($service, $this->registered_services);
    }
    
    // Function to get a list of registered services
    function get_registered()
    {
        return $this->registered_services;
    }
    
    // The parent validation function
    function validate()    
    {
        global $skin, $lang, $config;
        
        $validation_failed = false;
        $error_message = '';
        $services = explode(',', $config->sg_services);
        
        // Add the IP Ban validation if not added
        if (!in_array('ipban', $services))
        {
            array_push($services, 'ipban');
        }
        
        // Perform all validations
        foreach($services as $service_key)
        {
            $service_key = strtolower(trim($service_key));
            $service_name = 'validate_' . $service_key;
            
            if ($this->is_registered($service_key))
            {
                // Assume validation was successful
                $validation_output = true;
                
                // Perform validation
                eval('$validation_output = $this->' . $service_name . '();');
                
                // Check if validation succeeded
                if (!$validation_output)
                {
                    $error_message = $lang->get('sg_error_' . $service_key);
                    $validation_failed = true;
                    break;
                }
            }
        }
        
        // Validation failed. Show an error message and exit
        if ($validation_failed) 
        {
            // Show a bounce message
            $skin->assign(array(
                'msg_visibility'        => 'visible',
                'error_visibility'      => 'hidden',
                'message_text'          => $error_message,
                'msg_color'             => 'red',
            ));
            
            // Assign template data
            $skin->assign(array(
                'post_lang_list'        => $skin->output('tpl_languages'),
                'error_visibility'      => 'hidden',
            ));

            // Output the page
            $skin->title($lang->get('create_new') . ' &bull; ' . $lang->get('site_title'));
            $skin->output();
            exit;
        }
    }
    
    // IP Ban check
    function validate_ipban()
    {
        // Set global variables
        global $core, $db;
        
        // Get the banned IP list
        $sql = "SELECT ip FROM {$db->prefix}ipbans";
        $rows = $db->query($sql);
        
        // Check if user's IP is banned
        if (!empty($rows))
        {
            foreach($rows as $row)
            {
                if ($core->remote_ip() == $row['ip'])
                {
                    return false;
                }
            }
        }
        
        return true;    
    }
    
    // Sticky Notes' inbuilt Stealth Spam Guard
    function validate_stealth()
    {
        // Set global variables
        global $lang, $language, $data;
        
        // Check if data has HTML
        $html_exists = strpos(strtolower($data), '<a href') !== false ? true : false;
            
        // Validate
        if ($html_exists && $language != 'html4strict')
        {   
            return false;
        }
        else
        {
            return true;
        }
    }
    
    // Function to query Project Honey Pot
    // Info: http://www.projecthoneypot.org/
    function validate_php()
    {
        try
        {
            // Set global variables
            global $core, $lang, $config;
            
            // Skip validation is no key is specified in config.php
            if (!isset($config->sg_php_key) || empty($config->sg_php_key))
            {
                return true;
            }
            
            // Check config values
            $config->sg_php_days = isset($config->sg_php_days) ? $config->sg_php_days : 90;
            $config->sg_php_score = isset($config->sg_php_score) ? $config->sg_php_score : 50;
            $config->sg_php_type = isset($config->sg_php_type) ? $config->sg_php_type : 2;
            
            // We cannot process an IPv6 address
            if(!filter_var($core->remote_ip(), FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) 
            {
                return true;
            }
            
            // Convert IP address to reversed octet format
            $ip_ary = explode('.', $core->remote_ip());
            $rev_ip = $ip_ary[3] . '.' . $ip_ary[2] . '.' . $ip_ary[1] . '.' . $ip_ary[0];
            
            // Query Project Honey Pot
            $response = dns_get_record($config->sg_php_key . '.' . $rev_ip . '.dnsbl.httpbl.org');
            
            // Exit if NXDOMAIN is returned
            if (!isset($response[0]['ip']) || empty($response[0]['ip']))
            {
                return true;
            }
                
            // Extract the info
            $result = explode('.', $response[0]['ip']);
            $days = $result[1];
            $score = $result[2];
            $type = $result[3];
            
            // Perform PHP validation
            if ($days <= $config->sg_php_days && ($type >= $config->sg_php_type || $score >= $config->sg_php_score))
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        catch (Exception $e)
        {
            return true;
        }
    }
}

?>
