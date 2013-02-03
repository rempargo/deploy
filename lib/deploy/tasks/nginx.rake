namespace :deploy do
  namespace :nginx do

    desc 'Creates nginx .conf file for domain'
    task :conf,[:domain] do |cmd,args|

      domain = args[:domain].to_s

      if domain == ""
        default = 'example.com'
        domain = ask("What hostname do you want to use for this app? (#{default}) ") 
        domain = default if domain == ""
      end
      content = ERB.new(File.read(MyGem::Railtie.root.join('nginx_server_name.conf.erb'))).result(binding)

      file_path = "/etc/nginx/sites-enabled/#{domain}"
      write(file_path,content)
      puts "Don't forget to add the following in the nameserver of your domain provider (e.g. transip.nl)."
      puts "Name            TTL      Type  Value"
      puts "#{""}                1 Min.   A     #{ip4.ip_address if ip4}"
    end


    desc "create nginx upstream .conf file"
    task :upstream do
      if thin 
        file_path = "/etc/nginx/sites-enabled/#{Rails.application.class.parent_name.underscore}.upstream"
        content = ERB.new(File.read(MyGem::Railtie.root.join('nginx_upstream.conf.erb'))).result(binding)
        write(file_path,content)
      else
        puts 'Please deploy thin clusters first with: rake deploy:thin:port or rake deploy:thin:socket '
      end
              puts "Don't forget to run: service nginx restart"
    end

    #desc 'Creates nginx conf files for single domain'

  end
end

