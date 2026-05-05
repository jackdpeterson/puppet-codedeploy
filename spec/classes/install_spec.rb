require 'spec_helper'

describe 'codedeploy::install' do
  context "on RedHat" do
    let(:facts) do
      {
        os: { 'name' => 'RedHat', 'family' => 'RedHat' },
      }
    end
    let(:pre_condition) { 'include codedeploy' }

    it { is_expected.to compile.with_all_deps }
    it {
      is_expected.to contain_package('codedeploy-agent').with(
        ensure: 'present',
        provider: 'rpm',
        source: 'https://aws-codedeploy-us-west-1.s3.us-west-1.amazonaws.com/latest/codedeploy-agent.noarch.rpm',
      )
    }
  end

  context "on Ubuntu" do
    let(:facts) do
      {
        os: { 'name' => 'Ubuntu', 'family' => 'Debian' },
      }
    end
    let(:pre_condition) { 'include codedeploy' }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_package('ruby-full').with_ensure('installed') }
    it {
      is_expected.to contain_archive('/tmp/codedeploy-agent.deb').with(
        source: 'https://aws-codedeploy-us-west-1.s3.us-west-1.amazonaws.com/latest/codedeploy-agent_all.deb',
      )
    }
    it {
      is_expected.to contain_exec('install_codedeploy_agent').with(
        command: '/usr/bin/dpkg --force-depends -i /tmp/codedeploy-agent.deb',
        unless: '/usr/bin/dpkg -s codedeploy-agent',
      )
    }
  end

  context "with custom region" do
    let(:facts) do
      {
        os: { 'name' => 'Ubuntu', 'family' => 'Debian' },
      }
    end
    let(:pre_condition) { "class { 'codedeploy': aws_region => 'eu-west-1' }" }

    it {
      is_expected.to contain_archive('/tmp/codedeploy-agent.deb').with(
        source: 'https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/codedeploy-agent_all.deb',
      )
    }
  end

  context "on unsupported OS" do
    let(:facts) do
      {
        os: { 'name' => 'Solaris', 'family' => 'Solaris' },
      }
    end
    let(:pre_condition) { 'include codedeploy' }

    it { is_expected.to compile.and_raise_error(%r{Solaris not supported}) }
  end
end
