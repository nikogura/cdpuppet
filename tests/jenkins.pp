# removes an annoying yum warning that junks up logs
Package { allow_virtual => true, }

$role = 'cdpuppet::role::jenkins'
include $role
