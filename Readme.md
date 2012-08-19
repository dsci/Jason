## Jason (Json Persistence Framework)

### Introduction

It's only for demonstration purposes. If you want to use it in your application - feel free. 

It uses *.json files for persistence. One for each model (imagine as *row*).

### Features

By now, Jason supports:

* a persistence_layer
* a simple relation (association) mapper

It's customizable:

```ruby

Jason.setup do |config|

  config.persistence_path = "/Users/bob/jsons"

  config.restore_app      = MyOwn::RestoreApp

end

```

<code>config.restore_app</code> allows to use an own Class which handles restoring from *.json* files.
If this is set, it replaces the integrated <code>Encoding::PersistenceHandler::Restorable</code> class. 


**The persistence layer**

Usage of the persistence layer is widly known from other libraries.

By now, it supports the following datatypes:

* Integer
* String
* Date

```ruby
class Person

  include Jason::Persistence

  attribute :first_name,  String
  attribute :last_name,   String

end

person = Person.new(:first_name => "Michail", :last_name => "Bulgakov")
person.save

person.update_attributes(:first_name => "Sascha")

person.delete

Person.find("1223wer43")
Person.find_by_id("1223wer43")
Person.find_by_last_name("Bulgakov") #=> returns Array, it's kind of 'where'
Person.find_by_first_name("Michael")

```

**The relation mapper**

Usage of the relation mapper is also widly known from other libraries.

By now it supports:

* belongs_to
* has_many (work in progress)

```ruby
class Person

  include Jason::Persistence
  include Jason::Relation

  attribute :first_name,  String
  attribute :last_name,   String  
  attribute :age,         Integer

  belongs_to :wife

end

class Wife

  include Jason::Persistence
  include Jason::Relation

  attribute :name,  String
end

person = Person.new(:first_name => "Michail", :last_name => "Bulgakov")

woman = Wife.new(:name => "Natascha Rutskovskaja")

person.wife = woman 
person.save
```

<code>belongs_to</code> takes also a second parameter which is a hash:

```ruby

belongs_to :wife, :class => "Woman"

```

so different class (names) are assignable to the relation name. 

### TODO

| Feature                         | Status            |
|:--------------------------------|:------------------|
| Date                            | DONE              |
| has_many                        | DONE              |
| Custom data types               | TODO              |
| deletable only if already saved | DONE              |
| code documentation              | Partly & TODO     |
| Gemspec                         | DONE              |

### Last words

Author: Daniel Schmidt, 15/16/17. July 2012