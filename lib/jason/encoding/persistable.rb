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
              as_json = @persistable_obj.send(:as_json)
                
              # persist with relations if given.
              # persist belongs_to
              
              if @persistable_obj.class.ancestors.map(&:to_s).include?("Jason::Relation")
                as_json[@root].each_pair do |key,value|
                  next unless key.to_s.include?("_id")
                  relation = key.to_s.split("_id").first.to_sym
                  reflection = @persistable_obj.class.reflect_on_relation(relation)
                  if reflection
                    process_method = instance_method("process_#{reflection.type}")
                    process_method.bind(self).call(reflection,value)
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

        def process_belongs_to(reflection,value)
          persist = instance_method(:run_relation_persistence)
          action = lambda do |relation_name,relation_class,value|
            begin
              already_persisted = relation_class.find(value)
            rescue Jason::Errors::DocumentNotFoundError
              relation_obj = @persistable_obj.send(relation_name)
              relation_obj.save
            end
          end
          persist.bind(self).call(reflection,value,action)
        end

        def process_has_many(reflection,value)
          persist = instance_method(:run_relation_persistence)
          action = lambda do |relation_name,relation_class,value|
            ids = value.split(Jason::has_many_separator)
            ids.each do |id|
              begin
                relation_class.find(id)
              rescue Jason::Errors::DocumentNotFoundError
                relation_obj = @persistable_obj.send(relation_name).detect{|obj| obj.id == id}
                relation_obj.save unless relation_obj.nil?
              end
            end
          end
          persist.bind(self).call(reflection,value,action)
        end

        def run_relation_persistence(reflection,value,block)
          relation_name   = reflection.name
          relation_class  = Module.const_get(reflection.class_name.to_sym)
          block.call(relation_name,relation_class,value)
        end

        def r_objects
          @r_objects ||= []
        end

      end
    end
  end
end