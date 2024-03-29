require 'json'

def get_complete_domain_filename(path, domain, tar_name)
    split_tar = tar_name.split("_")
    p = split_tar[1]
    hyp = split_tar[2] 
    Dir.foreach(path) do |problem|
        return "#{path}/#{problem}" if problem.include?("_#{p}_") && problem.include?("_#{hyp}_")
    end
    return nil
end

def get_method_stats(fname)
    file = File.open(fname, 'r')
    raw = file.read
    raw_unsplit = raw.clone
    file.close

    raw = raw.split("\n")
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
    results[:correct] = correct
    results[:time] = time
    results[:spread] = spread
    results[:real_goal] = real_goal

    results[:tp] = correct
    results[:fn] = (correct-1).abs
    results[:tn] = (results[:probabilities].size - spread) - ((correct-1).abs)
    results[:fp] = spread - correct

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

def all_results(domain, distribution)
    dataset_path = "../../../datasets-aij"
    samples_path = "./samples_#{distribution}"
    res_path = "./res_#{distribution}.txt"
    run_path = "./probability_runner_incomplete.rb"
    thresholds = %w(0).freeze
    percentages = %w(10 30 50 70 100).freeze
    run_type = "--exhaust"

    problem_types = ["#{domain}-optimal", "#{domain}-suboptimal-80", 
        "#{domain}-optimal-20", "#{domain}-suboptimal-40", "#{domain}-suboptimal-60", "#{domain}-suboptimal-20", "#{domain}-optimal-80", 
        "#{domain}-optimal-60", "#{domain}-suboptimal", 
        "#{domain}-optimal-40"]

    prob_approaches = ["prob-#{heuristic}-definite", "prob-#{heuristic}-definite-possible", "prob-#{heuristic}-definite-overlooked",
              "prob-#{heuristic}-definite-possible-overlooked", "prob-#{heuristic}-possible", "prob-#{heuristic}-possible-overlooked",
              "prob-#{heuristic}-overlooked"]
    number_of_samples = 10
    runs = 1
    samples_path = "./samples_#{distribution}"
    system("mkdir #{samples_path}")
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
    goals = 0
    prob_approaches.each do |prob_approach|
        Dir.foreach("#{dataset_path}/#{domain}") do |problem_type|
            split_problem_type = problem_type.split("-")
            incompleteness =  ["20", "40" "60", "80"].include?(split_problem_type.last) ? "100" : split_problem_type.last
            result_file_content = "Obs% Accuracy Precision Recall F1-Score Spread Time Max-Norm Delta\n"
            next if problem_type == '.' || problem_type == '..' || problem_type.include?('noisy')
            Dir.foreach("#{dataset_path}/#{domain}/#{problem_type}") do |percent|
                next unless percentages.include?(percent)
                spread = 0
                time = 0
                accuracy = 0
                tp = 0
                fp = 0
                tn = 0
                fn = 0
                best_goal_difference = 0
                problem_counter = 0
                mnorm = 0
                optimality = problem_type.include?('-suboptimal') ? 'suboptimal' : 'optimal'
                if percentages.include?(percent)
                    Dir.foreach("#{dataset_path}/#{domain}/#{problem_type}/#{percent}") do |tar|
                        if tar == "." || tar == ".." || tar == "README.md" || tar == ".gitignore" || tar.include?("FILTERED")
                            next
                        end
                        complete_domain_file = get_complete_domain_filename("#{dataset_path}/#{domain}/#{domain}-optimal/100", domain, tar)
                        runs.times do |r|
                            puts "#{tar} - approach #{prob_approach} - run #{r}"

                            begin
                                tar_path = "#{dataset_path}/#{domain}/#{problem_type}/#{percent}/#{tar}"

                                problem_counter = problem_counter + 1

                                percentual_observed = percent
                                probs[tar] = {}
                                
                                counter[percentual_observed.to_s] += 1
                                res_file_name = ""
                                if distribution == "original"
                                    system("cp #{tar_path} ./")
                                    system("java -jar prob_recognizer1.0-incomplete_domains.jar #{tar} #{prob_approach} > /dev/null")
                                    res_file_name = "#{tar.split(".")[0]}.txt"
                                else
                                    system("cp #{tar_path} ./")
                                    system("ruby problem_generator_incomplete.rb #{tar} #{distribution} #{number_of_samples} #{percent} #{samples_path} #{optimality} #{complete_domain_file} > /dev/null")
                                    system("ruby #{run_path} #{samples_path} #{domain} #{problem_type} #{prob_approach} > /dev/null")
                                    system("cp #{samples_path}/original_problem.tar.bz2 ./")
                                    system("java -jar prob_recognizer1.0-incomplete_domains.jar original_problem.tar.bz2 #{prob_approach} > /dev/null")
                                    res_file_name = "original_problem.txt"
                                    result_original = get_method_stats(res_file_name)
                                    system("rm original_problem.tar.bz2 original_problem.txt")
                                    system("cp #{samples_path}/original_problem_priors.tar.bz2 ./")
                                    system("java -jar prob_recognizer1.0-incomplete_domains.jar original_problem_priors.tar.bz2 #{prob_approach} > /dev/null")
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
                                if r == 0
                                    spread += single_result_ex[:spread]
                                    accuracy += single_result_ex[:correct]
                                    tp += single_result_ex[:tp]
                                    fp += single_result_ex[:fp]
                                    tn += single_result_ex[:tn]
                                    fn += single_result_ex[:fn]

                                    if distribution != "original" # has to verify max_norm of prior distribution vs real distribution and difference between probabilities for real goal
                                        best_goal_difference += single_result_ex[:probabilities][single_result_ex[:real_goal]] - result_original[:probabilities][result_original[:real_goal]]
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
                                        mnorm += max_norm(priors, distro)
                                    end
                                end

                                time += single_result_ex[:time]

                                probs[tar] = single_result_ex[:probabilities]
                            rescue StandardError => e
                                puts e.backtrace
                            end
                        end
                    end
                end
                time = time.to_f/runs.to_f
                time = time.to_f/problem_counter.to_f
                spread = spread.to_f/problem_counter.to_f
                accuracy = accuracy.to_f/problem_counter.to_f
                best_goal_difference = best_goal_difference.to_f/problem_counter.to_f
                mnorm = mnorm.to_f/problem_counter.to_f
                tp = tp.to_f/problem_counter.to_f
                tn = tn.to_f/problem_counter.to_f
                fp = fp.to_f/problem_counter.to_f
                fn = fn.to_f/problem_counter.to_f
                precision = tp.to_f/(tp.to_f + fp.to_f).to_f
                recall = tp.to_f/(tp.to_f + fn.to_f).to_f
                f1_score = (2.to_f * recall.to_f * precision.to_f)/(recall.to_f + precision.to_f)
                result_file_content += "#{percent} #{accuracy.round(3)} #{precision.round(3)} #{recall.round(3)} #{f1_score.round(3)} #{spread.round(3)} #{time.round(3)} #{mnorm.round(3)} #{best_goal_difference.round(3)}\n"
            end
            result_file_name = "#{domain}-#{optimality}-#{incompleteness}-incompleteness-goalrecognition-prob-#{prob_approach.split('-').drop(1).join('_')}_landmarks.txt"
            File.open("./results/#{result_file_name}", 'w') { |file| file.write(result_file_content) }
        end
    end
    probs
end

def analyse(domain, heuristic, distribution)
    results = all_results(domain, heuristic, distribution)
    probs_path = "./probabilities/probabilities_#{distribution}.json"
    File.write(probs_path, JSON.pretty_generate(results))
end

domain = ARGV[0]
distribution = ARGV[1]
heuristic = ARGV[2]
analyse(domain, heuristic, distribution)
