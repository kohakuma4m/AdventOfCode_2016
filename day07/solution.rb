class Solution

    def initialize(data = "")
        @ip_addresses = data.split("\n")
    end

    def solution1
        tls_ips = @ip_addresses.select { |ip| ip =~ TLS_SUPPORT_REGEX }

        puts "========================"
        puts "Solution #1: #{tls_ips.length}"
        puts "========================"
    end

    def solution2
        ssl_ips = @ip_addresses.select { |ip| ip =~ SSL_SUPPORT_REGEX }

        puts "========================"
        puts "Solution #2: #{ssl_ips.length}"
        puts "========================"
    end

    ###################################

    TLS_SUPPORT_REGEX = /
        # No ABBA in any hypernet sequence from start
        ^(?!
            .*?
            \[\w*?(\w)(?!\1)(\w)\2\1\w*?\] # Valid ABBA inside hypernet sequence
            .*?
        )
        # First matching ABBA outside hypernet sequence
        (?=
            .*?
            (\w)(?!\3)(\w)\4\3 # Valid ABBA
            .*?
        )
    /x

    # Assuming all brackets [] are in matching pair...
    SSL_SUPPORT_REGEX = /
        (?=
            # First matching ABA outside hypernet sequence followed by BAB inside hypernet sequence
            .*?
            (\w)(?!\1)(\w)\1   (?!\w*?\]) # Valid ABA...not followed by closing hypernet sequence bracket
            .*?
            \[\w*?\2\1\2\w*?\] # BAB inside hypernet sequence
            .*?

            | # Or

            # First matching ABA inside hypernet sequence followed by BAB outside hypernet sequence
            .*?
            \[\w*?(\w)(?!\3)(\w)\3\w*?\] # Valid ABA inside hypernet sequence...
            .*?
            \4\3\4   (?!\w*?\]) # BAB...not followed by closing hypernet sequence bracket
            .*?
        )
    /x

end