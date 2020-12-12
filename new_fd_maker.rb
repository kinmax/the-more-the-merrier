file = File.open("./new_domains.txt", "r")
raw = file.read
file.close
domains = raw.split("\n")
domains.each do |domain|
    system("mkdir ./#{domain}/real-fd")
    system("git clone https://github.com/aibasel/downward.git ./#{domain}/real-fd")
    system("./#{domain}/real-fd/build.py")
end
system("mkdir ./real-fd")
system("git clone https://github.com/aibasel/downward.git ./real-fd")
system("./build.py")
