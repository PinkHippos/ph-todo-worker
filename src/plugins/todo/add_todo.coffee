act = require "#{__dirname}/../../seneca/act"
_handle_error = require "#{__dirname}/../helpers/handle_error"

module.exports = (args, done)->
  {todo} = args
  if !todo
    err_opts =
      role: 'util'
      cmd: 'missing_args'
      service: 'todo'
      name: 'add_todo'
      given:
        todo: todo
    act err_opts
    .then _handle_error done
  else
    add_opts =
      role: 'db'
      cmd: 'create'
      insert: todo
      model: 'Todo'
    act add_opts
    .catch _handle_error done
    .then (todo)->
      done null, data: todo
