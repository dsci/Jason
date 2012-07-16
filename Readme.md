## Jason (Json Persistence Framework)

### Introduction

It's only for demonstration purposes. If you want to used in your application - feel free. 

### Features

By now, Jason supports:

* a persistence_layer
* a simple relation (association) mapper

**The persistence layer**

Usage of the persistence layer is widly known from other libraries.

By now, it supports the following datatypes:

* Integer
* String
* Date (not fully supported)

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
| Date                            | TODO              |
| has_many                        | work in progress  |
| Custom data types               | TODO              |
| deletable only if already saved | TODO              |
| code documentation              | Partly & TODO     |
| Gemspec                         | TODO              |

### Last words

Author: Daniel Schmidt, 15/16. July 2012