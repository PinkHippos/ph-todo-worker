# /plugins/wit_ai/message_and_act
# 1 - Accepts a message and min_confidence_settings
# 2 - Call message with the given message
# 3 - Call parse_wit_response with min_confidence_settings and result of message
# 4 - Call build_action_opts with the parsed_wit_response
# 5 - Act on the built actions or return error if none are found
