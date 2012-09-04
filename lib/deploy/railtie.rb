require 'deploy'
require 'rails'

module MyGem
  class Railtie < Rails::Railtie
    
    def self.root
        Pathname.new("#{File.dirname(__FILE__)}")
      end
      
  	rake_tasks do
      # load 'lib/tasks/nginx.rake'
      # this does not work for some reason, code below is suggested
      Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
    end
  end
end
