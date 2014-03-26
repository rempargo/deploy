require 'transip'
require 'yaml'
require 'fileutils'
require 'json'
require 'colored'

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

# setting up git
unless File.exists? '.git'
  system('git init')
  system('git add .')
  system("git commit -m 'First commit'")
  system("git remote add origin git@github.com:#{app_config[:github_user]}/#{app_config[:app_name]}.git")



  github_pairs = { :name         => app_config[:app_name],
    :private      => app_config[:github_private],
    :description  => app_config[:app_description]
  }

  puts github_pairs.to_json

  command = "curl -u #{app_config[:github_user]} https://api.github.com/user/repos -d '#{github_pairs.to_json}'"
  puts command
  # system(command)

  system('git push -u origin master')
end

puts "###"
# clone on server

# if repo already exist, then clone
command = "ssh #{app_config[:server_user]}@#{app_config[:server_ip]} \"source /etc/profile;cd #{app_config[:server_apps_path]};git clone git@github.com:#{app_config[:github_user]}/#{app_config[:app_name]}.git\""
puts command
system(command)


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
