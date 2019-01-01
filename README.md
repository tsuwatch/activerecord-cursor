# ActiveRecord::Cursor

cursor pagination for ActiveRecord

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-cursor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-cursor

## Usage

```ruby
Post.all
=> [
  #<Post id: 1, published: true, score: 0, created_at: "2018-12-30 19:38:27", updated_at: "2018-12-30 19:38:27">,
  #<Post id: 2, published: false, score: 1, created_at: "2018-12-30 19:38:28", updated_at: "2018-12-30 19:38:28">,
  #<Post id: 3, published: true, score: 1, created_at: "2018-12-30 19:38:29", updated_at: "2018-12-30 19:38:29">,
  #<Post id: 4, published: false, score: 2, created_at: "2018-12-30 19:38:30", updated_at: "2018-12-30 19:38:30">
]
Post.cursor(key: :created_at)
=> [#<Post id: 1, published: false, score: 0, created_at: "2018-12-30 19:38:27", updated_at: "2018-12-30 19:38:27">]
Post.where(published: true).cursor(key: :created_at, reverse: true)
=> [#<Post id: 3, published: true, score: 1, created_at: "2018-12-30 19:38:29", updated_at: "2018-12-30 19:38:29">]
Post.where(published: true).cursor(key: :created_at, reverse: true, start: Post.next_cursor) # Get next page
=> [#<Post id: 1, published: true, score: 0, created_at: "2018-12-30 19:38:27", updated_at: "2018-12-30 19:38:27">]
Post.where(published: true).cursor(key: :created_at, reverse: true, stop: Post.prev_cursor) # Get previous page
=> [#<Post id: 3, published: true, score: 1, created_at: "2018-12-30 19:38:29", updated_at: "2018-12-30 19:38:29">]
```

### Options

- `key`: Cursor key. Defult: 'id'
- `reverse`: Set it to true, if your set are ordered descendingly (DESC). Default: false
- `size`: Page size. Default: 1
- `start`: Cursor value
- `stop`: Cursor value

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tsuwatch/activerecord-cursor.
