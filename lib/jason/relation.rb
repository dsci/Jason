module Jason

  module Relation

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end

    module InstanceMethods

    end

    module ClassMethods

      def reflections
        @reflections ||= []   
      end

      def reflect_on_relation(relation_name)
        reflections.detect{|reflection| reflection.name.eql?(relation_name.to_s)}
      end

      def has_many(*args)
        relation_name = args.shift.to_s
        options = args.empty? ? {} : args.shift
      
        class_name = options.fetch(:class, relation_name.downcase.singularize).capitalize

        reflections << Reflection::Base.new(:name => relation_name, 
                                            :class_name => class_name,
                                            :type => "has_many")
        method_definition_getter = <<-RUBY

          def #{relation_name}
            objects = []
            # find all children in *.json if included.
            # Otherwise return empty array.
            
            return objects
          end

        RUBY

        class_eval method_definition_getter


      end

      def belongs_to(*args)
        relation_name = args.shift.to_s
        options       = args.empty? ? {} : args.shift

        class_name    = options.fetch(:class, relation_name).capitalize

        reflections   << Reflection::Base.new(:name => relation_name,
                                              :class_name => class_name,
                                              :type => "belongs_to")

        ivar_name = "#{relation_name}_id".to_sym
        attribute ivar_name, String

        method_definition_setter = <<-RUBY
          def #{relation_name}=(obj)
            self.send("#{ivar_name}=", obj.id)  
            self.instance_variable_set("@#{relation_name}",obj)
            self.reload_attributes
          end

        RUBY

        method_definition_getter = <<-RUBY
          def #{relation_name}
            relation_obj = self.instance_variable_get("@#{relation_name}")
            if relation_obj
              return relation_obj
            else
              klass = Module.const_get("#{class_name}".to_sym)
              relation_obj = klass.find(self.send("#{ivar_name}"))
              self.instance_variable_set("@#{relation_name}", relation_obj)
              return relation_obj
            end
          end
        RUBY

        class_eval method_definition_setter
        class_eval method_definition_getter, "relation.rb"
      end


    end

  end


end