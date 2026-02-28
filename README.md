# EQPcDocker

A minimal Docker setup for running an EQEmu server with support for PC clients (Titanium, SoF, SoD, UF, RoF/RoF2).

Inspired by [EQMacDocker](https://github.com/nickgal/EQMacDocker).

## Requirements

- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/install/linux)

## Setup

```bash
# Clone this repo with submodules
git clone --recurse-submodules https://github.com/dashkto/EQPcDocker
cd EQPcDocker

# Create .env from the example — update SERVER_ADDRESS to your machine's IP
cp .env.example .env

# Build and run (first build will take a while)
docker compose up
```

## Client Configuration

Edit your EverQuest client's `eqhost.txt` to point at your server:

```
[LoginServer]
Host=YOUR_SERVER_IP:5998
```

Accounts are auto-created on first login.

## Architecture

| Service | Port | Description |
|---------|------|-------------|
| loginserver | 5998 (Titanium), 5999 (SoD+) | Login/account authentication |
| world | 9000 | World server, server select |
| zone | 7000-7400 | Zone instances |
| ucs | 7778 | Universal chat service |
| db | 3306 | MariaDB database |

## Database

The PEQ (ProjectEQ) database is automatically downloaded and imported on first run. This includes all NPCs, items, zones, spells, and quests up through Dragons of Norrath.

To reset the database, remove the Docker volume:

```bash
docker compose down
docker volume rm eqpcdocker_database
docker compose up
```

## Submodules

| Submodule | Source | Description |
|-----------|--------|-------------|
| Server | [EQEmu/Server](https://github.com/EQEmu/Server) | EQEmu server source code |
| Maps | [EQEmu/maps](https://github.com/EQEmu/maps) | Zone navigation meshes |
| Quests | [ProjectEQ/projecteqquests](https://github.com/ProjectEQ/projecteqquests) | Quest scripts |

## Credits

- [EQEmulator](https://github.com/EQEmu/Server) — the server emulator
- [ProjectEQ](https://github.com/ProjectEQ) — database content and quest scripts
- [EQMacDocker](https://github.com/nickgal/EQMacDocker) — the Docker architecture this project is based on
