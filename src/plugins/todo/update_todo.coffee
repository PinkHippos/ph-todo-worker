act = require "#{__dirname}/../../seneca/act"
_handle_error = require "#{__dirname}/../helpers/handle_error"

module.exports = (args, done)->
  {id, updates} = args
  if !id or !updates
    err_opts =
      role: 'util'
      cmd: 'missing_args'
      service: 'todo'
      name: 'update_todo'
      given:
        id: id
        updates: updates
    act err_opts
    .then _handle_error done
  else
    add_opts =
      role: 'db'
      cmd: 'update'
      query:
        primary_key: id
      changes: updates
      model: 'Todo'
    act add_opts
    .catch _handle_error done
    .then (updated_todo)->
      done null, data: updated_todo
