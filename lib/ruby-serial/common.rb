module RubySerial

  # Find shortest strings that are unlikely to get in functional Hashes' keys
  # !!! Use UTF-8 encoding as otherwise MessagePack won't be able to read data correctly

  # Following are used as Hash keys. No duplicates allowed.
  OBJECT_ID_REFERENCE = "\x00\xA0".force_encoding(Encoding::UTF_8)
  OBJECT_CONTENT_REFERENCE = "\x00\xF1".force_encoding(Encoding::UTF_8)
  OBJECT_CLASSNAME_REFERENCE = "\x00\xBB".force_encoding(Encoding::UTF_8)

  # Following are used as class identifiers in Hash values.
  # No duplicates allowed.
  CLASS_ID_SYMBOL = "\x00\xEE".force_encoding(Encoding::UTF_8)
  CLASS_ID_ENCODING = "\x00\xDD".force_encoding(Encoding::UTF_8)

end
