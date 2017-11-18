{expect} = require 'chai'
seneca = require 'seneca'
env = require('dotenv').config({path: "#{__dirname}/../../secrets.env"})
plugin_in_test = require "#{__dirname}/../../src/plugins/wit_ai/"

_outside_action_args = {}


_default_options_test =
  text: 'default test message'

_with_some_intent =
  text: 'with some intent'

_with_some_confidence =
  text: 'something with confidence'
  min_confidence_settings:
    overall: .75


_test_sets = {
  _default_options_test
  _with_some_intent
  _with_some_confidence
}
_outside_action_args = {}
# set responses for easy changing later
_mock_plugin_responses =
  missing_args: {}
  message:
    raw_wit_response:
      msg_id: 'SOME_WIT_AI_ID_1'
      # _text: ADDED BASED ON INPUT TEXT
      entities:
        foo:[
          {
            value: 'bar'
            confidence: .65
          }
        ]
        intent: [
          {
            value: 'bat'
            confidence: .95
          }
          {
            value: 'zap'
            confidence: .80
          }
        ]
  parse_response:
    foo:
      strongest_value: 'bar'
      strongest_confidence: .65
      values: ['bar']
    intent:
      strongest_value: 'bat'
      strongest_confidence: .95
      values: ['bat', 'zap']
  test_action:
    message: 'Hey you called the test action!'
    status: 200

_mock_plugin = (options)->
  @add 'role:util,cmd:missing_args', (msg, reply)->
    msg.given = @util.clean msg.given
    _outside_action_args['missing_args'] = @util.clean msg
    reply null, data: _mock_plugin_responses['missing_args']
  @add 'role:wit_ai,cmd:message', (args, done)->
    _outside_action_args['message'] = @util.clean args
    formatted_response = _mock_plugin_responses['message']
    formatted_response._text = args.text
    done null, data: formatted_response
  @add 'role:wit_ai,cmd:parse_response', (args, done)->
    _outside_action_args['parse_response'] = @util.clean args
    formatted_response = Object.assign {}, _mock_plugin_responses['parse_response']
    if args.raw_wit_response._text is _with_some_intent.text
      formatted_response.action_opts =
        role: 'wit_test'
        cmd: 'test_action'
    done null, data:  formatted_response
  @add 'role:wit_test,cmd:test_action', (args, done)->
    _outside_action_args['test_action'] = @util.clean args
    done null, data: _mock_plugin_responses['test_action']

_action_opts =
  role: 'wit_ai'
  cmd: 'message_and_act'
  text: _default_options_test.message

_fresh_instance = ()->
  fresh_instance = seneca log: 'test'
    .use plugin_in_test
    .use _mock_plugin
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
  describe 'handling action args without text key', ->
    bad_action_opts = Object.assign {}, _action_opts, text: null
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
      expect(_outside_action_args).to.include.keys 'missing_args'
    it "passes its arguments to the err handler as the 'given' key", ->
      handler_opts = _outside_action_args['missing_args']
      expect(handler_opts.given).to.deep.equal bad_action_opts

  describe 'handling correct action args', ->
    # Expect mock plugin actions to be called & the return to be used correctly
    Object.keys(_test_sets).forEach (test_name)->
      describe test_name, ->
        {text, min_confidence_settings} = _test_sets[test_name]
        action_response = null
        before 'send action and save response', (done)->
          _outside_action_args = {}
          _fresh_instance()
          .test done
          .ready ->
            @act 'role:wit_ai,cmd:message_and_act', {
                text
                min_confidence_settings
            }, (err, response)->
              action_response = response
              done()
        describe 'when calling message action', ->
          it 'calls the message action', ->
            expect _outside_action_args
              .to.include.keys 'message'
          it 'passes a text key', ->
            expect _outside_action_args['message']
              .to.include.keys [
                'text'
              ]
          it 'passes the correct message', ->
            expect _outside_action_args['message'].text
              .to.equal text
        describe 'when calling parse_response', ->
          it 'calls the parse_response action', ->
            expect _outside_action_args
              .to.include.keys 'parse_response'
          it 'passes a raw_wit_response', ->
            expect _outside_action_args['parse_response']
              .to.include.keys 'raw_wit_response'
          it 'passes the raw data from message action as raw_wit_response', ->
            expect _outside_action_args['parse_response'].raw_wit_response
              .to.equal _mock_plugin_responses['message']
          if min_confidence_settings
            it 'passes a min_confidence_settings', ->
              expect _outside_action_args['parse_response']
                .to.include.keys [
                  'min_confidence_settings'
                ]
            it 'passes the correct min_confidence_settings', ->
              expect _outside_action_args['parse_response'].min_confidence_settings
                .to.equal min_confidence_settings
