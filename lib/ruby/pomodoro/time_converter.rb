module Ruby
  module Pomodoro
    module TimeConverter
      class << self
        def to_format_string(seconds)
          days = seconds / 60 / 60 / 24
          hours = (seconds - days * 24 * 60 * 60) / 60 / 60
          minutes = (seconds - (hours * 60 * 60) - (days * 24 * 60 * 60)) / 60
          {d: days, h: hours, m: minutes}.select { |_k, v| v.positive? }.each.with_object(String.new) do |item, acc|
            acc << item.reverse.join(":") + " "
          end.strip
        end

        def to_seconds(format_string)
          return 0 if format_string.nil?

          match = format_string.split(" ").compact.map do |item|
            if item
              item.split(":").reverse.then { |res| res.size == 2 ? res : nil }
            end
            end.compact.to_h.select { |k| %w[m h d].include?(k) }
          (match["d"].to_i * 24 * 60 * 60) + (match["h"].to_i * 60 * 60) + (match["m"].to_i * 60)
        end
      end
    end
  end
end
