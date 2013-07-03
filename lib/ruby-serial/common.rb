module RubySerial

  # Find shortest strings that are unlikely to get in functional Hashes' keys
  # !!! Use UTF-8 encoding as otherwise MessagePack won't be able to read data correctly
  OBJECT_ID_REFERENCE = "\x00\xA0".force_encoding(Encoding::UTF_8)
  OBJECT_CONTENT_REFERENCE = "\x00\xF1".force_encoding(Encoding::UTF_8)
  OBJECT_CLASSNAME_REFERENCE = "\x00\xBB".force_encoding(Encoding::UTF_8)
  SYMBOL_ID = "\x00\xEE".force_encoding(Encoding::UTF_8)

end
