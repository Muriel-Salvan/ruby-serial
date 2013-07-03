RubySerial
=============

**Optimized serialization library for Ruby objects.**

Library serializing Ruby objects, optimized in many ways:
* Space efficient: Use MessagePack (binary compact storage) and don't serialize twice the same object
* Keep shared objects: if an object is shared by others, serialization still keeps the reference and does not duplicate objects in memory
* Gives the ability to fine tune which attributes of your objects are to be serialized
* Keeps backward compatibility with previously serialized versions

[See documentation here!](http://ruby-serial.sourceforge.net)

## Contact

Want to contribute? Have any questions? [Contact Muriel!](muriel@x-aeon.com)
