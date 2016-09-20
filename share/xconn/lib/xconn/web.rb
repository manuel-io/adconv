module XConn
  class WebApp < Sinatra::Base
    include XConn::Filter

    configure do
      set :threaded, false
      set :root, File.dirname(__FILE__)
      set :views, File.join(File.dirname(__FILE__), %w[web views])
      set :public_folder, File.join(File.dirname(__FILE__), %w[web static])
    end
  
    Liquid::Template.file_system =
      Liquid::LocalFileSystem.new \
        File.join(File.dirname(__FILE__), %w[web includes])

    Defaults = {
      title: 'XConnector: WeatherApp',
      subtitle: 'Overview'
    }

    get '/' do
      liquid :index, :locals => Defaults.merge(current(Logfile))
    end

    get '/temperature' do
      config = {
        name: 'temperature',
        title: 'Temperature over the Day',
        xlabel: 'Time since Midnight [min]',
        ylabel: 'Temperature [°C]',
        xrange: '["0":"23"]'
      }

      x, y = format_day(config) do |y, day, line|
        if line =~ /2016\-09\-#{day}, (\d+):\d+:\d+ \+0200: \- (\d+)/
          y[$1.to_i].push $2.to_i
        end
      end

      config = {
        name: 'temperature_week',
        title: 'Temperature over the Week',
        xlabel: 'Time since beginning of the Week [min]',
        ylabel: 'Temperature [°C]',
        xrange: '["0":"167"]'
      }

      x, y = format_week(config) do |y, week, line|
        if line =~ /2016\-09\-(\d+), (\d+):\d+:\d+ \+0200: \- (\d+)/
          if Date.parse(line[0..9]).strftime("%W") == week
            day_of_the_week = Date.parse("2016-09-#{$1}").strftime("%w")
            hour = $2.to_i
            y[((day_of_the_week.to_i - 1).to_i  * 24 )+ hour].push $3.to_i
          end
        end
      end

      liquid :temperature, :locals => Defaults.merge({
        subtitle: 'Statistics about temperature measurement'
      })
    end

    get '/humidity' do
      config = {
        name: 'humidity',
        title: 'Humidity over the Day',
        xlabel: 'Time since Midnight [min]',
        ylabel: 'Humidity [%]',
        xrange: '["0":"23"]'
      }

      x, y = format_day(config) do |y, day, line|
        if line =~ /2016\-09\-#{day}, (\d+):\d+:\d+ \+0200: \- \d+ (\d+)/
          y[$1.to_i].push $2.to_i
        end
      end

      config = {
        name: 'humidity_week',
        title: 'Humidity over the Week',
        xlabel: 'Time since beginning of the Week [min]',
        ylabel: 'Humidity [%]',
        xrange: '["0":"167"]'
      }

      x, y = format_week(config) do |y, week, line|
        if line =~ /2016\-09\-(\d+), (\d+):\d+:\d+ \+0200: \- \d+ (\d+)/
          if Date.parse(line[0..9]).strftime("%W") == week
            day_of_the_week = Date.parse("2016-09-#{$1}").strftime("%w")
            hour = $2.to_i
            y[((day_of_the_week.to_i - 1).to_i  * 24 )+ hour].push $3.to_i
          end
        end
      end

      liquid :humidity, :locals => Defaults.merge({
        subtitle: 'Statistics about air humidity'
      })
    end

    get '/moisture' do
      liquid :moisture, :locals => Defaults.merge({
        subtitle: 'Statistics about soil moisture'
      })
    end

    get '/light' do
      liquid :light, :locals => Defaults.merge({
        subtitle: 'Statistics about light conditions'
      })
    end

    get '/raw' do
      liquid :raw, :locals => Defaults.merge({
        subtitle: 'Unfilterd recived serial data',
        lines: File.read(Logfile)
      })
    end

    get '/help' do
      liquid :help, :locals => Defaults.merge({
        subtitle: 'Help desk'
      })
    end

  end
end
