require 'csv'

class Array         
    def [](index)
       self.at(index) ? self.at(index) : 0
    end
end

overtime_path = "./overtime"

percentages = [10, 30, 50, 70, 100]

Dir.foreach(overtime_path) do |percentage|
    next unless percentages.include?(percentage.to_i)

    overtime_accuracy = []
    counter = []

    Dir.foreach("#{overtime_path}/#{percentage}") do |overtime_file|
        next if overtime_file == ".." || overtime_file == "."
        over_file = File.open("#{overtime_path}/#{overtime_file}")
        overtime_raw = over_file.read
        over_file.close

        overtime = CSV.parse(overtime_raw)

        overtime.each do |overtime_item|
            counter[overtime_item[0]] += 1
            overtime_accuracy[overtime_item[0]] += overtime_item[1].to_i
        end
    end

    out_csv_text = "samples,accuracy"
    overtime_accuracy.each_with_index do |oa, i|
        out_csv_text += "\n#{i},#{overtime_accuracy[i].to_f/counter[i].to_f}"
    end

    File.open("#{overtime_path}/#{percentage}/overtime_accuracy.csv", 'w') { |file| file.write(out_csv_text) }
end