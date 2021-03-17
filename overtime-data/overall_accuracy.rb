require 'csv'
require 'byebug'

class Array         
    def [](index)
       self.at(index) ? self.at(index) : 0
    end
end

valid_types = ['normal', 'one']

type = ARGV[0]

unless valid_types.include?(type)
    puts "Invalid type #{type}! Should be 'normal' or 'one'!"
    exit(0)
end

percentages = ['10%', '30%', '50%', '70%', '100%']

current_dir = "./"

average = []
total = []


Dir.foreach(current_dir) do |filename|
    next unless filename.include?("#{type}.csv")

    csv = CSV.read(current_dir+filename)
    csv.each_with_index do |line, line_index|
        if line_index == 0
            average[line_index] = csv[line_index] if average[line_index] == 0
            total[line_index] = csv[line_index] if total[line_index] == 0
            next
        end
        average[line_index] = [] if average[line_index] == 0
        total[line_index] = [] if total[line_index] == 0
        line.each_with_index do |item, row_index|
            next if row_index == 0
            if csv[line_index][row_index] != 0
                total[line_index][row_index] += 1
                average[line_index][row_index] += csv[line_index][row_index].to_f
            end
        end
    end
end

average.each_with_index do |line, line_index|
    next if line_index == 0
    average[line_index][0] = line_index-1 
    line.each_with_index do |item, row_index|
        byebug
        next if row_index == 0
        average[line_index][row_index] = average[line_index][row_index].to_f/total[line_index][row_index].to_f
    end
end

out_csv = average.map { |c| c.join(",") }.join("\n")

File.write(current_dir+"overtime-overall-#{type}.csv", out_csv)
