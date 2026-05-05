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
      # The upstream .deb only lists ruby <= 3.2 in Depends, but the agent
      # is verified compatible with Ruby 3.3. Patch the control file to add
      # ruby3.3 as an alternative so dpkg/apt are satisfied natively.
      exec { 'patch_codedeploy_deb':
        command => '/bin/bash -c "set -e; cd /tmp; mkdir -p codedeploy-repack; dpkg-deb -R codedeploy-agent.deb codedeploy-repack; sed -i s/ruby3.2/ruby3.2\\ |\\ ruby3.3/ codedeploy-repack/DEBIAN/control; dpkg-deb -b codedeploy-repack codedeploy-agent-patched.deb; rm -rf codedeploy-repack"',
        creates => '/tmp/codedeploy-agent-patched.deb',
        require => Archive['/tmp/codedeploy-agent.deb'],
        path    => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
      }
      package { $codedeploy::package_name:
        ensure   => present,
        provider => 'dpkg',
        source   => '/tmp/codedeploy-agent-patched.deb',
        require  => [Exec['patch_codedeploy_deb'], Package['ruby-full']],
      }
    }
    default: {
      fail("${facts['os']['name']} not supported")
    }
  }
}
