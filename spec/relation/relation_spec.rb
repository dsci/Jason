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

    let(:person){Person.new(:firstname => "Bob",:age => 23)}

    context "belongs_to" do
      
      before do
        Wife = Class.new do
          include Jason::Persistence

          attribute :name, String

        end
      end
      
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

    context "has_many" do

      before(:all) do
        Child = Class.new do
          include Jason::Persistence

          attribute :name, String
        end
      end

      let(:children) do
        c = []
        ["Claudia", "Peter", "Max"].each do |name|
          c << Child.new(:name => name)
        end
        c
      end

      it "respond to children" do
        person.should respond_to(:children)
      end

      it "respond to children=" do
        person.should respond_to(:children=)
      end

      it "automatically persists" do
        person.children = children
        person.save

        aperson = Person.find(person.id)
        aperson.children.each do |child|
          children.map(&:id).should include child.id
        end
      end

    end
    

  end


end