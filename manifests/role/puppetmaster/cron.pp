# cdpuppet::role::puppetmaster::cron
# A puppet master implementing CD via cron
class cdpuppet::role::puppetmaster::cron inherits cdpuppet::role::puppetmaster {
  include cdpuppet::profile::puppetmaster::cron

}