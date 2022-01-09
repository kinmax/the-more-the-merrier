require 'json'
require 'byebug'

samples_folder_path = ARGV[0]

domain = ARGV[1]

prob_approach = ARGV[2]

k_value = 1


if ARGV.length < 4
    puts "[ERROR] Usage: ruby probability_runner <samples_folder_path> <domain> <prob_approach>"
    exit
end
output_path = "./runner_output.txt"

prob_approaches = ['prob-gc-definite', 'prob-gc-definite-possible', 'prob-gc-definite-overlooked',
              'prob-gc-definite-possible-overlooked', 'prob-gc-possible', 'prob-gc-possible-overlooked',
              'prob-gc-overlooked', 'prob-uniqueness-definite', 'prob-uniqueness-possible', 'prob-uniqueness-overlooked',
              'prob-uniqueness-definite-overlooked', 'prob-uniqueness-definite-possible-overlooked', 
              'prob-uniqueness-possible-definite', 'prob-uniqueness-possible-overlooked']

unless prob_approaches.include?(prob_approach.strip)
    puts "[ERROR] Invalid probabilistic approach #{prob_apporach}"
    puts "Possible probabilistic approaches:"
    puts prob_approaches.join("\n")
    exit
end

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

samples.times do |sample|
    puts "Running for sample #{sample}"
    sample_file_name = "problem_#{sample}.tar.bz2"
    system("cp #{samples_folder_path}/#{sample_file_name} ./")
    cmd = "java -jar prob_recognizer1.0-incomplete_domains.jar #{sample_file_name} #{prob_apporach} > /dev/null"
    system(cmd)
    output_path = "problem_#{sample}.txt"
    output_file = File.open(output_path)
    output = output_file.read
    output_file.close
    system("rm #{sample_file_name} #{output_path}")
end

system("rm *.pddl *.dat")
