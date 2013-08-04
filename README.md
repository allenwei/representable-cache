# Representable::Cache

provide cache feature for Representable

[representable](https://github.com/apotonick/representable)

## Installation

Add this line to your application's Gemfile:

    gem 'representable-cache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install representable-cache

## Usage


### Default Configuration

```ruby
Representable::Cache.cache_engine = Dalli::Client.new('localhost:11211', :namespace => "app_v1")
Representable::Cache.default_cache_key = [:id, :updated_at]
```

### Setup

```ruby
require 'representable/json'
require 'representable/cache'

module SongRepresenter
  include Representable::JSON
  include Representable::Cache

  property :title
  property :track
end
```

### settings

```ruby
module SongRepresenter
  include Representable::JSON
  include Representable::Cache

  property :title
  property :track
  representable_cache :cache_key => :id, :cache_name => "Brand",
:version => "v1"
end
```

options:
* cache_key: could be symble or array, will use default_cache_key if not
  set
* cache_name: default: module or class name
* version: version name, you can invalid old cache by bump cache version

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
