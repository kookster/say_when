module SayWhen
  module BaseStore

    def lock
        @_lock ||= Mutex.new
    end

    def add_trigger(item)
    end

    def add_job(item)
    end

    def get(class_name, group, name)
    end

    def get_job_for_trigger(trigger)
    end

    # could change at some point to acquire more than one at a time...
    def acquire_next_trigger(no_later_than)
    end

    def release_trigger(trigger)
    end

    def trigger_fired(trigger)
    end

    def trigger_error(trigger, exception)
    end

  end
end