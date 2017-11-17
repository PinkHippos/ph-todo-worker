module.exports = (args, done)->
  {parsed_wit_response} = args
  if !parsed_wit_response
    given = @util.clean args
    @act 'role:util,cmd:missing_args', {given}, (err, response)->
      done null, err: response.data
