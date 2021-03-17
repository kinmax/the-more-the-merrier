current_dir = "./"

Dir.foreach(current_dir) do |filename|
    next unless filename.split(".")[1] == "csv"
    csv = csv.read(current_dir+filename)
    csv.each_with_index do |line, line_index|
        next if line == 0
        line.each_with_index do |item, row_index|
            next if row_index == 0
            csv[line_index][row_index] = item * 100.to_f
        end
    end

    out_csv = csv.map { |c| c.join(",") }.join("\n")

    File.write()
end