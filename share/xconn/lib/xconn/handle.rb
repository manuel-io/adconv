module XConn
  class Handle
    def initialize modifiers

     ctrl = Thread.new do
        Ctrl.new({
          baudrate: modifiers[:baud],
          port: modifiers[:device],
          data: 8,
          stop: 1,
          timeout: 5000
        }) if modifiers[:stats]
      end

      app = Thread.new do
        Rack::Server.start({
          app: Rack::Builder.app { run WebApp },
          server: 'thin',
          Host: '0.0.0.0',
          Port: modifiers[:port].to_s
        }) if modifiers[:web]
      end

      ctrl.abort_on_exception = true
      exit false unless modifiers[:stats] unless modifiers[:web]
      unless modifiers[:web] then ctrl.join
      else app.join
      end
    end
  end
end
