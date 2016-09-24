#$:.unshift File.dirname(__FILE__)

require 'sinatra'
require 'yaml'
require 'serialport'
require 'syslog'
require 'fileutils'
require 'thin'
require 'liquid'
require 'gnuplot'
require 'date'

require 'xconn/handle'
require 'xconn/ctrl'
require 'xconn/web'

module XConn
  Base = File.join(Dir.home, '.xconn')
  Logfile = File.join(Base, 'xconn.log')
  License = File.join(File.dirname(__FILE__), *%w[.. .. .. LICENSE])
  Dir.mkdir Base, 0700 unless Dir.exist? Base
  FileUtils.touch(Logfile)
end
