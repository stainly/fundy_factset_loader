# Fundy FactSet Loader

A Docker image for running the FactSet DataFeed Loader on Kubernetes.

## Purpose

This image packages the FactSet DataFeed Loader (v2.13.7.0) on Ubuntu 22.04, designed to run as a Kubernetes CronJob that ingests financial data into a PostgreSQL database.

## What it does

The Loader runs on a scheduled interval and:
- Connects to FactSet's servers to download financial data (Prices, Fundamentals, Estimates, People, Events, Ownership)
- Pushes the data into a PostgreSQL database

## Supported Architectures

- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64/AWS Graviton)

## Usage

The image expects the following files to be injected at runtime via Kubernetes Secrets:
- `config` — FactSet and database configuration
- `key.txt` — FactSet OTP authentication key

## Image Tags

| Tag | Description |
| --- | --- |
| `latest` | Latest build from main branch |
| `v*` | Specific release version |
| `<sha>` | Git commit SHA for traceability |

## Requirements

- PostgreSQL 17
- FactSet DataFeed subscription (Prices, Fundamentals, Estimates)
- FactSet Curator credentials for authentication
