require 'active_support/hash_with_indifferent_access'
require_relative 'persistence_object'
require_relative 'deletable'
require_relative 'persistable'
require_relative 'restorable'


module Jason

  module Encoding

    module PersistenceHandler

      extend self

      def persist(obj, options={})
        return Persistable.new(obj,options).process_persistence
      end

      def delete(obj)
        return Deletable.new(obj).delete
      end

      def restore(*args)
        action = args.shift
        Jason.restore_app.new.send(action,*args)
      end      

    end

  end

end