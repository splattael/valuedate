require 'helper'

class Riot::Situation
  def validate(value=nil, &block)
    Schema.new(&block).validate(value)
  end
end

context "Schema" do

  asserts(:class) { Schema.new }.equals(Schema)

  context "empty" do
    asserts("validate") { validate }
    asserts("validate nil") { validate(nil) }
    asserts("validates 1") { !validate(1) }
  end

  context "equals" do
    asserts("valid 1") { validate(1) { equals 1 } }
    asserts("invalid 2") { !validate(2) { equals 1 } }
    asserts("valid String") { validate("test") { equals "test" } }
    asserts("invalid String") { !validate("test") { equals "tests" } }
    asserts("multiple validates") { !validate(1) {equals 1; equals 2} }
  end
end
