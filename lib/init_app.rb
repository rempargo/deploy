require 'yaml'
require 'fileutils'
require 'json'


MANDATORY_SETTINGS = [:app_name,:domain_name,:server_ip,:subdomains]

# setting variables DRY
app_config_file = 'app_config.yml'

# showings some settings
p RUBY_VERSION
app_config_source_path      =  "#{File.dirname(__FILE__)}/#{app_config_file}"

p app_config_source_path

def ask message
  print "\n#{message}"
  STDIN.gets.chomp
end


def modify_hash(hash)
  hash.each do |key,value| 
    answer = ask "What value do you want for #{key}: (#{value})"
    unless answer == ""
      puts "different #{answer}"
      hash[key] = answer
    end 
  end
end

# load YAML
app_config = YAML::load_file(app_config_source_path)
#p FileUtils.absolute_path '.'


p app_config
modify_hash(app_config)
p app_config

# setting variables DRY
app_path_dir    = "#{app_config[:app_name]}"
app_config_dir  = "#{app_path_dir}/config"
app_config_path = "#{app_config_dir}/#{app_config_file}"
app_public_path = "#{app_path_dir}/public"
rvmrc_path      = "#{app_path_dir}/.rvmrc"

# create direcories recursivily
FileUtils.mkpath  app_config_dir
FileUtils.mkpath  app_public_path
# show
p app_config_path

# writing YAML
File.open(app_config_path, 'w') {|f| f.write app_config.to_yaml } 

# writing .rvmrc
rvmrc_string = "rvm use #{app_config[:ruby_version]}@#{app_config[:app_name]} --create\n"
File.open(rvmrc_path, 'w') {|f| f.write rvmrc_string } 



Dir.chdir app_path_dir
system('ls')

# writing .gitignore
system('touch .gitignore')

# writing readme
File.open("readme.md", 'w') {|f| f.write app_config[:description] } 

# setting up git
 system('git init')
 system('git add .')
 system("git commit -m 'First commit'")
 system("git remote add origin git@github.com:#{app_config[:github_user]}/#{app_config[:app_name]}.git")
 
 
 github_pairs = { :name         => app_config[:app_name],
                  :private      => app_config[:github_private],
                  :description  => app_config[:description]
                  }
                  
 puts github_pairs.to_json
 
 command = "curl -u #{app_config[:github_user]} https://api.github.com/user/repos -d '#{github_pairs.to_json}'"
 puts command
# system(command)
 
 system('git push -u origin master')

 # clone on server
  command = "ssh #{app_config[:server_user]}@#{app_config[:server_ip]} \"source /etc/profile;cd #{app_config[:server_apps_path]};git clone git@github.com:#{app_config[:github_user]}/#{app_config[:app_name]}.git\""
  puts command
 system(command)


