# EnvMem

Ever read a web page about how to set your Ruby memory environment
variables and thought, "but how do I know that's right for my app?"
EnvMem is here to help you out.

Specifically, if you have a long-running or high-memory Ruby process
(server, batch, etc) then your process will do more garbage collecting
than is necessary in getting up to its long-term size. You can save a
bit of time and processor by setting its environment variables close
to their steady-state or end-of-process values.

This is the same thing you do when you set Ruby environment variables
to more Rails-friendly, batch-friendly or your-server-friendly values
from a web page. It's just that this way you can make sure it's a good
match for your app, specifically.

EnvMem generates a small, simple shellscript to set your environment
variable values. To use it, just source the script before running your
application. You can manually tweak it later if you like, or remove
variables you don't want to set for some reason - such as OLDMALLOC
values if you've compiled a Ruby without it, for instance.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'env_mem'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install env_mem

## Usage

EnvMem needs a dump of GC.stat values from your application in the
configuration you want to match. If you have a long-running Rails
server, that means after it has processed a bunch of HTTP requests. If
you're using EnvMem to configure your batch script, that probably
means dumping GC.stat after you've finished your batch work and your
job's memory configuration is nice and stable.

Since you'll need the GC.stat values from the process, you'll need to
dump them. First, here's how to do it *without* EnvMem:

~~~ ruby
File.open("gc_stat_dump.txt", "w") { |f| f.write GC.stat.inspect }
~~~

You can use EnvMem itself to dump GC.stat, but then you're using it at
runtime. Here's how:

~~~ ruby
require 'env_mem'
EnvMem.dump_to_file("gc_stat_dump.txt")
~~~

To create the environment script from the stat dump, translate from one filename to another:

~~~ ruby
$ env_mem gc_stat_dump.txt > env_wrapper.sh
~~~

Keep in mind that your application may change over time, and so it may
need different memory settings. A simple way to handle that is to run
your app *without* any Ruby memory environment variables set and then
dump GC.stat again and regenerate them.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/noahgibbs/env_mem. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

