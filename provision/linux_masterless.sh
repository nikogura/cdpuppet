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

hiera_config="${puppetConfigDir}/hiera.yaml"

ln -sf /vagrant/files/conf/hiera.yaml "${puppet_home}/hiera.yaml"

# lets have puppet and the command line use the same config shall we?
ln -sf ${puppet_home}/hiera.yaml /etc/hiera.yaml

#global hiera config
ln -sf /vagrant/hiera/global.${confType} ${environmentPath}/${environment}/hiera/global.${confType}

#per group hiera config
mkdir -p ${environmentPath}/${environment}/hiera/datagroup
ln -sf /vagrant/hiera/datagroup/${environment}.${confType} ${environmentPath}/${environment}/hiera/datagroup/${moduleName}.${confType}

echo "Provisioning with linux_masterless.sh"
echo "Module: ${moduleName}"

mkdir -p ${vagrantHome}/modules

modLink="${vagrantHome}/modules/${moduleName}"

if [ -e ${modLink} ] ; then
    :
else
    ln -s /vagrant ${modLink}
fi

modulePath="${environmentPath}:/home/vagrant/modules:/vagrant/modules"

puppet config set environmentpath ${environmentPath}
puppet config set environment ${environment}

cmd="puppet apply --modulepath ${modulePath} --detailed-exitcodes /vagrant/tests/${nodeName}.pp"

echo "provisioning with '${cmd}'"

${cmd}

echo "done with provision node: ${nodeName} module: ${moduleName}"

#echo "running spec tests"

#cd /vagrant

#bundle

#bundle exec rake clean spec

echo "finished"
