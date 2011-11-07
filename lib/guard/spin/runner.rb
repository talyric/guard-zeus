# Needed for socket_file
require 'socket'
require 'tempfile'
require 'digest/md5'

module Guard
  class Spin
    class Runner
      attr_reader :options

      def initialize(options = {})
        @options = options
        UI.info "Guard::Spin Initialized"
      end

      def launch_spin(action)
        UI.info "#{action}ing Spin", :reset => true
        start_spin
      end

      def kill_spin
        stop_spin
      end

      def run(paths)
        UI.info "Running [#{paths.join(", ")}]", :reset => true
        system "spin push #{paths.join(" ")}"
      end

      def run_all
        run(['spec'])
      end

      private

      def start_spin
        system "spin serve &"
      end

      def stop_spin
        file = socket_file
        if File.exist?(file)
          socket = UNIXSocket.open(file)
          if socket
            socket.close
            UI.info "Spin Stopped", :reset => true
          end
          File.delete(file)
        end
      end

      def socket_file
        key = Digest::MD5.hexdigest([Dir.pwd, 'spin-gem'].join)
        [Dir.tmpdir, key].join('/')
      end
    end
  end
end
