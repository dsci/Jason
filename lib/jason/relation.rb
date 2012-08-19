module Jason

  module Relation

    def self.included(base)
      base.class_eval do
        include InstanceMethods
        extend  ClassMethods
      end
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

        ivar_name = "#{relation_name}_ids".to_sym

        attribute ivar_name, String

        method_definition_getter = <<-RUBY

          def #{relation_name}
            # find all children in *.json if included.
            # Otherwise return empty array.
            relation_objects = self.instance_variable_get("@#{relation_name}")
            finder = ->() do
              objects = []
              object_ids = self.send("#{ivar_name}")
              unless object_ids.nil? or object_ids.empty?
                object_ids.split(Jason::has_many_separator).each do |object_id|
                  begin
                    klass = Module.const_get("#{class_name}".to_sym)
                    objects << klass.find(object_id)
                  rescue 
                    next
                  end
                end
              end
              self.instance_variable_set("@#{relation_name}", objects)
              return objects
            end
            relation_objects ||= finder.call
          end

        RUBY

        method_definition_setter = <<-RUBY

          def #{relation_name}=(objects)
            self.send("#{ivar_name}=", objects.map(&:id).join(Jason::has_many_separator))  
            self.instance_variable_set("@#{relation_name}",objects)
            self.reload_attributes
          end

        RUBY

        class_eval method_definition_getter
        class_eval method_definition_setter

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
            finder = ->() do 
              klass = Module.const_get("#{class_name}".to_sym)
              relation_obj = klass.find(self.send("#{ivar_name}"))
              self.instance_variable_set("@#{relation_name}", relation_obj)
              return relation_obj
            end
            relation_obj ||= finder.call
          end
        RUBY

        class_eval method_definition_setter, "relation.rb", 63
        class_eval method_definition_getter, "relation.rb", 72
      end


    end

  end


end