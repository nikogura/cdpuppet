#!/bin/bash

# argument processing
while [ $# -ge 1 ]; do
    case "$1" in
        --)
            shift
            break
            ;;
        -m)
            moduleName="$2"
            shift
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

puppetConfigDir="/etc/puppet"

if ls /etc/init.d/puppetmaster > /dev/null 2>&1; then
  echo 'Puppet Already Installed. Syncing Environments.'

  ln -sf /vagrant/files/r10k.yaml /etc/r10k.yaml

  ln -sf /vagrant/files/puppet.conf /etc/puppet/puppet.conf

  r10k deploy environment -v

  # this shouldnt be necessary, but it seems to be
  cd ${puppetConfigDir}/environments/production
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

  ln -sf /vagrant/files/r10k.yaml /etc/r10k.yaml

  rm ${puppetConfigDir}/puppet.conf
  ln -sf /vagrant/files/puppet.conf /etc/puppet/puppet.conf

  echo 'Populating Envrionments'

  r10k deploy environment -v

  # this shouldnt be necessary, but it seems to be
  cd ${puppetConfigDir}/environments/production
  r10k puppetfile install

  echo 'Provisioning Myself'
  echo "Role: ${role}"

  cmd="puppet apply --detailed-exitcodes -e "

  ${cmd} "include ${role}"

  echo 'Starting Puppet Master'

  service puppetmaster start

fi

echo "finished"
