_wrap_message = require "#{__dirname}/_wrap_message"
_wrap_and_log = (name, given, service)->
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
  message
module.exports = (args, done)->
  {name, given, service} = args
  if !name or !given or !service
    given = {name, given, service}
    name = 'missing_args'
    service = 'util'
    message = _wrap_and_log name, given, service
    done null, err: {
        status: 400
        message
    }
  else
    message = _wrap_and_log name, given, service
    done null, data:
      message: message
      status: 400
