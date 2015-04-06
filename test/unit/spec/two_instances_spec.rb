require_relative 'spec_helper'

describe 'install_varnish::two_instances' do
  before { stub_resources }
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: %w(varnish_install
                                           varnish_instance
                                           varnish_default_vcl
                                           varnish_log)) do |node|
      node_resources(node)
    end.converge(described_recipe)
  end

  it 'Installs the varnish package' do
    expect(chef_run).to install_package('varnish')
  end

  it 'does not enable the varnish service' do
    resource = chef_run.package('varnish')
    expect(resource).not_to notify('service[varnish]').to('enable').delayed
    expect(resource).not_to notify('service[varnish]').to('restart').delayed
  end

  it 'installs varnish' do
    expect(chef_run).to install_varnish('default')
  end

  it 'does not create the default varnish config' do
    expect(chef_run).not_to create_template('/etc/default/varnish')
  end

  it 'creates the default VCL' do
    expect(chef_run).to create_file('/etc/varnish/default.vcl')
  end

  it 'creates the service for instance 1' do
    expect(chef_run).to enable_varnish_instance('default')
  end

  it 'creates the service for instance 2' do
    expect(chef_run).to enable_varnish_instance('alternate')
  end
end
