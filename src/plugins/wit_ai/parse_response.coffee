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
    for key in keys
      raw_data = raw_wit_response.entities[key]
      if min_confidence_settings
        min_confidence = min_confidence_settings[key]
      else
        min_confidence = undefined
      parsed_response["parsed_#{key}"] = _parse_raw_data raw_data, min_confidence
    done null, data: parsed_response
