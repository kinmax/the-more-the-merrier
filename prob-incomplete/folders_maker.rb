domains = %w[blocks-world depots driverlog dwr easy-ipc-grid ferry logistics miconic rovers satellite zeno-travel]

domains.each do |domain|
    system("mkdir ./domain")
    system("mkdir ./domain/probabilities")
    system("mkdir ./domain/results")
    system("cp ./prob_recognizer1.0-incomplete_domains.jar ./domain")
    system("cp ./probability_runner_incomplete.rb ./domain")
    system("cp ./problem_generator_incomplete.rb ./domain")
    system("cp ./results_parser_probability_incomplete.rb ./domain")
end