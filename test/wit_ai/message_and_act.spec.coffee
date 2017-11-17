{expect} = require 'chai'
seneca = require 'seneca'
env = require('dotenv').config({path: "#{__dirname}/../../secrets.env"})
plugin_in_test = require "#{__dirname}/../../src/plugins/wit_ai/"

_outside_action_args = {}

_default_options_test =
  message: 'default test message'

_with_overall_confidence =
  message: 'overall confidence message'
  min_confidence_settings:
    overall: .75

_with_specific_confidence =
  message: 'specific confidence message'
  min_confidence_settings:
    intent: .6


_test_sets = [
  _default_options_test
  _with_overall_confidence
  _with_specific_confidence
]
_outside_action_args = {}

_mock_plugin = (options)->
  @add 'role:util,cmd:missing_args', (msg, reply)->
    msg.given = @util.clean msg.given
    _outside_action_args['util-missing_args'] = @util.clean msg
    reply null, data:{}
  @add 'role:wit_ai,cmd:message', (args, done)->
    _outside_action_args['wit_ai-message'] = @util.clean args
  @add 'role:wit_ai,cmd:parse_response', (args, done)->
    _outside_action_args['wit_ai-parse_response'] = @util.clean args

_action_opts =
  role: 'wit_ai'
  cmd: 'message_and_act'
  message: _default_options_test.message

_fresh_instance = ()->
  fresh_instance = seneca log: 'test'
    .use _mock_plugin
    .use plugin_in_test
  fresh_instance

describe '|--- role: WIT_AI cmd: MESSAGE_AND_ACT ---|', ->
  describe 'bootstrapping', ->
    bootstrapped_instance = null
    before 'create instance and save when ready', (done)->
      test_instance = _fresh_instance()
        .test done
        .ready ->
          bootstrapped_instance = test_instance
          done()
    it 'registers the pattern role:wit_ai,cmd:message_and_act', ->
      pattern_exists = bootstrapped_instance.has 'role:wit_ai,cmd:message_and_act'
      expect(pattern_exists).to.equal true
  describe 'handling action args without message', ->
    bad_action_opts = Object.assign {}, _action_opts, message: null
    action_response = null
    before 'start fresh instance, send bad action, and save response', (done)->
      _outside_action_args = {}
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

  # describe 'handling correct action args', ->
  #   _test_sets.forEach (test_set)->
  #     {message, min_confidence_settings, expected} = test_set
  #     action_response = null
  #     before 'send action and save response', (done)->
  #       _fresh_instance()
  #       .test done
  #       .ready ->
  #         @act 'role:wit_ai,cmd:message_and_act', {
  #             message
  #             min_confidence_settings
  #         }, (err, response)->
  #           action_response = response
  #           done()
