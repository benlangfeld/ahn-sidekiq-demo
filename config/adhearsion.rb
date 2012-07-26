# encoding: utf-8

Adhearsion.config do |config|

  config.development do |dev|
    dev.platform.logging.level = :trace
  end

  ##
  # Use with Rayo (eg Voxeo PRISM)
  #
  config.punchblock.username = "usera@blmbp.local" # Your XMPP JID for use with Rayo
  # config.punchblock.password = "" # Your XMPP password
end

Adhearsion.router do
  route 'foo' do
    logger.info Foo.new
  end
end
