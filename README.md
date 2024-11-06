# CSlant Home Runner

```text
██╗  ██╗ ██████╗ ███╗   ███╗███████╗    ██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ 
██║  ██║██╔═══██╗████╗ ████║██╔════╝    ██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
███████║██║   ██║██╔████╔██║█████╗      ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
██╔══██║██║   ██║██║╚██╔╝██║██╔══╝      ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗    ██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
```

This repo is to set up the runner for updating the homepage at https://cslant.com

We can use this runner to update the Home automatically with CI/CD pipelines.

## Installation

First, copy the `.env.example` file to `.env` and update the values.

```bash
envsubst < .env.example > .env
```

In the `.env` file, update the values to match your environment.

```bash
# .env

#SOURCE_DIR=~/source
SOURCE_DIR=/home/user/cslant.com/home

GIT_SSH_URL=git@github.com:cslant

# The name of the runner
WORKER_NAME="CSlant Home"

# add the env to choose "npm" or "yarn" as the installer
INSTALLER=yarn

# App Config
# E.g: prod, dev
ENV=prod

NODE_VERSION=22

USE_SUBMODULES=false
```

> [!IMPORTANT]
> ## Command can't be used if wrong values are set in the `.env` file.
> * If the `SOURCE_DIR` is wrong, the runner will not be able to find the source code. So, please make sure the `SOURCE_DIR` is correct.

Then, you can just run the following command to start the runner.

```bash
./runner.sh a
```

## Usage

The runner has the following commands:

| Command        | Description                  |
|----------------|------------------------------|
| `help`, `tips` | Shows the help message       |
| `build`, `b`   | Builds the Home              |
| `worker`, `w`  | Create or restart the worker |
| `all`, `a`     | Runs all the commands        |
