require 'sidekiq'
require 'sidekiq/util'
require 'sidekiq/manager'
require 'sidekiq/scheduled'

class AhnSidekiq::Plugin < Adhearsion::Plugin
  config :ahn_sidekiq do
    queues nil, desc: "Queue to process, with optional weight", transform: Proc.new { |v|
      q, weight = v.split ","
      AhnSidekiq::Plugin.parse_queues q, weight
    }

    environment nil, desc: "Application environment"

    timeout 0, desc: "Shutdown timeout"

    concurrency nil, desc: "processor threads to use"
  end

  init :ahn_sidekiq do
    Queue.new AhnSidekiq::Plugin.config.to_hash
  end

  def self.parse_queues(q, weight)
    [].tap do |queues|
      (weight || 1).to_i.times do
       queues << q
      end
    end
  end

  class Queue
    def initialize(options)
      Adhearsion::Events.shutdown { stop }
      Adhearsion::Events.after_initialized { run }
      @options = options
      @manager = Sidekiq::Manager.new @options
      @poller = Sidekiq::Scheduled::Poller.new
    end

    def run
      @manager.start!
      @poller.poll! true
    end

    def stop
      @poller.terminate! if @poller.alive?
      @manager.stop! shutdown: true, timeout: @options[:timeout]
      @manager.wait :shutdown
    end
  end
end
