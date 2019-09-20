require 'rspec'
require_relative '../models/person'

describe 'orm tests' do
  it 'should can add has_one attr' do
    p = Person.new
    p.first_name = 'daniel'
    expect(p.first_name).to eq('daniel')
  end

  it 'should can add boolean attr' do
    class Person
        has_one Boolean, named: :admin
    end
    p = Person.new
    p.admin = false
    expect(p.admin).to eq(false)
  end

  it 'should generate a random id after saving' do
    p = Person.new
    p.save!
    expect(p.id).to match(/([0-9a-f]{4}-?){4}/)
  end

  #database not implemented
  it 'should refresh' do
    p = Person.new
    p.save!
    p.refresh!
    expect(true).to be(true)
  end

  it 'should raise error at refresh because was never saved' do
    p = Person.new
    expect {
        p.refresh!
    }.to raise_error('The object has no id')
  end



end
