# Encoding: utf-8

require_relative 'spec_helper'

%w(varnish varnishlog varnishncsa).each do |varnish_service|
  describe service(varnish_service) do
    it { should_not be_enabled }
    it { should_not be_running }
  end
end


['6081', '6082'].each do |port|
  describe port(port) do
    it { should_not be_listening }
  end
end
