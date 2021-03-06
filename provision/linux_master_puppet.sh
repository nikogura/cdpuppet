#!/bin/bash

# argument processing
while [ $# -ge 1 ]; do
    case "$1" in
        --)
            shift
            break
            ;;
        -e)
            environment="$2"
            shift
            ;;
        -r)
            role="$2"
            shift
            ;;
        -b)
            bootstrapDir="$2"
            shift
            ;;
        -h)
            puppet_home="$2"
            shift
            ;;
        -h)
            echo "bash $0 -e <environment> -r <role> -b <bootstrap dir> "
            echo "    -e <environment>  Environment for this box"
            echo "    -r <role>  Role for this box"
            echo "    -b <bootstrap dir>  Directory for bootstrap code.  Typically it's the repo clone where you got this script from."
            exit 0
            ;;
    esac

    shift

done

if [ -z "${puppet_home}" ]; then
    puppet_home="/etc/puppet"
fi

# figure out the bootstrap directory, and fail if we cannot.
if [ -z "${bootstrapDir}" ]; then
  bootstrapDir=$(echo $( cd $(dirname $0) ; pwd -P ) | sed 's/\/provision//')
  if [ -z "${bootstrapDir}" ]; then
    echo "Script requires a bootstrap directory.  Set with -b <dir>.  Usually this is the directory where this code resides."
    exit 1
  fi
fi

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

  gem install r10k -v 1.5.1
  #gem install system_timer

  # have to get these into place manually before running puppet
  cp ${bootstrapDir}/files/conf/r10k.yaml /etc/r10k.yaml
  cp ${bootstrapDir}/files/conf/puppet.conf ${puppet_home}/puppet.conf
  cp ${bootstrapDir}/files/conf/hiera.yaml ${puppet_home}/hiera.yaml

  echo 'Populating Envrionments'

  r10k deploy environment -v

  # this shouldnt be necessary, but it seems to be
  cd ${puppet_home}/environments/production
  r10k puppetfile install

  echo 'Provisioning Myself'
  echo "Role: ${role}"

  cmd="puppet apply --confdir ${puppet_home} --detailed-exitcodes -e "

  ${cmd} "include ${role}"

  echo 'Starting Puppet Master'

  service puppetmaster start

fi

echo "finished"
