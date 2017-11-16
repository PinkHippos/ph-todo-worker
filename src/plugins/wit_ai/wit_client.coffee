{WIT_AI_ACCESS_TOKEN} = process.env
{Wit, log} = require 'node-wit'

client = new Wit {
  accessToken: WIT_AI_ACCESS_TOKEN
  logger: new log.Logger log.DEBUG
}

module.exports = client
