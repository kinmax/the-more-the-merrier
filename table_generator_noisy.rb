require 'json'

file_path = File.join(File.dirname(__FILE__), 'results_goalcompletion_noisy.json')
file = File.open(file_path, 'r')
raw = file.read
results = JSON.parse(raw)
output_path = "./table_uniqueness_noisy.txt"

table = "\\begin{table}[h]
\\centering
\\resizebox{\\textwidth}{!}{%
    \\begin{tabular}{|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|}
      \\hline
      \\multicolumn{4}{|c|}{}&\\multicolumn{4}{|c|}{\\textit{Exhaust}}&\\multicolumn{4}{|c|}{\\textit{h^m}}&\\multicolumn{4}{|c|}{\\textit{RHW}}&\\multicolumn{4}{|c|}{\\textit{Zhu/Givan}}\\\\
      \\hline
      \\textbf{Domain}&$|\\mathcal{G}|$&\\textbf{\\% Obs}&$|\\mathcal{O}|$&$|\\mathcal{L}|$&\\makecell{\\textbf{Time (s)}\\\\$\\theta$   \\textbf{(0 / 10 / 20 / 30)}}&\\makecell{\\textbf{Accuracy (\\%)}\\\\$\\theta$   \\textbf{(0 / 10 / 20 / 30)}}&\\makecell{\\textbf{Spread}\\\\$\\theta$   \\textbf{(0 / 10 / 20 / 30)}}&$|\\mathcal{L}|$&\\makecell{\\textbf{Time (s)}\\\\$\\theta$   \\textbf{(0 / 10 / 20 /30)}}&\\makecell{\\textbf{Accuracy (\\%)}\\\\$\\theta$   \\textbf{(0 / 10 / 20 / 30)}}&\\makecell{\\textbf{Spread}\\\\$\\theta$   \\textbf{(0 / 10 / 20 / 30)}}&\\makecell{$|\\mathcal{L}|$}&\\makecell{\\textbf{Time (s)}\\\\$\\theta$   \\textbf{(0 / 10 / 20 / 30)}}&\\makecell{\\textbf{Accuracy (\\%)}\\\\$\\theta$   \\textbf{(0 / 10 / 20 / 30)}}&\\makecell{\\textbf{Spread}\\\\$\\theta$   \\textbf{(0 / 10 / 20 / 30)}}&\\makecell{$|\\mathcal{L}|$}&\\makecell{\\textbf{Time (s)}\\\\$\\theta$   \\textbf{(0 / 10 / 20 /30)}}&\\makecell{\\textbf{Accuracy (\\%)}\\\\$\\theta$   \\textbf{(0 / 10 / 20 / 30)}}&\\makecell{\\textbf{Spread}\\\\$\\theta$   \\textbf{(0 / 10 / 20 / 30)}}\\\\
      \\hline
      "

 puts results["blocks-world-noisy"]["observations"]["25"]["rhw"]["accuracy"]["0"]

results.each do |key, value|
    domain = key.upcase
    table += "\\makecell{#{domain}\\\\#{value["problems"]}} & #{'%.1f' % value["goals_avg"]} & \\makecell{25 \\\\ 50 \\\\ 75 \\\\ 100} & \\makecell{#{'%.1f' % value["observations"]["25"]["observations_avg"]} \\\\ #{'%.1f' % value["observations"]["50"]["observations_avg"]} \\\\ #{'%.1f' % value["observations"]["75"]["observations_avg"]} \\\\ #{'%.1f' % value["observations"]["100"]["observations_avg"]}} & #{'%.1f' % value["landmarks_avg"]["exhaust"]} & \\makecell{#{'%.3f' % value["observations"]["25"]["exhaust"]["time"]["0"]} / #{'%.3f' % value["observations"]["25"]["exhaust"]["time"]["10"]} / #{'%.3f' % value["observations"]["25"]["exhaust"]["time"]["20"]} / #{'%.3f' % value["observations"]["25"]["exhaust"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["50"]["exhaust"]["time"]["0"]} / #{'%.3f' % value["observations"]["50"]["exhaust"]["time"]["10"]} / #{'%.3f' % value["observations"]["50"]["exhaust"]["time"]["20"]} / #{'%.3f' % value["observations"]["50"]["exhaust"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["75"]["exhaust"]["time"]["0"]} / #{'%.3f' % value["observations"]["75"]["exhaust"]["time"]["10"]} / #{'%.3f' % value["observations"]["75"]["exhaust"]["time"]["20"]} / #{'%.3f' % value["observations"]["75"]["exhaust"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["100"]["exhaust"]["time"]["0"]} / #{'%.3f' % value["observations"]["100"]["exhaust"]["time"]["10"]} / #{'%.3f' % value["observations"]["100"]["exhaust"]["time"]["20"]} / #{'%.3f' % value["observations"]["100"]["exhaust"]["time"]["30"]}} & \\makecell{#{'%.1f' % value["observations"]["25"]["exhaust"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["25"]["exhaust"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["25"]["exhaust"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["25"]["exhaust"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["50"]["exhaust"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["50"]["exhaust"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["50"]["exhaust"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["50"]["exhaust"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["75"]["exhaust"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["75"]["exhaust"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["75"]["exhaust"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["75"]["exhaust"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["100"]["exhaust"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["100"]["exhaust"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["100"]["exhaust"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["100"]["exhaust"]["accuracy"]["30"]}} & \\makecell{#{"%.3f" % value["spread"]["25"]["exhaust"]["0"]} / #{"%.3f" % value["spread"]["25"]["exhaust"]["10"]} / #{"%.3f" % value["spread"]["25"]["exhaust"]["20"]} / #{"%.3f" % value["spread"]["25"]["exhaust"]["30"]} \\\\ #{"%.3f" % value["spread"]["50"]["exhaust"]["0"]} / #{"%.3f" % value["spread"]["50"]["exhaust"]["10"]} / #{"%.3f" % value["spread"]["50"]["exhaust"]["20"]} / #{"%.3f" % value["spread"]["50"]["exhaust"]["30"]} \\\\ #{"%.3f" % value["spread"]["75"]["exhaust"]["0"]} / #{"%.3f" % value["spread"]["75"]["exhaust"]["10"]} / #{"%.3f" % value["spread"]["75"]["exhaust"]["20"]} / #{"%.3f" % value["spread"]["75"]["exhaust"]["30"]} \\\\ #{"%.3f" % value["spread"]["100"]["exhaust"]["0"]} / #{"%.3f" % value["spread"]["100"]["exhaust"]["10"]} / #{"%.3f" % value["spread"]["100"]["exhaust"]["20"]} / #{"%.3f" % value["spread"]["100"]["exhaust"]["30"]}} & #{'%.1f' % value["landmarks_avg"]["hm"]} & \\makecell{#{'%.3f' % value["observations"]["25"]["hm"]["time"]["0"]} / #{'%.3f' % value["observations"]["25"]["hm"]["time"]["10"]} / #{'%.3f' % value["observations"]["25"]["hm"]["time"]["20"]} / #{'%.3f' % value["observations"]["25"]["hm"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["50"]["hm"]["time"]["0"]} / #{'%.3f' % value["observations"]["50"]["hm"]["time"]["10"]} / #{'%.3f' % value["observations"]["50"]["hm"]["time"]["20"]} / #{'%.3f' % value["observations"]["50"]["hm"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["75"]["hm"]["time"]["0"]} / #{'%.3f' % value["observations"]["75"]["hm"]["time"]["10"]} / #{'%.3f' % value["observations"]["75"]["hm"]["time"]["20"]} / #{'%.3f' % value["observations"]["75"]["hm"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["100"]["hm"]["time"]["0"]} / #{'%.3f' % value["observations"]["100"]["hm"]["time"]["10"]} / #{'%.3f' % value["observations"]["100"]["hm"]["time"]["20"]} / #{'%.3f' % value["observations"]["100"]["hm"]["time"]["30"]}} & \\makecell{#{'%.1f' % value["observations"]["25"]["hm"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["25"]["hm"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["25"]["hm"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["25"]["hm"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["50"]["hm"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["50"]["hm"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["50"]["hm"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["50"]["hm"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["75"]["hm"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["75"]["hm"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["75"]["hm"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["75"]["hm"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["100"]["hm"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["100"]["hm"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["100"]["hm"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["100"]["hm"]["accuracy"]["30"]}} & \\makecell{#{"%.3f" % value["spread"]["25"]["hm"]["0"]} / #{"%.3f" % value["spread"]["25"]["hm"]["10"]} / #{"%.3f" % value["spread"]["25"]["hm"]["20"]} / #{"%.3f" % value["spread"]["25"]["hm"]["30"]} \\\\ #{"%.3f" % value["spread"]["50"]["hm"]["0"]} / #{"%.3f" % value["spread"]["50"]["hm"]["10"]} / #{"%.3f" % value["spread"]["50"]["hm"]["20"]} / #{"%.3f" % value["spread"]["50"]["hm"]["30"]} \\\\ #{"%.3f" % value["spread"]["75"]["hm"]["0"]} / #{"%.3f" % value["spread"]["75"]["hm"]["10"]} / #{"%.3f" % value["spread"]["75"]["hm"]["20"]} / #{"%.3f" % value["spread"]["75"]["hm"]["30"]} \\\\ #{"%.3f" % value["spread"]["100"]["hm"]["0"]} / #{"%.3f" % value["spread"]["100"]["hm"]["10"]} / #{"%.3f" % value["spread"]["100"]["hm"]["20"]} / #{"%.3f" % value["spread"]["100"]["hm"]["30"]}} & #{'%.1f' % value["landmarks_avg"]["rhw"]} & \\makecell{#{'%.3f' % value["observations"]["25"]["rhw"]["time"]["0"]} / #{'%.3f' % value["observations"]["25"]["rhw"]["time"]["10"]} / #{'%.3f' % value["observations"]["25"]["rhw"]["time"]["20"]} / #{'%.3f' % value["observations"]["25"]["rhw"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["50"]["rhw"]["time"]["0"]} / #{'%.3f' % value["observations"]["50"]["rhw"]["time"]["10"]} / #{'%.3f' % value["observations"]["50"]["rhw"]["time"]["20"]} / #{'%.3f' % value["observations"]["50"]["rhw"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["75"]["rhw"]["time"]["0"]} / #{'%.3f' % value["observations"]["75"]["rhw"]["time"]["10"]} / #{'%.3f' % value["observations"]["75"]["rhw"]["time"]["20"]} / #{'%.3f' % value["observations"]["75"]["rhw"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["100"]["rhw"]["time"]["0"]} / #{'%.3f' % value["observations"]["100"]["rhw"]["time"]["10"]} / #{'%.3f' % value["observations"]["100"]["rhw"]["time"]["20"]} / #{'%.3f' % value["observations"]["100"]["rhw"]["time"]["30"]}} & \\makecell{#{'%.1f' % value["observations"]["25"]["rhw"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["25"]["rhw"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["25"]["rhw"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["25"]["rhw"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["50"]["rhw"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["50"]["rhw"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["50"]["rhw"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["50"]["rhw"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["75"]["rhw"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["75"]["rhw"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["75"]["rhw"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["75"]["rhw"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["100"]["rhw"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["100"]["rhw"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["100"]["rhw"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["100"]["rhw"]["accuracy"]["30"]}} & \\makecell{#{"%.3f" % value["spread"]["25"]["rhw"]["0"]} / #{"%.3f" % value["spread"]["25"]["rhw"]["10"]} / #{"%.3f" % value["spread"]["25"]["rhw"]["20"]} / #{"%.3f" % value["spread"]["25"]["rhw"]["30"]} \\\\ #{"%.3f" % value["spread"]["50"]["rhw"]["0"]} / #{"%.3f" % value["spread"]["50"]["rhw"]["10"]} / #{"%.3f" % value["spread"]["50"]["rhw"]["20"]} / #{"%.3f" % value["spread"]["50"]["rhw"]["30"]} \\\\ #{"%.3f" % value["spread"]["75"]["rhw"]["0"]} / #{"%.3f" % value["spread"]["75"]["rhw"]["10"]} / #{"%.3f" % value["spread"]["75"]["rhw"]["20"]} / #{"%.3f" % value["spread"]["75"]["rhw"]["30"]} \\\\ #{"%.3f" % value["spread"]["100"]["rhw"]["0"]} / #{"%.3f" % value["spread"]["100"]["rhw"]["10"]} / #{"%.3f" % value["spread"]["100"]["rhw"]["20"]} / #{"%.3f" % value["spread"]["100"]["rhw"]["30"]}} & #{'%.1f' % value["landmarks_avg"]["zg"]} & \\makecell{#{'%.3f' % value["observations"]["25"]["zg"]["time"]["0"]} / #{'%.3f' % value["observations"]["25"]["zg"]["time"]["10"]} / #{'%.3f' % value["observations"]["25"]["zg"]["time"]["20"]} / #{'%.3f' % value["observations"]["25"]["zg"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["50"]["zg"]["time"]["0"]} / #{'%.3f' % value["observations"]["50"]["zg"]["time"]["10"]} / #{'%.3f' % value["observations"]["50"]["zg"]["time"]["20"]} / #{'%.3f' % value["observations"]["50"]["zg"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["75"]["zg"]["time"]["0"]} / #{'%.3f' % value["observations"]["75"]["zg"]["time"]["10"]} / #{'%.3f' % value["observations"]["75"]["zg"]["time"]["20"]} / #{'%.3f' % value["observations"]["75"]["zg"]["time"]["30"]} \\\\ #{'%.3f' % value["observations"]["100"]["zg"]["time"]["0"]} / #{'%.3f' % value["observations"]["100"]["zg"]["time"]["10"]} / #{'%.3f' % value["observations"]["100"]["zg"]["time"]["20"]} / #{'%.3f' % value["observations"]["100"]["zg"]["time"]["30"]}} & \\makecell{#{'%.1f' % value["observations"]["25"]["zg"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["25"]["zg"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["25"]["zg"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["25"]["zg"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["50"]["zg"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["50"]["zg"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["50"]["zg"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["50"]["zg"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["75"]["zg"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["75"]["zg"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["75"]["zg"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["75"]["zg"]["accuracy"]["30"]} \\\\ #{'%.1f' % value["observations"]["100"]["zg"]["accuracy"]["0"]} / #{'%.1f' % value["observations"]["100"]["zg"]["accuracy"]["10"]} / #{'%.1f' % value["observations"]["100"]["zg"]["accuracy"]["20"]} / #{'%.1f' % value["observations"]["100"]["zg"]["accuracy"]["30"]}} & \\makecell{#{"%.3f" % value["spread"]["25"]["zg"]["0"]} / #{"%.3f" % value["spread"]["25"]["zg"]["10"]} / #{"%.3f" % value["spread"]["25"]["zg"]["20"]} / #{"%.3f" % value["spread"]["25"]["zg"]["30"]} \\\\ #{"%.3f" % value["spread"]["50"]["zg"]["0"]} / #{"%.3f" % value["spread"]["50"]["zg"]["10"]} / #{"%.3f" % value["spread"]["50"]["zg"]["20"]} / #{"%.3f" % value["spread"]["50"]["zg"]["30"]} \\\\ #{"%.3f" % value["spread"]["75"]["zg"]["0"]} / #{"%.3f" % value["spread"]["75"]["zg"]["10"]} / #{"%.3f" % value["spread"]["75"]["zg"]["20"]} / #{"%.3f" % value["spread"]["75"]["zg"]["30"]} \\\\ #{"%.3f" % value["spread"]["100"]["zg"]["0"]} / #{"%.3f" % value["spread"]["100"]["zg"]["10"]} / #{"%.3f" % value["spread"]["100"]["zg"]["20"]} / #{"%.3f" % value["spread"]["100"]["zg"]["30"]}} \\Bstrut \\\\
    \\hline
    "
end

table += "\\end{tabular}}
\\caption{Resultados obtidos na reprodução dos experimentos}
\\label{table:resultados}
\\end{table}"

File.write(output_path, table)

