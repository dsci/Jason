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
          raise Jason::Errors::DocumentNotFoundError, "Document not found with #{@id}." if obj.nil?
          
          instance = @klass.new(HashWithIndifferentAccess.new(obj[key]))
          instance.instance_eval {@new_record = false }
          
          return instance
        end

        def all(*args)
          options = args.shift

          @klass = options[:klass]
          key = Jason::singularize_key(@klass)
          persisted_file_content = load_from_file(where_to_persist(@klass.name))
          r_objects = ActiveSupport::JSON.decode(persisted_file_content)
          r_objects.map do |obj|
            instance = @klass.new(HashWithIndifferentAccess.new(obj[key]))
            instance.instance_eval {@new_record = false }
            instance
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
              instance = @klass.new(HashWithIndifferentAccess.new(obj[key]))
              instance.instance_eval {@new_record = false }
              found_objects << instance
            end
          end
          found_objects
        end


      end
      
    end
  end
end