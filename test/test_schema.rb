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

  context "matchers" do
    asserts("equals") { Schema.matchers[:equals].call(1, 1) }
    asserts("!equals") { !Schema.matchers[:equals].call(1, 2) }
    asserts("is_a?") { Schema.matchers[:is_a?].call("string", String) }
    asserts("!is_a?") { !Schema.matchers[:is_a?].call("string", Fixnum) }
  end

  context "equals" do
    asserts("valid 1") { v(1) { value.equals 1 } }
    asserts("invalid 2") { !v(2) { value.equals 1 } }
    asserts("valid String") { v("test") { value.equals "test" } }
    asserts("invalid String") { !v("test") { value.equals "tests" } }
    asserts("invalid multiple") { !v(1) { value.equals 1; value.equals 2} }
  end

  context "is_a?" do
    asserts("valid String") { v("test") { value.is_a?(String) } }
    asserts("invalid String") { !v(1) { value.is_a?(String) } }
    asserts("valid multiple") { v("test") { value.is_a?(String); value.is_a?(Object) } }
    asserts("invalid multiple") { !v("test") { value.is_a?(String); value.is_a?(Fixnum) } }
  end

  context "chaining" do
    asserts("valid") { v(1) { value.is_a?(Fixnum).equals(1) }}
    asserts("invalid") { !v(1) { value.is_a?(Fixnum).equals(2) }}
  end

  context "nesting" do
    setup do
      Schema.new do
        value.hash(
          :key    => value.is_a?(String),
          :value  => value.is_a?(Fixnum)
        )
      end
    end

    asserts("valid") { topic.validate(:key => "fasel", :value => 23) }
    asserts("invalid") { !topic.validate(:key => 23, :value => 23) }
    asserts("missing") { !topic.validate(:key => "fasel") }
  end

  context "deep nesting" do
    setup do
      Schema.new do
        value.hash(
          :image => value.hash(
            :src => value.is_a?(String),
            :height => value.is_a?(Fixnum)
          ),
          :text => value.is_a?(String)
        )
      end
    end

    asserts("valid") do
      topic.validate(
        :image => {
          :src => "/image.gif",
          :height => 80
        },
        :text => "Image"
      )
    end
    asserts("invalid") do
      !topic.validate(
        :image => {
          :src => "/image.gif",
        },
        :text => "Image"
      )
    end

  end # deep nesting

end
