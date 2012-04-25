module SayWhen
  module BaseJob

    def execute(trigger=nil)
      self.execute_job((data || {}).merge(:trigger=>trigger))
    end

    def execute_job(options={})
      tm = (self.job_method || 'execute').to_sym
      tc = self.job_class.constantize
      task = if tc.respond_to?(tm)
        tc
      else
        to = tc.new
        if to.respond_to?(tm)
          to
        else
          raise "Neither #{self.job_class} class nor instance respond to #{tm}"
        end
      end

      task.send(tm, options)
    end

  end
end
