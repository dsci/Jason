module Jason

  module Encoding

    module PersistenceHandler

      class Deletable < PersistenceObject

        include Jason::Operations::File

        def delete
          deleted = true
          persisted_file_content  = load_from_file(where_to_persist)
          r_objects       =  ActiveSupport::JSON.decode(persisted_file_content)
          p r_objects
          r_objects.delete_if{|obj| obj[@root]["id"] == @persistable_obj.send(:id)}
          p r_objects
          save_to_file(ActiveSupport::JSON.encode(r_objects))
        rescue 
          deleted = false

        ensure
          return deleted
        end

      end
      
    end

  end

end