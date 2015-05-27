# cdpuppet

Roles and Profiles for implementing Continuous Delivery with Puppet and R10K

# Vagrant Testing / Demonstrations

Clone the cdpuppet repo somewhere.

    git clone git@github.com:nikogura/cdpuppet.git
    
    cd cdpuppet

Edit the Vagrantfile for the type of master you want.  By default it's Cron Synced.

Fire up the master:
    
    vagrant up puppet
    
Fire up an agent:

    vagrant up agent1
    
# Instantiating an existing box

Clone the cdpuppet repo somewhere.  

    git clone git@github.com:nikogura/cdpuppet.git
    
    cd cdpuppet
    
Cron synched version :

    bash provision/linux_master_puppet.sh -e production -r 'cdpuppet::role::puppetmaster::cron' -b $(pwd)
    
Jenkins synced version:

    bash provision/linux_master_puppet.sh -e production -r 'cdpuppet::role::puppetmaster::jenkins' -b $(pwd)



