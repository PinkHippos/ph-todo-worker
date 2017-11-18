# /plugins/wit_ai/message_and_act
# 1 - Accepts a message and min_confidence_settings
# 2 - Call message with the given message
# 3 - Call parse_wit_response with min_confidence_settings and result of message
# 5 - Act on the built actions or return error if none are found

module.exports = (args, done)->
  {text, min_confidence_settings} = args
  if !text
    given = @util.clean args
    @act 'role:util,cmd:missing_args', {given}, (err, response)->
      done null, err: response.data
  else
    message_action = "role:wit_ai,cmd:message"
    @act message_action, {text}, (err, message_response)->
      if err or message_response.err
        done null, err:
          seneca_err: err
          action_err: message_response.err
          message: 'Error while calling ' + message_action
      else
        parse_action = "role:wit_ai,cmd:parse_response"
        raw_wit_response = message_response.data
        @act parse_action, {
          raw_wit_response
          min_confidence_settings
        }, (err, parse_response)->
          if err or parse_response.err
            done null, err:
              seneca_err: err
              action_err: parse_response.err
              message: 'Error while calling ' + parse_action
          else
            parsed_wit_response = parse_response.data
            if parsed_wit_response.action_opts
              @act parsed_wit_response.action_opts, (err, wit_action_response)->
                if err or wit_action_response.err
                  done null, err:
                    seneca_err: err
                    action_err: wit_action_response.err
                    message: 'Error while calling dynamic wit generated action'
                else
                  done null, data: wit_action_response.data
            else
              done null, err:
                message: 'No action options found for the given message'
                status: 400
                parsed_wit_response: parsed_wit_response
