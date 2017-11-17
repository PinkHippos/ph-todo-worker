## role:wit_ai,cmd:parse_wit_response ##
# Calls _parse_raw_data with each of the keys in the raw wit.ai response

## _parse_raw_data ##
# Accepts a raw_data array of objects with confidence and value keys
# Optionally accepts a min_confidence that defaults to .5
# Returns object
# {
#   values: array of all the values above min confidence
#   strongest_value: value with the highest confidence
#   strongest_confidence: highest confidence from the set
#     ^^^^ Use to ask a follow up if its above the given min
#          but still not high enough to act on
# }
_parse_raw_data = (raw_data, min_confidence = .5)->
  values = []
  strongest_data_set =
    confidence: 0
  for data_set, i in raw_data
    {confidence, value} = data_set
    if confidence >= min_confidence
      values.push value
    if confidence > strongest_data_set.confidence
      strongest_data_set = data_set
  strongest_value = strongest_data_set.value
  strongest_confidence = strongest_data_set.confidence
  parsed_data = {values, strongest_value, strongest_confidence}
  parsed_data

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
  base_opts = false
  if cmd and role then base_opts = {cmd, role}
  base_opts

_get_formatted_action = (formatted_opts, parsed_wit_response)->
  primary_intent = parsed_wit_response.intent.strongest_value
  switch primary_intent
    when 'todo:add_todo'
      {reminder} = parsed_wit_response
      formatted_opts.new_todo =
        text: reminder.strongest_value
  formatted_opts

module.exports = (args, done)->
  {raw_wit_response, min_confidence_settings} = args
  if !raw_wit_response
    @act 'role:util,cmd:missing_args', {
      given: @util.clean args
    }, (err, response)->
      done null, err: response.data
  else
    keys = Object.keys raw_wit_response.entities
    parsed_response = {}
    # Check for overall confidence, option set confidence, or default to .51
    base_confidence = process.env.WIT_AI_MIN_CONFIDENCE or .51
    if min_confidence_settings and min_confidence_settings.overall
      base_confidence = min_confidence_settings.overall
    for key in keys
      # Get fresh copy of base_confidence each time
      min_confidence = Number base_confidence
      # Grab the raw data
      raw_data = raw_wit_response.entities[key]
      # Check if theres a specific min confidence set for the key
      if min_confidence_settings and min_confidence_settings.hasOwnProperty key
        min_confidence = min_confidence_settings[key]
      # Set the parsed data on the correlating key on the parsed_data object
      parsed_response[key] = _parse_raw_data raw_data, min_confidence
      # Only try to build action_opts if theres a parsed intent and cmd/role
      if parsed_response.intent
        action_opts = _get_cmd_and_role parsed_response.intent
        if action_opts
          parsed_response.action_opts = _get_formatted_action action_opts, parsed_response
    done null, data: parsed_response
