require 'spec_helper'

class Person

  include Jason::Persistence

  attribute :firstname,     String
  attribute :lastname,      String
  attribute :date_of_birth, Date
  attribute :age,           Integer

end

describe "Jason::Persistence" do

  before(:all) do
    FileUtils.rm_rf(File.join(fixtures_path, 'people.json'))
  end

  after(:all) do
    FileUtils.rm_rf(File.join(fixtures_path, 'people.json'))
  end

  context "class methods" do

    subject{Person}

    it{should respond_to :attribute}
    it{should respond_to :find}
    it{should respond_to :all}

    context "#find" do

      context "when document found" do

        let(:person) do
          Person.new(:lastname => "Hauptmann", :firstname => "Rene", :age => 12,
                     :date_of_birth => "2000/09/09")
        end

        before do
          person.save
        end

        subject{Person.find(person.id)}

        it "returns single object" do
          subject.should be_instance_of Person
        end

        it "id equals the person id" do
          subject.id.should eq person.id
        end

        it "lastname equals person lastname" do
          subject.lastname.should eq person.lastname
        end

        it "firstname equals person firstname" do
          subject.firstname.should eq person.firstname
        end

        it "date_of_birth is a date and equals person date" do
          subject.date_of_birth.should be_instance_of Date
          subject.date_of_birth.day.should eq 9
          subject.date_of_birth.month.should eq 9
          subject.date_of_birth.year.should eq 2000
        end

        it "is not a new record" do
          subject.new_record?.should be false
        end

        it "age is a fixnum" do
          subject.age.should be_instance_of Fixnum
        end

      end

      context "when document not found" do
        
        it "raises an Jason::DocumentNotFoundError" do
          expect{Person.find('123456')}.to raise_error Jason::Errors::DocumentNotFoundError
        end

      end

    end

    context "#all" do

      it "returns an array of documents" do
        result = Person.all
        result.should be_instance_of Array
        result.each do |instance|
          instance.should be_instance_of Person
        end
        result.should_not be_empty
      end

    end

    context "magic finders" do

      before(:all) do
        FileUtils.rm_rf(File.join(fixtures_path, 'people.json'))
        ["Max", "Werner", "Claudia", "Werner"].each do |name|
          person = Person.new(:firstname => name,:lastname => "Winter")
          person.save
        end
      end

      it{should respond_to(:find_by_firstname)}
      it{should respond_to(:find_by_lastname)}
      it{should respond_to(:find_by_date_of_birth)}

      it "find by firstname" do
        result = Person.find_by_firstname("Werner")
        result.should be_instance_of Array
        result.should have(2).items
      end

      it "find by lastname" do
        result = Person.find_by_lastname("Winter")
        result.should have(4).items
      end
    end

  end

  context "instance methods" do

    let(:person) do
      Person.new(:firstname => "Bill",
                 :lastname => "Cosby")
    end
    subject{person}

    it{should respond_to(:attributes)}
    it{should respond_to(:to_hsh)}
    it{should respond_to(:update_attributes)}
    it{should respond_to(:save)}
    it{should respond_to(:new_record?)}
    it{should respond_to(:as_json)}

    context "defining attributes" do
      
      context "get access to getters"  do 
      
        it{should respond_to(:firstname)}
        it{should respond_to(:lastname)}
        it{should respond_to(:date_of_birth)}
        it{should respond_to(:id)}
      
      end
  
      context "get access to setters" do

        it{should respond_to(:firstname=)}
        it{should respond_to(:lastname=)}
        it{should respond_to(:date_of_birth=)}
        it{should respond_to(:id=)}
  
      end
  
      context "setting attributes and getting their values" do
  
        it "first name should be Bill" do
          person.firstname.should eq "Bill"
        end

        it "last name should be Cosby" do
          person.lastname.should eq "Cosby"
        end

        context "when using the constructor" do

          it "an id is generated" do
            person.id.should_not be_nil
          end

        end
  
      
        context "#attributes" do
        
          subject{person.attributes}

          it "is a Hash" do
            subject.should be_instance_of Hash
          end
  
          it "includes the defined attributes as keys" do
            keys = subject.keys
            keys.should include(:firstname)
            keys.should include(:lastname)
          end
  
          it "and its values as value of the key" do
            values = subject.values
            values.should include("Bill")
            values.should include("Cosby")
          end

        end

      end
    end

    context "#save" do

      it "returns true if successful" do
        person.new_record?.should be true
        person.save.should be true
      end

      it "sets new_record to false" do
        person.save
        person.new_record?.should be false
      end

    end 

    context "#update_attributes" do

      let(:another_person) do
        Person.new(:firstname => "max", :lastname => "Mustermann")
      end

      it "returns true if successful" do
        another_person.save
        result = another_person.update_attributes(:firstname => "William")
        result.should be true
        another_person.new_record?.should be false
      end

    end

    context "#delete" do

      let(:another_person) do
        Person.new(:firstname => "max", :lastname => "Mustermann")
      end

      it "raise UndeletableError if it is a new record" do
        expect{another_person.delete}.to raise_error Jason::Errors::UndeletableError
      end

      it "returns true if successful" do
        another_person.save
        person = Person.find(another_person.id)
        person.delete.should be true
        expect{Person.find(person.id)}.to raise_error Jason::Errors::DocumentNotFoundError
      end

    end
  end

end