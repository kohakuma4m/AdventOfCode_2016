require "fileutils"

# Reading args
folder = ARGV[0]
if !folder || !folder.match(/^day[0-9][0-9]$/)
    abort("USAGE: ruby generate.rb dayXX")
end

# Adding new solution directory
if !Dir.exist?(folder)
    puts "Creating new folder: #{folder}"
    Dir.mkdir(folder)
end

# Adding new solution default template
src_file = "templates/default.rb"
dest_file = "#{folder}/solution.rb"
if !File.exist?(dest_file)
    puts "Creating new default template: #{dest_file}"
    FileUtils.cp(src_file, dest_file)
end

# Adding new solution input file
input_file = "#{folder}/input.txt";
if !File.exist?(input_file)
    puts "Creating new empty input file: #{input_file}"
    FileUtils.touch(input_file)
end