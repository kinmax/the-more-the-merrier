file = File.open("./domains.txt", "r")
raw = file.read
file.close
domains = raw.split("\n")
domains.each do |domain|
    system("mkdir ./#{domain}/fd")
    system("git clone https://github.com/kinmax/MODDED_FD.git ./#{domain}/fd")
    system("python3 ./#{domain}/fd/build.py")
end
system("git clone https://github.com/kinmax/MODDED_FD.git ./fd")
system("python3 ./fd/build.py")
