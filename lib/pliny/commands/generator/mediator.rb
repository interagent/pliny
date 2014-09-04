module Pliny::Commands
  class Generator
    class Mediator < Base
      def create_mediator
        mediator = "./lib/mediators/#{field_name}.rb"
        render_template('mediator.erb', mediator,
                        singular_class_name: singular_class_name)
        display "created mediator file #{mediator}"
      end

      def create_mediator_test
        test = "./spec/mediators/#{field_name}_spec.rb"
        render_template('mediator_test.erb', test,
                        singular_class_name: singular_class_name)
        display "created test #{test}"
      end
    end
  end
end
