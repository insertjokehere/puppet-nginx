# Define: nginx::vhost::redirect.
#
#   nginx vhost. redirects, For bouncing web traffic as you would with apache.
#
# Parameters:
#
# Requires:
#   include nginx::server
#
define nginx::vhost::redirect (
  $dest,
  $port           = '80',
  $priority       = '10',
  $template       = 'nginx/vhost-redirect.conf.erb',
  $servername     = '',
  $ssl            = false,
  $ssl_port       = '443',
  $status         = 'permanent',
  $magic          = '',
  $isdefaultvhost = false,
  $ssl_path       = '',
  $ssl_cert_file  = '',
  $ssl_key_file   = ''
) {

  include nginx
  include nginx::params

  case $ssl_path {
    '':      { $nginx_ssl_path = $nginx::params::ssl_path }
    default: { $nginx_ssl_path = $ssl_path }
  }

  case $ssl_cert_file {
    '':      { $nginx_ssl_cert_file = $nginx::params::ssl_cert_file }
    default: { $nginx_ssl_cert_file = $ssl_cert_file }
  }

  case $ssl_key_file {
    '':      { $nginx_ssl_key_file = $nginx::params::ssl_key_file }
    default: { $nginx_ssl_key_file = $ssl_key_file }
  }

  if $servername == '' {
    $srvname = $name
  } else {
    $srvname = $servername
  }

  # Need to make some variable names so the templates can use them!
  # Such as an app_server name that is unique, so when we have ssl and
  # non-ssl unicorn hosts they still work.
  if $ssl == true {
    $appname = regsubst( $srvname , '^(\w+?)\..*?$' , '\1_ssl' )
  } else {
    $appname = regsubst( $srvname , '^(\w+?)\..*?$' , '\1' )
  }

  file {
    "${nginx::params::vdir}/${priority}-${name}":
      content => template($template),
      owner   => 'root',
      group   => '0',
      mode    => '755',
      require => Package['nginx'],
      notify  => Service['nginx'],
  }

}
