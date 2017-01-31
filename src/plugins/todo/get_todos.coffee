act = require "#{__dirname}/../../seneca/act"
_handle_error = require "#{__dirname}/../helpers/_handle_error"

module.exports = (args, done)->
  {todo_id, user_id} = args
  if !todo_id and !user_id
    err_opts =
      role: 'util'
      cmd: 'missing_args'
      service: 'todo'
      name: 'get_todos'
      given:
        user_id: user_id
        todo_id: todo_id
    act err_opts
    .then _handle_error done
  else
    if todo_id
      query =
        primary_key: todo_id
    else if todo_id
      query =
        filters: [
          {author: user_id}
        ]
    add_opts =
      role: 'db'
      cmd: 'read'
      query: query
      insert: todo
      model: 'Todo'
    act add_opts
    .catch _handle_error done
    .then (todos)->
      done null, data: todos
