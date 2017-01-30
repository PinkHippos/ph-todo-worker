_wrap_message = require "#{__dirname}/_wrap_message"
module.exports = (args, done)->
  {message, err, service, status} = args
  if status
    message = """
    #{message}\n
    -- Status --
    #{status}\n
    """
  if err
    # TODO add logic to print error better
    # or just print err message
    message = """
    #{message}
    -- Error Object --
    #{JSON.stringify err}
    """
  message = _wrap_message 'ERROR', message, service
  console.log message
  done null, data: 'Error logged.'
