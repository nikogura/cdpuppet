# write a file from data in hiera
define cdpuppet::hierafile (
  $target_dir,
  $template,
  $mode = 0644,
  $run_user = root,
  $run_group = root,

){
  file {"${target_dir}/${name}":
    ensure  => present,
    mode    => 0644,
    content => template("${module_name}/${template}"),
    owner   => $run_user,
    group   => $run_group,
  }

}
