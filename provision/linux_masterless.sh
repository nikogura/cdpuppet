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
    ln -sf /vagrant/hiera.yaml "${puppetConfigDir}/hiera.yaml"
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

cmd="puppet apply --modulepath ${modulePath} --detailed-exitcodes /vagrant/tests/${environment}.pp"

echo "provisioning with '${cmd}'"

${cmd}

echo "done with provision node: ${nodeName} module: ${moduleName}"

#echo "running spec tests"

#cd /vagrant

#bundle

#bundle exec rake clean spec

echo "finished"
