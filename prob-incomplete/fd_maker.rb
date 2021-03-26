domains = %w[blocks-world depots driverlog dwr easy-ipc-grid ferry logistics miconic rovers satellite zeno-travel]
distros = %w[one normal]
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
