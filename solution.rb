# Reading args
folder, *args = ARGV

# Running day folder solution
Dir.chdir("#{folder}") do
    system "ruby ./script.rb #{args.join(" ")}"
end