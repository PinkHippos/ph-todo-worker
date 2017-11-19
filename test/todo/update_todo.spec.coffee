{expect} = require 'chai'
seneca = require 'seneca'

plugin_in_test = require "#{__dirname}/../../src/plugins/todo"


_action_opts =
  role: 'todo'
  cmd: 'update_todo'
  id: 'SOME_TODO_ID'
  changes:
    status: 'complete'

_outside_action_args = {}

_fresh_instance = ()->
  fresh_instance = seneca log: 'test'
    .add 'role:util,cmd:missing_args', (msg, reply)->
      _outside_action_args['util-missing_args'] = @util.clean msg
      reply null, data: {}
    .add 'role:db,cmd:update', (msg, reply)->
      _outside_action_args['db-update'] = @util.clean msg
      reply null, data: {}
    .use plugin_in_test
  fresh_instance

describe '|--- role:TODO cmd: UPDATE_TODO ---|', ->
  describe 'bootstrapping', ->
    bootstrapped_instance = null
    before 'delete instance and save when ready', (done)->
      test_instance = _fresh_instance()
        .test done
        .ready ->
          bootstrapped_instance = test_instance
          done()
    it 'registers the pattern role:todo,cmd:update_todo', ->
      pattern_exists = bootstrapped_instance.has 'role:todo,cmd:update_todo'
      expect(pattern_exists).to.equal true
  describe "handling bad action args", ->
    no_id_opts = Object.assign {}, _action_opts, id: null
    no_changes_opts = Object.assign {}, _action_opts, changes: null
    bad_args_tests = {
      no_id_opts
      no_changes_opts
    }
    Object.keys(bad_args_tests).forEach (test_name)->
      describe test_name, ->
        action_response = null
        _local_outside_action_args = null
        before 'start fresh instance, send bad action, and save response', (done)->
          _outside_action_args = {}
          _fresh_instance()
          .test done
          .ready ->
            @act bad_args_tests[test_name], (err, response)->
              action_response = response
              _local_outside_action_args = Object.assign {}, _outside_action_args
              done err
        it 'sends back an error', ->
          expect(action_response).to.include.keys 'err'
        it 'calls the error handler', ->
          expect(_local_outside_action_args).to.include.keys 'util-missing_args'
        it "passes its arguments to the err handler as the 'given' key", ->
          expect(_local_outside_action_args['util-missing_args'].given)
            .to.deep.equal bad_args_tests[test_name]

  describe 'handling correct action args', ->
    action_response = null
    before 'send action and save response', (done)->
      _fresh_instance()
      .test done
      .ready ->
        @act _action_opts, (err, response)->
          action_response = response
          done err
    describe 'responding to succesful calls', ->
      it 'sends back an object with a data key', ->
        expect(action_response).to.include.keys 'data'
    describe 'calling the db plugin', ->
      it 'calls the db plugin', ->
        expect(_outside_action_args).to.include.keys 'db-update'
      it 'passes all the required keys', ->
        expect(_outside_action_args['db-update']).to.include.keys [
          'model'
          'query'
          'changes'
        ]
      it "specifies the 'Todo' model", ->
        expect(_outside_action_args['db-update'].model).to.equal 'Todo'
      it "passes the id as the 'query.primary_key' key", ->
        expect(_outside_action_args['db-update'].query.primary_key)
          .to.deep.equal _action_opts.id
