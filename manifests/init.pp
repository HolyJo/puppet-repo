class repo::config {
    file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL':
        ensure => present,
        source => "puppet:///modules/repo/rpm-gpg/RPM-GPG-KEY-EPEL",
        owner => "root",
        group => "root",
        before => Yumrepo['epel'],
    }

    file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-WANdisco':
        ensure => present,
        source => "puppet:///modules/repo/rpm-gpg/RPM-GPG-KEY-WANdisco",
        owner => "root",
        group => "root",
        before => File['/etc/yum.repos.d/wandisco.repo']
    }

    file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-remi':
        ensure => present,
        source => "puppet:///modules/repo/rpm-gpg/RPM-GPG-KEY-remi",
        owner => "root",
        group => "root",
        before => Yumrepo['remi']
    }


    file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-jenkins':
        ensure => present,
        source => "puppet:///modules/repo/rpm-gpg/RPM-GPG-KEY-jenkins",
        owner => "root",
        group => "root",
        before => Yumrepo['jenkins']
    }


    yumrepo { "epel":
        baseurl => "http://download.fedoraproject.org/pub/epel/6/$architecture",
        descr => "EPEL repository",
        enabled => 1,
        gpgcheck => 1,
        gpgkey => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL",
        notify => Service['network']
    }

    yumrepo { "jenkins":
        baseurl => "http://pkg.jenkins-ci.org/redhat",
        descr => "RedHat Linux RPM packages for Jenkins",
        enabled => 1,
        gpgcheck => 1,
        gpgkey => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-jenkins",
        before => Yumrepo['remi-php55'],
    }

    yumrepo { "remi":
        baseurl => "http://rpms.famillecollet.com/enterprise/6/remi/$architecture",
        descr => "Remi repository",
        enabled => 1,
        gpgcheck => 1,
        gpgkey => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi",
        notify => Service['network'],
        before => Yumrepo['remi-php55']
    }

    yumrepo { "remi-php55":
        baseurl => "http://rpms.famillecollet.com/enterprise/6/php55/$architecture",
        descr => "Remi php55 repository",
        enabled => 1,
        gpgcheck => 1,
        gpgkey => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi",
        notify => Service['network']
    }

    file { '/etc/yum.repos.d/wandisco.repo':
        ensure => present,
        source => "puppet:///modules/repo/wandisco.repo",
        owner => "root",
        group => "root",
    }

    file { '/etc/yum.repos.d/puias-unsupported.repo':
        ensure => present,
        source => "puppet:///modules/repo/puias-unsupported.repo",
        owner => "root",
        group => "root",
    }

    service { "network":
        ensure  => "running",
        enable  => "true",
    }

    exec { "clean_yum_metadata":
        command => "/usr/bin/yum -d 0 -e 0 -y clean metadata",
        refreshonly => true,
        require => [
            Yumrepo['remi-php55'],
            Service['network']
        ]
    }

#    exec {"yum_update":
#      command => "/usr/bin/yum update -y --skip-broken",
#      require => [
#        Yumrepo['remi-php55'],
#        Service['network']
#      ]
#    }

    Yumrepo['remi-php55'] -> Exec['clean_yum_metadata']

}

class repo {
    include repo::config
}
