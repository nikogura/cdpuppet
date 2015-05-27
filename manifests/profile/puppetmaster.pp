# cdpuppet::profile::puppetmaster
class cdpuppet::profile::puppetmaster (
  $puppet_home = '/etc/puppet',
  $run_user = 'root',
  $run_group = 'root',

){

  # TODO add templates for r10k, hiera, and puppet configs.  Generate them from Hiera data  All you should have to do is clone this repo, fill your CR with
  # your data, and run the initial provision script.  The rest should *just work* and maintain it's own state.

  # removes an annoying yum warning that junks up logs
  Package { allow_virtual => true, }

  $puppet_bin = "${puppet_home}/bin"

  $scripts = [
    'deploy_environment.sh',
    'update_master.sh',
    'r10k_postrun.rb',
  ]

  $puppet_confs = [
    'hiera.yaml',
    'puppet.conf',
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

  file {'/etc/r10k.yaml':
    ensure  => present,
    mode    => 0644,
    source  => "puppet:///modules/cdpuppet/conf/r10k.yaml",
    owner   => $run_user,
    group   => $run_group,
  }

  file {'/etc/hiera.yaml':
    ensure  => link,
    target  => "$puppet_home/hiera.yaml",
    require => File["$puppet_home/hiera.yaml"],

  }

  cdpuppet::file {$scripts:
    target_dir => $puppet_bin,
    run_user   => $run_user,
    run_group  => $run_group,
    mode       => 0755,
    type       => 'script',
  }

  cdpuppet::file {$puppet_confs:
    target_dir => $puppet_home,
    type => 'conf',

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
    $type,
    $mode = 0644,
    $run_user = root,
    $run_group = root,

  ){
    file {"$target_dir/$name":
      ensure  => present,
      mode    => $mode,
      source  => "puppet:///modules/cdpuppet/${type}/${name}",
      owner   => $run_user,
      group   => $run_group,
      require => File[$target_dir],
    }

  }

}
