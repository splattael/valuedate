require 'helper'

class Riot::Situation
  def v(value=nil, &block)
    Valuedate.validate(value, &block)
  end
end

class Riot::Context
  def asserts_validation_error(options={}, &block)
    asserts("validation_error with #{options.inspect}") do
      begin
        instance_eval(&block)
        false
      rescue Valuedate::ValidationFailed => e
        error = e.errors.first
        options.all? do |key, value|
          error.options[key] == value
        end
      end
    end
  end
end

context "Valuedate" do

  asserts(:class) { Valuedate.schema }.equals(Valuedate)

  context "empty" do
    asserts("valid without block") { v }
    asserts("valid empty block") { v {} }
    asserts("valid nil block") { v { nil } }
    asserts("valid nil") { v(nil) }
    asserts("valid 1") { v(1) }
  end

  context "callable" do
    asserts("valid with true") { v { proc {|v| true } } }
    asserts("invalid with false") { !v { proc {|v| false } } }
  end

  context "matchers" do
    asserts("equals") { Valuedate.matchers[:equals].call(1, 1) }
    asserts("!equals") { !Valuedate.matchers[:equals].call(1, 2) }
    asserts("is_a") { Valuedate.matchers[:is_a].call("string", String) }
    asserts("!is_a") { !Valuedate.matchers[:is_a].call("string", Fixnum) }
  end

  context "equals" do
    asserts("valid 1") { v(1) { value.equals 1 } }
    asserts("invalid 2") { !v(2) { value.equals 1 } }
    asserts("valid String") { v("test") { value.equals "test" } }
    asserts("invalid String") { !v("test") { value.equals "tests" } }
    asserts("invalid multiple") { !v(1) { value.equals 1; value.equals 2} }
  end

  context "is_a" do
    asserts("valid String") { v("test") { value.is_a(String) } }
    asserts("invalid String") { !v(1) { value.is_a(String) } }
    asserts("valid multiple") { v("test") { value.is_a(String); value.is_a(Object) } }
    asserts("invalid multiple") { !v("test") { value.is_a(String); value.is_a(Fixnum) } }
  end

  context "chaining" do
    asserts("valid") { v(1) { value.is_a(Fixnum).equals(1) }}
    asserts("invalid") { !v(1) { value.is_a(Fixnum).equals(2) }}
  end

  context "nesting" do
    setup do
      Valuedate.schema do
        value.hash(
          :key    => value.is_a(String),
          :value  => value.is_a(Fixnum)
        )
      end
    end

    asserts("valid") { topic.validate(:key => "fasel", :value => 23) }
    asserts("invalid") { !topic.validate(:key => 23, :value => 23) }
    asserts("missing") { !topic.validate(:key => "fasel") }
  end

  context "deep nesting" do
    setup do
      Valuedate.schema do
        value.hash(
          :image => value.hash(
            :src => value.is_a(String),
            :height => value.is_a(Fixnum)
          ),
          :text => value.is_a(String)
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

  context "optional_value" do
    asserts("valid nil") { v(nil) { optional_value } }
    asserts("valid 1") { v(1) { optional_value } }
    asserts("valid empty optional String") { v(nil) { optional_value.is_a(String) } }
    asserts("valid given and String") { v("test") { optional_value.is_a(String) } }
    asserts("invalid given non-String") { !v(1) { optional_value.is_a(String) } }

    context "netsted" do
      setup do
        Valuedate.schema do
          optional_value.hash(
            :image => value.hash(
              :src  => value.is_a(String),
              :alt  => optional_value.is_a(String),
              :size => optional_value.hash(
                :width => value.is_a(Fixnum),
                :height => value.is_a(Fixnum)
              )
            )
          )
        end
      end

      asserts("valid empty") { topic.validate }
      asserts("invalid non Hash") { !topic.validate(23) }
      asserts("invalid wrong key") { !topic.validate(:type => {}) }
      asserts("invalid empty image") { !topic.validate(:image => {}) }
      asserts("valid all given") do
        topic.validate(
          :image => {
            :src  => "/img.gif",
            :alt  => "Alt",
            :size => { :width => 80, :height => 80 }
          }
        )
      end
      asserts("valid minimal Hash") { topic.validate(:image => { :src => "/img.gif" }) }
      asserts("invalid alt") { !topic.validate(:image => { :src => "/img.gif", :alt => 23 }) }
    end
  end

  context "any" do
    asserts("valid") { v(1) { value.any(value.equals(1), value.equals(2)) } }
    asserts("valid") { v(2) { value.any(value.equals(1), value.equals(2)) } }
    asserts("invalid") { !v(3) { value.any(value.equals(1), value.equals(2)) } }

    context "nested" do
      setup do
        Valuedate.schema do
          value.any(
            value.hash(:result => value.equals("ok")),
            value.hash(:error => value.equals("failed"), :init => value.equals(23))
          )
        end
      end

      asserts("invalid when empty") { !topic.validate }
      asserts("valid when result ok") { topic.validate(:result => "ok") }
      asserts("invalid when result nok") { !topic.validate(:result => "nok") }
      asserts("valid when error") { topic.validate(:error => "failed", :init => 23) }
      asserts("invalid missing init") { !topic.validate(:error => "failed") }
    end
  end

  context "in" do
    asserts("valid range") { v(1) { value.in(1..5) } }
    asserts("invalid range") { !v(0) { value.in(1..5) } }
    asserts("valid array") { v(1) { value.in([1,2,3]) } }
    asserts("invalid array") { !v(0) { value.in([1,2,3]) } }
  end

  context "is and not" do
    asserts("valid Fixnum") { v(1) { value.is { |value| value == 1 } } }
    asserts("valid not Fixnum") { v(1) { value.not { |value| value == 2 } } }
    asserts("invalid is Fixnum") { v(1) { !value.is { |value| value == 2 } } }
    asserts("invalid not Fixnum") { v(1) { !value.not { |value| value == 1 } } }

    asserts("valid empty array") { v([]) { value.is_a(Array).is { |value| value.empty? } } }
    asserts("valid array size") { v([1,2]) { value.is { |value| value.size == 2 } } }
    asserts("invalid array size") { !v([1,2]) { value.not { |value| value.size == 2 } } }
  end

  context "matches" do
    asserts("valid Regexp") { v("test me") { value.matches(%r{^test}) } }
    asserts("invalid Regexp") { !v("fest me") { value.matches(%r{^test}) } }
    asserts("invalid Fixnum") { !v(1) { value.matches(%r{^test}) } }
  end

  # TODO refactor!
  context "errors" do
    setup do
      Valuedate.schema {}
    end

    asserts("empty") { topic.errors.empty? }
    asserts("with error") do
      topic.error(:value => "value")
      topic.errors.first.options[:value]
    end.equals("value")

    context "aggregate" do
      setup do
        Valuedate.schema do
          value.hash(
            :key1 => value.is_a(String).equals("key"),
            :key2 => value.hash(
              :key3 => value.is_a(Fixnum)
            )
          )
        end
      end

      asserts("fails") { !topic.validate({}) }
      asserts_validation_error(:key => :key3, :matcher => :is_a) { topic.validate!(:key1 => "key", :key2 => {:key3 => 0.0}) }
      asserts("passes") { topic.validate(:key1 => "key", :key2 => {:key3 => 23}) }
    end
  end
end
