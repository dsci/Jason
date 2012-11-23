module Jason
  module Encoding
    module PersistenceHandler
    
      class Restorable

        include Jason::Operations::File

        def by_id(*args)
          options = args.shift

          @id = options[:id]
          @klass = options[:klass]
          key = Jason::singularize_key(@klass)
          persisted_file_content = load_from_file(where_to_persist(@klass.name))
          r_objects = ActiveSupport::JSON.decode(persisted_file_content)
          obj = r_objects.detect{|obj| obj[key]["id"] == @id}
          raise Jason::Errors::DocumentNotFoundError, "Document not found with id #{@id}." if obj.nil?
          
          return restore_with_cast(obj[key])
        rescue MultiJson::DecodeError => de
          raise Jason::Errors::DocumentNotFoundError, "Document not found with id #{@id}."
        end

        def all(*args)
          options = args.shift

          @klass = options[:klass]
          key = Jason::singularize_key(@klass)
          persisted_file_content = load_from_file(where_to_persist(@klass.name))
          r_objects = ActiveSupport::JSON.decode(persisted_file_content)
          r_objects.map do |obj|
            restore_with_cast(obj[key])
          end
        end

        def with_conditions(*args)
          options = args.pop
          
          @klass = options[:klass]
          options.delete(:klass)
          key = Jason::singularize_key(@klass)

          persisted_file_content = load_from_file(where_to_persist(@klass.name))
          r_objects = ActiveSupport::JSON.decode(persisted_file_content)
          found_objects = []
          
          r_objects.each do |obj|
            if obj[key][options.keys.join.to_s] == options.values.join
              found_objects << restore_with_cast(obj[key])
            end
          end
          found_objects
        end

        private 

        def restore_with_cast(attributes)
          instance = @klass.new(HashWithIndifferentAccess.new(attributes))
          
          instance.instance_eval do
            @new_record = false 
            # parse in given datatypes
            @attributes.each_pair do |key,value|
              begin
                attribute_definition = self.class.defined_attributes.detect do |item| 
                  item[:name] == key.to_sym
                end[:type]
                cast_type = "#{attribute_definition}".to_sym
                cast_to = Jason::DATA_TYPES[cast_type]
                instance_variable_set("@#{key}",value.send(cast_to))
              rescue 
                next
              end
            end
          end
          return instance
        end
      end
      
    end
  end
end