require 'json'
require 'byebug'

samples_folder_path = ARGV[0]

k_value = 1


if ARGV.length < 1
    puts "Usage: ruby probability_runner <samples_folder_path>"
    exit
end
output_path = "./runner_output.txt"

counter = {}

untar_cmd = "tar -xjf #{samples_folder_path}/original_problem.tar.bz2"
system(untar_cmd)
hyps_file = File.open("./hyps.dat")
hyps = hyps_file.read
hyps_file.close
hyps = hyps.split("\n")
hyps.length.times do |ind|
    hyps[ind] = hyps[ind].strip.downcase
    counter[hyps[ind]] = 0
end
system("rm *.pddl *.dat")

next_priors = {}
# samples = hyps.uniq.length * 10
samples = 250

problem_name_path = "#{samples_folder_path}/problem_name.txt"
problem_name_file = File.open(problem_name_path)
problem_name = problem_name_file.read
problem_name_file.close

overtime_path = "./overtime"

system("mkdir #{overtime_path}")

overtime_out = ""

cmd = "java -jar probabilistic-recognizer-landmarks0.5.jar #{samples_folder_path}/original_problem.tar.bz2 > /dev/null"
system(cmd)

output_path = "#{samples_folder_path}/original_problem.txt"
output_file = File.open(output_path)
output = output_file.read
output_file.close
correct = output.split("CORRECT = ")[1].split("\n")[0] == "true"

original_correct_out = correct ? '1' : '0'
overtime_out += "#{0},#{original_correct_out}\n"

samples.times do |sample|
    puts "Running for sample #{sample}"
    sample_file_name = "problem_#{sample}.tar.bz2"
    system("cp #{samples_folder_path}/#{sample_file_name} ./")
    cmd = "java -jar probabilistic-recognizer-landmarks0.5.jar #{sample_file_name} > /dev/null"
    system(cmd)
    output_path = "problem_#{sample}.txt"
    output_file = File.open(output_path)
    output = output_file.read
    output_file.close
    system("rm #{sample_file_name} #{output_path}")
    recognized = output.split("MOST_LIKELY_GOALS:\n")[1].split("\nREAL_GOAL = ")[0].strip.split("\n")
    correct = output.split("CORRECT = ")[1].split("\n")[0] == "true"
    if correct
        recognized.each do |rec|
            counter[rec.split(" = ")[0].strip] += 1
        end
    end

    hyps.each do |hyp|
        next_priors[hyp] = ((counter[hyp] + k_value).to_f)/((counter.values.reduce(0, :+) + (hyps.length * k_value)).to_f)
    end
    
    File.open("./priors.dat", "w") do |file|
        next_priors.sort_by {|k, v| v}.reverse.each do |p|
            string_to_print = "#{p[0]} = #{p[1]}\n"
            file.puts(string_to_print)
        end
    end
    system("tar -xjf #{samples_folder_path}/original_problem.tar.bz2")
    system("tar -cjf ./original_problem_priors.tar.bz2 ./*.pddl ./*.dat")
    system("mv ./original_problem_priors.tar.bz2  #{samples_folder_path}/")
    system("rm *.pddl *.dat")

    cmd = "java -jar probabilistic-recognizer-landmarks0.5.jar #{samples_folder_path}/original_problem_priors.tar.bz2 > /dev/null"
    system(cmd)

    output_path = "#{samples_folder_path}/original_problem_priors.txt"
    output_file = File.open(output_path)
    output = output_file.read
    output_file.close
    correct = output.split("CORRECT = ")[1].split("\n")[0] == "true"

    original_correct_out = correct ? '1' : '0'
    overtime_out += "#{sample+1},#{original_correct_out}\n"
end


File.open("#{overtime_path}/#{problem_name.strip}.csv", 'w') { |file| file.write(overtime_out) }

hyps.each do |hyp|
    next_priors[hyp] = ((counter[hyp] + k_value).to_f)/((counter.values.reduce(0, :+) + (hyps.length * k_value)).to_f)
end

File.open("./priors.dat", "w") do |file|
    next_priors.sort_by {|k, v| v}.reverse.each do |p|
        string_to_print = "#{p[0]} = #{p[1]}\n"
        file.puts(string_to_print)
    end
end
system("tar -xjf #{samples_folder_path}/original_problem.tar.bz2")
system("tar -cjf ./original_problem_priors.tar.bz2 ./*.pddl ./*.dat")
system("mv ./original_problem_priors.tar.bz2  #{samples_folder_path}/")
system("rm *.pddl *.dat")
