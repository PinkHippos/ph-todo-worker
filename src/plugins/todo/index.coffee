# Todo plugin
# role:todo,cmd:*
module.exports = ->
  # Defining all the action patterns for the api
  patterns =
    add_todo:
      cmd: 'add_todo'
      # todo:
      #   title: string
      #   details: [string]
    get_todos:
      cmd: 'get_todos'
      # title: string
      # user_id: string
      # username: string
    update_todo:
      cmd: 'update_todo'
      # id: string
    delete_todo:
      cmd: 'delete_todo'
      # id: string

  # Looping over the patterns to add the role key
  for key of patterns
    patterns[key].role = 'todo'

  # Adding all of the plugin's functions
  @add patterns.add_todo, require "#{__dirname}/add_todo"
  @add patterns.get_todos, require "#{__dirname}/get_todos"
  @add patterns.update_todo, require "#{__dirname}/update_todo"
  @add patterns.delete_todo, require "#{__dirname}/delete_todo"

  # return the name for logging in seneca
  'todo'
