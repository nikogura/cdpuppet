#!/bin/bash

# argument processing
while [ $# -ge 1 ]; do
    case "$1" in
        --)
            shift
            break
            ;;
        -n)
            nodeName="$2"
            shift
            ;;
        -e)
            environment="$2"
            shift
            ;;
        -t)
            confType="$2"
            shift
            ;;
        -r)
            role="$2"
            shift
            ;;
        -h)
            echo "Help Message Here"
            exit 0
            ;;
    esac

    shift

done

puppet_home="/etc/puppet"

if ls /etc/init.d/puppetmaster > /dev/null 2>&1; then
  echo 'Puppet Already Installed. Syncing Environments.'

  r10k deploy environment -v

  # this shouldnt be necessary, but it seems to be
  cd ${puppet_home}/environments/production
  r10k puppetfile install

  echo "Provisioning Myself"
  echo "Role: ${role}"

  cmd="puppet apply --detailed-exitcodes -e "

  ${cmd} "include ${role}"

else
  echo 'Installing Puppet Master.'
  yum --nogpgcheck -y install puppet-server
  yum --nogpgcheck -y install git
  #yum --nogpgcheck -y install ruby193

  gem install r10k
  #gem install system_timer

  # have to get these into place manually before running puppet
  cp /vagrant/files/conf/r10k.yaml /etc/r10k.yaml
  cp /vagrant/files/conf/puppet.conf /etc/puppet/puppet.conf
  cp /vagrant/files/conf/hiera.yaml /etc/puppet/hiera.yaml

  echo 'Populating Envrionments'

  r10k deploy environment -v

  # this shouldnt be necessary, but it seems to be
  cd ${puppet_home}/environments/production
  r10k puppetfile install

  echo 'Provisioning Myself'
  echo "Role: ${role}"

  cmd="puppet apply --detailed-exitcodes -e "

  ${cmd} "include ${role}"

  echo 'Starting Puppet Master'

  service puppetmaster start

fi

echo "finished"
