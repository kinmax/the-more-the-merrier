require 'json'
require 'byebug'

samples_folder_path = ARGV[0]
threshold = ARGV[1].to_i
extraction_method = ARGV[2]

k_value = 1
samples = 10


if ARGV.length < 3
    puts "Usage: ruby probability_runner <samples_folder_path> <threshold> <extraction_method>"
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

samples.times do |sample|
    puts "Running for sample #{sample}"
    sample_file_name = "problem_#{sample}.tar.bz2"
    cmd = "ruby probability_analyser.rb #{samples_folder_path}/#{sample_file_name} #{threshold} #{extraction_method} > #{output_path}"
    system(cmd)
    output_file = File.open(output_path)
    output = output_file.read
    output_file.close
    system("rm #{output_path}")
    probs = output.split("#####")[1].strip
    probs = probs.split("\n")
    best = probs.first.split("###")[0].strip.downcase
    recognized = []
    correct = output.split("CORRECT-")[1].split("\n")[0] == "TRUE"
    # comment out 2 of the following 3 blocks according to your needs
    # BLOCK 1 - adds 1 to every goal in recognized list
    probs.each do |prob|
        if(prob.include?("RECOGNIZED") && correct)
            counter[prob.split("###")[0]] += 1
        end
    end
    # BLOCK 2 - adds one to the single best goal
    # counter[best] += 1 if correct 
    # BLOCK 3 - uses each goal's probability to form the priors
    # if correct
    #     probs.each do |prob|
    #         goal = prob.split("###")[0]
    #         probability = prob.split("###")[1].to_f
    #         counter[goal] += probability*100
    #     end
    # end
    hyps.each do |hyp|
        next_priors[hyp] = ((counter[hyp] + k_value).to_f)/((counter.values.sum + (hyps.length * k_value)).to_f)
    end
    File.open("./priors.dat", "w") do |file|
        next_priors.sort_by {|k, v| v}.reverse.each do |p|
            string_to_print = "#{p[0]} ### #{p[1]}}\n"
            file.puts(string_to_print)
        end
    end
    if sample == samples-1
        system("tar -xjf #{samples_folder_path}/original_problem.tar.bz2")
        system("tar -cjf ./original_problem_priors.tar.bz2 ./*.pddl ./*.dat")
        system("mv ./original_problem_priors.tar.bz2  #{samples_folder_path}/")
        system("rm *.pddl *.dat")
        break
    end
    untar_cmd = "tar -xjf #{samples_folder_path}/problem_#{sample+1}.tar.bz2"
    system(untar_cmd)
    system("rm #{samples_folder_path}/problem_#{sample+1}.tar.bz2")
    tar_cmd = "tar -cjf ./problem_#{sample+1}.tar.bz2 ./*.pddl ./*.dat"
    system("rm ./priors.dat")
    system(tar_cmd)
    system("mv ./problem_#{sample+1}.tar.bz2 #{samples_folder_path}/")
    system("rm *.pddl *.dat")
end

cmd = "ruby probability_analyser.rb #{samples_folder_path}/original_problem_priors.tar.bz2 #{threshold} #{extraction_method} > #{output_path}"
system(cmd)
output_file = File.open(output_path, "r")
output = output_file.read
output_file.close
system("rm #{output_path}")
system("rm *.pddl *.dat")
puts output
