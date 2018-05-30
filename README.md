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

### Long-Running Servers and Other Challenges

There isn't always an obvious way to get statistics at the start and
the end of the process. Start is usually easy, but end can be a
challenge. Here's something I've tried with a large Rails server that
has worked okay:

~~~ ruby
pid = Process.pid
File.open("gc_stats_#{pid}_start.txt", "w") { |f| f.print GC.stats.inspect }
at_exit {
  File.open("gc_stats_#{pid}_stop.txt", "w") { |f| f.print GC.stats.inspect }
}
~~~

The "at_exit" block is saying that before the process exits, it should
stop and write out the GC stats again. Doing this during teardown
means you won't necessarily have an accurate count of how many active
objects are currently sitting around... But most of your statistics
will work great.

You can get a tiny bit of extra accuracy by instead adding a
controller action to dump the GC stats while the Rails server is still
fully active. But for most purposes, this will do just fine.

### What the Variables Mean

Ruby has two obvious thresholds, "malloc" and "oldmalloc", that keep
going up. The "malloc" limit is so that Ruby garbage-collects
regularly every so many bytes allocated. The "oldmalloc" limit is to
garbage collect as (its estimate of) the old-generation size in bytes
increases.

Ordinarily a Ruby process will increase in size asymptotically,
approaching its "full size." This is common for things like server
processes that add and retain long-term memory (e.g. classes, caches)
while adding a much smaller amount of per-request memory that gets
garbage collected soon after the request is finished.

After each time the limit causes a major garbage collection (e.g. the
total allocated size crosses the "malloc" limit), that limit is raised
by a configurable "growth factor". For instance, with the default
RUBY\_GC\_MALLOC\_LIMIT\_GROWTH\_FACTOR of 1.4, the malloc limit will
get 40% bigger each time. With a growth factor of 1.6, it would get
60% bigger. There can also be a LIMIT_MAX variable, so that the limit
grows by the smaller of the growth factor or the limit max. For
instance, with a growth factor of 1.6 and a limit max of 100,000, Ruby
would grow its malloc limit by 60% each time until 60% was bigger than
100,000, and then it would grow by 100,000 each time.

Slots are slightly different than the malloc and oldmalloc limits -
slots are fully managed by Ruby itself, while Ruby uses a system
allocator to managed the malloc and oldmalloc systems.

With slots, Ruby starts with RUBY\_GC\_HEAP\_INIT\_SLOTS of them
allocated. Slots also have a growth factor
(RUBY\_GC\_HEAP\_GROWTH\_FACTOR) and a maximum growth
(RUBY\_GC\_HEAP\_GROWTH\_MAX\_SLOTS). But Ruby will only use them if
you don't set ratios of free slots (see below.) By default, Ruby will
aim for 40% of slots free, allocating more to reach this ratio. By
default it will free pages of slots when at least 65% of its slots are free.

Here is a list of the variables in question:

* RUBY\_GC\_HEAP\_INIT\_SLOTS - initial number of slots
* RUBY\_GC\_HEAP\_FREE\_SLOTS - minimum free slots allowable after GC
* RUBY\_GC\_HEAP\_GROWTH\_FACTOR - growth factor for slots
* RUBY\_GC\_HEAP\_GROWTH\_MAX\_SLOTS - maximum slots to add at one time
* RUBY\_GC\_HEAP\_FREE\_SLOTS\_MIN\_RATIO - allocate additional slots when below this ratio
* RUBY\_GC\_HEAP\_FREE\_SLOTS\_MAX\_RATIO - free pages of slots when  above this ratio
* RUBY\_GC\_HEAP\_FREE\_SLOTS\_GOAL\_RATIO - allocate slots to get to this ratio free (if 0.0, use the growth factor)

* RUBY\_GC\_HEAP\_OLDOBJECT\_LIMIT\_FACTOR - do a major GC when the
  number of old objects is above this factor times the old objects
  after the *last* major GC.

* RUBY\_GC\_MALLOC\_LIMIT
* RUBY\_GC\_MALLOC\_LIMIT\_MAX
* RUBY\_GC\_MALLOC\_LIMIT\_GROWTH\_FACTOR

* RUBY\_GC\_OLDMALLOC\_LIMIT
* RUBY\_GC\_OLDMALLOC\_LIMIT\_MAX
* RUBY\_GC\_OLDMALLOC\_LIMIT\_GROWTH\_FACTOR

### Limitations

There are a *lot* of things you can do with the Ruby environment
variables, and many different applications with different needs. Right
now, EnvMem tries to do a bit to help you. But there's always room for
more.

(You can view these as limitations in EnvMem. You can also view them
as places *you* can begin optimization. Both are correct.)

For instance:

EnvMem doesn't try to preserve environment variable settings from
before you ran it. If you changed any of the "growth factors," for
instance, EnvMem won't currently change them. You may also want to
reduce the growth factors for a fully mature application, or set some
of the LIMIT\_MAX environment variables so that your app can't bloat as
quickly. EnvMem won't do that for you either since it's so
application-specific what "reasonable" behavior is.

EnvMem also tries not to assert anything about the balance of old- and
new-generation objects. In a tightly-optimized application you'd
expect old objects to dominate, while an application that generates a
lot of transient garbage may need different settings. It's possible to
balance MALLOC\_LIMIT settings with OLDMALLOC\_LIMIT settings to
affect this, but EnvMem doesn't try to.

Similarly, you may want a much smaller FREE\_SLOTS ratio with a more
mature, more tightly-tuned application. EnvMem doesn't look at this,
either.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/noahgibbs/env_mem. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

