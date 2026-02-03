---
date: 2024-06-09
---

(adr-0015)=
# 0015 Backup database volumes also

## Context and Problem Statement

The database setup based on CloudNative PG has a backup integrated which pushed
the WAL into S3 and creates regular snapshots.

The restore is not yet smooth and needs always a new target to be defined, which
makes using the WAL backup difficult.

Should the database volumes also be included into the regular volume snapshots?


## Decision Outcome

For now yes, even though the backup is not adding as much extra value as one
might think.

The reason is that after a database restore the volume does not contain the
whole WAL anymore, because CNPG does create a new DB. This would then also be
reflected in the backups via k8up.

It will require further investigation to find out if a cluster can be restored
based on a volume snapshot only instead of using the CNPG mechanisms.
