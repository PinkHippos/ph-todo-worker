module.exports = (args, done)->
  {id, changes} = args
  if !id or !changes
    err_opts =
      role: 'util'
      cmd: 'missing_args'
      service: 'todo'
      name: 'update_todo'
      given: @util.clean args
    @act err_opts, (err, response)->
      done null, err: response.data
  else
    add_opts =
      role: 'db'
      cmd: 'update'
      query:
        primary_key: id
      changes: changes
      model: 'Todo'
    @act add_opts, (err, response)->
      if err or response.err
        done null, err:
          seneca_err: err
          action_err: response.err
      else
        done null, data: response.data
