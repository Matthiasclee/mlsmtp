module SMTPServer
  module Queue
    class QueueWorker
      @@all_workers = []
      @@running_workers = []

      def initialize(mod:, eq:)
        @mod = mod
        @eq = eq

        @running = false
        @dead = false
        @pid = nil
      end

      def start
        return false if @dead
        return true if @running

        @running = true
        @@running_workers << self

        @pid = fork do
          Database.connect
          handler = QueueHandler.new(mod: @mod, eq: @eq)
          handler.run
        end

        return @pid
      end

      def restart
        stop
        sleep(Config.active["queue"]["workers"]["restart_delay"])
        start
      end

      def stop(killcode: "TERM")
        Process.kill(killcode, @pid)
        @running = false
        @@running_workers.delete(self)
      end

      def kill
        stop
        @dead = true
        @@all_workers.delete(self)
      end

      def self.all_workers
        @@all_workers
      end

      def self.running_workers
        @@running_workers
      end

      attr_reader :mod, :eq, :running, :dead, :pid
    end
  end
end
