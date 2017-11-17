{expect} = require 'chai'
seneca = require 'seneca'
env = require('dotenv').config({path: "#{__dirname}/../../secrets.env"})
plugin_in_test = require "#{__dirname}/../../src/plugins/wit_ai/"

_outside_action_args = {}

_default_options_test =
  message: 'default test message'

_with_overall_confidence =
  message: 'with some confidence message'
  min_confidence_settings:
    overall: .75

_with_specific_confidence =
  message: 'I have specific confidence settings'
  min_confidence_settings:
    intent: .6

_count_todo_test =
  parsed_wit_response:
    intent:
      strongest_value: 'todo:count'
      strongest_confidence: .3
      values: ['todo:count']
  expected:
    role: 'todo'
    cmd: 'count'

_test_sets = [
  _default_options_test
  _add_todo_test
  _get_weather_test
  _count_todo_test
]
_outside_action_args = {}

_action_opts =
  role: 'wit_ai'
  cmd: 'build_action_opts'
  parsed_wit_response: _default_options_test.parsed_wit_response

_fresh_instance = ()->
  fresh_instance = seneca log: 'test'
    .add 'role:util,cmd:missing_args', (msg, reply)->
      msg.given = @util.clean msg.given
      _outside_action_args['util-missing_args'] = @util.clean msg
      reply null, data:{}
    .use plugin_in_test
  fresh_instance

describe '|--- role: WIT_AI cmd: BUILD_ACTION_OPTS ---|', ->
  describe 'bootstrapping', ->
    bootstrapped_instance = null
    before 'create instance and save when ready', (done)->
      test_instance = _fresh_instance()
        .test done
        .ready ->
          bootstrapped_instance = test_instance
          done()
    it 'registers the pattern role:wit_ai,cmd:build_action_opts', ->
      pattern_exists = bootstrapped_instance.has 'role:wit_ai,cmd:build_action_opts'
      expect(pattern_exists).to.equal true
  describe 'handling action args without parsed_wit_response', ->
    bad_action_opts = Object.assign {}, _action_opts, parsed_wit_response: null
    action_response = null
    before 'start fresh instance, send bad action, and save response', (done)->
      _fresh_instance()
      .test done
      .ready ->
        @act bad_action_opts, (err, response)->
          action_response = response
          done()
    it 'sends back an error', ->
      expect(action_response).to.include.keys 'err'
    it 'calls the error handler', ->
      expect(_outside_action_args).to.include.keys 'util-missing_args'
    it "passes its arguments to the err handler as the 'given' key", ->
      handler_opts = _outside_action_args['util-missing_args']
      expect(handler_opts.given).to.deep.equal bad_action_opts

  describe 'handling correct action args', ->
    _test_sets.forEach (test_set)->
      {parsed_wit_response, expected} = test_set
      action_response = null
      before 'send action and save response', (done)->
        _fresh_instance()
        .test done
        .ready ->
          @act 'role:wit_ai,cmd:build_action_opts', {
              parsed_wit_response
          }, (err, response)->
            action_response = response
            done()
      it 'returns a data object', ->
        expect(action_response).to.include.keys 'data'
        expect(action_response.data).to.be.an 'object'
      it 'formats the data object with cmd and role', ->
        expect(action_response.data).to.include.keys [
          'cmd'
          'role'
        ]
      it "sets role to #{expected.role}", ->
        expect(action_response.data.role).to.equal expected.role
      it "sets cmd to #{expected.cmd}", ->
        expect(action_response.data.cmd).to.equal expected.cmd
      it 'formats the rest of the keys as expected', ->
        expect(action_response.data).to.eql expected
