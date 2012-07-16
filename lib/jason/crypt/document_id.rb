module Jason

  module Encryptors

    class Document

      def self.process_document_id(length=21)
        rand(36**length).to_s(36)
      end

    end

  end

end