# src/plugins/todo/index.coffee
# Todo plugin
# role:todo,cmd:*

module.exports = ->
  plugin = 'todo'
  # Defining all the action patterns for the api
  patterns =
    [
      'add_todo'
        # todo:
        #   title: string
        #   details: [string]
      'get_todos'
        # title: string
        # user_id: string
        # username: string
      'update_todo'
        # id: string
      'delete_todo'
        # id: string
    ]

  for cmd in patterns
    pattern_string = "role:#{plugin},cmd:#{cmd}"
    @add pattern_string, require "#{__dirname}/#{cmd}"
  
  # return the name for logging in seneca
  plugin
