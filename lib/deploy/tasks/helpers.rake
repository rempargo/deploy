include RbConfig
require 'socket'

def ask message
  print "\n#{message}"
  STDIN.gets.chomp
end


# write or show
def write(file_path,content)
  if CONFIG['host_os'] =~ /linux/
    File.open(file_path, 'w') {|f| f.write(content) }
    puts content
    puts "================================="
    puts "wrote #{file_path}"
  else
    puts "================================="
    puts file_path
    puts "---------------------------------"
    puts content
    puts "================================="
  end
end

def thin_file
  Rails.root.join('config','thin.yml')
end

def thin
  YAML.load(File.read(thin_file)) if File.exists?(thin_file)
end

def save_thin_yml(hash)
  hash=remove_options(hash)
  options = "#{ hash.inject(""){|options,key_value|options +   "--#{key_value[0]} #{key_value[1]} "}}"
  command = "thin config -C #{thin_file} #{options}"
  p command
  system(command)
end

def remove_options(hash)
  hash.delete("max_conns")
  hash.delete("max_persistent_conns")
  hash.delete("require")
  hash.delete("daemonize")
  hash.delete("onebyone")
  hash
end  


def ip4
  Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}
end


