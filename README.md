# Fundy FactSet Loader

Docker image for running the FactSet DataFeed Loader on Kubernetes (AWS EKS).

## Overview

Packages FDSLoader64 v2.13.7.0 on Ubuntu 22.04 as a Kubernetes CronJob that ingests FactSet financial data into PostgreSQL (CloudNativePG).

## Architecture

- `linux/amd64` only — FDSLoader64 is a x86_64 PAR binary

## Required Environment Variables

| Variable | Description |
| --- | --- |
| `PGHOST` | PostgreSQL server hostname |
| `PGDATABASE` | Database name |
| `PGUSER` | Database user |
| `PGPASSWORD` | Database password (encrypted at startup) |
| `FACTSET_SERIAL` | FactSet serial number |
| `FACTSET_USER` | FactSet username |
| `MACHINE_CORES` | Max parallel downloads (default: 4) |
| `KEY_FILE_PATH` | Optional: path to mounted `key.txt` |

## Required Secrets (Kubernetes)

- `key.txt` — FactSet OTP authentication key (mount as file)

## Image Tags

| Tag | Description |
| --- | --- |
| `latest` | Latest build from main branch |
| `v*` | Specific release version |
| `<sha>` | Git commit SHA |

## Requirements

- PostgreSQL 17 (CloudNativePG)
- FactSet DataFeed subscription
- FactSet Curator credentials
