# Snakemake profile for UC Berkeley's Savio cluster

This is a [Snakemake
profile](https://snakemake.readthedocs.io/en/stable/getting_started/migration.html#profiles)
for UC Berkeley's Savio cluster. Snakemake versions greater than 8 rely on
these profiles to dispatch Snakemake rules as jobs onto clusters via their
schedulers (e.g. [Slurm](https://slurm.schedmd.com/documentation.html)).
Snakemake recently deprecated cluster configuration files; this profile
will migrate that functionality. Thanks to [Silas
Tittes](https://twitter.com/SilasTittes) for sharing his profile that
worked for the [UO Cluster talapas](https://racs.uoregon.edu/talapas), from
which this is based upon.


## Installation

You can install with:

```
$ curl https://raw.githubusercontent.com/vsbuffalo/savio-snakemake/main/install.sh | bash
```

This will run the `install.sh` script, which will create the
`~/.config/snakemake/` directory if it does not exist, and then clone this
repository into `~/.config/snakemake/savio/`. This will place the workflow
profile at `~/.config/snakemake/savio/config.yaml`. 

## Configuration

You will need to configure the file at `~/.config/snakemake/savio/config.yaml` by

1. Adjusting the `slurm_partition` line to what [Savio
   partition](https://docs-research-it.berkeley.edu/services/high-performance-computing/user-guide/hardware-config/)
   you want to use. You can also do this at the rule-level (see below) in the `resources` block.

2. Change your `slurm_account` name.

## Usage

Then, once configured, this Snakemake profile can be used in workflows by
running `Snakemake` (I think it is best to do this on a new interactive session
created with `srun`) with,

```bash
$ snakemake --workflow-profile ~/.config/snakemake/savio all 
```

Note that this job will use **default resources** and only *two* jobs. This is 
intentional, since the user should override the number of jobs on the command line
with `-j/--jobs`

```bash
$ snakemake --workflow-profile ~/.config/snakemake/savio all --jobs 4
```

or, set the resources in the Snakemake rule itself, e.g. 

```python
rule a:
  input: "some_infile.txt"
  output: "some_outfile.txt"
  resources:
    slurm_partition = "savio2_bigmem",  # set custom partitions for certain jobs
    mem_mb =64000,  # increasing this can solve out-of-memory erros
    cpus_per_task = 40,
    runtime = 60
  shell:
    """
    # some command
    """
```

This is more reproducible, and helps future researchers see what resources
are needed for larger jobs. If the defaults in `config.yaml` are too far 
different from your needs, you can alter the local `config.yaml`.

## Example

As a minimal reproducible example, this repository includes a test `Snakefile`
in `savio_test/`. I will use [mamba](https://github.com/mamba-org/mamba) to
install the packages (which should be available on savio). Go to the test
directory, create a Python virtual environment from the `requirements.txt`, and
activate it:

```bash
$ cd ~/.config/snakemake/savio/savio_test/ 
$ mamba create -n snakemake_env -c conda-forge -c bioconda  --file requirements.txt
$ mamba activate snakemake_env
```

The `Snakefile` (shown below) will simply spawn jobs the node's hostnam
to a results directory:

```Snakefile
rule test_rule:
  output: "results/{letter}.txt"
  shell:
     """
     hostname > {output}
     """

rule all:
  input: expand("results/{letter}.txt", letter=["A", "B", "C", "D", "E"])
```

To run this with four jobs, use

```
$ snakemake --workflow-profile ~/.config/snakemake/savio all --jobs 4
```

or more simply, 

```
$ bash run.sh
```

Then, you can use `squeue | grep <your_username>` to see that the jobs
launched. Again, for large jobs, I recommend spawning a new interactive session
with `srun`, since sometimes large, complicated DAGs can be resource-intensive
to create.

## Slurm Logs

Slurm logs are stored within the `.snakemake/` directory created by 
Snakemake. You can access them with 

```
$ find .snakemake/slurm_logs/rule_test_rule/ -maxdepth 1
```

to see rule-level log directories.

## Debugging

Slurm jobs during development often fail, and the added layers of complexity of the job scheduler can make debugging trickier. Here are some general tips:

 1. Look at the Slurm log — there are two logs, the Snakemake-level one and the standard output from the command in `.snakemake/slurm_logs`. Look at both.
 2. Look at what is being passed directly to the Slurm scheduler. New Snakemake versions do not write the scripts; they are just generated on the fly and passed into the scheduler. You can see them with `--verbose`: e.g. `snakemake --profile /global/home/users/vsb/dotfiles2/.config/snakemake/savio all -jobs 20  --verbose`.

## Issues & Future Additions

Please create a GitHub [pull
request](https://github.com/vsbuffalo/savio-snakemake/pulls) if you fix a bug or add a useful feature.
For problems, create a new [GitHub issue](https://github.com/vsbuffalo/savio-snakemake/issues).

In the future, I would like to add some bash profile helper commands, e.g. for
quickly looking at the last log files, etc. If you want to work on adding these 
features, please create a new issue for discussion!

