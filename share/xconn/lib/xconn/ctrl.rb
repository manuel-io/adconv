module XConn
  class Ctrl
    def initialize(opts)
      Thread.current[:stdout] = StringIO.new
      Thread.current[:stderr] = StringIO.new

      @serial = SerialPort.new opts[:port]
      @serial.baud = opts[:baudrate]
      @serial.flow_control = SerialPort::NONE
      @serial.parity = SerialPort::NONE
      @serial.data_bits = opts[:data]
      @serial.stop_bits = opts[:stop]
      @serial.read_timeout = opts[:timeout]
      
      loop do
        if getok
          if getcmd('-', result = String.new)
              line = Time.now.strftime "%Y-%m-%d, %H:%M:%S %z: " + result
              File.open(Logfile, 'a') { |fd| fd << "#{line}" }
          end
        end
        @serial.break 1
      end
    end

    private

    def getok(command = "*")
      @serial.puts(command)
      if (res = @serial.gets) =~ /^#{command}/
        return true
      else
        return false
      end
      rescue
        return false
    end

    def getcmd(command = nil, result)
      @serial.puts(command)
      if (result.replace @serial.gets) =~ /^#{command}/
        return true
      else
        return false
      end
      rescue
        return false
    end
  end
end
