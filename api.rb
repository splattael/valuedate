validator = Schema.schema do
  equals 1
end

Schema.define do
  hash(
    :name =>  String,
    :age  =>  Integer,
    :roles  => optional.is_a(Array).part_of(%w(admin user)),
    :images => is_a(Array).not.empty
    :images => array do
      hash(
        :src => String,
        :alt => String,
        :title => is_a(String).optional
      )
    end
    :info =>  optional.hash(
      :title  =>  String
    )
  )
end


