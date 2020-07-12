# frozen_string_literal: true

dataset_path = "./dataset-copy"
untarcmd = "tar -xjf "
tarcmd = "tar cvfj "
percentages = %w(10 30 50 70 100).freeze


Dir.foreach(dataset_path) do |domain|
    if domain == "." || domain == ".." || domain == "README.md" || domain == ".zenodo.json" || domain == ".git" || domain.include?("noisy") || domain == ".gitignore"
        next
    end

    Dir.foreach("#{dataset_path}/#{domain}") do |percent|
        unless percentages.include?(percent)
            next
        end

        Dir.foreach("#{dataset_path}/#{domain}/#{percent}") do |tar|
            if tar == "." || tar == ".." || tar == "README.md" || tar == ".gitignore" || tar.include?("FILTERED")
                next
            end
            if domain == "blocks-world" || domain == "kitchen" || domain == "logistics"
                puts tar
                system(untarcmd + "#{dataset_path}/#{domain}/#{percent}/#{tar} > /dev/null" )
                if(domain == "blocks-world")
                    domain_file = File.open("domain.pddl", "r")
                    dom = domain_file.read
                    domain_file.close
                    dom.gsub!("-block", "- block")
                    File.write("domain.pddl", dom)
                end
                if(domain == "kitchen")
                    domain_file = File.open("domain.pddl", "r")
                    dom = domain_file.read
                    domain_file.close
                    dom.gsub!("water_jug keetle cloth tea_bag cup sugar bowl milk", "water_jug keetle cloth tea_bag bowl milk")
                    dom.gsub!("bread toaster butter knife peanut_butter spoon", "butter knife peanut_butter spoon")
                    File.write("domain.pddl", dom)
                end
                if(domain == "logistics")
                    domain_file = File.open("template.pddl", "r")
                    dom = domain_file.read
                    domain_file.close
                    dom.gsub!("obj88 obj77 obj66 obj55 obj44 obj66 obj23 obj22 obj21 obj13 obj12 obj11 obj00 - package", "obj88 obj77 obj66 obj55 obj44 obj23 obj22 obj21 obj13 obj12 obj11 obj00 - package")
                    File.write("template.pddl", dom)
                end
                #system("ruby problem_formatter.rb template.pddl real_hyp.dat template.pddl > /dev/null")
                system(tarcmd + "#{dataset_path}/#{domain}/#{percent}/#{tar} *.dat *.pddl > /dev/null")
            end
        end
    end
end

system("rm *.pddl *.dat")
