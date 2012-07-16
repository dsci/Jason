module Jason
  module Encoding
    module PersistenceHandler

      class PersistenceObject 
        attr_accessor :persistable_obj

        def initialize(obj)
          @persistable_obj  = obj
          @root             = obj.class.name.downcase.singularize
        end
      end
      
    end
  end
end