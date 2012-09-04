namespace :deploy do
  namespace :thin do


    desc "create default thin with ports configuration file in 'config/deployment.yml'"
    task :port => :environment do
      unless thin
        # since thin file does not exis, will create one.
        command = "thin config -C #{thin_file} -e production --servers 3 --timeout 20 --wait 15 --onebyone --port 3000"
        system(command)
      else
        unless thin["port"]
          hash = thin
          hash.delete("socket")
          hash["port"] = "3000"
          save_thin_yml(hash)
        end
      end
      Rake::Task['deploy:thin:create_yml'].reenable
      Rake::Task['deploy:thin:create_yml'].invoke
      Rake::Task['deploy:nginx:upstream'].reenable
      Rake::Task['deploy:nginx:upstream'].invoke
      
    end


    # "create default thin with sockets configuration file in 'config/deployment.yml'"
    task :socket => :environment do
      unless thin
      command = "thin config -C #{thin_file} -e production --servers 3 --timeout 20 --wait 15 --onebyone --socket /tmp/thin.#{Rails.application.class.parent_name.underscore}.socket"
      unless system(command)
      puts 'The thin gem is not installed in your current system/environment/gemset/Gemfile'
      puts 'add the following to your Gemfile'
      puts "gem 'thin'"
      puts 'Or install manually with:'
      puts 'gem install thin --no-ri --no-rdoc'
      abort('Will stop rake task now!')
      end
      else
        unless thin["socket"]
          hash = thin
          hash.delete("port")
          hash["socket"] = "/tmp/thin.#{Rails.application.class.parent_name.underscore}.socket"
          save_thin_yml(hash)
        end
      end
      Rake::Task['deploy:thin:create_yml'].reenable
      Rake::Task['deploy:thin:create_yml'].invoke
      Rake::Task['deploy:nginx:upstream'].reenable
      Rake::Task['deploy:nginx:upstream'].invoke
    end    

    # "create default thin with ports configuration file in 'config/deployment.yml'"
    task :create_yml => :environment do 
      changed_thin = {}
      hash = thin
      hash=remove_options(hash)

      hash.each do |key,value| 
        answer = ask "What value do you want for #{key}: (#{value})"
        unless answer == ""
          puts "different #{answer}"
          changed_thin[key] = answer
        end 
      end
      save_thin_yml(hash.merge(changed_thin))
    end
  end
end