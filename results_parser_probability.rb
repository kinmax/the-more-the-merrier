require 'json'

def get_method_stats(fname)
    file = File.open(fname, 'r')
    raw = file.read
    raw_unsplit = raw.clone
    file.close

    raw = raw.split("\n")
    goals = raw[0].split(" = ")[1].to_f
    landmarks = raw[1].split(" = ")[1].to_f
    obs = raw[2].split(" = ")[1].to_f
    spread = raw[3].split(" = ")[1].to_f
    correct = raw[4].split(" = ")[1] == "true" ? 1 : 0
    time = raw[5].split(" = ")[1].to_f/1000.to_f
    real_goal = raw_unsplit.split("REAL_GOAL = ")[1].strip

    probs = raw_unsplit.split("POSTERIOR_PROBABILITIES:\n")[1].split("\nMOST_LIKELY_GOALS")[0].split("\n")
    results = {}
    results[:probabilities] = {}
    probs.each do |p|
        tuple = p.split(" = ")
        results[:probabilities][tuple[0]] = tuple[1].to_f
    end
    results[:real_goal] = real_goal
    results[:observations] = obs
    results[:goals] = goals
    results[:landmarks] = landmarks
    results[:correct] = correct
    results[:time] = time
    results[:spread] = spread

    results
end

def max_norm(d1, d2)
    max = -1
    d1.keys.each do |k|
        curr = (d1[k] - d2[k]).abs
        max = curr if curr > max
    end
    return max
end

def all_results(domain, type, distribution)
    dataset_path = "../../ijcai-09-benchmarks"
    dataset_path = "../../../datasets-aij"
    samples_path = "./samples_#{distribution}"
    res_path = "./res_#{distribution}.txt"
    run_path = "./probability_runner.rb"
    thresholds = %w(0).freeze
    percentages = type == "noisy" ? %w(25 50 75 100).freeze : %w(10 30 50 70 100).freeze
    run_type = "--exhaust"
    number_of_samples = 10
    runs = 3
    samples_path = "./samples_#{distribution}"
    result = {}
    goals = 0
    landmarks = 0
    observations = {}
    spread = {}
    seconds = {}   
    accuracy = {}
    counter = {}
    probs = {}
    best_goal_difference = {}
    mnorm = {}
    percentages.each do |p|
        observations[p] = 0
        seconds[p] = 0
        accuracy[p] = 0
        counter[p] = 0
        spread[p] = 0
        best_goal_difference[p] = 0
        mnorm[p] = 0
    end
    
    puts domain
    symbol_domain = domain.gsub("-", "_").to_sym
    result[symbol_domain] = {}
    problem_counter = 0
    goals = 0
    runs.times do |r|
        Dir.foreach("#{dataset_path}/#{domain}") do |percent|
            if percentages.include?(percent)
                Dir.foreach("#{dataset_path}/#{domain}/#{percent}") do |tar|
                    if tar == "." || tar == ".." || tar == "README.md" || tar == ".gitignore" || tar.include?("FILTERED")
                        next
                    end
                    puts "#{tar} - run #{r}"

                    begin
                        tar_path = "#{dataset_path}/#{domain}/#{percent}/#{tar}"

                        problem_counter = problem_counter + 1

                        percentual_observed = percent
                        probs[tar] = {}
                        
                        counter[percentual_observed.to_s] += 1
                        res_file_name = ""
                        if distribution == "original"
                            system("cp #{tar_path} ./")
                            system("java -jar probabilistic-recognizer-landmarks0.5.jar #{tar} > /dev/null")
                            res_file_name = "#{tar.split(".")[0]}.txt"
                        else
                            system("cp #{tar_path} ./")
                            system("ruby problem_generator.rb #{tar} #{distribution} #{number_of_samples} #{percent} #{samples_path} > /dev/null")
                            system("ruby #{run_path} #{samples_path} > /dev/null")
                            system("cp #{samples_path}/original_problem.tar.bz2 ./")
                            system("java -jar probabilistic-recognizer-landmarks0.5.jar original_problem.tar.bz2 > /dev/null")
                            res_file_name = "original_problem.txt"
                            result_original = get_method_stats(res_file_name)
                            system("rm original_problem.tar.bz2 original_problem.txt")
                            system("cp #{samples_path}/original_problem_priors.tar.bz2 ./")
                            system("java -jar probabilistic-recognizer-landmarks0.5.jar original_problem_priors.tar.bz2 > /dev/null")
                            res_file_name = "original_problem_priors.txt"
                        end
                        single_result_ex = get_method_stats(res_file_name)
                        # if single_result_ex[:correct] == 0
                        #     puts "FAILED - Domain: #{domain} - Problem: #{tar} - Threshold: #{tr} - Algorithm: #{run_type}"
                        #     file_path = "/home/kin/tcc/#{domain}/res.txt"
                        #     file = File.open(file_path, 'r')
                        #     raw = file.read
                        #     file.close
                        #     puts raw
                        # end += 1
                        system("rm ./*.tar.bz2 #{res_file_name}")
                        goals += single_result_ex[:goals]
                        landmarks += single_result_ex[:landmarks]
                        observations[percentual_observed.to_s] += single_result_ex[:observations]
                        spread[percentual_observed.to_s] += single_result_ex[:spread]
                        seconds[percentual_observed.to_s] += single_result_ex[:time]
                        accuracy[percentual_observed.to_s] += single_result_ex[:correct]

                        if distribution != "original" # has to verify max_norm of prior distribution vs real distribution and difference between probabilities for real goal
                            best_goal_difference[percentual_observed.to_s] += single_result_ex[:probabilities][single_result_ex[:real_goal]] - result_original[:probabilities][result_original[:real_goal]]
                            system("tar -xjf #{samples_path}/original_problem_priors.tar.bz2")
                            priors_file = File.open("priors.dat")
                            raw_priors = priors_file.read.strip
                            priors_file.close
                            distro_file = File.open("#{samples_path}/distribution.txt")
                            raw_distro = distro_file.read.strip
                            distro_file.close
                            priors = {}
                            distro = {}
                            raw_priors.split("\n").each do |p|
                                priors[p.split(" = ")[0]] = p.split(" = ")[1].to_f
                            end
                            raw_distro.split("\n").each do |d|
                                distro[d.split(" = ")[0]] = d.split(" = ")[1].to_f
                            end
                            mnorm[percentual_observed.to_s] += max_norm(priors, distro)
                        end

                        probs[tar] = single_result_ex[:probabilities]
                    rescue StandardError => e
                        puts e.backtrace
                    end
                end
            end
        end
    end
    begin
        if problem_counter == 0
            problem_counter = 1
        end
        result[symbol_domain][:problems] = problem_counter/runs
        result[symbol_domain][:goals_avg] = goals.to_f/problem_counter.to_f
        result[symbol_domain][:observations] = {}
        result[symbol_domain][:spread] = {}
        result[symbol_domain][:best_goal_difference] = {}
        result[symbol_domain][:max_norm] = {}
        result[symbol_domain][:landmarks_avg] = landmarks.to_f/problem_counter.to_f;
        percentages.each do |p|
            result[symbol_domain][:observations][p] = {}
        end

        percentages.each do |p|
            if counter[p] == 0
                counter[p] = 1
            end
            result[symbol_domain][:observations][p][:observations_avg] = (observations[p].to_f/counter[p].to_f)
            result[symbol_domain][:spread][p] = (spread[p].to_f)/(counter[p].to_f)
            result[symbol_domain][:observations][p][:time] = ((((seconds[p].to_f/counter[p].to_f)*1000).floor)/1000.0)
            result[symbol_domain][:observations][p][:accuracy] = ((accuracy[p].to_f/counter[p].to_f) * 100.0)
            result[symbol_domain][:best_goal_difference][p] = (best_goal_difference[p].to_f/counter[p].to_f)
            result[symbol_domain][:max_norm][p] = (mnorm[p].to_f/counter[p].to_f)
        end
    rescue StandardError => e
        puts e.backtrace
    end

    [result, probs]
end

def analyse(domain, type, distribution)
    results = all_results(domain, type, distribution)
    output_path = "./results_#{distribution}.json"
    File.write(output_path, JSON.pretty_generate(results[0]))
    probs_path = "./probabilities_#{distribution}.json"
    File.write(probs_path, JSON.pretty_generate(results[1]))
end

domain = ARGV[0]
distribution = ARGV[1]
type = ARGV[2]
analyse(domain, type, distribution)
