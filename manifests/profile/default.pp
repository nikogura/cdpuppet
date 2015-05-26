# puppetjenkins::profile::default
class puppetjenkins::profile::default {
  package {'git':
    ensure => installed,
  }

  $plugins = [
    'scm-sync-configuration',
    'scm-api',
    'credentials',
    'ssh-credentials',
    'git-client',
    'github',
    'git',
  ]
#include jenkins

  class { 'jenkins':
    configure_firewall => true,
  }

  jenkins::plugin { $plugins : }

}