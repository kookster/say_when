require 'date'

module SayWhen

  # Based on the extended cron capabilties 
  # http://wiki.opensymphony.com/display/QRTZ1/CronTriggers+Tutorial
  class CronExpression
    attr_reader :expression
    attr_accessor :time_zone, :seconds, :minutes, :hours, :days_of_month, :months, :days_of_week, :years

    def initialize(expression, time_zone=nil)
      if expression.is_a?(Hash)
        opts = expression

        @expression = if opts[:expression]
          opts[:expression]
        else
          [:days_of_month, :days_of_week].each do |f|
            opts[f] ||= '?'
          end

          [:seconds, :minutes, :hours, :days_of_month, :months, :days_of_week, :years].each do |f|
            opts[f] ||= '*'
          end
          
          "#{opts[:seconds]} #{opts[:minutes]} #{opts[:hours]} #{opts[:days_of_month]} #{opts[:months]} #{opts[:days_of_week]} #{opts[:years]}"
        end
        
        @time_zone = if opts.has_key?(:time_zone) && !opts[:time_zone].blank?
          opts[:time_zone]
        else
          Time.zone.nil? ? "UTC" : Time.zone.name
        end

      else
        @expression = expression
        @time_zone = if time_zone.blank?
            Time.zone.nil? ? "UTC" : Time.zone.name
          else
            time_zone
          end
      end

      parse
      validate
    end
    
    def parse
      return if @expression.blank? 
      vals = @expression.split.collect{|word| word.upcase.gsub(/\s/, '')}
      @seconds = SecondsCronValue.new(vals[0])
      @minutes = MinutesCronValue.new(vals[1])
      @hours = HoursCronValue.new(vals[2])
      @days_of_month = DaysOfMonthCronValue.new(vals[3])
      @months = MonthsCronValue.new(vals[4])
      @days_of_week = DaysOfWeekCronValue.new(vals[5])
      @years = YearsCronValue.new(vals[6] || "*")    
    end
  
    def validate
      return if @expression.blank? 
      raise "days_of_week or days_of_month needs to be ?" if (@days_of_month.is_specified && @days_of_week.is_specified)
    end
  
    def to_s
      "s:#{seconds}m:#{minutes}h:#{hours}dom:#{days_of_month}m:#{months}dow:#{days_of_week}y:#{years}"
    end
    
    def will_fire_on?(date)
     # puts "will fire on? #{date} : #{self.to_s}"
      [@seconds, @minutes, @hours, @days_of_month, @months, @days_of_week, @years].detect{|part| !part.include?(date)}.nil?
    end

    def next_fire_at(time=nil)
      Time.zone = @time_zone
      after = time.nil? ? Time.zone.now : time.in_time_zone(@time_zone)
      # after = 1.second.since(after)
      # puts "next fire at after: #{after.inspect}"

      while (true)
        [years, months, days_of_month, days_of_week, hours, minutes, seconds].each do |cron_value|
          # puts "next_fire_at cron val loop: #{cron_value.part}"
          # puts "before move_to_next: #{after.inspect}"
          after, changed = move_to_next(cron_value, after)
          # puts "after move_to_next:  #{after.inspect}"
          return if after.nil?
          break if changed
        end
        
        break if will_fire_on?(after)
      end
      # puts "NEXT FIRE AT: #{after}, NOW: #{Time.zone.now}"
      return after
    end

    def last_fire_at(time=nil)
      Time.zone = @time_zone
      before = time.nil? ? Time.zone.now : time.in_time_zone(@time_zone)
      # before = 1.second.ago(before)
      # puts "last fire at before: #{before.inspect}"

      while (true)
        [years, months, days_of_month, days_of_week, hours, minutes, seconds].each do |cron_value|
          # puts "last_fire_at cron val loop: #{cron_value.part} for #{before.inspect}"
          # puts "before move_to_last: #{before.to_s}"
          before, changed = move_to_last(cron_value, before)
          # puts "after move_to_last:  #{before.to_s}"
          return if before.nil?
          break if changed
        end
        
        break if will_fire_on?(before)
      end
      # puts "NEXT FIRE AT: #{before}, NOW: #{Time.zone.now}"
      return before
    end

    protected

    def move_to_next(cron_value, after)
      unless cron_value.include?(after)
        after = cron_value.next(after)
        [after, true]
      end
      [after, false]
    end

    def move_to_last(cron_value, before)
      unless cron_value.include?(before)
        before = cron_value.last(before)
        [before, true]
      end
      [before, false]
    end

  
  end

  class CronValue
    attr_accessor :part, :min, :max, :expression, :values  
  
    def initialize(p, min, max, exp)
      self.part = p
      self.min = min
      self.max = max
      self.values = []
      self.expression = exp
      parse(exp)
    end
  
    def parse(exp)
      self.values = self.class.parse_number(self.min, self.max, exp.upcase)
    end

    def to_s
      "[e:#{self.expression}, v:#{self.values.inspect}]\n" 
    end
    
    def include?(date)
      self.values.include?(date.send(part))
    end
  
    #works for secs, mins, hours
    def self.parse_number(min, max, val)
      values = []
      case val
        #check for a '/' for increments
        when /(\w+)\/(\d+)/ then (( $1 == "*") ? min : $1.to_i).step(max, $2.to_i) {|x| values << x}
    
        #check for ',' for list of values
        when /(\d+)(,\d+)+/ then values = val.split(',').collect{|v| v.to_i}.sort
    
        #check for '-' for range of values
        when /(\d+)-(\d+)/ then values = (($1.to_i)..($2.to_i)).to_a

        #check for '*' for all values between min and max
        when /^(\*)$/ then values = (min..max).to_a

        #lastly, should just be a number
        when /^(\d+)$/ then values << $1.to_i

        #if nothing else, leave values as []
        else values = []
      end
      values
    end
  end

  class SecondsCronValue < CronValue
    def initialize(exp)
      super(:sec, 0, 59, exp)
    end

    def next(date)
      # date = date.to_time
      n = self.values.detect{|v| v > date.sec}
      if n.blank?
        1.minute.since(date).change(:sec=>self.values.first)
      else
        date.change(:sec=>n)
      end
    end
    
    def last(date)
      # date = date.to_time
      n = self.values.reverse.detect{|v| v < date.sec}
      if n.blank?
        1.minute.ago(date).change(:sec=>self.values.last)
      else
        date.change(:sec=>n)
      end
    end
    

  end

  class MinutesCronValue < CronValue
    def initialize(exp)
      super(:min, 0, 59, exp)
    end

    def next(date)
      # date = date.to_time
      n = self.values.detect{|v| v > date.min}
      if n.blank?
        1.hour.since(date).change(:min=>self.values.first, :sec=>0)
      else
        date.change(:min=>n, :sec=>0)
      end
    end

    def last(date)
      # date = date.to_time
      n = self.values.reverse.detect{|v| v < date.min}
      if n.blank?
        1.hour.ago(date).change(:min=>self.values.last, :sec=>59)
      else
        date.change(:min=>n, :sec=>59)
      end
    end
  end

  class HoursCronValue < CronValue
    def initialize(exp)
      super(:hour, 0, 24, exp)
    end
    
    def next(date)
      # date = date.to_time
      # puts "HoursCronValue next: date: #{date.inspect}, hour: #{date.hour}"
      n = self.values.detect{|v| v > date.hour}
      if n.blank?
        1.day.since(date).change(:hour=>self.values.first, :min=>0, :sec=>0)
      else
        date.change(:hour=>n, :min=>0, :sec=>0)
      end
    end

    def last(date)
      # date = date.to_time
      n = self.values.reverse.detect{|v| v < date.hour}
      if n.blank?
        1.day.ago(date).change(:hour=>self.values.last, :min=>59, :sec=>59)
      else
        date.change(:hour=>n, :min=>59, :sec=>59)
      end
    end

  end

  class DaysOfMonthCronValue < CronValue
    attr_accessor :is_specified, :is_last, :is_weekday
    def initialize(exp)
      self.is_last = false
      self.is_weekday = false
      super(:mday, 1, 31, exp)
    end
  
    def parse(exp)
      if self.is_specified = !(self.expression =~ /\?/)
        case exp
          when /^(L)$/ then self.is_last = true
          when /^(W)$/ then self.is_weekday = true
          when /^(WL|LW)$/ then self.is_last = (self.is_weekday = true)
          when /^(\d+)W$/ then self.is_weekday = true; self.values << $1.to_i 
          else super(exp)
        end
      end
    end

    def last(date)
      result = if !is_specified
        date
      elsif is_last
        eom = date.end_of_month
        eom = nearest_week_day(eom) if is_weekday
        if eom > date
          eom = 1.month.ago(date)
          eom = nearest_week_day(eom.change(:day=>eom.end_of_month))
        end
        eom
      elsif is_weekday
        if values.empty?
          nearest = nearest_week_day(date)
          if nearest > date
            nearest = 1.month.ago(date)
            nearest = nearest_week_day(date.change(:day=>date.end_of_month))
          end
        else
          nearest = nearest_week_day(date.change(:day=>values.first))
          nearest = nearest_week_day(1.month.ago(date).change(:day=>values.first)) if nearest > date
        end
        nearest
      else
        # puts "change to the next specified day of the month...#{self.values.inspect} "
        l = self.values.reverse.detect{|v| v < date.mday}
        # puts "last should be #{n}"
        if l.blank?
          1.month.ago(date).change(:day=>self.values.last)
        else
          # puts "change date to have day of month of #{n}"
          date.change(:day=>l.to_i)
        end
      end
      result = result.change(:hour=>23, :min=>59, :sec=>59)
      # puts "result after change #{result}"
      result
    end
    
    def next(date)
      result = if !is_specified
        date
      elsif is_last
        last = date.end_of_month
        last = nearest_week_day(last) if is_weekday
        # last = nearest_week_day(1.month.since(date).change(:day=>1)) if last < date
        if last < date
          last = 1.month.since(date)
          last = nearest_week_day(last.change(:day=>last.end_of_month))
        end
        last
      elsif is_weekday
        if values.empty?
          nearest = nearest_week_day(date)
          nearest = nearest_week_day(1.month.since(date).change(:day=>1)) if nearest < date
        else
          nearest = nearest_week_day(date.change(:day=>values.first))
          nearest = nearest_week_day(1.month.since(date).change(:day=>values.first)) if nearest < date
        end
        nearest
      else
        # puts "change to the next specified day of the month...#{self.values.inspect} "
        n = self.values.detect{|v| v > date.mday}
        # puts "next should be #{n}"
        if n.blank?
          date.months_since(1).change(:day=>self.values.first) 
        else
          # puts "change date to have day of month of #{n}"
          ndate = date.change(:day=>n.to_i)
          # puts "after change date #{ndate}, #{ndate.class.name}"
          ndate
        end
      end
      result = result.change(:hour=>0)
      # puts "result after change #{result}"
      result
    end
    
    def include?(date)
      return true unless is_specified
      last = date.clone
      #must be last weekday of the month
      if is_last
        last = last.end_of_month.to_date
        last = nearest_week_day(last) if is_weekday
        last == date.to_date
      elsif is_weekday
        if values.empty?
          (1..5).include?(date.wday)
        else
          nearest_week_day(date.change(:day=>values.first)) == date
        end
      else
        super(date)
      end
    end
    
    def nearest_week_day(date)
      if (1..5).include?(date.wday)
        date
      elsif date.wday == 6
        (date.beginning_of_month.to_date == date.to_date) ? 2.days.since(date) : 1.day.ago(date)
      elsif date.wday == 0
        (date.end_of_month.to_date == date.to_date) ? date = 2.days.ago(date) : 1.day.since(date)
      end
    end
    
    def to_s
      "[e:#{self.expression}, v:#{self.values.inspect}, is:#{is_specified}, il:#{is_last}, iw:#{is_weekday}]\n" 
    end  
  end

  class MonthsCronValue < CronValue
    MONTHS = Date::ABBR_MONTHNAMES[1..-1].collect{|a| a.upcase } 
  
    def initialize(exp)
      super(:month, 1, 12, exp)
    end
  
    def parse(exp)    
      if exp =~ /[A-Z]+/
        MONTHS.each_with_index{|mon, index| 
          exp = exp.gsub(mon, (index+1).to_s)
        }
      end
      super(exp)
    end

    def last(date)
      last_month = self.values.reverse.detect{|v| v < date.month} 
      result = if last_month.nil?
        date.change(:year=>date.year - 1, :month=>self.values.last)
      else
        date.change(:month=>last_month)
      end
      result.change(:day=>result.end_of_month, :hour=>23, :min=>59, :sec=>59)
    end

    def next(date)
      next_month = self.values.detect{|v| v > date.month} 
      result = if next_month.nil?
        date.change(:year=>date.year + 1, :month=>self.values.first, :day=>1, :hour=>0)
      else
        date.change(:month=>next_month, :day=>1, :hour=>0)
      end
      result
    end

  end

  class DaysOfWeekCronValue < CronValue
    DAYS = Date::ABBR_DAYNAMES.collect{|a| a.upcase }
    attr_accessor :is_specified, :is_last, :nth_day

    def initialize(exp)
      self.is_last = false
      super(:wday, 1, 7, exp)
    end

    def parse(exp)
      if self.is_specified = !(self.expression =~ /\?/)
        if exp =~ /[A-Z]+/
          DAYS.each_with_index{|day, index| 
            exp = exp.gsub(day, (index+1).to_s)
          }
        end
        case exp
          when /^L$/ then values << self.max
          when /^(\d+)L$/ then self.is_last = true; values << $1.to_i
          when /^(\d+)#(\d+)/ then self.values << $1.to_i; self.nth_day = $2.to_i
          else super(exp)
        end
      end
    end

    def include?(date)
      # puts "DaysOfWeekCronValue::include? is_specified:#{is_specified}, date:#{date}"
      return true unless is_specified
      if is_last
        last = last_wday(date, values.first).to_date
        # puts "checking is_last: date=#{date} == last #{last}"
        date.to_date == last
      elsif nth_day
        date.to_date == nth_wday(self.nth_day, self.values.first, date.month, date.year).to_date
      else
        self.values.include?(date.wday+1)
      end
    end
    
    def last(date)
      # puts "DaysOfWeekCronValue::last date:#{date}, is_last:#{is_last}"
      last_dow = if !is_specified
        date
      elsif is_last
        last = last_wday(date, values.first)
        # puts "DaysOfWeekCronValue::last after first last_wday: #{date}"
        if last.to_date > date.to_date
          last = last_wday(1.month.ago(date).change(:day=>1), values.first)
        end
        last
      elsif nth_day
        nth = nth_wday(self.nth_day, self.values.first, date.month, date.year)
        # puts "DaysOfWeekCronValue::last after first nth_wday: #{nth}"
        if nth.to_date > date.to_date
          nth = 1.month.ago(date).change(:day=>1)
          nth = nth_wday(self.nth_day, self.values.first, nth.month, nth.year)
        end
        nth
      else
        n = self.values.detect{|v| v > date.wday}
        n = self.values[0] if n.blank?
        base = (n < (date.wday + 1)) ? 7 : 0
        days_forward = n + (base - (date.wday + 1))
        days_forward.days.since(date)
      end
      last_dow = last_dow.change(:hour=>23, :min=>59, :sec=>59)
      # puts "DaysOfWeekCronValue: #{last_dow.class.name}: #{last_dow.to_s}"
      last_dow
    end

    def next(date)
      next_dow = if !is_specified
        date
      elsif is_last
        last = last_wday(date, values.first)
        # puts "1 last_wday = #{last}"
        if last.to_date <= date.to_date
          last = last_wday(1.month.since(date).change(:day=>1), values.first)
          # puts "2 last_wday = #{last}"
        end
        last
      elsif nth_day
        nth = nth_wday(self.nth_day, self.values.first, date.month, date.year)
        if nth.to_date <= date.to_date
          date = 1.month.since(date)
          nth = nth_wday(self.nth_day, self.values.first, date.month, date.year)
        end
        nth
      else
        n = self.values.detect{|v| v > date.wday}
        n = self.values[0] if n.blank?
        base = (n < (date.wday + 1)) ? 7 : 0
        days_forward = n + (base - (date.wday + 1))
        days_forward.days.since(date)
      end
      next_dow.change(:hour=>0)
    end

    # 1 last_wday = 2008-05-30
    # latest_wday date=Sun Jun 01 10:00:00 -0400 2008, wday=5
    # 2 last_wday = 2008-06-28 '
    #   **** should be 06-27
    def last_wday(date, aWday)
      # puts "last_wday date=#{date.to_time}, wday=#{wday}"
      # sleep(1)
      wday = aWday - 1
      eom = date.end_of_month
      if eom.wday == wday
        eom
      elsif eom.wday > wday
        (eom.wday - wday).days.ago(eom)
      else
        ((7 - wday) + eom.wday).days.ago(eom)
      end
    end

    # compliments of the ruby way
    def nth_wday(n, aWday, month, year)
      wday = aWday - 1
      if (!n.between? 1,5) or
         (!wday.between? 0,6) or
         (!month.between? 1,12)
        raise ArgumentError
      end
      t = Time.zone.local year, month, 1
      # puts "t = #{t}"
      first = t.wday
      if first == wday
        fwd = 1
      elsif first < wday
        fwd = wday - first + 1
      elsif first > wday
        fwd = (wday+7) - first + 1
      end
      target = fwd + (n-1)*7
      begin
        t2 = Time.zone.local year, month, target
        # puts "t2 = #{t2}"
      rescue ArgumentError
        return nil
      end
      if t2.mday == target
        t2
      else
        nil
      end
    end


    def to_s
      "[e:#{self.expression}, v:#{self.values.inspect}, is:#{is_specified}, il:#{is_last}, nd:#{nth_day}]\n" 
    end

  end

  class YearsCronValue < CronValue
    def initialize(exp)
      super(:year, 1970, 2099, exp)
    end

    def next(date)
      next_year = self.values.detect{|v| v > date.year} 
      if next_year.nil? 
        return nil
      else
        date.change(:year=>next_year, :month=>1, :day=>1, :hour=>0)
      end
    end

    def last(date)
      last_year = self.values.reverse.detect{|v| v < date.year} 
      if last_year.nil? 
        return nil
      else
        date.change(:year=>last_year, :month=>12, :day=>31, :hour=>23, :min=>59, :sec=>59)
      end
    end

  end

end
