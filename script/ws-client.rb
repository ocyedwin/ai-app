require 'faye/websocket'
require 'eventmachine'

EM.run {
  ws = Faye::WebSocket::Client.new('ws://127.0.0.1:6789')

  ws.on :open do |event|
    p [:open]
    ws.send('{"video_path": "storage/2x/3b/2x3bz9om18gjbr1gklei7rb1rbbj", "question": "What is this video about?"}')
  end

  ws.on :message do |event|
    p [:message, event.data]
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}