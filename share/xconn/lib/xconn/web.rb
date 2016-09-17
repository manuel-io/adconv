module XConn
  class WebApp < Sinatra::Base

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
      liquid :index, :locals => Defaults
    end

    get '/temperature' do
      liquid :temperature, :locals => Defaults.merge({
        subtitle: 'Statistics about temperature measurement'
      }).merge(current(Logfile))
    end

    get '/humidity' do
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
      current(Logfile)
      liquid :help, :locals => Defaults.merge({
        subtitle: 'Help desk'
      })
    end

  end
end
