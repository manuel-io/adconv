#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'xconn'
require 'getoptlong'

modifiers = {
  device: '/dev/ttyUSB0'
}

opts = GetoptLong.new(
  [ '--device', '-d', GetoptLong::REQUIRED_ARGUMENT  ]
)

opts.each do |opt, arg|
  case opt
    when '--device'
      modifiers[:device] = arg
  end
end

XConn::Handle.new modifiers
