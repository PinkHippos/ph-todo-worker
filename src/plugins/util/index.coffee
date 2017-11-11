# Util Plugin
# role:'util',cmd:*

module.exports = (options)->
  plugin = 'util'
  patterns = [
      'missing_args'
        # name: <calling fn's name>
        # given: [
        #   {
        #     name: <var name>
        #     value: <given value>
        #   }
        # ]
      'handle_err'
        # message: string
        # service: string
        # [err: object]
        # [status: number or string]
      'log'
        # message: string
        # service: string
    ]

  for cmd in patterns
    pattern_string = "role:#{plugin},cmd:#{cmd}"
    @add pattern_string, require "#{__dirname}/#{cmd}"

  # return the name for logging in seneca
  plugin
