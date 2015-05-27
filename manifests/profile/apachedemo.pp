# cdpuppet::profile::apachedemo
class cdpuppet::profile::apachedemo {
  # removes an annoying yum warning that junks up logs
  Package { allow_virtual => true, }

  class {'apache':
    default_vhost => false,

  }

  apache::vhost { 'vagrant.localdomain':
    port    => '80',
    docroot => '/srv/http/',
  }

  file {'/srv/http/index.html':
    owner   => 'apache',
    group   => 'apache',
    mode    => 0644,
    content => '<html>
    <head>
    </head>
    <body>
      <h1> Apache running on the virtualmachine, accessible via forwarded ports! </h1>
    </body>
  </html>',

  }

  firewall { '100 allow apache access':
    port   => [80],
    proto  => tcp,
    action => accept,
  }



}