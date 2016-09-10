module XConn
  class WebApp < Sinatra::Base

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
      title: 'XConnector: WeatherApp'
    }

    get '/' do
      liquid :index, :locals => Defaults
    end

    get '/help' do
      "Help desk"
    end

    get '/raw' do
      liquid :raw, :locals => Defaults.merge({ lines: File.read(Logfile) })
    end

  end
end
