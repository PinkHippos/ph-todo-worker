_wrap_message = require "#{__dirname}/_wrap_message"
module.exports = (args, done)->
  {message, service} = args
  if !service or !message
    errOpts =
      role: 'util'
      cmd: 'handle_err'
      type: 'missing_args'
      given:[
        {name: 'service'
        value: service},
        {name: 'message'
        value: message}
      ]
      message: err.message
      status: err.status
      service: 'util'
    act errOpts
  else
    console.log _wrap_message 'LOG', message, service
    done null, data: 'Success'
