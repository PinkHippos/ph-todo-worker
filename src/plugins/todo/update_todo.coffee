act = require "#{__dirname}/../../seneca/act"
_handle_error = require "#{__dirname}/../helpers/_handle_error"

module.exports = (args, done)->
  {id, changes} = args
  if !id or !changes
    err_opts =
      role: 'util'
      cmd: 'missing_args'
      service: 'todo'
      name: 'update_todo'
      given:
        id: id
        changes: changes
    act err_opts
    .then _handle_error done
  else
    add_opts =
      role: 'db'
      cmd: 'update'
      query:
        primary_key: id
      changes: changes
      model: 'Todo'
    act add_opts
    .catch _handle_error done
    .then (updated_todo)->
      done null, data: updated_todo
