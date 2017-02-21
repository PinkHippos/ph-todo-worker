act = require "#{__dirname}/../../seneca/act"
_handle_error = require "#{__dirname}/../helpers/_handle_error"

module.exports = (args, done)->
  {todo_id, user_id, status} = args
  if todo_id
    query =
      primary_key: todo_id
  else if todo_id
    query =
      filters: [
        {author: user_id}
      ]
  else if status
    query =
      filters: [
        {status: status}
      ]
  else
    query = 'all'
  get_opts =
    role: 'db'
    cmd: 'read'
    query: query
    model: 'Todo'
  act get_opts
  .then (todos)->
    done null, data: todos
  .catch _handle_error done
