module.exports = (options)->
  plugin = 'wit_ai'
  commands = [
    'message'
    'parse_response'
  ]
  for cmd in commands
    pattern_string = "role:#{plugin},cmd:#{cmd}"
    @add pattern_string, require "#{__dirname}/#{cmd}"
  plugin