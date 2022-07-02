# Borg

A container for backing up stuff to a Borg repo, which may be local or remote (using SSH). It can also handle CephFS snapshotting.

It will backup, prune, and compact the repo according to your specifications. Then it will quit. You need to set up your own scheduling, such as a local crontab or Kubernetes CronJob.

# Environment

These environment variables can be used to configure the container.

```
# These can be omitted if no SSH is required
SSH_PRIVATE_KEY=<private key here>
SSH_KNOWN_HOSTS=<known_hosts contents here>

# These must be set
SOURCE=/m/source/
TARGET=/m/target/

# These are optional, defaults are empty
SYNC_OPTIONS=--exclude .cache
PRUNE_OPTIONS=--save-space
COMPACT_OPTIONS=--threshold 10

# These are set by default
HOURLY=24
DAILY=7
WEEKLY=4
MONTHLY=12
YEARLY=2

# this is off by default, setting to 1 will create the special CephFS ".snap/snap" folder in the source folder for use while backing up
CEPH=1
```

Also, you can specify any Borg environment variables, such as:

```
BORG_PASSPHRASE=supersecret
```

`SYNC_SOURCE` and `TARGET` will be fed to Borg as is. They can be either local (e.g. /path/to/repo) or remote (e.g. user@examplehost.com:/path/to/file::Archive1) or whatever Borg normally accepts.

`SYNC_OPTIONS` can be used to define extra options for `borg create`.

# Borg cache

Unless you mount a volume at `/root/.cache/borg` borg will have to recreate its cache for every backup. This can be time consuming. Giving it some room to save state is recommended.

# Example usage, Docker CLI

```
# Just for practice, let's create some folders to play with

mkdir -p /tmp/tmp
cd /tmp/tmp

mkdir -p SOURCE REPO cache

borg init --encryption repokey ./SOURCE
# (press enter for empty passphrase, or specify a passphrase and set BORG_PASSPHRASE env variable)

sudo docker run -it \
  -v /tmp/tmp/SOURCE:/SOURCE \
  -v /tmp/tmp/REPO:/REPO \
  -v /tmp/tmp/cache:/root/.cache/borg \
  -e SOURCE=/SOURCE \
  -e TARGET=/REPO::test-{now}
  mikabytes/docker-borg:latest
```

# Notes

In the container world mount points is highly changeable. Borg uses a "root recursion" algorithm that makes this a bit problematic. For this reason, this script will "cd" into the source folder before running the backup. This effectively makes the source folder the root. Read more [here](https://borgbackup.readthedocs.io/en/stable/usage/help.html#borg-patterns)
