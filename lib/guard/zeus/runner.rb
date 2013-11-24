# Needed for socket_file
require 'socket'
require 'tempfile'
require 'digest/md5'

module Guard
  class Zeus
    class Runner
      attr_reader :options

      def initialize(options = {})
        @options = {:run_all => true}.merge(options)
        UI.info "Guard::Zeus Initialized"
      end

      def launch_zeus(action)
        UI.info "#{action}ing Zeus", :reset => true
        spawn_zeus zeus_serve_command, zeus_serve_options
      end

      def kill_zeus
        stop_zeus
      end

      def run(paths)
        #run_command zeus_push_command(paths), zeus_push_options
      end

      def run_all
        #return unless options[:run_all]
        #if rspec?
        #  run(['rspec'])
        #elsif test_unit?
        #  run(Dir['test/**/*_test.rb']+Dir['test/**/test_*.rb'])
        #end
      end

      private

      def sockfile
        File.join(Dir.pwd, ".zeus.sock")
      end

      def run_command(cmd, options = '')
        system "#{cmd} #{options}"
      end

      def spawn_zeus(cmd, options = '')
        #@zeus_pid = fork do
        #  exec "#{cmd} #{options} &"
        #end
        system "#{cmd} #{options} &"
        #sleep 1
        loop do
          @zeus_pid=`pidof zeus-linux-amd64`.to_i
          break unless @zeus_pid == 0
        end
        UI.info "pid=#{@zeus_pid}", :reset => true
      end

      def stop_zeus
        while (@zeus_pid = `pidof zeus-linux-amd64`.to_i) != 0
          UI.info "Stopping Zeus PID=#{@zeus_pid}", :reset => true

          begin
            Timeout::timeout(10) {
              Process.kill(:INT, @zeus_pid)
              begin
                loop { Process.kill(0, @zeus_pid); sleep 0.01 }
              rescue Errno::ESRCH
              end
            }
          rescue
            begin
              Timeout::timeout(10) {
                UI.info "Killing Zeus PID=#{@zeus_pid}", :reset => true
                Process.kill(:KILL, @zeus_pid)
                begin
                  loop { Process.kill(0, @zeus_pid); sleep 0.01 }
                rescue Errno::ESRCH
                end
              }
            rescue
              raise "Unable to kill Zeus :("
            end
          end
          #
          #Process.kill(:INT, @zeus_pid)
          #
          #begin
          #  #unless Process.waitpid(@zeus_pid, Process::WNOHANG)
          #  unless Process.waitpid(@zeus_pid, 0)
          #    UI.info "Killing Zeus PID=#{@zeus_pid}", :reset => true
          #    Process.kill(:KILL, @zeus_pid)
          #  end
          #rescue Errno::ECHILD
          #end
          #File.delete(sockfile) if File.exist? sockfile
          UI.info "Zeus Stopped PID=#{@zeus_pid}", :reset => true
        end
        sock_file = "#{Dir.pwd}/.zeus.sock"
        if File.exist?(sock_file)
          UI.info "Deleting old #{sock_file}", :reset => true
          File.delete(sock_file)
        end
      end

      def zeus_push_command(paths)
        cmd_parts = []
        cmd_parts << "bundle exec" if bundler?
        cmd_parts << "zeus test"
        cmd_parts << paths.join(' ')
        cmd_parts.join(' ')
      end

      def zeus_push_options
        ''
      end

      def zeus_serve_command
        cmd_parts = []
        cmd_parts << options[:pre_cli] unless options[:pre_cli].nil?
        cmd_parts << "bundle exec" if bundler?
        cmd_parts << "zeus start"
        cmd_parts.join(' ')
      end

      def zeus_serve_options
        opt_parts = []
        opt_parts << options[:cli] unless options[:cli].nil?
        opt_parts.join(' ')
      end

      def bundler?
        @bundler ||= options[:bundler] != false && File.exist?("#{Dir.pwd}/Gemfile")
      end

      def test_unit?
        @test_unit ||= options[:test_unit] != false && File.exist?("#{Dir.pwd}/test/test_helper.rb")
      end

      def rspec?
        @rspec ||= options[:rspec] != false && File.exist?("#{Dir.pwd}/spec")
      end
    end
  end
end
