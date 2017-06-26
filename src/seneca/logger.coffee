Logstash = require 'logstash-client'
Logger = ->
Logger.preload = ()->
  options = @options()
  logger = new Logstash options['logstash-logger']
  return extend: logger: (context, payload)->
    # console.log 'PAYLOAD', payload
    formatted_log =
      message:
        pattern: payload.pattern
        log_info:
          level: payload.level
          case: payload.case
        action_info:
          id: payload.actid
          result: payload.result
          action_args: context.util.clean payload.msg
    logger.send formatted_log
module.exports = Logger
