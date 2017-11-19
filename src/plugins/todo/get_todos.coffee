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
  @act get_opts, (err, response)->
    if err or response.err
      done null, err:
        seneca_err: err
        action_err: response.err
        message: 'Could not read todos'
    else
      done null, data: response.data
