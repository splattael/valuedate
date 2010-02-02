require 'rubygems'
require 'hashidator'
require 'valuedate'

require 'benchmark'

MAP = {
  :full => {
    :valid_input => {
      :id     => 123,
      :name   => "Harry",
      :age    => 21,
      :admin  => true,
      :mails  => ["foo@example.com", "bar@example.com"],
      :other  => {
        :country      => "Denmark",
        :country_code => 12,
        :random       => "foobar"
      },
      :validate_array => [
        {:name => "John"},
        {:name => "Coltrane"}
      ]
    },
    :hashidator => Hashidator.new(
      :id     => Integer,         # Is integer?
      :name   => String,
      :age    => (13..99),        # Within range?
      :admin  => Boolean,
    #  :mails  => [String],        # Array consisting of strings?
      :other  => {
        :country_code => :to_i,   # Ducktyping!
        :country      => String,
        :random       => /foo/    # Regular expressions
      }
    #  :validate_array => [{:name => String}]
    ),
    :valuedate => Valuedate.schema do
      value.hash(
        :id     =>  value.is_a(Integer),
        :name   =>  value.is_a(String),
        :age    =>  value.in(13..99),
        :admin  =>  value.is_a(Boolean),
        :other  =>  value.hash(
          :country_code =>  value.is { |v| v.respond_to?(:to_i) },
          :country      =>  value.is_a(String),
          :random       =>  value.matches(/foo/)
        )
      )
    end
  },
  :simple => {
    :valid_input => {
      :int    => 1,
      :string => "String"
    },
    :hashidator => Hashidator.new(
      :int    => Integer,
      :string => String
    ),
    :valuedate => Valuedate.schema do
      value.hash(
        :int    => value.is_a(Integer),
        :string => value.is_a(String)
      )
    end
  }
}

# Test
MAP.each do |type, hash|
  puts "Checking #{type}"
  valid_input = hash[:valid_input]
  hash[:valuedate].validate!(valid_input)
  hash[:hashidator].validate(valid_input)
end

ITERATIONS = 20_000

Benchmark.bmbm do |benchmark|
  MAP.each do |type, hash|
    valid_input = hash[:valid_input]
    valuedate = hash[:valuedate]
    hashidator = hash[:hashidator]

    benchmark.report("valuedate##{type}") do
      ITERATIONS.times { valuedate.validate(valid_input) }
    end
    benchmark.report("hashidator##{type}") do
      ITERATIONS.times { hashidator.validate(valid_input) }
    end
  end
end

# Checking simple
# Checking full
# Rehearsal -----------------------------------------------------
# valuedate#simple    0.770000   0.000000   0.770000 (  0.784011)
# hashidator#simple   0.270000   0.000000   0.270000 (  0.272961)
# valuedate#full      2.490000   0.010000   2.500000 (  2.593328)
# hashidator#full     0.950000   0.000000   0.950000 (  0.968783)
# -------------------------------------------- total: 4.490000sec
# 
#                         user     system      total        real
# valuedate#simple    0.760000   0.000000   0.760000 (  0.811121)
# hashidator#simple   0.260000   0.000000   0.260000 (  0.263747)
# valuedate#full      2.520000   0.000000   2.520000 (  2.578588)
# hashidator#full     0.940000   0.000000   0.940000 (  0.947101)
# 
