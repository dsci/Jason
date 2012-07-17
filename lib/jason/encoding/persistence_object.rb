module Jason
  module Encoding
    module PersistenceHandler

      class PersistenceObject 
        attr_accessor :persistable_obj

        def eigenclass
          class << self;
            self;
          end
        end

        def initialize(obj)
          @persistable_obj  = obj
          @root             = Jason.singularize_key(obj.class)
        end

        def instance_method(method_name)
          eigenclass.instance_method(method_name)
        end
      end
      
    end
  end
end