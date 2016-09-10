#$:.unshift File.dirname(__FILE__)

require 'sinatra'
require 'yaml'
require 'serialport'
require 'syslog'
require 'fileutils'
require 'thin'
require 'liquid'

require 'xconn/handle'
require 'xconn/web'
require 'xconn/ctrl'

module XConn
  Base = File.join(Dir.home, '.xconn')
  Logfile = File.join(Base, 'xconn.log')
  Dir.mkdir Base, 0700 unless Dir.exist? Base
  FileUtils.touch(Logfile)
end
