#!/usr/bin/ruby

for arg in ARGV
   f = File.new("#{arg}.md", "w")
   if f
    file_content = 
"---
layout: tags
tag: #{arg}
permalink: /tags/#{arg}/
---
"
    f.syswrite(file_content)
   else
    puts "Unable to write into #{arg}"
   end
end
