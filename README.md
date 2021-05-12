# rancher-bench

This repository contains a set of benchmarks for common [Rancher v2.x](https://github.com/rancher/rancher) developer workflows.
Start the benchmark by cloning the repository and executing the following:

```bash
./bench.sh
```

You may want to clean the `tmp` directory used for benchmarking to reclaim disk space.

```bash
rm -r /tmp/rancher-bench/
```

> Note: this has only been tested on macOS systems using GNU Bash to execute `bench.sh`.
