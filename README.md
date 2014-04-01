RubySerial
=============

[![Gem Version](https://badge.fury.io/rb/ruby-serial.png)](http://badge.fury.io/rb/ruby-serial)
[![Inline docs](http://inch-pages.github.io/github/Muriel-Salvan/ruby-serial.png)](http://inch-pages.github.io/github/Muriel-Salvan/ruby-serial)
[![Build Status](https://travis-ci.org/Muriel-Salvan/ruby-serial.png?branch=master)](https://travis-ci.org/Muriel-Salvan/ruby-serial)
[![Code Climate](https://codeclimate.com/github/Muriel-Salvan/ruby-serial.png)](https://codeclimate.com/github/Muriel-Salvan/ruby-serial)
[![Code Climate](https://codeclimate.com/github/Muriel-Salvan/ruby-serial/coverage.png)](https://codeclimate.com/github/Muriel-Salvan/ruby-serial)
[![Dependency Status](https://gemnasium.com/Muriel-Salvan/ruby-serial.svg)](https://gemnasium.com/Muriel-Salvan/ruby-serial)

ruby-serial is a Ruby library serializing Ruby objects, optimized in many ways:

* **Fast and small**: use [MessagePack](http://msgpack.org/) (binary compact storage) and don't serialize twice the same object
* **Independent of Ruby version**: dump and load data across different versions
* **Keep shared objects**: if an object is shared by others, serialization still keeps the reference and does not duplicate objects in memory
* Gives the ability to **fine tune which attributes of your objects are to be serialized** (defaults to all)
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

str = RubySerial.dump [ :hello, 'World', 42 ]
# => "1\x00\x82\xA3obj\x93\x82\xA2\x00\xBB\xA2\x00\xEE\xA2\x00\xF1\xA5hello\xA5World*\xABshared_objs\x80"

RubySerial.load str
# => [:hello, "World", 42]
```

### More info

See [ruby-serial home page](http://ruby-serial.x-aeon.com) for more complete examples and references.

### Contact

Contributions, questions, jokes? Send them to [Muriel](mailto:muriel@x-aeon.com)
