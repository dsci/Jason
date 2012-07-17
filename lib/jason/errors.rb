module Jason

  module Errors

    class NotSupportedDataTypeError < StandardError;end

    class DocumentNotFoundError < StandardError;end

    class UndeletableError < StandardError; end

  end 

end