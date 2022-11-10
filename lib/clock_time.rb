##
# Class with static method to measure ealpsed time as an alternative to Time.now
# https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
##
class ClockTime

    def self.now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

end