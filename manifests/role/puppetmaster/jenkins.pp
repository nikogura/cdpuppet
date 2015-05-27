# cdpuppet::role::puppetmaster
# a puppetmaster implementing CD via Jenkins
class cdpuppet::role::puppetmaster {
  user {'jenkins':
    ensure  => present,


  }
}