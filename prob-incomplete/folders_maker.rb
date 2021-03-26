domains = %w[blocks-world depots driverlog dwr easy-ipc-grid ferry logistics miconic rovers satellite zeno-travel]

domains.each |domain| do
    system("mkdir ./#{domain}")
    system("mkdir ./#{domain}/normal")
    system("mkdir ./#{domain}/one")
    system("mkdir ./#{domain}/normal/probabilities")
    system("mkdir ./#{domain}/normal/results")
    system("mkdir ./#{domain}/one/probabilities")
    system("mkdir ./#{domain}/one/results")
    
    system("cp ./prob_recognizer1.0-incomplete_#{domain}s.jar ./#{domain}/normal")
    system("cp ./prob_recognizer1.0-incomplete_#{domain}s.jar ./#{domain}/one")
    system("cp ./probability_runner_incomplete.rb ./#{domain}/normal")
    system("cp ./probability_runner_incomplete.rb ./#{domain}/one")
    system("cp ./problem_generator_incomplete.rb ./#{domain}/normal")
    system("cp ./problem_generator_incomplete.rb ./#{domain}/one")
    system("cp ./results_parser_probability_incomplete.rb ./#{domain}/normal")
    system("cp ./results_parser_probability_incomplete.rb ./#{domain}/one")
end