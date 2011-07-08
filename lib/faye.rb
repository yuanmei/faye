require 'forwardable'
require 'set'
require 'eventmachine'
require 'json'

module Faye
  VERSION = '0.6.2'
  
  ROOT = File.expand_path(File.dirname(__FILE__))
  
  BAYEUX_VERSION   = '1.0'
  ID_LENGTH        = 128
  JSONP_CALLBACK   = 'jsonpcallback'
  CONNECTION_TYPES = %w[long-polling callback-polling websocket cross-origin-long-polling tcp in-process]
  
  MANDATORY_CONNECTION_TYPES = %w[long-polling callback-polling tcp in-process]
  
  autoload :FrameParser, File.join(ROOT, 'faye', 'util', 'frame_parser')
  autoload :RackAdapter, File.join(ROOT, 'faye', 'adapters', 'rack_adapter')
  autoload :TcpAdapter,  File.join(ROOT, 'faye', 'adapters', 'tcp_adapter')
  autoload :WebSocket,   File.join(ROOT, 'faye', 'util', 'web_socket')
  
  %w[ mixins/publisher
      mixins/timeouts
      mixins/logging
      util/namespace
      engines/base
      engines/connection
      engines/memory
      engines/redis
      protocol/grammar
      protocol/extensible
      protocol/channel
      protocol/subscription
      protocol/client
      protocol/server
      transport/transport
      transport/local
      transport/http
      transport/tcp
      error
      
  ].each do |lib|
    require File.join(ROOT, 'faye', lib)
  end
  
  def self.random(bitlength = ID_LENGTH)
    limit    = 2 ** bitlength - 1
    max_size = limit.to_s(36).size
    string   = rand(limit).to_s(36)
    string = '0' + string while string.size < max_size
    string
  end
  
  def self.to_json(value)
    case value
      when Hash, Array then JSON.unparse(value)
      when String, NilClass then value.inspect
      else value.to_s
    end
  end
  
  def self.ensure_reactor_running!
    Thread.new { EM.run } unless EM.reactor_running?
    while not EM.reactor_running?; end
  end
end

