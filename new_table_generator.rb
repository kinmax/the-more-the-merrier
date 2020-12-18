require 'json'
require 'byebug'

def capitalized(name)
    ret = ""
    splitname = name.split("-")
    splitname.each_with_index do |s,i|
        ret += "-" if i != splitname.size
        ret += s.capitalize
    end
    ret
end

domains = %w[blocks-world easy-ipc-grid intrusion-detection logistics]
distros = %w[original one normal]

table = "\\begin{table*}[bth]
\\centering
\\fontsize{5}{6.5}\\selectfont
\\setlength\\tabcolsep{2pt}
\\begin{tabular}{|c|c|c|c c|c|c|c|c|c|c|c|c|c|c|c|c|c|}
    \\hline
    
    \\multicolumn{5}{|c|}{} & \\multicolumn{3}{c|}{\\textbf{No Priors}} & \\multicolumn{5}{c|}{\\textbf{One-shot}} & \\multicolumn{5}{c|}{\\textbf{Normal}}\\\\
    
    \\hline
    
    \\textbf{Domain} & $|\\goalconditions|$ & $|\\mathcal{L}|$ & \\textbf{\\% Obs} & $\\observations$ & \\textbf{Time} & \\textbf{Acc \\%} & \\textbf{S in $\\goalconditions$} & \\textbf{Time} & \\textbf{Acc \\%} & \\textbf{S in $\\goalconditions$} & \\textbf{Max Norm} & $\\Delta$ & \\textbf{Time} & \\textbf{Acc \\%} & \\textbf{S in $\\goalconditions$} & \\textbf{Max Norm} & $\\Delta$ \\\\
    
    \\hline \n\n"

domains.each do |domain|
    distros.each do |distro|
        file = File.open("./#{domain}/#{distro}/results_#{distro}.json")
        raw = file.read
        file.close
        hash = JSON.parse(raw)[domain.gsub("-", "_")]
        if distro == "original"
            table += "\\makecell{\\sc #{capitalized(domain)} \\\\ (#{hash['problems']})} & #{hash['goals_avg'].round(1)} & #{hash['landmarks_avg'].round(1)} & \\makecell{10\\\\30\\\\50\\\\70\\\\100} & \\makecell{#{hash['observations']['10']['observations_avg'].round(1)}\\\\#{hash['observations']['30']['observations_avg'].round(1)}\\\\#{hash['observations']['50']['observations_avg'].round(1)}\\\\#{hash['observations']['70']['observations_avg'].round(1)}\\\\#{hash['observations']['100']['observations_avg'].round(1)}} & "
        end
        table += "\\makecell{#{hash['observations']['10']['time'].round(3)}\\\\#{hash['observations']['30']['time'].round(3)}\\\\#{hash['observations']['50']['time'].round(3)}\\\\#{hash['observations']['70']['time'].round(3)}\\\\#{hash['observations']['100']['time'].round(3)}} & \\makecell{#{hash['observations']['10']['accuracy'].round(1)}\\%\\\\#{hash['observations']['30']['accuracy'].round(1)}\\%\\\\#{hash['observations']['50']['accuracy'].round(1)}\\%\\\\#{hash['observations']['70']['accuracy'].round(1)}\\%\\\\#{hash['observations']['100']['accuracy'].round(1)}\\%} & \\makecell{#{hash['spread']['10'].round(1)}\\\\#{hash['spread']['30'].round(1)}\\\\#{hash['spread']['50'].round(1)}\\\\#{hash['spread']['70'].round(1)}\\\\#{hash['spread']['100'].round(1)}} & "
        if distro != "original"
            table += "\\makecell{#{hash['max_norm']['10'].round(3)}\\\\#{hash['max_norm']['30'].round(3)}\\\\#{hash['max_norm']['50'].round(3)}\\\\#{hash['max_norm']['70'].round(3)}\\\\#{hash['max_norm']['100'].round(3)}} & \\makecell{#{hash['best_goal_difference']['10'].round(3)}\\\\#{hash['best_goal_difference']['30'].round(3)}\\\\#{hash['best_goal_difference']['50'].round(3)}\\\\#{hash['best_goal_difference']['70'].round(3)}\\\\#{hash['best_goal_difference']['100'].round(3)}}"
            if distro == "one"
                table += " & "
            else
                table += " \\\\ \n\n"
            end
        end
    end
    table += "\\hline \n\n"
end

table += "\\end{tabular}
    
\\caption{Experimental results comparing our landmark-based probabilistic model with \\textit{no prior} probability distribution, \\textit{one-shot} recognition, \\textit{normal} probability distribution.}
\\label{tab:results}
\\end{table*} \n"

out_file = File.open("./new_table.txt", "w")
out_file.write(table)
out_file.close
