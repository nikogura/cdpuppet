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
        -f)
            factstring="$2"
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

function qrystring() {
    qry=$1

    while read key value; do
        facts+=(["$key"]="$value")
    done < <(awk -F'&' '{for(i=1;i<=NF;i++) {print $i}}' <<< $qry | awk -F'=' '{print $1" "$2}')
}

declare -A facts

qrystring "$factstring"

for k in ${!facts[@]}; do
    echo "${k}: ${facts[$k]}" >> ${factDir}/${factFile}
done

modulePath="${environmentPath}:/home/vagrant/modules:/vagrant/modules"

puppet config set environmentpath ${environmentPath}
puppet config set environment ${environment}

cmd="/usr/bin/puppet agent --onetime --no-daemonize --verbose --certname ${nodeName}.local --environment ${environment}"

echo "provisioning with '${cmd}'"

${cmd}

echo "done with provision node: ${nodeName}"

echo "finished"
