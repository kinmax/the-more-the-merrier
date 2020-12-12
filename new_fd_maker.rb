file = File.open("./new_domains.txt", "r")
raw = file.read
file.close
domains = raw.split("\n")
distros = %w[original one normal]
domains.each do |domain|
    distros.each do |d|
        system("mkdir ./#{domain}/#{d}/real-fd")
        system("git clone https://github.com/aibasel/downward.git ./#{domain}/#{d}/real-fd")
        system("./#{domain}/#{d}/real-fd/build.py")
    end
end
system("mkdir ./real-fd")
system("git clone https://github.com/aibasel/downward.git ./real-fd")
system("./build.py")
