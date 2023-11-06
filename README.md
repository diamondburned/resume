# resume

Diamond's resume repository.

## Usage

The `resume.json` is compatible with [Resumake](https://resumake.io/). To
generate the actual PDF, run:

```sh
./generate.sh
```

Note that, by default, some private information are censored in the final PDF.
This information is encrypted with `git-crypt`. `./generate.sh` will
automatically determine if the secret JSON is good for use or not.
