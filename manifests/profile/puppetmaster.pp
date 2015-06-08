# cdpuppet::profile::puppetmaster
class cdpuppet::profile::puppetmaster (
  $puppet_home = '/etc/puppet',
  $run_user = 'root',
  $run_group = 'root',
  $r10k_data = undef,       # optionally configure r10k from hiera
  $hiera_data = undef,      # optionally configure hiera from hiera
  $puppet_data = undef,     # optionally configure puppet from hiera
  $auth_data = undef,       # optionally configure auth from hiera
  $autosign_data = undef,   # optionally configure autosigning from hiera
  $fileserver_data = undef, # optionally configure fileserver from hiera
  $routes_data = undef,     # optionally configure routes from hiera
  $tagmail_data = undef,    # optionally configure tagmail from hiera
  $puppetdb_data = undef,   # optionally configure puppetdb from hiera


){

  # removes an annoying yum warning that junks up logs
  Package { allow_virtual => true, }

  $puppet_bin = "${puppet_home}/bin"

  $scripts = [
    'deploy_environment.sh',
    'update_master.sh',
    'r10k_postrun.rb',
  ]

  $r10k = '/etc/r10k.yaml'
  $hiera = '/etc/hiera.yaml'

  file {$puppet_home:
    ensure => directory,
  }

  file {$puppet_bin:
    ensure => directory,
    require => File[$puppet_home],
  }

  file {"${puppet_home}/autosign.conf":
    ensure  => present,
    content => "*.local",

  }

  # r10k config

  if ($r10k_data) {
    file {$r10k:
      ensure  => present,
      mode    => 0644,
      content => to_yaml($r10k_data),
      owner   => $run_user,
      group   => $run_group,
    }

  } else {
    file {$r10k:
      ensure  => present,
      mode    => 0644,
      source  => "puppet:///modules/cdpuppet/conf/r10k.yaml",
      owner   => $run_user,
      group   => $run_group,
    }

  }

  # Hiera config

  if ($hiera_data) {
    file {"${puppet_home}/hiera.yaml":
      ensure  => present,
      mode    => 0644,
      content => to_yaml($hiera_data),
      owner   => $run_user,
      group   => $run_group,
    }

  } else {
    file {"${puppet_home}/hiera.yaml":
      ensure  => present,
      mode    => 0644,
      source  => "puppet:///modules/cdpuppet/conf/hiera.yaml",
      owner   => $run_user,
      group   => $run_group,
    }

  }

  file {$hiera:
    ensure  => link,
    target  => "$puppet_home/hiera.yaml",
    require => File["$puppet_home/hiera.yaml"],

  }

  # Puppet Config

  if ($puppet_data) {
    cdpuppet::hierafile {'puppet.conf':
      target_dir => $puppet_home,
      template   => 'puppet_conf.erb',
      run_user   => $run_user,
      run_group  => $run_group,
    }

  } else {
    cdpuppet::file {'puppet.conf':
      target_dir => $puppet_home,
      run_user   => $run_user,
      run_group  => $run_group,
      mode       => 0755,
      type       => 'conf',
    }

  }

  # auth.conf
  if ($auth_data) {
    cdpuppet::hierafile {'auth.conf':
      target_dir => $puppet_home,
      template   => 'auth_conf.erb',
      run_user   => $run_user,
      run_group  => $run_group,
    }
  }

  # autosign.conf
  if ($autosign_data) {
    cdpuppet::hierafile {'autosign.conf':
      target_dir => $puppet_home,
      template   => 'autosign_conf.erb',
      run_user   => $run_user,
      run_group  => $run_group,
    }
  }

  # fileserver.conf
  if ($fileserver_data) {
    cdpuppet::hierafile {'fileserver.conf':
      target_dir => $puppet_home,
      template   => 'fileserver_conf.erb',
      run_user   => $run_user,
      run_group  => $run_group,
    }
  }

  # puppetdb.conf
  if ($puppetdb_data) {
    cdpuppet::hierafile {'puppetdb.conf':
      target_dir => $puppet_home,
      template   => 'puppet_conf.erb',
      run_user   => $run_user,
      run_group  => $run_group,
    }
  }

  # routes.yaml
  if ($routes_data) {
    file {"${puppet_home}/routes.yaml":
      ensure  => present,
      mode    => 0644,
      content => to_yaml($routes_data),
      owner   => $run_user,
      group   => $run_group,
    }
  }

  # tagmail.conf
  if ($tagmail_data) {
    cdpuppet::hierafile {'tagmail.conf':
      target_dir => $puppet_home,
      template   => 'tagmail_conf.erb',
      run_user   => $run_user,
      run_group  => $run_group,
    }
  }

  # server side scripts
  cdpuppet::file {$scripts:
    target_dir => $puppet_bin,
    run_user   => $run_user,
    run_group  => $run_group,
    mode       => 0755,
    type       => 'script',
  }

  #network and security stuff (Because iptables and selinux are blocking things by default)

  firewall { '100 allow puppet agent access':
    port   => [8140],
    proto  => tcp,
    action => accept,
  }

  firewall { '101 allow mcollective access':
    port   => [61613],
    proto  => tcp,
    action => accept,
  }

  firewall { '102 allow connections to puppet database':
    port   => [8081],
    proto  => tcp,
    action => accept,
  }

  firewall { '103 allow connections to puppetdb api':
    port   => [8080],
    proto  => tcp,
    action => accept,
  }

  firewall { '104 allow connections to postgeresql':
    port   => [5432],
    proto  => tcp,
    action => accept,
  }

  firewall { '105 allow https connections to puppet console':
    port   => [443],
    proto  => tcp,
    action => accept,
  }

  firewall { '106 allow connections to node classifier/console services api':
    port   => [4433],
    proto  => tcp,
    action => accept,
  }

  firewall { '107 allow connections to puppet report submission endpoint':
    port   => [4435],
    proto  => tcp,
    action => accept,
  }

  class { 'selinux':
    mode => 'permissive'
  }


}
