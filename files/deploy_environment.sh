#!/bin/bash

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
        -n)
            name="$2"
            shift
            ;;
        -h)
            echo "Help Message Here"
            exit 0
            ;;
    esac

    shift

done

umask 0022

r10k='/opt/puppet/bin/r10k'
pe_dir='/etc/puppetlabs/puppet'
env_dir="${pe_dir}/environments"

${r10k} deploy environment ${environment} -v

# this shouldn't be necessary
cd "${env_dir}/${environment}"

${r10k} puppetfile install -v

if [ -n "${name}" ] ; then
    cd modules

    mkdir ${name}

    cd ${name}

    ln -s ../../manifests

fi

