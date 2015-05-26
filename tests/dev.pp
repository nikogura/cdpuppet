# removes an annoying yum warning that junks up logs
Package { allow_virtual => true, }

$role = 'puppetjenkins::role::default'
include $role
