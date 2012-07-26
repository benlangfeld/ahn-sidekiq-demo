class OutboundCaller
  include Sidekiq::Worker

  def perform(*args)
    p args
  end
end
