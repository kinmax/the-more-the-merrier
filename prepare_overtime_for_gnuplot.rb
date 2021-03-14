require 'csv'

class Array
    def [](index)
       self.at(index) ? self.at(index) : 0
    end
end

percentages = [10, 30, 50, 70, 100]

overtime_path = "./overtime"

csvs = {}

number_of_samples = -1

Dir.foreach(overtime_path) do |percentage|
	next unless percentages.include?(percentage.to_i)
	csv = CSV.read("#{overtime_path}/#{percentage}/overtime_accuracy.csv")
	csvs[percentage] = csv
	number_of_samples = csv.size if csv.size > number_of_samples
end

new_csv = "\"Number of Samples\",\"10%\",\"30%\",\"50%\",\"70%\",\"100%\"\n"

number_of_samples.times do |sample|
	new_csv += "#{sample},#{csvs["10"][sample]},#{csvs["30"][sample]},#{csvs["50"][sample]},#{csvs["70"][sample]},#{csvs["100"][sample]}"
	new_csv = new_csv + "\n" unless sample == number_of_samples - 1
end

File.open("#{overtime_path}/overtime_accuracy.csv", 'w') { |file| file.write(new_csv) }
