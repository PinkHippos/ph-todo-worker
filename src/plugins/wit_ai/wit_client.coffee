{Wit, log} = require 'node-wit'

{WIT_AI_ACCESS_TOKEN, WIT_AI_LOG_LEVEL} = process.env
logger = null
if WIT_AI_LOG_LEVEL then logger = new log.Logger log[WIT_AI_LOG_LEVEL]

client = new Wit {
  accessToken: WIT_AI_ACCESS_TOKEN
  logger: logger
}

module.exports = client
