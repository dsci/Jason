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
              # persist with relations if given.
              # persist belongs_to
              as_json = @persistable_obj.send(:as_json)
              as_json[@root].each_pair do |key,value|
                next unless key.to_s.include?("_id")
                belongs_to_relation = key.to_s.split("_id").first.to_sym
                reflection = @persistable_obj.class.reflect_on_relation(belongs_to_relation)
                if reflection
                  # is relation already persisted?
                  relation_class = Module.const_get(reflection.class_name.to_sym)
                  already_persisted = relation_class.find(value) rescue false
                  unless already_persisted
                    relation_obj = @persistable_obj.send(belongs_to_relation)
                    relation_obj.save
                  else
                    next
                  end
                end
              end
              
              r_objects << as_json
            else 
              r_objects.each do |object|
                if object[@root]["id"] == @persistable_obj.send(:id)
                  # persist with relations if given.
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