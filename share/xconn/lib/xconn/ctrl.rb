module XConn

  module Filter

    def current(logfile)
      temperature = 0;
      humidity = 0;
      moisture = 0;
      light = 0;

      line = File.readlines(logfile)[-1..-1].last
      if line =~ /([-]*\d+) (\d+) (\d+) (\d+)/
        temperature = $1.to_s
        humidity = $2.to_s
      end
      {
        temperature: temperature,
        humidity: humidity,
        moisture: moisture,
        light: light
      }
    end

    def plot(x, y, opts)
      y = y.collect do |i|
        if i.length > 1 then
          i.inject(:+)/(i.length-1)
        else
          i.inject(:+)/(i.length)
        end
      end

      Gnuplot.open do |gp|
        Gnuplot::Plot.new(gp) do |plot|
          plot.title  opts[:title]
          plot.ylabel opts[:ylabel]
          plot.xlabel opts[:xlabel]
          plot.xrange opts[:xrange]
          plot.grid
          plot.terminal 'png'                                                            
          plot.output File.join(settings.public_folder, "#{opts[:name]}.png")

          plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with = 'lines lt rgb "#4a90d9"'
            ds.linewidth = 2
            ds.notitle
          end
        end
      end
      return x, y
    end

    def format_week(opts)
      x = (0..167).collect { |i| i.to_s }
      y = (0..167).collect { |i| [0] }

      File.readlines(Logfile).each do |line|
        yield y, Time.now.strftime("%W"), line
      end

      return plot x, y, opts
    end

    def format_day(opts)
      x = (0..23).collect { |i| i.to_s }
      y = (0..23).collect { |i| [0] }

      File.readlines(Logfile).each do |line|
        yield y, Time.new.strftime('%d'), line
      end

      return plot x, y, opts
    end
  end

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
