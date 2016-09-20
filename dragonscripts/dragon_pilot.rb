#! /usr/bin/ruby

require 'socket'      # Sockets are in standard library

hostname = 'localhost'
port = 3001


s = TCPSocket.open(hostname, port)
sleep(0.3)
puts "slept"
s.write(Integer(ARGV[0])-1)
puts "written #{ARGV[0]}"
s.close
puts "closed"

