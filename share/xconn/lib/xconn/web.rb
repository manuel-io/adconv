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
      title: 'Weather Stats',
      subtitle: 'Overview'
    }

    get '/' do
      liquid :index, :locals => Defaults.merge(current(Logfile))
    end

    get '/temperature' do
      config = {
        name: 'temperature',
        title: 'Temperature over the Day',
        xlabel: 'Time since Midnight [h]',
        ylabel: 'Temperature [°C]',
        xrange: '["0":"23"]'
      }

      x, y = format_day(config) do |y, year, month, day, line|
        if line =~ /#{year}\-#{month}\-#{day}, (\d+):\d+:\d+ \+0200: \- (\d+)/
          y[$1.to_i].push $2.to_i
        end
      end

      config = {
        name: 'temperature_week',
        title: 'Temperature over the Week',
        xlabel: 'Time since beginning of the Week [h]',
        ylabel: 'Temperature [°C]',
        xrange: '["0":"167"]'
      }

      x, y, week = format_week(config) do |y, year, month, week, line|
        if line =~ /#{year}\-#{month}\-(\d+), (\d+):\d+:\d+ \+0200: \- (\d+)/
          if Date.parse(line[0..9]).strftime("%W") == week
            day_of_the_week = Date.parse("#{year}-#{month}-#{$1}").strftime("%w")
            hour = $2.to_i
            y[((day_of_the_week.to_i - 1).to_i  * 24 )+ hour].push $3.to_i
          end
        end
      end

      liquid :temperature, :locals => Defaults.merge({
        subtitle: 'Temperature',
        week: week
      })
    end

    get '/humidity' do
      config = {
        name: 'humidity',
        title: 'Humidity over the Day',
        xlabel: 'Time since Midnight [h]',
        ylabel: 'Humidity [%]',
        xrange: '["0":"23"]'
      }

      x, y = format_day(config) do |y, year, month, day, line|
        if line =~ /#{year}\-#{month}\-#{day}, (\d+):\d+:\d+ \+0200: \- \d+ (\d+)/
          y[$1.to_i].push $2.to_i
        end
      end

      config = {
        name: 'humidity_week',
        title: 'Humidity over the Week',
        xlabel: 'Time since beginning of the Week [h]',
        ylabel: 'Humidity [%]',
        xrange: '["0":"167"]'
      }

      x, y, week = format_week(config) do |y, year, month, week, line|
        if line =~ /#{year}\-#{month}\-(\d+), (\d+):\d+:\d+ \+0200: \- \d+ (\d+)/
          if Date.parse(line[0..9]).strftime("%W") == week
            day_of_the_week = Date.parse("#{year}-#{month}-#{$1}").strftime("%w")
            hour = $2.to_i
            y[((day_of_the_week.to_i - 1).to_i  * 24 )+ hour].push $3.to_i
          end
        end
      end

      liquid :humidity, :locals => Defaults.merge({
        subtitle: 'Air humidity',
        week: week
      })
    end

    get '/moisture' do
      config = {
        name: 'moisture',
        title: 'Soil moisture over the Day',
        xlabel: 'Time since Midnight [h]',
        ylabel: 'Moisture [%]',
        xrange: '["0":"23"]'
      }

      x, y = format_day(config) do |y, year, month, day, line|
        if line =~ /#{year}\-#{month}\-#{day}, (\d+):\d+:\d+ \+0200: \- \d+ \d+ (\d+)/
          y[$1.to_i].push $2.to_i
        end
      end

      config = {
        name: 'moisture_week',
        title: 'Soil moisture over the Week',
        xlabel: 'Time since beginning of the Week [h]',
        ylabel: 'Moisture [%]',
        xrange: '["0":"167"]'
      }

      x, y, week = format_week(config) do |y, year, month, week, line|
        if line =~ /#{year}\-#{month}\-(\d+), (\d+):\d+:\d+ \+0200: \- \d+ \d+ (\d+)/
          if Date.parse(line[0..9]).strftime("%W") == week
            day_of_the_week = Date.parse("#{year}-#{month}-#{$1}").strftime("%w")
            hour = $2.to_i
            y[((day_of_the_week.to_i - 1).to_i  * 24 )+ hour].push $3.to_i
          end
        end
      end
      liquid :moisture, :locals => Defaults.merge({
        subtitle: 'Soil moisture',
        week: week
      })
    end

    get '/light' do
      config = {
        name: 'light',
        title: 'Light conditions over the Day',
        xlabel: 'Time since Midnight [h]',
        ylabel: 'Light [%]',
        xrange: '["0":"23"]'
      }

      x, y = format_day(config) do |y, year, month, day, line|
        if line =~ /#{year}\-#{month}\-#{day}, (\d+):\d+:\d+ \+0200: \- \d+ \d+ \d+ (\d+)/
          y[$1.to_i].push $2.to_i
        end
      end

      config = {
        name: 'light_week',
        title: 'Light conditions over the Week',
        xlabel: 'Time since beginning of the Week [h]',
        ylabel: 'Light [%]',
        xrange: '["0":"167"]'
      }

      x, y, week = format_week(config) do |y, year, month, week, line|
        if line =~ /#{year}\-#{month}\-(\d+), (\d+):\d+:\d+ \+0200: \- \d+ \d+ \d+ (\d+)/
          if Date.parse(line[0..9]).strftime("%W") == week
            day_of_the_week = Date.parse("#{year}-#{month}-#{$1}").strftime("%w")
            hour = $2.to_i
            y[((day_of_the_week.to_i - 1).to_i  * 24 )+ hour].push $3.to_i
          end
        end
      end

      liquid :light, :locals => Defaults.merge({
        subtitle: 'Light conditions',
        week: week
      })
    end

    get '/raw' do
      liquid :raw, :locals => Defaults.merge({
        subtitle: 'Serial data',
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
