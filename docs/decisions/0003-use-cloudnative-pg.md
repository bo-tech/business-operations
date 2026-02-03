---
date: 2023-09-19
---

(adr-0003)=
# 0003 Use CloudNativePG as Operator for PostgreSQL

## Context and Problem Statement

Some of our applications need a PostgreSQL database to store some of their
state. Managing PostgreSQL in Kubernetes shall be done with an Operator.

Which Operator should we use?


## Considered options

- CrunchyData Postgres Operator
- CloudNativePG


## Decision Outcome

Use CloudNativePG as PostgreSQL Operator, because it seems to be more
lightweight for small scale setups.


## Pros and Cons of the Options

Both options looked to be very good fits.

## Pointers

- CloudNativePG - <https://cloudnative-pg.io/>
- CrunchyData - <https://github.com/CrunchyData/postgres-operator>
