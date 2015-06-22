# CD Puppet

Roles and Profiles for implementing Continuous Delivery with Puppet and R10K

This module contains Roles and Profiles for instantiating a Puppet Master with whatever config you like and synchronizing it 
via r10k to a Control Repo.  The configs for Puppet, Hiera, and R10K are created by the module based on Hiera data in your 
Control Repo.

As a demo, the included files sync with https://github.com/nikogura/control-repo.

This module does NOT install Puppet.  Puppet is considered to be already installed on the target box.  By not installing Puppet, 
it should work equally well with Open Source and Puppet Enterprise.

At present, it does not support PuppetDB, though that will be added as soon as time allows.

# Vagrant Testing / Demonstrations

Clone the cdpuppet repo somewhere.

    git clone git@github.com:nikogura/cdpuppet.git
    
    cd cdpuppet

Edit the Vagrantfile for the type of master you want.  By default it's Cron Synced.

Fire up the master:
    
    vagrant up puppet
    
Fire up an agent:

    vagrant up agent1
    
# Customizing CDPuppet

By default, CDPuppet points at [Nik's Demo Control Repo](https://github.com/nikogura/control-repo).  The odds are, this is NOT what you 
have in mind for your Puppetmaster.  I can hardly blame you.

Gotcha:  Hiera configs contain keys that look like ruby symbols.  This means that Puppet (which is written in ruby) is going to bork when it tries to write hiera.yaml from a yaml datasource.  To make this work, you've got to keep your puppet data in JSON.  If it's in syntactically proper JSON, it works great.  If you try do it from YAML, it doesn't work so well.  So, even if your main hiera data is YAML, I recommend you keep the puppetmaster data in JSON.

The class cdpuppet::profile::puppetmaster accepts a number of parameters that will customize CDPuppet's behavior for you.

* puppet_home   ($confdir, usually /etc/puppet or /etc/puppetlabs/puppet)  The central puppet config directory.  Defaults to '/etc/puppet'.
* run_user      User puppet will be running as.  Used to set file ownership.
* run_group     Group puppet will be running under.  Used to set file group.
* r10k_data     Hash of data with which to build r10k.yaml
* hiera_data    Hash of data with which to build hiera.yaml
* puppet_data   Hash of data with which to build puppet.conf   

Here's an example of JSON Hiera data:

    "cdpuppet::profile::puppetmaster::cron::sync_interval": "*",
    "cdpuppet::profile::puppetmaster::puppet_data": {
      "main": {
        "logdir": "/var/log/puppet",
        "rundir": "/var/run/puppet",
        "ssldir": "$confdir/ssl",
        "environmentpath": "$confdir/environments",
        "basemodulepath": "$confdir/modules:/usr/share/puppet/modules",
        "environment_timeout": 0,
        "certname": "puppetmaster.local"
      },
      "master": {
        "autosign": "/etc/puppet/autosign.conf",
        "dns_alt_names":"puppet,puppet.local,puppetmaster.local",
        "reports": "store"
      },
      "agent": {
        "classfile": "$vardir/classes.txt",
        "localconfig": "$vardir/localconfig"
      }
    },
    "cdpuppet::profile::puppetmaster::hiera_data": {
      ":backends": [
        "json"
      ],
      ":hierarchy": [
        "datagroup/puppetmaster",
        "global"
      ],
      ":json": {
        ":datadir": "/etc/puppet/enviornments/%{::environment}/hiera"
      }
    },
    "cdpuppet::profile::puppetmaster::r10k_data": {
      "postrun": [
        "/usr/bin/ruby",
        "/etc/puppet/bin/r10k_postrun.rb"
      ],
      "sources": {
        "dynamic": {
          "remote": "git@github.com:nikogura/control-repo.git",
          "basedir": "/etc/puppet/environments"
        }
      }
  
    }
    
That data will cause CDPuppet to overwrite /etc/r10k.yaml, /etc/hiera.yaml, /etc/puppet/hiera.yaml, and /etc/puppet/puppet.conf 
with new files created from that data.

You'll still need the 'bootstrap' versions from files/conf to start things off, but after the first puppet run on the master 
they'll be replaced. You'll be able to see that it worked on a vagrant test as the puppet.conf generated from hiera will not contain any comments, 
unlike the bootstrap version.


# Instantiating an existing box

#### TL;DR;

1. [Create Control Repo](#control-repo)
2. [Customize Hiera Data](#customize-hiera-data)
3. [Clone CDPuppet](#clone-cdpuppet)
4. [Bootstrap the Puppet Master](#bootstrap-puppet-master)
5. [...](#...)
6. [Profit](#profit)

## Control Repo

## Customize Hiera Data

## Clone CDPuppet

Clone the cdpuppet repo somewhere.  

    git clone git@github.com:nikogura/cdpuppet.git
    
## Bootstrap Puppet Master

Change directory into the clone

    cd cdpuppet
    
Then instantiate the Puppet Master of your choice.

#### Unsynched version:

    bash provision/linux_master_puppet.sh -e production -r 'cdpuppet::role::puppetmaster' -b $(pwd)
    
#### Cron synched version:

    bash provision/linux_master_puppet.sh -e production -r 'cdpuppet::role::puppetmaster::cron' -b $(pwd)
    
#### Jenkins synced version: (note Jenkins version is not complete yet)

    bash provision/linux_master_puppet.sh -e production -r 'cdpuppet::role::puppetmaster::jenkins' -b $(pwd)

## ...

## Profit
