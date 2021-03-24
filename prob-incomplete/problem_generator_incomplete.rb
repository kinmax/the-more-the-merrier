require 'json'
require 'byebug'

def uniform_distribution(candidates)
    probs = {}
    candidates.each do |c|
        probs[c] = 1.to_f/candidates.length.to_f
    end
    probs
end

def one_distribution(candidates, real_goal)
    probs = {}
    candidates.each do |c|
        probs[c] = c == real_goal ? 1.to_f : 0.to_f
    end
    probs
end

def normal_distribution(candidates, real_goal)
    probs = {}
    ordered_candidates = order_by_similarity(candidates, real_goal)
    prob = candidates.size > 1 ? 0.5 : 1.0
    left = candidates.size
    prob_left = 1.to_f
    final = false
    ordered_candidates.each_with_index do |oc, index|
        if index == 0
            probs[oc] = prob
            left -= 1
            prob_left -= prob
            next
        end
        if left <= 4 && index % 2 == 1 && !final
            prob = prob_left.to_f/left.to_f
            final = true
        end
        if final
            probs[oc] = prob
        else
            prob = prob/2.to_f if index % 2 == 1
            split_factor = index == 0 ? 1.to_f : 2.to_f
            probs[oc] = prob/split_factor
            probs[oc] += prob/2.to_f if index % 2 == 1 && index == ordered_candidates.length-1
        end
        prob_left -= probs[oc]
        left -= 1       
    end
    probs
end

def order_by_similarity(candidates, real_goal)
    candidates.sort { |a,b| similarity(real_goal, a) <=> similarity(real_goal, b) }.reverse
end

# number of facts in common between g1 and g2
# g1 is used as baseline, so this represents the similarity value of g2 in comparison to g1
# 1.0 = all facts are equal between g1 and g2, 0.0 = no facts in common between g1 and g2
def similarity(g1, g2)
    g1_facts = g1.split(",")
    g2_facts = g2.split(",")
    g1_facts.map{ |f| f.strip! }
    g2_facts.map{ |f| f.strip! }
    common = (g1_facts & g2_facts).length
    common.to_f/g1.length.to_f
end

def select_goal(probs)
    cands = probs.keys.sort{ |a, b| probs[a] <=> probs[b] }.reverse
    sum = 0.to_f
    r = rand()
    cands.each do |cand|
        if r >= sum && r < (sum + probs[cand])
            return cand
        end
        sum += probs[cand]
    end
    return cands.last
end

if ARGV.length < 5
    puts "Usage: ruby problem_generator.rb <tar_path> <probabilistic_distribution> <number_of_samples> <observation_level> <samples_folder_path>"
    exit
end

tar_path = ARGV[0]
system("tar -xjf #{tar_path}")

probabilistic_distribution = ARGV[1]
raise "Invalid probabilistic distribution! Must be one of those: [uniform one normal]" if !%w[uniform one normal].include?(probabilistic_distribution)

number_of_samples = ARGV[2].to_i
raise "Invalid number of samples! Must be greater than 0" if number_of_samples <= 0

observation_level = ARGV[3].to_i
raise "Invalid observation level! Must be an integer i where 0 <= i <= 100" if observation_level < 0 || observation_level > 100

samples_path = ARGV[4]

optimality = ARGV[5]
raise "Invalid optimality! Must be optimal or suboptimal" unless %w[optimal suboptimal].include?(optimality)

complete_domain = ARGV[6]
raise "Invalid complete domain file #{complete_domain} - not a file!" unless File.file?(complete_domain)

if optimality == 'optimal'
    fd_params = "--search \"astar(lmcut())\""
else
    fd_params = "--evaluator \"hff=ff()\" --search \"lazy_greedy([hff], preferred=[hff])\""
end

hyps_file = File.open("./hyps.dat", "r")
hyps = hyps_file.read
hyps_file.close
hyps = hyps.downcase
split_hyps = hyps.split("\n")
candidates = []
split_hyps.each do |hyp|
    if hyp.empty? || candidates.include?(hyp)
        next
    end
    hyp.strip!
    candidates.push(hyp)
end

template_file = File.open("./template.pddl", 'r')
template = template_file.read
template_file.close
template = template.downcase

domain_file = File.open("./domain.pddl", "r")
dom = domain_file.read
domain_file.close
dom = dom.downcase

real_hyp_file = File.open("./real_hyp.dat", "r")
real_hyp = real_hyp_file.read
real_hyp = real_hyp.downcase
real_hyp.strip!

probabilities = {}

system("rm -rf #{samples_path}")
system("mkdir #{samples_path}")

case(probabilistic_distribution)
when "uniform" 
    probabilities = uniform_distribution(candidates)
when "one"
    probabilities = one_distribution(candidates, real_hyp)
when "normal"
    probabilities = normal_distribution(candidates, real_hyp)
end

number_of_samples = candidates.size * 10

number_of_samples.times do |i|
    system("tar -xjf #{tar_path}")
    puts "Generating problem #{i}"
    new_problem_path = "#{samples_path}/problem_#{i}"
    system("mkdir #{new_problem_path}")
    system("cp ./domain.pddl #{new_problem_path}")
    system("cp ./template.pddl #{new_problem_path}")
    system("cp ./hyps.dat #{new_problem_path}")
    goal = select_goal(probabilities)
    problem = template.gsub("<hypothesis>", goal.gsub(",", " "))
    observation_level
    output_path = "#{new_problem_path}/problem.pddl"
    File.write(output_path, problem)    
    cmd = "python3 ./real-fd/fast-downward.py #{complete_domain} #{new_problem_path}/problem.pddl #{fd_params}  > ./output_#{probabilistic_distribution}.txt"
    system(cmd)
    plan_file = File.open("./output_#{probabilistic_distribution}.txt")
    plan = plan_file.read
    plan_file.close
    plan = plan.split("\n")
    start = 0
    finish = 0
    plan.each_with_index do |line, ind|
        start = ind + 1 if line.include?("Actual search time:")
        finish = ind - 1 if line.include?("Plan length:")
    end
    plan = plan[start..finish]
    plan.map {|action| action.gsub!(" (1)", "").strip!}
    number_of_actions = (plan.length.to_f * (observation_level.to_f/100.to_f)).ceil
    indexes_to_add = []
    while indexes_to_add.length < number_of_actions do
        r = rand(plan.length)
        indexes_to_add << r unless indexes_to_add.include?(r)
    end
    indexes_to_add.sort!
    observations = []
    indexes_to_add.each do |ind|
        observations << "(#{plan[ind]})"
    end
    observations_string = observations.join("\n")
    real_hyp_file_new_path = "#{new_problem_path}/real_hyp.dat"
    File.write(real_hyp_file_new_path, goal)
    obs_file_new_path = "#{new_problem_path}/obs.dat"
    File.write(obs_file_new_path, observations_string)
    system("rm #{new_problem_path}/problem.pddl")
    system("rm ./*.pddl ./*.dat")
    system("cp -r #{new_problem_path}/* ./")
    system("tar -cjf ./problem_#{i}.tar.bz2 ./*.pddl ./*.dat")
    system("rm -rf ./*.pddl ./*.dat")
    system("rm -rf #{new_problem_path}")
    system("mv problem_#{i}.tar.bz2 #{samples_path}")
    system("rm -rf ./problem_#{i}")
    system("echo #{tar_path.split("/").last} > #{samples_path}/problem_name.txt")
end
distribution_string = ""
probabilities.each do |key, value|
    distribution_string += "#{key} = #{value}\n"
end
distribution_path = "#{samples_path}/distribution.txt"
File.write(distribution_path, distribution_string)

system("cp -r #{tar_path} #{samples_path}")
system("mv #{samples_path}/#{tar_path.split("/").last} #{samples_path}/original_problem.tar.bz2")
