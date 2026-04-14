# Ansible Collection - dextercd.general

Just publishing some roles that have been useful to me.

## Restic

The `dextercd.general.restic` role is used to configure [Restic](https://restic.net/) to perform system backups.

It's designed to be extensible by other roles by having those roles drop configuration files/script into predefined directories.

The backup script will start by running all scripts inside `/etc/restic-backup/setup/*`.
This can be used to prepare data to be backed up (such as a database dump or a list of installed packages),
or to directly create Restic snapshots of certain resources.

All files in `/etc/restic-backup/files/*` are concatenated to get a list of paths that need to be backed up.
If you install something that requires backing up new paths, you should just drop a file in this directory containing those paths.

All files in `/etc/restic-backup/excludes/*` are concatenated to get a list of paths that should be skipped.
For example, you probably don't want to back up the files of a running database, so you skip those and only back up the dump created by the `setup` script.

Once the backup is done, the scripts in the `/etc/restic-backup/teardown/*` directory are run.
You can use this to delete temporary files.


## Postgres

The `dextercd.general.postgres` role installs postgres and sets it up for Restic backups by placing a Restic setup script that creates a snapshot for every database.
