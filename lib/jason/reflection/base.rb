module Jason

  module Reflection

    class Base

      attr_accessor :name,:class_name, :type

      def initialize(attrs={})
        attrs.each_pair do |key,value|
          self.send("#{key}=", value)
        end
      end

    end

  end

end