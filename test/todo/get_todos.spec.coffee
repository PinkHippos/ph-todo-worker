{expect} = require 'chai'
seneca = require 'seneca'

plugin_in_test = require "#{__dirname}/../../src/plugins/todo"


_action_opts =
  role: 'todo'
  cmd: 'get_todos'
  todo_id: 'foo'
  status: 'bar'

_outside_action_args = {}

_fresh_instance = ()->
  fresh_instance = seneca log: 'test'
    .add 'role:util,cmd:handle_err,type:missing_args', (msg, reply)->
      msg.given = @util.clean msg.given
      _outside_action_args['util-missing_args'] = @util.clean msg
      reply null, data:{}
    .add 'role:db,cmd:read', (msg, reply)->
      _outside_action_args['db-read'] = @util.clean msg
      reply null, data: [
        id: 'foo'
        text: 'baz'
      ]

    .use plugin_in_test
  fresh_instance

describe '|--- cmd: TODO sub_cmd: GET_TODOS ---|', ->
  describe 'bootstrapping', ->
    bootstrapped_instance = null
    before 'read instance and save when ready', (done)->
      test_instance = _fresh_instance()
        .test done
        .ready ->
          bootstrapped_instance = test_instance
          done()
    it 'registers the pattern role:todo,cmd:get_todos', ->
      pattern_exists = bootstrapped_instance.has 'role:todo,cmd:get_todos'
      expect(pattern_exists).to.equal true
  describe 'handling action args without todo_id or status', ->
    action_opts = Object.assign {}, _action_opts, {
      status: null
      todo_id: null
    }
    action_response = null
    before 'start fresh instance, send action, and save response', (done)->
      _fresh_instance()
      .test done
      .ready ->
        @act action_opts, (err, response)->
          action_response = response
          done err
    it 'formats a query for the db plugin', ->
      expect(_outside_action_args['db-read']).to.include.keys [
        'query'
        'model'
      ]
    it 'sets the query to all', ->
      expect(_outside_action_args['db-read'].query).to.equal 'all'
  describe 'responding to succesful calls', ->
    action_response = null
    before 'start fresh instance, send action, and save response', (done)->
      _fresh_instance()
      .test done
      .ready ->
        @act _action_opts, (err, response)->
          action_response = response
          done err
    it 'sends back an object with a data key', ->
      expect(action_response).to.include.keys 'data'
    it 'sends back the todo(s) as the data key', ->
      expect(action_response.data).to.deep.equal [{
        id: 'foo'
        text: 'baz'
      }]
  describe 'handling specific action args', ->
    only_id = Object.assign {}, _action_opts, {
      status: null
    }
    only_status = Object.assign {}, _action_opts, {
      id: null
    }
    specific_args_tests = {only_id, only_status}
    Object.keys(specific_args_tests).forEach (test_name)->
      describe test_name, ->
        action_response = null
        _local_outside_action_args = {}
        before 'send action and save response', (done)->
          _fresh_instance()
          .test done
          .ready ->
            @act specific_args_tests[test_name], (err, response)->
              action_response = response
              _local_outside_action_args = Object.assign {}, _outside_action_args
              done err
        describe 'calling the db plugin', ->
          it 'calls the db plugin', ->
            expect(_local_outside_action_args).to.include.keys 'db-read'
          it 'passes all the required keys', ->
            expect(_local_outside_action_args['db-read']).to.include.keys [
              'model'
              'query'
            ]
          it "specifies the 'Todo' model", ->
            expect(_local_outside_action_args['db-read'].model).to.equal 'Todo'
          it "passes a proper query as the 'query' key", ->
            if specific_args_tests[test_name].todo_id
              expect(_local_outside_action_args['db-read'].query).to.include.keys [
                'primary_key'
              ]
            else
              expect(_local_outside_action_args['db-read'].query).to.include.keys [
                'filters'
              ]
