# removes an annoying yum warning that junks up logs
Package { allow_virtual => true, }

$role = 'cdpuppet::role::puppetmaster'
include $role
