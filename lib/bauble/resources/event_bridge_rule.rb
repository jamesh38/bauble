# frozen_string_literal: true

require_relative 'resource'

module Bauble
  module Resources
    # EventBridgeRule class
    class EventBridgeRule < Resource
      def initialize(app, rule_name:, **kwargs)
        super(app)
        @rule_name = rule_name
        @description = kwargs.fetch(:description, 'Bauble EventBridge Rule')
        @event_pattern = kwargs.fetch(:event_pattern, nil)
        @schedule_expression = kwargs.fetch(:schedule_expression, nil)
        @state = kwargs.fetch(:state, 'ENABLED')
        @event_bus_name = kwargs.fetch(:event_bus_name, 'default')
        @targets = []

        validate_inputs
      end

      def synthesize
        event_rule_hash = {
          @rule_name => {
            'type' => 'aws:cloudwatch:EventRule',
            'properties' => {
              'name' => @rule_name,
              'description' => @description,
              'eventBusName' => @event_bus_name,
              'state' => @state
            }
          }
        }

        event_rule_hash[@rule_name]['properties']['eventPattern'] = @event_pattern.to_json if @event_pattern
        event_rule_hash[@rule_name]['properties']['scheduleExpression'] = @schedule_expression if @schedule_expression

        @targets.each do |target|
          event_rule_hash.merge!(target)
        end

        event_rule_hash
      end

      def bundle
        true
      end

      def add_target(function)
        @targets << {
          "#{@rule_name}-#{function.name}-target" => {
            'type' => 'aws:cloudwatch:EventTarget',
            'properties' => {
              'rule' => "${#{@rule_name}.name}",
              'arn' => "${#{function.name}.arn}"
            }
          },
          "#{function.name}-permission" => {
            'type' => 'aws:lambda:Permission',
            'properties' => {
              'action' => 'lambda:InvokeFunction',
              'function' => "${#{function.name}.name}",
              'principal' => 'events.amazonaws.com',
              'sourceArn' => "${#{@rule_name}.arn}"
            }
          }
        }
      end

      private

      def validate_inputs
        name_present?
        pattern_or_schedule?
        pattern_and_schedule?
      end

      def pattern_or_schedule?
        return if @event_pattern || @schedule_expression

        raise 'EventBridgeRule must have an event_pattern or a schedule_expression'
      end

      def pattern_and_schedule?
        return unless @event_pattern && @schedule_expression

        raise 'EventBridgeRule cannot have both an event_pattern and a schedule_expression'
      end

      def name_present?
        return if @rule_name

        raise 'EventBridgeRule must have a rule_name'
      end
    end
  end
end
