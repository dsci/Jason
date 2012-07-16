module Jason 

  module Operations

    module File

      private

      def where_to_persist(obj_name=nil)
        if obj_name.nil? and self.respond_to?(:persistable_obj)
          file_prefix = persistable_obj.class.name.tableize 
        else
          file_prefix = obj_name.tableize
        end
        ::File.join(Jason.persistence_path,"#{file_prefix}.json")
      end

      def save_to_file(json)
        persisted = true
        begin
          open(where_to_persist, 'w') do |file|
            file.puts json
          end
        rescue => e
          puts e.message
          persisted = false
        end
        return persisted
      end

      def load_from_file(file_name)
        ::File.open(file_name).read rescue ""
      end

     
    end


  end

end