# For development only
#require "rubygems"
#require 'bundler/setup'

# for any Ruby implementation which not support require_relative
require "require_relative"
require 'active_support/core_ext/module/qualified_const'
#require 'active_support/core_ext/string/inflections'
require 'active_support/inflector'
require 'active_support/json'

module Jason

  require 'jason/core_ext/string'

  extend self

  module Encryptors
    autoload :Document,  'jason/crypt/document_id'
  end

  module Operations
    autoload :File, 'jason/operations/file'
  end

  module Encoding
    autoload :PersistenceHandler, 'jason/encoding/persistence_handler'
  end

  module Reflection
    autoload :Base,  'jason/reflection/base'
  end

  autoload :Errors,         'jason/errors'

  autoload :Relation,       'jason/relation'
  autoload :Persistence,    'jason/persistence' 
   
  DATA_TYPES = {
    :Integer => :to_i,
    :String => :to_s,
    :Date => :to_date
  }

  #Integer = :to_i
  #String  = :to_s
  #Date    = :to_date

  def setup(&block)
    yield(self)
  end

  mattr_accessor :persistence_path
  @@persistence_path = File.expand_path(File.join(File.dirname( __FILE__)), 'json')

  mattr_accessor :restore_app
  @@restore_app = Encoding::PersistenceHandler::Restorable

  mattr_accessor :has_many_separator
  @@has_many_separator = ","

  def singularize_key(key)
    key.name.downcase.singularize if key.respond_to?(:name)
  end

  

end