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
        -h)
            echo "Help Message Here"
            exit 0
            ;;
    esac

    shift

done

# some global variables
puppet_home="/etc/puppet"
environmentPath="${puppet_home}/environments"
vagrantHome="/home/vagrant"

# hiera configs
mkdir -p ${environmentPath}/${environment}/hiera

ln -sf /vagrant/files/conf/hiera.yaml "${puppet_home}/hiera.yaml"

ln -sf ${puppet_home}/hiera.yaml /etc/hiera.yaml

ln -sf /vagrant/hiera/global.${confType} ${environmentPath}/${environment}/hiera/global.${confType}

mkdir -p ${environmentPath}/${environment}/hiera/datagroup
ln -sf /vagrant/hiera/datagroup/${environment}.${confType} ${environmentPath}/${environment}/hiera/datagroup/${moduleName}.${confType}

mkdir -p ${vagrantHome}/modules

modLink="${vagrantHome}/modules/${moduleName}"

ln -sf /vagrant ${modLink}

modulePath="${environmentPath}:/home/vagrant/modules:/vagrant/modules"

if ls /etc/init.d/puppetmaster > /dev/null 2>&1; then
  echo 'Puppet Already Installed. Syncing Environments.'

  r10k deploy environment -v

  # this shouldnt be necessary, but it seems to be
  cd ${puppet_home}/environments/production
  r10k puppetfile install

else
  echo 'Installing Puppet Master.'
  yum --nogpgcheck -y install puppet-server
  yum --nogpgcheck -y install git
  #yum --nogpgcheck -y install ruby193

  gem install r10k
  #gem install system_timer

  # setting up autosigning
  echo "*.local" > ${puppet_home}/autosign.conf

  # config files

  rm -f ${puppet_home}/puppet.conf
  ln -sf /vagrant/files/conf/puppet.conf ${puppet_home}/puppet.conf

  mkdir -p ${puppet_home}/bin

  ln -sf /vagrant/files/script/deploy_environment.sh ${puppet_home}/bin
  ln -sf /vagrant/files/script/update_master.sh ${puppet_home}/bin
  ln -sf /vagrant/files/script/r10k_postrun.rb ${puppet_home}/bin

  ln -sf /vagrant/files/conf/hiera.yaml ${puppet_home}/hiera.yaml
  #ln -sf /vagrant/files/conf/puppetdb.conf ${puppet_home}/puppetdb.conf
  #ln -sf /vagrant/files/conf/routes.yaml ${puppet_home}/routes.yaml

  ln -sf /vagrant/files/conf/r10k.yaml /etc/r10k.yaml
  ln -sf /vagrant/Puppetfile /etc/puppet/Puppetfile

  rm /etc/hiera.yaml
  ln -sf /etc/puppet/hiera.yaml /etc/hiera.yaml

  ln -sf /vagrant /home/vagrant/modules/cdpuppet

  echo 'Populating Envrionments'

  r10k deploy environment -v

  # this shouldnt be necessary, but it seems to be
  cd ${puppet_home}/environments/production
  r10k puppetfile install

  # Crudely disable iptables
  service iptables stop
  chkconfig --del iptables

  # Crudely get selinux out of the way
  sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

  echo 'Starting Puppet Master'

  service puppetmaster start

fi

echo "finished"
