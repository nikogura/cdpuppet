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

# some global variables
puppet_home="/etc/puppet"
environmentPath="${puppet_home}/environments"
vagrantHome="/home/vagrant"

# hiera configs
mkdir -p ${environmentPath}/${environment}/hiera

factDir='/etc/facter/facts.d'
factFile='provision.yaml'

mkdir -p ${factDir}
echo "---" > ${factDir}/${factFile}
echo "role: ${role}" >> ${factDir}/${factFile}

modulePath="${environmentPath}:/home/vagrant/modules:/vagrant/modules"

puppet config set environmentpath ${environmentPath}
puppet config set environment ${environment}

cmd="/usr/bin/puppet agent --onetime --no-daemonize --verbose --certname ${nodeName}.local --environment ${environment}"

echo "provisioning with '${cmd}'"

${cmd}

echo "done with provision node: ${nodeName}"

echo "finished"
