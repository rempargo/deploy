namespace :nginx do

  def ask message
       print message
       STDIN.gets.chomp
  end

  desc 'Creates nginx conf files for single domain'
  task :conf,[:domain] do |cmd,args|
    domain = args[:domain]
    puts domain
	puts domain.strip
    content = ERB.new(File.read(Rails.root.join('lib','domain_server_name.conf.erb'))).result(binding)
    File.open(Rails.root.join('config','nginx',domain), 'w') {|f| f.write(content) }
  end


  desc 'Creates nginx conf files for all domains'
  task :create do 
    domains = []
    File.open(Rails.root.join('lib','domains_for_sale')).each_line do |line|
      p line
      domains << line.strip
    end
    domains.each do |domain|    
      Rake::Task['nginx:conf'].reenable
      Rake::Task['nginx:conf'].invoke(domain)
    end
  end

  desc 'copy all nginx files to nginx direcotry'
  task :copy do
    command = "cp #{Rails.root.join('config','nginx')}/* /etc/nginx/domains_for_sale/"
    system(command)
  end

  desc 'Choose port for this app'
  task :port do
  puts "The following ports are already used on this server:"
  system ('cat ../*/port') # refactor to ruby code
  port = ask("\nWhich starting port you want to use for this app? ")  
  File.open('port', 'w') {|f| f.write(port) }
  end



end

