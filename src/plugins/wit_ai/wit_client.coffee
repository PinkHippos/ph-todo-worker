{Wit, log} = require 'node-wit'

{WIT_AI_ACCESS_TOKEN, WIT_AI_LOG_LEVEL} = process.env
if !WIT_AI_LOG_LEVEL then WIT_AI_LOG_LEVEL = 'DEBUG'

client = new Wit {
  accessToken: WIT_AI_ACCESS_TOKEN
  logger: new log.Logger log[WIT_AI_LOG_LEVEL]
}

module.exports = client
