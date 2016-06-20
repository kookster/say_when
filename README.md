# SayWhen

SayWhen is a job scheduling library for use in any project, but with a few extra hooks for rails projects.
It was roughly inspired by the [Quartz scheduler](http://quartz-scheduler.org/).

You add it to a ruby program (optionally configure it) and then schedule jobs using a few different strategies, with cron-like expressions the most powerful.

When scheduling, you specify a trigger which controls when execution will occur, such as a cron trigger, or an execute only once trigger, and a job, which is the actual work to perform.

The cron triggers are based on the [extended cron capabilities](http://wiki.opensymphony.com/display/QRTZ1/CronTriggers+Tutorial).

Jobs can be stored different ways, either in memory (e.g. loaded on start from a ruby file), or saved to a database.

The scheduler can execute the jobs in different ways, either by loading and running them itself synchronously, or by delegating the processing to ActiveJob.

SayWhen can be run either in its own process, or can run as a supervised actor in a Celluloid process (e.g. sidekiq or shoryuken).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'say_when'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install say_when

<<<<<<< HEAD
## Configuration

To use, first configure how jobs are stored and processed.
Be default, they are in memory, and processed synchronously, but that can be configured to behave differently.

The currently available storage options are:
- Memory (default) - usually jobs are initialized in code on load
- ActiveRecord - stores the scheduled jobs and can log execution information to database tables

The processor options are:
- Simple - the scheduler process executes the job itself synchronously
- ActiveJob - delegates the work to an ActiveJob async call
- Test - stubs out processing, useful for testing only

You also have some options for running SayWhen:
- SimplePoller - just a simple looping process, can be started with rake
- CelluloidPoller - defines a Celluloid Actor appropriate for adding to a running Celluloid process, such as from Shoryuken or Sidekiq

Finally, there are options for triggers that determine when jobs run:
-

```ruby
# config/intializers/say_when.rb

require 'say_when'

# you can specify a the logger
SayWhen.logger = Rails.logger

# configure the scheduler for how to store and process scheduled jobs
# it will default to a :memory strategy and :simple processor
SayWhen.configure do |options|
  options[:storage_strategy]   = :active_record
  options[:processor_strategy] = :simple
end
```

## Usage

### Basics
There is a very verbose way to create a scheduled job, setting the options for the trigger and job explicitly, and then some helper methods that make this easier for common cases.

Here is an example of the verbose way of scheduling a job, which is a good place to start:
```ruby

  job = SayWhen::Scheduler.schedule(
    trigger_strategy: 'once',
    trigger_options: { at: 10.second.since },
    job_class: SomeTask,
    job_method: 'execute',
    data: { id: 123 }
  )
```

There are also convenience methods on the `Scheduler`:
```ruby

```

## `ActiveRecord` Integration

Besides storing jobs in ActiveRecord, you can also associate jobs with other models.

There is an `acts_as_scheduled` method you can call in an ActiveRecord class for this purpose.
It both makes it easier to schedule a job, and to see manage the list of related jobs.

For example, you might create a job to send a reminder a week after a user is created, and relate this new job to that user.
By associating it with the `ActiveRecord` object, you can more easily manage this reminder, such as canceling it if they close their account.

When using `ActiveRecord` integration in Rails, there is a generator for the migration to create the tables for saving scheduled jobs:
=======
## ActiveRecord integration

Besides storing jobs in ActiveRecord, you can also associate jobs with other models.

There is an `acts_as_scheduled` method you can call in an ActiveRecord class for this purpose.
It both makes it easier to schedule a job, and to see manage the list of related jobs.

For example, you might create a job to send a reminder a week after a user is created, and relate this new job to that user.
By associating it with the AR object, you can more easily manage this reminder, such as cancelling it if they close their account.

When using AR integration in Rails, there is a generator for the migration to create the tables for saving scheduled jobs:
>>>>>>> 37285157ab728c0f38702a975fb43d9f7a0f71d2
```
bundle exec rails generate say_when:migration
```

<<<<<<< HEAD
The resulting migration assumes the scheduled jobs will use a integer based id column, please update the default migration if this is not the case in your system:
=======
The resulting migration assumes the scheduled jobs will use a integer based id column, please updatethe default migration if this is not the case in your system:
>>>>>>> 37285157ab728c0f38702a975fb43d9f7a0f71d2
```ruby
# change this to string or other type as needed
t.integer   :scheduled_id
```
<<<<<<< HEAD

## Pollers

The `SimplePoller` does what you would expect; when you run it, it starts up a loop of checking for jobs to run, sleeping, and then checking again.

It can be executed from the rake task:
```
bundle exec rake say_when:start
```

But that isn't doing much except loading the environment then this:
```ruby
require 'say_when'
require 'say_when/poller/simple_poller'

SayWhen::Poller::SimplePoller.start
```

For my own purposes, I use things like `daemontools` and `god` to daemonize, so this has been enough for me, but it would not be hard to write a command line script for it.

The reality is that most of the time I am also running a job processing process, either `shoryuken` or `sidekiq`, and I would prefer to piggyback on that same process instead of starting up another. Since both of those use Celluloid, I also created a Celluloid actor class that can be added to the celluloid based job process via hooks in their startup.

For Shoryuken, add this to your initializer (probably `config/initializers/shoryuken.rb`):
```ruby
require 'say_when/poller/celluloid_poller'

Shoryuken.on_start do
  # check for new jobs to run every 5 seconds
  SayWhen::Poller::CelluloidPoller.supervise_as :say_when, 5
end
```

For Sidekiq, there is a slightly different syntax, but basically the same idea
(via https://github.com/mperham/sidekiq/wiki/Deployment#events):
```ruby
require 'say_when/poller/celluloid_poller'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    SayWhen::Poller::CelluloidPoller.supervise_as :say_when, 5
  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/say_when/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
