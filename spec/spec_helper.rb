$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'

require 'jason'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

def fixtures_path
  File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))
end

class JasonSpecObject
  include Jason::Persistence
end

RSpec.configure do |config|

  config.before(:all) do
    Jason.setup do |config|

      config.persistence_path = fixtures_path

    end
  end

end