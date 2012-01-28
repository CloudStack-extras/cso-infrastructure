class httpd::proxy {
  include httpd
  package { mod_proxy_html: ensure => present }

}
