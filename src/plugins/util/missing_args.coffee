_wrap_message = require "#{__dirname}/_wrap_message"
module.exports = (args, done)->
  {name, given, service} = args
  base = """
  Missing Argument Error
  -- Service: #{service}
  -- Function: #{name}
  """
  builtMessage = base
  for arg, value of given
    builtMessage = """#{builtMessage}\n
    - Argument Set -
    Argument Name --> #{arg}
    Given Value --> #{value}
    -----------------"""
  message = _wrap_message 'Error', builtMessage, service
  console.log message
  done null, data:
    message: message
    status: 400
