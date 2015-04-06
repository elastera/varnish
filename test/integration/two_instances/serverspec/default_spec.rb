# Encoding: utf-8

require_relative 'spec_helper'

describe service('varnish') do
  it { should_not be_enabled }
  it { should_not be_running }
end

%w(varnish-default varnish-alternate2).each do |varnish_service|
  describe service(varnish_service) do
    it { should be_enabled }
    it { should be_running }
  end
end

## default instance
def curl_localhost
  'curl localhost:6081'
end

describe command(curl_localhost) do
  its(:exit_status) { should eq 0 }
end

['6081', '6082'].each do |port|
  describe port(port) do
    it { should be_listening }
  end
end

## alternate instance
def curl_localhost_alt
  'curl localhost:6181'
end

describe command(curl_localhost_alt) do
  its(:exit_status) { should eq 0 }
end

['6181', '6182'].each do |port|
  describe port(port) do
    it { should be_listening }
  end
end

def varnish_version
  'varnishd -V 2>&1'
end

describe command(varnish_version) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/varnishd \(varnish-3.0./) }
end

describe file('/etc/varnish/default.vcl') do
  its(:content) { should_not match(/vcl 4.0/) }
end

## default instance
def thread_pool_max
  'varnishadm -S /etc/varnish/secret -T localhost:6082 param.show thread_pool_max | head -1 | awk "{print $2}" '
end

describe command(thread_pool_max) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/500/) }
end

## alternate instance
def thread_pool_max_alt
  'varnishadm -S /etc/varnish/secret -T localhost:6182 param.show thread_pool_max | head -1 | awk "{print $2}" '
end

describe command(thread_pool_max_alt) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/400/) }
end
