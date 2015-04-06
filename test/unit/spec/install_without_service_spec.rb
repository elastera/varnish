require_relative 'spec_helper'

describe 'install_varnish::install_without_service' do
  before { stub_resources }
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: %w(varnish_install
                                           varnish_default_config
                                           varnish_default_vcl
                                           varnish_log)) do |node|
      node_resources(node)
    end.converge(described_recipe)
  end

  it 'Installs the varnish package' do
    expect(chef_run).to install_package('varnish')
  end

  it 'does not enable the varnish service' do
    expect(chef_run).not_to enable_service('varnish')
    expect(chef_run).not_to start_service('varnish')
  end

  it 'varnish package does not notify the varnish service' do
    resource = chef_run.package('varnish')
    expect(resource).not_to notify('service[varnish]').to('enable').delayed
    expect(resource).not_to notify('service[varnish]').to('restart').delayed
  end

  it 'does not enable the varnishlog service' do
    expect(chef_run).not_to enable_service('varnishlog')
  end

  it 'installs varnish' do
    expect(chef_run).to install_varnish('default')
  end
end
