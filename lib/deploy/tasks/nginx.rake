namespace :deploy do
  namespace :nginx do

    desc 'Creates nginx .conf file for domain'
    task :conf,[:domain] do |cmd,args|
      domain = args[:domain]
      puts domain
      puts domain.strip
      content = ERB.new(File.read(Deploy::Railtie.root.join('lib','nginx_server_name.conf.erb'))).result(binding)

      file_path = "/etc/nginx/sites-enabled/#{domain}"
      write(file_path,content)
    end


    desc "create default thin config file with sockets configuration file in 'config/deployment.yml'"
    task :upstream do
      if thin 
        file_path = Rails.root.join('config','deployment.yml')
        #default = 'www.example.com'
        #hostname = ask("What hostname do you want to use for this app? (#{default}) ") 
        
        # should be a regex that checks for valid hostname
        #if  hostname == "" 
        #  hostname =  default
        #end  

        content = ERB.new(File.read(MyGem::Railtie.root.join('nginx_upstream.conf.erb'))).result(binding)
        write(file_path,content)
      else
        puts 'Please deploy thin clusters first with: rake deploy:thin:port or rake deploy:thin:socket '
      end
    end

    #desc 'Creates nginx conf files for single domain'
    task :conf,[:domain] do |cmd,args|
      if args[:domain] = "" then
        # default = Rails.application.class.parent_name.underscore
        default = 'www.example.com'      
        domain = ask("\nWhat hostname do you want to use for this app? (#{default}) ")
      elsif
        domain = args[:domain]
        then
        puts domain
        content = ERB.new(File.read(MyGem::Railtie.join('domains_for_sale.conf.erb'))).result(binding)
        puts content
        # config_file = Rails.root.join('config','nginx',domain)
        config_file = "/etc/nginx/sites-enabled/#{domain}"
        begin
          write(config_file,content)          
        rescue
          puts "something went wrong trying to write file #{config_file}"
        end
      end
    end
  
  end
end

