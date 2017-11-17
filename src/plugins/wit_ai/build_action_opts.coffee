# /plugins/wit_ai/build_action_opts
# Builds actions options using parsed wit response
# Uses switch case to format action options based on cmd and role
# Eventually will take min confidence for automatic escalation or clarification

###
  _get_cmd_and_role
  1 - Takes a parsed intent object with key strongest_value
  2 - Splits value on colon ':'
  3 - Assumes role is first and cmd is second in array
  4 - Returns object with cmd and role keys
###
_get_cmd_and_role = (intent)->
  {strongest_value} = intent
  _action_arr = strongest_value.split ':'
  role = _action_arr[0]
  cmd = _action_arr[1]
  {cmd, role}

module.exports = (args, done)->
  {parsed_wit_response} = args
  if !parsed_wit_response
    given = @util.clean args
    @act 'role:util,cmd:missing_args', {given}, (err, response)->
      done null, err: response.data
  else
    primary_intent = parsed_wit_response.intent.strongest_value
    formatted_opts = _get_cmd_and_role parsed_wit_response.intent
    switch primary_intent
      when 'todo:add_todo'
        {reminder} = parsed_wit_response
        formatted_opts.new_todo =
          text: reminder.strongest_value
    done null, data: formatted_opts
