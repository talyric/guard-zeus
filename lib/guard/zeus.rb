require 'guard'
require 'guard/guard'

module Guard
  class Zeus < Guard

    autoload :Runner, 'guard/zeus/runner'
    attr_accessor :runner

    def initialize(watchers=[], options={})
      super
      @runner = Runner.new(options)
    end

    def start
      Notifier.notify("Starting Zeus...", :title => "Starting Zeus...", :image => :pending)
      runner.kill_zeus
      runner.launch_zeus("Start")
      Notifier.notify("Zeus started.", :title => "Zeus started.", :image => :pending)
    end

    def reload
      Notifier.notify("Re-starting Zeus...", :title => "Re-starting Zeus...", :image => :pending)
      runner.kill_zeus
      runner.launch_zeus("Reload")
      Notifier.notify("Zeus re-started.", :title => "Zeus re-started.", :image => :pending)
    end

    def run_all
      #runner.run_all
    end

    def run_on_changes(paths)
      Notifier.notify("Event #{paths.inspect}...", :title => "Event...", :image => :pending)

      reload
      #runner.kill_zeus
      #runner.launch_zeus("Reload")
      #runner.run(paths)
    end
    # for guard 1.0.x and earlier
    alias :run_on_change :run_on_changes

    def stop
      Notifier.notify("Stopping Zeus...", :title => "Stopping Zeus...", :image => :pending)
      runner.kill_zeus
      Notifier.notify("Zeus stopped.", :title => "Zeus stopped.", :image => :pending)
    end

  end
end
