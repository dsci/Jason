module Jason
  module Encoding
    module PersistenceHandler

      class PersistenceObject 
        attr_accessor :persistable_obj

        def initialize(obj)
          @persistable_obj  = obj
          @root             = Jason.singularize_key(obj.class)
        end
      end
      
    end
  end
end