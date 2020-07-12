# Evaluating the Effect of Probabilistic Interpretation and Landmark Extraction Algorithms on Landmark-Based Goal Recognition

## Presentation

Hello, fellow stranger! I will guide you through the wonders of this repository and assist you in what you came here to do.

## Pre-Requisites

I suggest you have a Linux/Unix based machine, since we use Linux/Unix-like filesystem paths. It may not work on Windows-based systems.

First you need to know what you need pre-installed on your machine. We use the FastDownward planner, so you need everything that FastDownward depends on. You should check their web page: http://www.fast-downward.org/. Maybe at the time you're reading this pre-requisites for FD have changed, but maybe this will help:

```
sudo apt install cmake g++ git make python3
```

All the code written for this work is in Ruby, so you must have Ruby installed. You should check their website for information about installation on your system: https://www.ruby-lang.org/pt/documentation/installation/. If you are on a Debian/Ubuntu system, I will cut the way for you:

```
sudo apt-get install ruby-full
```

Now you should have everything ready to get started!

## Quick Setup (for running some problems or a single domain (come here first))

If you wish to run tests for only some problems, or maybe for one domain, you should first run the following:

```
bash quick_setup.sh
```

This will download the modified version of FastDownward planner in a version that works with this code. It was modified to work as a landmark extractor, and run the build for it. It will be located in the ```fd/``` directory.

It will also download the dataset used for tests presented on the paper. The dataset will be in ```dataset-copy``` directory.

You must be connected to the Internet to run the setup.

After that, you can run the recognizer with Goal Completion heuristic for a single problem with the following command:

```
ruby problem_analyser.rb <tar_path> <threshold> <extraction_method>
```

If you want the Landmark Uniqueness heuristic, you should go for:

```
ruby problem_analyser_uniqueness.rb <tar_path> <threshold> <extraction_method>
```

```<tar_path>``` is the path for the ```tar.bz2``` file inside the dataset folder that contains the problem.

```<threshold>``` is a threshold value that should range from 0 to 100. If you're not sure, go with 0.

```<extraction_method>``` is the desired extraction algorithm. you can set this parameter to five different values:

```
--exhaust
--hm
--rhw
--zg
--hoffmann
```

If you're not sure, just go with ```--exhaust```, it will do the trick.

All parameters are required for correct functioning.

On the output, you will see a bunch of information that is required for the results aggregation (this code was only created to support the experiments). You can see if the heuristic has correctly inferred the goal by looking at the "CORRECT-TRUE" or "CORRECT-FALSE" at the output. For Goal Completion, the "PROBABILITY-CORRECT" or "PROBABILITY-FALSE" only means whether the probability got the same result as the original heuristic or not.

Now, if you want to run a whole domain of problems from the dataset with Goal Completion heuristic, you should run the following:

```
ruby results_parser.rb <domain_name> <noisy>
```

If you want the Landmark Uniqueness heuristic, go for:

```
ruby results_parser_uniqueness.rb <domain_name> <noisy>
```

```<domain_name>``` is the name of the domain being run. It must match the domain directory name on the dataset and is a required parameter.

```<noisy>``` is a flag to let the results aggregator know if you're working with problems from the dataset that have noisy observations. You simply add the word ```noisy``` to the end of the command and everything will be set. If you don't add the word, it will assume you're working with problems from the dataset that do not contain noisy observations.

The results for the domain will be available at the ```results.json``` file. It will be run for 0% and 10% thresholds.

## Full Setup (for the fun stuff)

OK, so you've played around a little and now want the real deal. Well, if you wish to run for all the domains on the dataset, I recommend you do the following.

First, make sure you have enough disk space (at least 20 GB). Trust me, you don't want the following script to run you out of disk space. Now, run the following:

```
bash experiments_setup.sh
```

This will create a folder for each domain on the dataset and copy FastDownward and all other scripts and executables to each folder. It will also build FastDownward into every folder. That is why you need the disk space. This might take a while, so I would go grab a cup of coffee and sit back while it runs.

After it has finished running, you can go into each folder and run the ```results_parser``` as mentioned before, for each folder (and each domain). So if, for example, you're running Goal Completion for blocks-world domain without noisy observations, you should go into blocks-world folder and run:

```
ruby results_parser.rb blocks-world
```


 You must choose 1 heuristic to run for all domains. That will result in you having a results.json for each domain folder. Then, you can merge them together in a single file (one for noisy and one for not-noisy observations) through the following:

```
ruby merge_results.rb <heuristic> <noisy>
```

The ```heuristic``` parameter defines what heuristic you're compiling results for, so it can add it to the merged results file name. You should go for ```goalcompletion``` or ```uniqueness```.

The ```noisy``` parameter has the same behavior as the one in ```results_parser```. It will add the ```noisy``` to the file name to let you know which file is for noisy problems and which is not. If you don't inform this parameter, it will consider as "not noisy".

I must warn you not to run another heuristic until you've compiled all the results for a single heuristic, since the results will be overwritten inside the domains folders, so be careful about that. After you've merged the results and kept them safe somewhere, you can run everything again for the other heuristic.

I also recommend you run this with something like ```screen``` for Linux, since some domains may take a really long time to run (days long).

You can then use the table and graphs generators (based on GNUPlot) to create LaTeX tables and GNUPlot graphs.
