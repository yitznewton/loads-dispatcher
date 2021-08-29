root = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
$: << File.join(root, 'app/load_factories')

require 'spec_helper'
require 'truckers_edge_load_factory'

describe TruckersEdgeLoadFactory do
  it 'fails' do
    expect(true).to be_falsy
  end
end
