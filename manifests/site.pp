# /etc/puppet/manifests/site.pp
#
import "modules"
import "nodes"
import "infrastructure"
filebucket { main: server => puppet }

# global defaults
File { backup => main }
Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin" }

Package {
        provider => $operatingsystem ? {
                debian => aptitude,
                ubuntu => aptitude,
                redhat => yum,
                fedora => yum,
                centos => yum,
        }
}

