module XConn

  module Filter

    def current(logfile)
      time = String.new
      date = String.new
      temperature = 0;
      humidity = 0;
      moisture = 0;
      light = 0;

      line = File.readlines(logfile)[-1..-1].last
      if line =~ /([\-\d]+, [:\d]+ \+\d+): - (\d+) (\d+) (\d+) (\d+)/
        time = Time.parse($1).strftime("%H:%M %Z")
        date = Time.parse($1).strftime("%d. %B %Y")
        temperature = $2.to_s
        humidity = $3.to_s
      end
      {
        time: time,
        date: date,
        temperature: temperature,
        humidity: humidity,
        moisture: moisture,
        light: light
      }
    end

    def plot(file, x, y, opts)
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
          plot.output file

          plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with = 'lines lt rgb "#4a90d9"'
            ds.linewidth = 2
            ds.notitle
          end
        end
      end
      return x, y
    end

    def format_week(opts, time = Time.new)
      x = (0..167).collect { |i| i.to_s }
      y = (0..167).collect { |i| [0] }
      year = time.strftime '%Y'
      month = time.strftime '%m'
      week = time.strftime '%W'
      file = File.join(settings.public_folder, 'graphics', "#{opts[:name]}.png") 

      def file.exist?
        File.exist? self
      end

      def file.update?
        File.mtime(self).to_i < (Time.now.to_i - 300)
      end

      if !file.exist? || file.update?
        File.readlines(Logfile).each do |line|
          yield y, year, month, week, line
        end

        return *plot(file, x, y, opts), week
      end

      return 0, 0, week
    end

    def format_day(opts, time = Time.new)
      x = (0..23).collect { |i| i.to_s }
      y = (0..23).collect { |i| [0] }
      year = time.strftime '%Y'
      month = time.strftime '%m'
      day = time.strftime '%d'
      file = File.join(settings.public_folder, 'graphics', "#{opts[:name]}.png") 

      def file.exist?
        File.exist? self
      end

      def file.update?
        File.mtime(self).to_i < (Time.now.to_i - 300)
      end

      if !file.exist? || file.update?
        File.readlines(Logfile).each do |line|
          yield y, year, month, day, line
        end

        return plot file, x, y, opts
      end
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
