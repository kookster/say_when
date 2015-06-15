# SayWhen

SayWhen is a job scheduling library for use in any project, but with a few extra hooks for rails projects.
It was roughly inspired by the [Quartz scheduler](http://quartz-scheduler.org/).

You add it to a ruby program (optionally configure it) and then schedule jobs using a few different strategies, with cron-like expressions the most powerful.

When scheduling, you specify a trigger which controls when execution will occur, such as a cron trigger, or an execute only once trigger, and a job, which is the actual work to perform.

The cron triggers are based on the [extended cron capabilties](http://wiki.opensymphony.com/display/QRTZ1/CronTriggers+Tutorial).

Jobs can be stored different ways, either in memory (e.g. loaded on start from a ruby file), or saved to a database.

The scheduler can execute the jobs in different ways, either by loading and running them itself synchronously, or by delegating the processing.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'say_when'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install say_when

## ActiveRecord integration

Besides storing jobs in ActiveRecord, you can also associate jobs with other models.

There is an `acts_as_scheduled` method you can call in an ActiveRecord class for this purpose.
It both makes it easier to schedule a job, and to see manage the list of related jobs.

For example, you might create a job to send a reminder a week after a user is created, and relate this new job to that user.
By associating it with the AR object, you can more easily manage this reminder, such as cancelling it if they close their account.

When using AR integration in Rails, there is a generator for the migration to create the tables for saving scheduled jobs:
```
bundle exec rails generate say_when:migration
```

The resulting migration assumes the scheduled jobs will use a integer based id column, please updatethe default migration if this is not the case in your system:
```ruby
# change this to string or other type as needed
t.integer   :scheduled_id
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/say_when/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
