class cdpuppet::profile::puppetmaster::cron (
  $sync_interval = [0,10,20,30,40,50],
  $puppet_bin = '/etc/puppet/bin',

){
  cron {'sync dev':
    command => "${puppet_bin}/deploy_environment.sh -e dev ",
    minute  => $sync_interval,
  }

  cron {'sync qa':
    command => "${puppet_bin}/deploy_environment.sh -e qa ",
    minute  => $sync_interval,

  }

  cron {'sync staging':
    command => "${puppet_bin}/deploy_environment.sh -e staging ",
    minute  => $sync_interval,

  }

  cron {'sync production':
    command => "${puppet_bin}/deploy_environment.sh -e production ",
    minute  => $sync_interval,
  }


}