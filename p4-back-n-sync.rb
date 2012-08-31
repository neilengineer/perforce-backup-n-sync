#!/usr/bin/env ruby
#by Neil Zhao(neil.zhao@qualcomm.com)

time=`date +%y-%m-%d-%T`.strip
log="/tmp/sync.log.#{time}"
path=ARGV[0]

def usage()
  p "Usage: p4-back-n-sync.rb sync_path"
end
if path.to_s.empty? 
  usage()
  exit -1
end

files_2_update=`p4 sync -n #{path}`.split(/\n/) 
if files_2_update.empty? 
  p "already updated or file(s) not in client view".upcase
  exit -2
end

open("#{log}", "a") { |f|
    f.puts "###############{time}###############"
    files_2_update.each {|x| 
      f.puts "####"
      update=(x=~/updating/)
      delete=(x=~/delete/)
      opened=(x=~/opened/)
      y=x.split(/\ /).last.strip
      f.puts "Opened, skipping file: #{x.split(/#/)[0]}" if (opened!=nil)
      if (opened==nil)&&((update!=nil)||(delete!=nil))
          `cp -f #{y} #{y}.#{time}`
          f.puts "#{y} --backuped as--> #{y}.#{time}\n"
          z=`p4 sync #{y}`
          f.puts "PERFORCE LOG --> #{z}"
      end
    }
}
p "############################"
p "Sync done, check log at #{log}"
p "############################"
