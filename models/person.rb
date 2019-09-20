require_relative './orm'

class Person
    has_one String, named: :first_name
    has_one String, named: :last_name
    has_one Numeric, named: :age
end
