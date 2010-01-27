require 'helper'

class Riot::Situation
  def v(value=nil, &block)
    Schema.new(&block).validate!(value)
  end
end

context "Schema" do

  asserts(:class) { Schema.new }.equals(Schema)

  context "empty" do
    asserts("validate") { v }
    asserts("validate nil") { v(nil) }
    asserts("validates 1") { !v(1) }
  end

  context "matchers" do
    asserts("equals") { Schema.matchers[:equals].call(1, 1) }
    asserts("!equals") { !Schema.matchers[:equals].call(1, 2) }
    asserts("is_a?") { Schema.matchers[:is_a?].call("string", String) }
    asserts("!is_a?") { !Schema.matchers[:is_a?].call("string", Fixnum) }
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
    asserts("valid multiple") { v("test") { is_a?(String); is_a?(Object) } }
    asserts("invalid multiple") { !v("test") { is_a?(String); is_a?(Fixnum) } }
  end

  context "chaining" do
    asserts("valid") { v(1) { is_a?(Fixnum).equals(1) }}
    asserts("invalid") { !v(1) { is_a?(Fixnum).equals(2) }}
  end

  context "hash" do
    setup do
      Schema.new do
        hash(
          :key    => value.is_a?(String),
          :value  => value.is_a?(Fixnum)
        )
      end
    end

    asserts("valid") { topic.validate!(:key => "fasel", :value => 23) }
    asserts("invalid") { !topic.validate!(:key => 23, :value => 23) }
    asserts("missing") { !topic.validate!(:key => "fasel") }
  end
end
