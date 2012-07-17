require 'spec_helper'

describe String do

  subject{String.new}

  it{should respond_to(:to_date)}

  context "#to_date" do

    it "converts string to Date object" do
      date_string = "2012-10-09"
      eql_date = Chronic.parse(date_string)
      date_string.to_date.should eq eql_date.to_date
    end

  end


end


