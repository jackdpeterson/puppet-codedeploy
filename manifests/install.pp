# @summary Installs the AWS CodeDeploy agent.
class codedeploy::install {
  case $facts['os']['name'] {
    'RedHat', 'Amazon': {
      $region = $codedeploy::aws_region
      package { $codedeploy::package_name:
        ensure   => present,
        provider => 'rpm',
        source   => "https://aws-codedeploy-${region}.s3.${region}.amazonaws.com/latest/codedeploy-agent.noarch.rpm",
      }
    }
    'Debian', 'Ubuntu': {
      ensure_packages(['ruby-full'], { 'ensure' => 'present' })

      $region  = $codedeploy::aws_region
      $deb_url = "https://aws-codedeploy-${region}.s3.${region}.amazonaws.com/latest/codedeploy-agent_all.deb"

      archive { '/tmp/codedeploy-agent.deb':
        source  => $deb_url,
        creates => '/tmp/codedeploy-agent.deb',
      }
      exec { 'install_codedeploy_agent':
        command => '/usr/bin/dpkg --force-depends -i /tmp/codedeploy-agent.deb',
        unless  => '/usr/bin/dpkg -s codedeploy-agent',
        require => [Archive['/tmp/codedeploy-agent.deb'], Package['ruby-full']],
        path    => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
      }
    }
    default: {
      fail("${facts['os']['name']} not supported")
    }
  }
}
