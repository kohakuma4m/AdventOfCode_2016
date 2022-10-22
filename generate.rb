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
srcFile = "templates/default.rb"
destFile = "#{folder}/script.rb"
if !File.exist?(destFile)
    puts "Creating new default template: #{destFile}"
    FileUtils.cp(srcFile, destFile)
end

# Adding new solution input file
inputFile = "#{folder}/input.txt";
if !File.exist?(inputFile)
    puts "Creating new empty input file: #{inputFile}"
    FileUtils.touch(inputFile)
end