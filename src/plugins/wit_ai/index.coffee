module.exports = (options)->
  plugin = 'wit_ai'
  commands = [
    'message'
    'parse_response'
    'message_and_act'
  ]
  for cmd in commands
    pattern_string = "role:#{plugin},cmd:#{cmd}"
    @add pattern_string, require "#{__dirname}/#{cmd}"
  plugin
