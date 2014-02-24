RubySerial
=============

[![Build Status](https://travis-ci.org/Muriel-Salvan/ruby-serial.png?branch=master)](https://travis-ci.org/Muriel-Salvan/ruby-serial)

ruby-serial is a Ruby library serializing Ruby objects, optimized in many ways:

* **Space efficient**: Use MessagePack (binary compact storage) and don't serialize twice the same object
* **Keep shared objects**: if an object is shared by others, serialization still keeps the reference and does not duplicate objects in memory
* Gives the ability to **fine tune which attributes of your objects are to be serialized**
* Keeps **backward compatibility** with previously serialized versions.
* Has **callbacks support** to fine tune the serialization process.
* Can serialize objects having **reference cycles** (self-contained Arrays, Hashes, objects...)

### Installation

RubySerial is packaged as a simple Ruby gem:

```
gem install ruby-serial
```

### Usage

Its usage is the same as Marshal library:

```ruby
require 'ruby-serial'
# Create example
class User
  attr_accessor :name
  attr_accessor :comment
  def ==(other)
    other.is_a?(User) and (@name == other.name) and (@comment == other.comment)
  end
end
shared_obj = 'This string instance will be shared'
user = User.new
user.name = 'John'
user.comment = shared_obj # shared_obj is referenced here
obj = [
  'My String',
  shared_obj, # shared_obj is also referenced here
  1,
  user
]

# Get obj as a serialized String
serialized_obj = RubySerial::dump(obj)
# Get back our objects from the serialized String
deserialized_obj = RubySerial::load(serialized_obj)
# Both objects are the same
puts "Same? #{obj == deserialized_obj}"
# => true

# The shared object is still shared!
puts "Shared? #{deserialized_obj[1].object_id == deserialized_obj[3].comment.object_id}"
# => true
```

### More info

[Complete doc over here](http://ruby-serial.sourceforge.net)!

[Bug tracker](http://sourceforge.net/p/ruby-serial/bugs/)

### Contact

Contributions, questions, jokes? Send them to [Muriel](mailto:muriel@x-aeon.com)
