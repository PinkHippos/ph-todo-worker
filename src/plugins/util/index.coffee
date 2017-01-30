# Util Plugin
act = require '../seneca_config/act'

module.exports = (options)->
  patterns =
    missing_args:
      cmd: 'handle_err'
      type: 'missing_args'
      # name: <calling fn's name>
      # given: [
      #   {
      #     name: <var name>
      #     value: <given value>
      #   }
      # ]
    general:
      cmd: 'handle_err'
      type: 'general'
      # message: string
      # service: string
      # [err: object]
      # [status: number or string]
    log:
      cmd: 'log'
      type: 'general'
      # message: string
      # service: string

  for pattern, val of patterns
    patterns[pattern].role = 'util'

  @add patterns.general, require "#{__dirname}/general_error"
  @add patterns.missing_args, require "#{__dirname}/missing_args"
  @add patterns.log, require "#{__dirname}/general_log"
