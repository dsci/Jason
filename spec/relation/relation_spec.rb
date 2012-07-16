require 'spec_helper'

describe "Jason::Relation" do
  
  #class Person
  class Person
    include Jason::Persistence
    include Jason::Relation
  
    attribute :firstname, String
    attribute :lastname,  String
    attribute :age,       Integer

    has_many    :children
    belongs_to  :wife
  end

  context "class methods" do

    subject{Person}

    it{should respond_to :has_many}
    it{should respond_to :belongs_to}
    it{should respond_to :reflect_on_relation}

  end

  context "persisting relations" do

    context "belongs_to" do
      
      before do
        Wife = Class.new do
          include Jason::Persistence

          attribute :name, String

        end
      end

      let(:person){Person.new(:firstname => "Bob",:age => 23)}
      let(:wife){Wife.new(:name => "Hanne")}

      it "automatically persist" do
      
        person.wife = wife
        person.save

        expect{Wife.find(wife.id)}.to_not raise_error Jason::Errors::DocumentNotFoundError
        expected_wife = Wife.find(wife.id)

        expected_wife.id.should eq wife.id
        expected_wife.name.should eq wife.name

        pperson = Person.find(person.id)

        pperson.wife.id.should eq expected_wife.id  
      end

    end
    

  end


end