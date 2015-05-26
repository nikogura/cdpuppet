# puppetjenkins::profile::default
class puppetjenkins::profile::default {
  $epel = 'epel'
  $rpmforge = 'rpmforge'
  $rpmforgeExtra = 'rpmforge-extras'

  yumrepo {$epel:
    baseurl => "http://download.fedoraproject.org/pub/epel/6/x86_64",
    gpgcheck => 0,
  }

  yumrepo {$rpmforge:
    baseurl => "http://apt.sw.be/redhat/el6/en/x86_64/rpmforge",
    #mirrorlist => 'http://mirrorlist.repoforge.org/el6/mirrors-rpmforge',
    gpgcheck => 0,

  }

  yumrepo {$rpmforgeExtra:
    baseurl => "http://apt.sw.be/redhat/el6/en/x86_64/extras",
    #mirrorlist => "http://mirrorlist.repoforge.org/el6/mirrors-rpmforge-extras"
    gpgcheck => 0,
  }

  package {'git':
    ensure => latest,
    require => Yumrepo[$rpmforgeExtra],
  }

  $plugins = [
    'scm-sync-configuration',
    'scm-api',
    'credentials',
    'ssh-credentials',
    'git',
    'git-client',
    'github-api',
    'github',
    'greenballs',
  ]

  #include jenkins

  class { 'jenkins':
    configure_firewall => true,
    require => Package['git'],
  }

  jenkins::plugin { $plugins : }

  /*
  firewall { '100 allow jenkins access':
    port   => [8080],
    proto  => tcp,
    action => accept,
  }

  class { 'selinux':
    mode => 'permissive'
  }
  */

}