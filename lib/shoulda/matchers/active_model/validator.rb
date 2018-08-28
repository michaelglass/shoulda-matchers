module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class Validator
        include Helpers

        attr_reader :attribute, :context

        def initialize(record, attribute, options = {})
          @record = record
          @attribute = attribute
          @context = options[:context]
          @expects_strict = options[:expects_strict]
          @expected_message = options[:expected_message]

          @validation_result = nil
          @captured_validation_exception = false
        end

        def expects_strict?
          @expects_strict
        end

        def perform_validation
          if context
            record.valid?(context)
          else
            record.valid?
          end

          all_validation_errors = record.errors.dup

          validation_error_messages =
            if record.errors.respond_to?(:[])
              record.errors[attribute]
            else
              record.errors.on(attribute)
            end

          @validation_result = {
            all_validation_errors: all_validation_errors,
            validation_error_messages: validation_error_messages,
            validation_exception_message: nil,
          }
        rescue ::ActiveModel::StrictValidationFailed => exception
          @captured_validation_exception = true
          @validation_result = {
            all_validation_errors: nil,
            validation_error_messages: [],
            validation_exception_message: exception.message,
          }
        end

        # def passes?
          # perform_validation
          # # validation_messages.none?
          # # !validation_messages_match?
          # # require "pry-byebug"; binding.pry
          # !validation_messages_match?
        # end

        # def fails?
          # perform_validation
          # # validation_messages_match?
          # # require "pry-byebug"; binding.pry
          # validation_messages_match?
        # end

        def validation_messages_match?
          validation_message_type_matches? && has_matching_validation_messages?
        end

        def validation_message_type_matches?
          expects_strict? == captured_validation_exception?
        end

        def captured_validation_exception?
          @captured_validation_exception
        end

        def has_matching_validation_messages?
          matched_validation_messages.compact.any?
        end

        def has_validation_messages?
          validation_messages.any?
        end

        def has_any_validation_errors?
          all_validation_errors.any?
        end

        def all_formatted_validation_errors
          format_validation_errors(all_validation_errors)
        end

        def formatted_validation_messages
          format_attribute_specific_validation_errors(validation_messages)
        end

        def validation_exception_message
          validation_result[:validation_exception_message]
        end

        def pretty_print(pp)
          Shoulda::Matchers::Util.pretty_print(self, pp, {
            record: record,
            attribute: attribute,
            context: context,
            expects_strict: expects_strict?,
            expected_message: expected_message,
            validation_result: validation_result,
            matched_validation_messages: matched_validation_messages,
          })
        end

        protected

        attr_reader :record, :expected_message, :validation_result

        private

        def validation_messages
          if expects_strict?
            [validation_exception_message]
          else
            validation_error_messages
          end
        end

        def matched_validation_messages
          if expected_message
            validation_messages.grep(expected_message)
          else
            validation_messages
          end
        end

        def all_validation_errors
          if validation_result
            validation_result[:all_validation_errors]
          else
            []
          end
        end

        def validation_error_messages
          if validation_result
            validation_result[:validation_error_messages]
          else
            []
          end
        end
      end
    end
  end
end
