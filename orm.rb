#!/usr/bin/ruby
require 'tadb'
require 'objspace'

module Persistable

    module Has
        def has_one(type, hash)
            attr_accessor hash[:named]
        end
    end

    module Save
        def has_id?()
           instance_variable_defined?(:@id) 
        end
        
        def save!()
            if !has_id?
                self.class.attr_accessor :id
                one = "%4x" % (rand * 0xffff)
                two = "%4x" % (rand * 0xffff)
                three = "%4x" % (rand * 0xffff)
                four = "%4x" % (rand * 0xffff)
                random = "#{one}-#{two}-#{three}-#{four}" 
                self.instance_variable_set(:@id, random)
            end
            #save to database
        end

        def refresh!()
            if !has_id?
                raise 'The object has no id'
            end
            #refresh saved value from database to instance
        end

        def forget!()
            self.remove_instance_variable(:@id)
            #remove from database
        end
    end

end

class Class
    def method_missing(symbol, a, b)
        if symbol == :has_one
            instance_eval {|obj| obj.singleton_class.include Persistable::Has}
            self.send symbol, a, b
        else
          super
        end
    end
end

class Object
    include Persistable::Save
end

puts TADB::DB.respond_to?(:clear_all)
puts Class.respond_to?(:has_one)
puts Object.respond_to?(:save!)

class User
    has_one String, named: :name
end

u = User.new
u.name = 'test_name'
u.save!
puts u.id
ObjectSpace.each_object(Persistable::Has) {|x| puts x.to_s}
