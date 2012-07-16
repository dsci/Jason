module Jason
  module Encoding
    module PersistenceHandler

      class Persistable < PersistenceObject

        include Jason::Operations::File

        def initialize(obj,options={})
          @update           = options.fetch(:update, false)
          super(obj)
        end
       
        def process_persistence
          persisted = true
          begin
            persisted_file_content  = load_from_file(where_to_persist)
            r_objects       =  ActiveSupport::JSON.decode(persisted_file_content)
          rescue MultiJson::DecodeError => de
            r_objects = []
          ensure
            # There was something persisted before. Search for id and replace.
            # (Only if update is true)
            # If not updated, append to objects array.
            unless @update
              r_objects << @persistable_obj.send(:as_json)
            else 
              r_objects.each do |object|
                if object[@root]["id"] == @persistable_obj.send(:id)
                  object[@root] = @persistable_obj.send(:as_json)[@root]
                  break
                end
              end
            end
            persisted = save_to_file(ActiveSupport::JSON.encode(r_objects))
          end
          return persisted
        end

        private 

        def r_objects
          @r_objects ||= []
        end

      end
    end
  end
end