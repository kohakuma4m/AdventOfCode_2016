require "set"

class Solution

    def initialize(data = "")
        @data = data
    end

    def solution1
        bots_map = init_bots(@data)
        output_bins_map = init_outputs_bins(bots_map.values)

        simulate_bots(bots_map, output_bins_map)

        target_chips = [17, 61].to_set
        target_bot = bots_map.values.find { |bot| (target_chips - bot.processed_values).empty? }

        puts "========================"
        bots_map.each { |id, bot| puts bot }
        puts "========================"
        puts "Solution #1: #{target_bot&.id || "???" }"
        puts "========================"
    end

    def solution2
        bots_map = init_bots(@data)
        output_bins_map = init_outputs_bins(bots_map.values)

        simulate_bots(bots_map, output_bins_map)

        target_bins = [0, 1, 2].map(&:to_s)
        result = target_bins.map { |id| output_bins_map[id].values.reduce(&:*) }.reduce(&:*)

        puts "========================"
        output_bins_map.each { |id, bin| puts bin }
        puts "========================"
        puts "Solution #2: #{result}"
        puts "========================"
    end

    ###################################

    OUTPUT_TYPES = { bot: "bot", output: "output" }

    Output = Struct.new(:id, :type) {
        def to_s
            return "#{type} ##{id}"
        end
    }

    Bot = Struct.new(:id, :values, :processed_values, :low_output, :high_output) {
        def to_s
            return "bot ##{id}, values: #{values}, processed values: #{processed_values.to_a}, low --> #{low_output}, high --> #{high_output}"
        end
    }

    Bin = Struct.new(:id, :values) {
        def to_s
            return "output bin ##{id}, values: #{values}"
        end
    }

    INPUT_INSTRUCTIONS_REGEX = /^value (\d+) goes to bot (\d+)$/
    OUTPUT_INSTRUCTIONS_REGEX = /^bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)$/

    def init_bots(data)
        lines = data.split("\n")

        # Initializing bots
        bots_map = {}
        lines.select { |line| line.start_with?("value") }
            .each { |line|
                value, bot_id = line.match(INPUT_INSTRUCTIONS_REGEX).captures
                if !bots_map[bot_id]
                    bots_map[bot_id] = Bot.new(bot_id, [], Set.new)
                end

                bots_map[bot_id].values.push(Integer(value))
            }

        # Giving intructions to bots
        lines.select { |line| line.start_with?("bot") }
            .each { |line|
                bot_id, low_output_type, low_output_id, high_output_type, high_output_id = line.match(OUTPUT_INSTRUCTIONS_REGEX).captures
                if !bots_map[bot_id]
                    bots_map[bot_id] = Bot.new(bot_id, [], Set.new)
                end

                bots_map[bot_id].low_output = Output.new(low_output_id, low_output_type)
                bots_map[bot_id].high_output = Output.new(high_output_id, high_output_type)
            }

        return bots_map.sort_by { |id, bot| id.to_i }.to_h
    end

    def init_outputs_bins(bots)
        output_bins_map = {}

        bots.each do |bot|
            if bot.low_output.type == OUTPUT_TYPES[:output]
                output_bins_map[bot.low_output.id] = Bin.new(bot.low_output.id, [])
            end
            if bot.high_output.type == OUTPUT_TYPES[:output]
                output_bins_map[bot.high_output.id] = Bin.new(bot.high_output.id, [])
            end
        end

        return output_bins_map.sort_by { |id, bin| id.to_i }.to_h
    end

    def simulate_bots(bots_map, output_bins_map)
        loop do
            # Getting next active bots
            active_bots = bots_map.values.select { |bot| bot.values.length == 2 }
            if active_bots.length == 0
                break
            end

            active_bots.each do |bot|
                bot.values.sort!
                bot.processed_values.merge(bot.values)
                min_val = bot.values.shift
                max_val = bot.values.pop

                # Low output
                case bot.low_output.type
                    when OUTPUT_TYPES[:output]
                        output_bins_map[bot.low_output.id].values.push(min_val)
                    when OUTPUT_TYPES[:bot]
                        bots_map[bot.low_output.id].values.push(min_val)
                end

                # High output
                case bot.high_output.type
                    when OUTPUT_TYPES[:output]
                        output_bins_map[bot.high_output.id].values.push(max_val)
                    when OUTPUT_TYPES[:bot]
                        bots_map[bot.high_output.id].values.push(max_val)
                end
            end
        end
    end

end