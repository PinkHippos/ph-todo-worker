act = require "#{__dirname}/../../seneca/act"
_handle_error = require "#{__dirname}/../helpers/_handle_error"

module.exports = (args, done)->
  {new_todo} = args
  if !new_todo
    err_opts =
      role: 'util'
      cmd: 'handle_err'
      type: 'missing_args'
      service: 'todo'
      name: 'add_todo'
      given:
        new_todo: new_todo
    act err_opts
    .then _handle_error done
  else
    add_opts =
      role: 'db'
      cmd: 'create'
      insert: new_todo
      model: 'Todo'
    act add_opts
    .then (todo)->
      done null, data: todo
    .catch _handle_error done
