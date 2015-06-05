define cdpuppet::file (
  $target_dir,
  $type,
  $mode = 0644,
  $run_user = root,
  $run_group = root,

){
  file {"$target_dir/$name":
    ensure  => present,
    mode    => $mode,
    source  => "puppet:///modules/cdpuppet/${type}/${name}",
    owner   => $run_user,
    group   => $run_group,
    require => File[$target_dir],
  }

}
