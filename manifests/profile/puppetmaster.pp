# cdpuppet::profile::puppetmaster
class cdpuppet::profile::puppetmaster (
  $puppet_home = '/etc/puppet',
  $run_user = 'root',
  $run_group = 'root',

){
  # removes an annoying yum warning that junks up logs
  Package { allow_virtual => true, }

  $puppet_bin = "${puppet_home}/bin"

  $scripts = [
    'deploy_environment.sh',
    'update_master.sh',
    'r10k_postrun.rb',
  ]

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

  cdpuppet::file {$scripts:
    target_dir => $puppet_bin,
    run_user   => $run_user,
    run_group  => $run_group,
    mode       => 0755,
  }

  $puppet_confs = [
    'hiera.yaml',
    'puppet.conf',
  ]

  cdpuppet::file {$puppet_confs:
    target_dir => $puppet_home,

  }

  file {'/etc/r10k.yaml':
    ensure  => present,
    mode    => 0644,
    content => "puppet:///modules/cdpuppet/r10k.yaml",
    owner   => $run_user,
    group   => $run_group,
  }

  file {'/etc/hiera.yaml':
    ensure  => link,
    target  => "$puppet_home/hiera.yaml",
    require => File["$puppet_home/hiera.yaml"],

  }

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

  define cdpuppet::file (
    $target_dir,
    $mode = 0644,
    $run_user = root,
    $run_group = root,

  ){
    file {"$target_dir/$name":
      ensure  => present,
      mode    => $mode,
      content => "puppet:///modules/cdpuppet/${name}",
      owner   => $run_user,
      group   => $run_group,
      require => File[$target_dir],
    }

  }

}
