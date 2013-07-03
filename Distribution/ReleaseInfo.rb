RubyPackager::ReleaseInfo.new.
  author(
    :name => 'Muriel Salvan',
    :email => 'muriel@x-aeon.com',
    :web_page_url => 'http://murielsalvan.users.sourceforge.net'
  ).
  project(
    :name => 'Ruby Serial',
    :web_page_url => 'http://ruby-serial.sourceforge.net',
    :summary => 'Optimized serialization library for Ruby objects.',
    :description => 'Library serializing Ruby objects, optimized in many ways:
* Space efficient: Use MessagePack (binary compact storage) and don\'t serialize twice the same object
* Keep shared objects: if an object is shared by others, serialization still keeps the reference and does not duplicate objects in memory
* Gives the ability to fine tune which attributes of your objects are to be serialized
* Keeps backward compatibility with previously serialized versionsRuby library giving block-buffered and cached read over IO objects with a String-like interface. Ideal to parse big files as Strings, limiting memory consumption.',
    :image_url => 'http://ruby-serial.sourceforge.net/wiki/images/c/c9/Logo.png',
    :favicon_url => 'http://ruby-serial.sourceforge.net/wiki/images/2/26/Favicon.png',
    :browse_source_url => 'http://ruby-serial.git.sourceforge.net/',
    :dev_status => 'Beta'
  ).
  add_core_files( [
    'lib/**/*'
  ] ).
  add_test_files( [
    'test/**/*'
  ] ).
  add_additional_files( [
    'README',
    'README.md',
    'LICENSE',
    'AUTHORS',
    'Credits',
    'ChangeLog',
    'Rakefile'
  ] ).
  gem(
    :gem_name => 'ruby-serial',
    :gem_platform_class_name => 'Gem::Platform::RUBY',
    :require_path => 'lib',
    :has_rdoc => true,
    :test_file => 'test/run.rb',
    :gem_dependencies => [
      [ 'msgpack' ]
    ],
  ).
  source_forge(
    :login => 'murielsalvan',
    :project_unix_name => 'ruby-serial',
    :ask_for_key_passphrase => true
  ).
  ruby_forge(
    :project_unix_name => 'ruby-serial'
  )
