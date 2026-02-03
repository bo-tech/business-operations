---
date: 2023-09-19
---

(adr-0004)=
# 0004 Multiple databases in one PostgreSQL Cluster

## Context and Problem Statement

Should we run one PostgreSQL Cluster per database or host multiple databases per
PostgreSQL Cluster?


## Considered options

- One database per cluster
- Multiple databases per cluster


## Decision Outcome

Start with one database per cluster and follow the recommendation of
CloudNativePG at <https://cloudnative-pg.io/documentation/1.16/faq/>.


## Pros and Cons of the Options


### One database per cluster

Good, because backup and restore are handled per cluster and not per database.
Good, because applications can upgrade their PostgreSQL version independently.
Bad, because there is an overhead to run many PostgreSQL clusters.


### Many databases per cluster

Good, because there is only small overhead created.
Bad, because backup and restore of all databases can only be one on cluster level.
Bad, because updating PostgreSQL can only be done for all applications together.


## More Information

This decision is reversible if this approach turns out to cause an unreasonable
amount of overhead.

Using the tooling `pg_restore` and `pg_dump` allows to transport a database
across PostgreSQL versions. It is not fully clear if loading databases from
multiple clusters into one new cluster can be done automatically, it certainly
can be done in a manual one-off operation though.


## Pointers

- CloudNativePG - <https://cloudnative-pg.io/>
- CrunchyData - <https://github.com/CrunchyData/postgres-operator>
