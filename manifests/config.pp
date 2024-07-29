# == Class codedeploy::config
#
# This class is called from codedeploy.
#
class codedeploy::config {

  case $facts['os']['name'] {
    'RedHat', 'Amazon': {
      file { $::codedeploy::config_location:
        ensure  => file,
        content => template('codedeploy/codedeployagent.yml.erb'),
        mode    => '0644',
        owner   => root,
        group   => root,
      }
    }
    default: {
    }
  }
}
