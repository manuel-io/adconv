module XConn
  class Handle
    def initialize modifiers

     ctrl = Thread.new do
        Ctrl.new({
          baudrate: 9600,
          port: modifiers[:device],
          data: 8,
          stop: 1,
          timeout: 5000
        })
      end

      app = Thread.new do
        Rack::Server.start({
          app: Rack::Builder.app { run WebApp },
          server: 'thin',
          Host: '0.0.0.0',
          Port: '9292'
        })
      end

      ctrl.abort_on_exception = true
      app.join
    end
  end
end
