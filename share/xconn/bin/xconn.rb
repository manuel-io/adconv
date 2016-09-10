$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'xconn'

XConn::Handle.new
