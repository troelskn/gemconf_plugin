# Install hook code here
require 'fileutils'

def transform_config_file(input)
  matches = input.match(/([\s\S]*\nRails::Initializer.run.*\n)([\s\S]+)(\nend[\s\S]*)/)
  raise "Can't parse config file." unless matches
  before = matches[1]
  content = matches[2]
  after = matches[3]
  first = true
  lines = []
  # Replace config.gem calls with new inclusion code + store the lines for later
  content.gsub! /^([ \t]*#?[ \t]*config\.gem.+)$/ do |line|
    lines << line
    if first
      first = false
      "\n  # Load gems that this application depends on.\n  # They can then be installed with \"script/install_gems\" on new installations.\n  # All gem dependencies should be listed in \"gemconf.rb\"\n  eval File.read(File.join(File.dirname(__FILE__), 'gemconf.rb'))"
    else
      ""
    end
  end
  # Strip out comment about "Specify gems"
  content.gsub!(/  # Specify gems[^\n]*(\n[ \t]*#.*)*/, "")
  # Remove excessive blanklines
  content.gsub!(/(\s*\n){2,}/, "\n\n")

  return before + content + after, lines.map{|line| line.gsub(/(^\s+|\s+$)/, "") }
end

raise "Can't find 'script' directory. Are you running this script from Rails root? " unless File.directory? "#{FileUtils.pwd}/script"
raise "'config/gemconf.rb' already exists." if File.file? "#{FileUtils.pwd}/config/gemconf.rb"
raise "Can't find 'config/environment.rb'. Are you running this script from Rails root? " unless File.file? "#{FileUtils.pwd}/config/environment.rb"

puts ">>> Writing new file to 'script/install_gems'"
FileUtils.cp "#{File.dirname(__FILE__)}/script/install_gems", "#{FileUtils.pwd}/script/install_gems"

config_file = File.read("#{FileUtils.pwd}/config/environment.rb")
new_config_file, lines = transform_config_file(config_file)

do_path = nil
while do_path.nil?
  puts "\nThe initializer in 'config/environment.rb' should be changed to\n"
  puts "include the new 'config/gemconf.rb'. This installer can try to\n"
  puts "patch 'config/environment.rb'. If the file is relatively standard\n"
  puts "this usually works, but you can chose to do it manually if you wish.\n\n"
  puts "Do you want to have your 'config/environment.rb' automatically patched? [yn]\n"
  user_input = gets.chomp.downcase
  if ["y", "n"].include?(user_input)
    do_path = user_input == "y"
  end
end

if do_path
  puts ">>> Writing changes to 'config/environment.rb'"
  File.open("#{FileUtils.pwd}/config/environment.rb", 'w') do |f|
    f.write new_config_file
  end
else
  puts "Remember to edit 'config/environment.rb' and add the following\n"
  puts "line instead of the current gem-dependencies.\n"
  puts "    eval File.read(File.join(File.dirname(__FILE__), 'gemconf.rb'))\n"
end

puts ">>> Writing changes to 'config/gemconf.rb'"
File.open("#{FileUtils.pwd}/config/gemconf.rb", 'w') do |f|
  f.write "# Specify the gems that your application depends on.\n"
  f.write "# You have to specify the :lib option for libraries, where the Gem name (sqlite3-ruby) differs from the file itself (sqlite3)\n\n"
  f.write lines.join("\n")
end
