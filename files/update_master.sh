#!/bin/bash

umask 0022

#cd /etc/puppetlabs/puppet
cd /etc/puppet

# Optional reset command that gets run by flag
optional=("git reset --hard origin/master")

# Commands that always get run
#always=("/usr/bin/git pull origin master" "/opt/puppet/bin/r10k puppetfile install")
always=("/usr/bin/git pull origin master" "/usr/bin/r10k puppetfile install")

if [ "${run_optional}" == "yes" ]; then
  commands=( "${optional[@]}" "${always[@]}" )
else
  commands=( "${always[@]}" )
fi

for i in "${commands[@]}"; do
  echo "Running command: ${i}"
  eval $i
  status=$?
  if [ $status -ne 0 ]; then
    echo "${i}: returned not 0"
    exit $status
  fi
done