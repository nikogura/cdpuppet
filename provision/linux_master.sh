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
puppetConfigDir="/etc/puppet"
environmentPath="${puppetConfigDir}/environments"
vagrantHome="/home/vagrant"

# hiera configs
mkdir -p ${environmentPath}/${environment}/hiera

hiera_config="${puppetConfigDir}/hiera.yaml"

if [ -e  ${hiera_config} ] ; then
    :
else
    ln -s /vagrant/files/hiera.yaml "${puppetConfigDir}/hiera.yaml"
fi

if [ -L /etc/hiera.yaml ] ; then
    :
elif [ -f /etc/hiera.yaml ] ; then
    rm -f /etc/hiera.yaml
    ln -s ${puppetConfigDir}/hiera.yaml /etc/hiera.yaml
else
    ln -s ${puppetConfigDir}/hiera.yaml /etc/hiera.yaml
fi

if [ -e   ${environmentPath}/${environment}/hiera/global.${confType} ] ; then
    :
else
    ln -sf /vagrant/hiera/global.${confType} ${environmentPath}/${environment}/hiera/global.${confType}
fi

if [ -e  ${environmentPath}/${environment}/hiera/datagroup/${moduleName}.${confType} ] ; then
    :
else
    mkdir -p ${environmentPath}/${environment}/hiera/datagroup
    ln -sf /vagrant/hiera/datagroup/${environment}.${confType} ${environmentPath}/${environment}/hiera/datagroup/${moduleName}.${confType}
fi

mkdir -p ${vagrantHome}/modules

modLink="${vagrantHome}/modules/${moduleName}"

if [ -e ${modLink} ] ; then
    :
else
    ln -s /vagrant ${modLink}
fi

modulePath="${environmentPath}:/home/vagrant/modules:/vagrant/modules"

if ls /etc/init.d/puppetmaster > /dev/null 2>&1; then
  echo 'Puppet Already Installed. Syncing Environments.'

  r10k deploy environment -v

  # this shouldnt be necessary, but it seems to be
  cd ${puppetConfigDir}/environments/production
  r10k puppetfile install

else
  echo 'Installing Puppet Master.'
  yum --nogpgcheck -y install puppet-server
  yum --nogpgcheck -y install git
  #yum --nogpgcheck -y install ruby193

  gem install r10k

  # setting up autosigning
  echo "*.local" > ${puppetConfigDir}/autosign.conf

  # config files

  rm -f ${puppetConfigDir}/puppet.conf
  ln -sf /vagrant/files/puppet.conf ${puppetConfigDir}/puppet.conf

  ln -sf /vagrant/bin ${puppetConfigDir}/bin

  ln -sf /vagrant/files/hiera.yaml ${puppetConfigDir}/hiera.yaml
  #ln -sf /vagrant/puppetdb.conf ${puppetConfigDir}/puppetdb.conf
  #ln -sf /vagrant/routes.yaml ${puppetConfigDir}/routes.yaml

  ln -sf /vagrant/files/r10k.yaml /etc/r10k.yaml
  ln -sf /vagrant/Puppetfile /etc/puppet/Puppetfile

  rm /etc/hiera.yaml
  ln -sf /etc/puppet/hiera.yaml /etc/hiera.yaml

  ln -sf /vagrant /home/vagrant/modules/cdpuppet

  echo 'Populating Envrionments'

  r10k deploy environment -v

  # this shouldnt be necessary, but it seems to be
  cd ${puppetConfigDir}/environments/production
  r10k puppetfile install

  echo 'Starting Puppet Master'

  service puppetmaster start

fi

echo "finished"
