# @author Paul Verschoor
#require 'transip'
require 'yaml'
require 'fileutils'
require 'json'
require 'colored'
require 'erb'
puts "##################"
APP_ROOT = File.expand_path File.expand_path(File.dirname(__FILE__))
require APP_ROOT + "/dns_app.rb"
puts "###################"

MANDATORY_SETTINGS = [:app_name,:domain_name,:server_ip,:subdomains]

# setting variables DRY
app_config_file = 'app_config.yml'

# showings some settings
p RUBY_VERSION
system ('rvm list rubies')
app_config_source_path      =  "#{File.dirname(__FILE__)}/#{app_config_file}"

p app_config_source_path

def ask message
  print "\n#{message}"
  STDIN.gets.chomp
end


def modify_array(array)
  array.each do |value| 
    answer = ask "What values do you want to give: (#{value}): "
    unless answer == ""
      puts "different #{answer}"
      puts "#{answer.class}"      
      hash[key] = answer
    end 
  end
end


def modify_hash(hash)
  hash.each do |key,value| 
    answer = ask "What value do you want for #{key}: (#{value}): "
    unless answer == ""
      puts "different #{answer}"
      if value.class == Array
        hash[key] = eval(answer)
      else
        hash[key] = answer
      end
    end 
  end
end

#array = ['eerste','tweede']
#p array
#modify_hash(array)
#p array
#exit

# load YAML
app_config = YAML::load_file(app_config_source_path)
#p FileUtils.absolute_path '.'
puts ARGV[0]
puts ARGV[0].class
p "---"
p app_config[:app_name]=ARGV[0] if ARGV[0]


puts app_config.to_s.yellow
app_config.update(modify_hash(app_config.select{|key|key==:app_name}))

# setting variables DRY
app_path_dir    = "#{app_config[:app_name]}"
app_config_dir  = "#{app_path_dir}/config"
app_config_path = "#{app_config_dir}/#{app_config_file}"
app_public_path = "#{app_path_dir}/public"
rvmrc_path      = "#{app_path_dir}/.rvmrc"

if File.exists?(app_config_path) and YAML::load_file(app_config_path)[:app_name]==app_config[:app_name] then
  p "Using already configured configuration from #{File.expand_path(app_config_path)}"
  app_config = YAML::load_file(app_config_path)
elsif File.exists?(app_config_path) and not YAML::load_file(app_config_path)[:app_name]==app_config[:app_name] then
  puts "app_name given is not the same as stated in configuration file #{File.expand_path(app_config_path)} (lists: #{YAML::load_file(app_config_path)[:app_name]}) "
end
app_config.update(modify_hash(app_config.reject{|key|key==:app_name}))
puts app_config.to_s.yellow

#############################################################################################




# create local app directory

# create direcories recursivily
FileUtils.mkpath  app_config_dir
FileUtils.mkpath  app_public_path
# show
p  app_config_path
p File.expand_path app_config_path

# writing YAML
File.open(app_config_path, 'w') {|f| f.write app_config.to_yaml } 
#exit

# writing .rvmrc
rvmrc_string = "rvm use #{app_config[:ruby_version]}@#{app_config[:app_name]} --create\n"
File.open(rvmrc_path, 'w') {|f| f.write rvmrc_string } 



Dir.chdir app_path_dir
system('ls')

# writing .gitignore
system('touch .gitignore') unless File.exists? '.gitignore'

# writing readme
File.open("readme.md", 'w') {|f| f.write app_config[:app_description] } unless File.exists? 'readme.md'


# @param app_config [Hash] the hash with all the config settings
# @return [don't know!]

def system_p(command)
  p command
  puts command.to_s.blue
  system(command)
end

def git_setup(app_config)

  # setting up git
  unless File.exists? '.git'
    system('git init')
    system('git add .')
    system("git commit -m 'First commit'")


  end
end

def git_create_remote_repositary(app_config)
  
  github_pairs = { :name         => app_config[:app_name],
    :private      => app_config[:github_private],
    :description  => app_config[:app_description]
  }

  puts github_pairs.to_json
  command = "curl -u #{app_config[:github_user]} https://api.github.com/user/repos -d '#{github_pairs.to_json}'"
  system_p(command)
end

def git_push(app_config)
  puts `pwd`
  puts `git status`
  system_p("git remote add origin git@github.com:#{app_config[:github_user]}/#{app_config[:app_name]}.git")

  system_p('git push -u origin master')    
end

# clone on server
def git_clone_on_server(app_config)
  # if repo already exist, then clone
  system_p "ssh #{app_config[:server_user]}@#{app_config[:server_ip]} \"source /etc/profile;mkdir -p #{app_config[:server_apps_path]};cd #{app_config[:server_apps_path]};git clone git@github.com:#{app_config[:github_user]}/#{app_config[:app_name]}.git\""
end


puts __FILE__
puts __FILE__
puts __FILE__
puts __FILE__
def nginx_conf_path(app_config)
  "/etc/nginx/sites-enabled/#{app_config[:app_name]}"
end

def nginx_upstream_path(app_config)
  "#{nginx_conf_path(app_config)}.upstream"
end


def nginx_conf(app_config)
  #local variables
  domain            = app_config[:subdomains].map{|sub|"#{sub}.#{app_config[:domain_name]}"}.join(' ')
  app_name          = app_config[:app_name]
  server_apps_path  = app_config[:server_apps_path] 
  
  
  
  template_path=APP_ROOT + '/deploy/nginx_server_name.conf.erb'
  p template_path
  p puts File.exists? template_path
  content = ERB.new(File.read(template_path)).result(binding)
end

def nginx_upstream(app_config)
  #local variables
  app_name          = app_config[:app_name]
  
  thin            = {}
  thin['port']    = app_config[:internal_port].to_i
  thin['servers'] = app_config[:internal_servers].to_i
  
  template_path=APP_ROOT + '/deploy/nginx_upstream.conf.erb'
  p template_path
  p puts File.exists? template_path
  content = ERB.new(File.read(template_path)).result(binding)
end


puts nginx_conf_path(app_config)
puts nginx_conf(app_config)

puts nginx_upstream(app_config)
puts nginx_upstream_path(app_config)

git_setup(app_config) if (ask "Setting up git? yes/no?")[0] == 'y'
git_create_remote_repositary(app_config) if (ask "create remote repositary? yes/no?")[0] == 'y'
git_push(app_config) if (ask "Push to github? yes/no?")[0] == 'y'
git_clone_on_server(app_config) if  (ask "Clone on server? yes/no?")[0] == 'y'


transip_key_file = File.expand_path "~/.ssh/#{app_config[:transip_key_file]}"
p transip_key_file
puts File.exists? transip_key_file
if File.exists?(transip_key_file) then
  answer = ask "DNS updaten? yes/no?" 
  if answer[0].downcase == 'y' then
    transip = Transip::DomainClient.new(username: app_config[:transip_user], key_file: transip_key_file, ip: app_config[:transip_ip], mode: :readwrite)

    transip = Transip::DomainClient.new(username: 'nebits', key_file: '/Users/paulverschoor/.ssh/transip_api', ip: '212.64.109.224', mode: :readwrite)

    transip.request(:set_dns_entries, :domain_name => app_config[:domain_name], :dns_entries => app_config[:subdomains].collect{|subdomain|Transip::DnsEntry.new(subdomain, 60, 'A', app_config[:server_ip])})
  end
else
  puts "#{transip_key_file} does not exist, can not update DNS entries"
end
