wit_client = require "#{__dirname}/wit_client"
module.exports = (args, done)->
  {text, context} = args
  if !text
    err_opts =
      role: 'util'
      cmd: 'missing_args'
      given: @util.clean args
    @act err_opts, (err, response)->
      done null, err: response.data
  else
    wit_client
      .message text, context
      .then (wit_response)->
        # console.log 'WIT RESPONSE', wit_response
        done null, data: wit_response
      .catch (err)->
        done null, err:
          message: 'Error with wit_client.message'
          err: err
