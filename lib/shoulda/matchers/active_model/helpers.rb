module Shoulda
  module Matchers
    module ActiveModel
      # @private
      module Helpers
        def pretty_error_messages(object)
          format_validation_errors(object.errors)
        end

        def format_validation_errors(errors)
          list_items = errors.keys.map do |attribute|
            messages = errors[attribute]
            "* #{attribute}: #{messages}"
          end

          list_items.join("\n")
        end

        def format_attribute_specific_validation_errors(errors)
          errors.map { |error| "- #{error.inspect}" }.join("\n")
        end

        def default_error_message(type, attribute, options = {})
          model_name = options.delete(:model_name)
          instance = options.delete(:instance)

          RailsShim.generate_validation_message(
            instance,
            attribute.to_sym,
            type,
            model_name,
            options
          )
        end
      end
    end
  end
end
