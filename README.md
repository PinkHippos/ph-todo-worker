# Pink Hippos Worker v0.4.0

## Plugins
### `role:util`
cmd | Required Keys | Optional Keys
:---: | :---: | :---:
`log` | `message`, `service` | *none*
`missing_args` | `given` | `name`, `service`
`handle_err` | `message`, `service`| `err`, `status`

### `role:todo`
cmd | Required Keys | Optional Keys
:---: | :---: | :---:
`add_todo` | `new_todo` | *none*
`get_todos` | *none* | `todo_id`, `status`
`update_todo` | `id`, `changes` | *none*
`delete_todo` | `id` | *none*

### `role:wit_ai`
cmd | Required Keys | Optional Keys
:---: | :---: | :---:
`message` | `text` | `context`
`parse_response` | `raw_wit_response` | `min_confidence_settings`
`message_and_act` | `text` | `min_confidence_settings`

### `role:pusher`
cmd | Required Keys | Optional Keys
:---: | :---: | :---:
`trigger_event` | `event_name`, `channel`, `data` | *none*
