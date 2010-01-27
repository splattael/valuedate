require 'helper'

class Riot::Situation
  def v(value=nil, &block)
    Schema.new(&block).validate(value)
  end
end

context "Schema" do

  asserts(:class) { Schema.new }.equals(Schema)

  context "empty" do
    asserts("validate") { v }
    asserts("validate nil") { v(nil) }
    asserts("validates 1") { !v(1) }
  end

  context "equals" do
    asserts("valid 1") { v(1) { equals 1 } }
    asserts("invalid 2") { !v(2) { equals 1 } }
    asserts("valid String") { v("test") { equals "test" } }
    asserts("invalid String") { !v("test") { equals "tests" } }
    asserts("invalid multiple") { !v(1) {equals 1; equals 2} }
  end

  context "is_a?" do
    asserts("valid String") { v("test") { is_a?(String) } }
    asserts("invalid String") { !v(1) { is_a?(String) } }
    asserts("valid multple") { v("test") { is_a?(String); is_a?(Object) } }
    asserts("invalid multple") { !v("test") { is_a?(String); is_a?(Fixnum) } }
  end
end
