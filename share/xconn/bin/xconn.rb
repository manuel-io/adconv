#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'xconn'
require 'getoptlong'

modifiers = {
  device: '/dev/ttyUSB0',
  baud: 9600,
  port: 9292,
  stats: true,
  web: true
}

opts = GetoptLong.new(
  [ '--device', '-d', GetoptLong::REQUIRED_ARGUMENT  ]
)

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"

  opts.on('-b', '--baud rate', Integer, 'Set the baud rate (Default: 9600)') do |value|
    modifiers[:baud] = value.to_i
  end

  opts.on('-d', '--device file', String, 'Set the device file (Default: /dev/ttyUSB0)') do |value|
    modifiers[:device] = value
  end

  opts.on('-p', '--port integer', Integer, 'Set the TCP port (Default: 9292)') do |value|
    modifiers[:port] = value.to_i
  end

  opts.on('-s', '--[no-]stats', 'Enable/disable generating stats') do |value|
    modifiers[:stats] = value
  end

  opts.on('-w', '--[no-]web', 'Enable/disable web interface') do |value|
    modifiers[:web] = value
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end

end.parse!

XConn::Handle.new modifiers
