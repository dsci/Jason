module Jason

  module Persistence

    extend self

    def included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods

      attr_accessor :new_record

      def defined_attributes
        @defined_attributes ||= []
      end

      def find(id)
        #with_id id do
        #  klass_to_restore self
        #end
        Encoding::PersistenceHandler::restore(:by_id,{:id => id,:klass=>self})
      end

      def all
        Encoding::PersistenceHandler::restore(:all,{:klass => self})
      end

      def with_id(id,&block)
        p id 
        block.call
      end

      # PUBLIC Add attribute to persistence layer for this model.
      #
      # Defines getter and setter methods for given attribute
      # 
      # The Setter methods converts the attribute into the given 
      # data type. 
      #
      # args - List of arguments:
      # 
      #  * first argument   - attribute name as symbol
      #  * second argument  - data type of attribute
      #
      # Currently three data types are supported:
      #
      # * String
      # * Integer
      # * Date 
      def attribute(*args)
        attribute_name,attribute_type = args[0], args[1]

        unless DATA_TYPES.keys.include?("#{attribute_type}".to_sym)
          raise Errors::NotSupportedDataTypeError.new("This Kind of type is not supported or missing!") 
        end

        cast_to = DATA_TYPES["#{attribute_type}".to_sym]#eval "Jason::#{attribute_type}"

        define_method attribute_name do 
          instance_variable_get("@#{attribute_name}")
        end

        define_method "#{attribute_name}=" do |attribute|
          instance_variable_set("@#{attribute_name}", attribute.send(cast_to))
        end

        defined_attributes << attribute_name unless defined_attributes.include?(attribute_name)

        unless defined_attributes.include?(:id)
          define_method :id do 
            instance_variable_get("@id")
          end

          define_method "id=" do |val|
            instance_variable_set("@id", val)
          end
          defined_attributes << :id
        end
      end

    end


    module InstanceMethods

      def initialize(attrs=nil)
        @attributes = attrs || {}
        @new_record = true
        process_attributes(attrs) unless attrs.nil?
        yield(self) if block_given?
      end

      def attributes
        @attributes.merge!(:id => self.id)
      end

      def save
        saved = Encoding::PersistenceHandler.persist(self, new_record? ? {} : {:update => true})
        @new_record = saved ? false : true
        return saved
      end

      def delete
        Encoding::PersistenceHandler.delete(self)
      end

      def update_attributes(attributes={})
        process_attributes(attributes.merge(:id => self.id), :reload => true)
        updated = Encoding::PersistenceHandler.persist(self,:update => true)
        return updated
      end

      def to_hsh
        #p self.attributes
        self.attributes
      end

      def as_json
        jsonable = {}
        jsonable[self.class.name.downcase.singularize] = self.to_hsh
        return jsonable
      end

      def new_record?
        @new_record
      end

      private 

      def reload_attributes
        self.class.defined_attributes.each do |attribute|
          called_attribute = self.send(attribute)
          @attributes[attribute] = called_attribute if called_attribute
        end
      end

      def process_attributes(attrs={}, options = {})
        reload = options.fetch(:reload, false)
        attrs.each_pair{ |key,value| self.send("#{key}=",value) }
        unless attrs.has_key?(:id)
          # generate a new id 
          @id = Encryptors::Document.process_document_id
        end
        reload_attributes if reload
      end

    end

  end

end