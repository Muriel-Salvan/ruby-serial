module RubySerialTest

  module Common

    # Objects that can share the same reference when duplicated (even as Hash keys)
    DATA_SAMPLES_SHAREABLE = {
      'Array' => [ 1, 2, 3 ],
      'Hash' => { 1 => 2, 3 => 4 }
    }

    # Objects that can share the same reference when duplicated except when used as Hash keys
    DATA_SAMPLES_SHAREABLE_EXCEPT_AS_HASH_KEYS = {
      'String' => 'My test string',
    }.merge(DATA_SAMPLES_SHAREABLE)

    # All data samples to test
    DATA_SAMPLES = {
      'Fixnum' => 123456,
      'Float' => 1.23456,
      'Symbol' => :TestSymbol,
      'Nil' => nil,
      'True' => true,
      'False' => false
    }.merge(DATA_SAMPLES_SHAREABLE_EXCEPT_AS_HASH_KEYS)

  end

end
