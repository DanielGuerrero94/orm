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

    module Search
        def all_instances()
            instances = []
            ObjectSpace.each_object(self.class) do
                |obj|
                if obj.instance_variable_defined?(:@id) 
                    instances << obj
                end
            end
            instances
        end

        def find_by_type(symbol, *args)
            symbol = symbol.to_s.sub!(/^find_by_/, "@")
            if !instance_variable_defined?(symbol)
                raise 'The object does not have that attribute'
            end
            puts symbol
            puts *args
        end
    end

end

class Class
    def method_missing(symbol, *args, &block)
        if symbol == :has_one
            instance_eval {|obj| obj.singleton_class.include Persistable::Has}
            instance_eval {|obj| obj.include Persistable::Save}
            instance_eval {|obj| obj.include Persistable::Search}
            self.send symbol, *args
        else
          super
        end
    end
end

class Object
    def method_missing(symbol, *args, &block)
        if symbol.to_s.start_with?("find_by")
            find_by_type(symbol, *args)
        else
            super
        end 
    end
end

Object.const_set("Boolean", true)
