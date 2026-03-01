# EQPcDocker

A minimal Docker setup for running an EQEmu server with support for PC clients (Titanium, SoF, SoD, UF, RoF/RoF2).

Inspired by [EQMacDocker](https://github.com/nickgal/EQMacDocker).

## Requirements

- [Docker Desktop](https://docs.docker.com/desktop/) with at least **6 GB RAM** allocated to the Docker VM
- [Docker Compose](https://docs.docker.com/compose/install/linux) (included with Docker Desktop)

## Setup

```bash
# Clone this repo with submodules (~1.2 GB for maps)
git clone --recurse-submodules https://github.com/dashkto/EQPcDocker
cd EQPcDocker

# Create .env from the example — update SERVER_ADDRESS to your LAN IP
cp .env.example .env
# Find your LAN IP: ipconfig getifaddr en0 (macOS) or hostname -I (Linux)

# Build and run
docker compose up
```

### First Run

The first run involves two slow steps:

1. **C++ compilation** (~45 min on Apple Silicon, longer on older hardware) — the EQEmu server is compiled from source inside Docker using a multi-stage build. The build uses `--parallel 1` to avoid OOM kills. Subsequent runs use the Docker build cache.

2. **PEQ database download** (~30 MB from `db.eqemu.dev`) — downloaded and imported into MariaDB on first container start. The database is persisted in a Docker volume, so this only happens once (or when you reset the volume).

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
| login | 5998 (Titanium), 5999 (SoD+) | Login/account authentication |
| world | 9000 | World server, server select |
| zone | 7000-7400 | Dynamic zone instances via eqlaunch |
| ucs | 7778 | Universal chat service |
| queryserv | — | Query server (internal) |
| shared | — | One-shot: loads shared memory (items/spells) |
| db | 3306 (internal) | MariaDB 10.11 with PEQ content |

## Database

The [PEQ (ProjectEQ)](https://db.eqemu.dev) database is automatically downloaded and imported on first run. This includes all NPCs, items, zones, spells, and quests up through Dragons of Norrath (expansion 9).

The `world` binary runs database migrations automatically on startup, so the schema stays up to date with the server version.

To reset the database:

```bash
docker compose down -v   # removes database AND shared memory volumes
docker compose up
```

## Build Notes

The server Dockerfile compiles mainline [EQEmu/Server](https://github.com/EQEmu/Server) from source. Key details:

- **vcpkg** manages C++ dependencies (libsodium, fmt, glm, cereal, luajit, recastnavigation, etc.). The vcpkg and websocketpp submodules are cloned at pinned commits during the build because Docker's `ADD` doesn't preserve `.git` metadata.
- **`--parallel 1`** is used for compilation to prevent OOM kills in the Docker VM. Even `--parallel 2` can exhaust memory on files like `database.cpp`.
- **`.dockerignore`** excludes `.git` directories to keep the build context manageable (the Maps submodule alone is ~1.1 GB).
- The `docker-compose.yml` uses a shared `image: eqpcdocker-server` so Docker builds the server image once and reuses it across all services, rather than building 7 copies in parallel.
- Make sure other Docker containers aren't running during the build — the compilation needs most of the Docker VM's memory.

## Submodules

| Submodule | Source | Description |
|-----------|--------|-------------|
| Server | [EQEmu/Server](https://github.com/EQEmu/Server) | EQEmu server source code |
| Maps | [EQEmu/maps](https://github.com/EQEmu/maps) | Zone navigation meshes |
| Quests | [ProjectEQ/projecteqquests](https://github.com/ProjectEQ/projecteqquests) | Quest scripts |

## Troubleshooting

- **Build killed / OOM**: Increase Docker Desktop's memory limit (Settings > Resources). Close other Docker containers. The build needs ~4 GB free.
- **SSL errors during DB download**: The PEQ database is downloaded from `db.eqemu.dev` over HTTPS. If you're behind a corporate proxy with SSL inspection, the download uses `curl -k` to bypass certificate verification.
- **Services keep restarting**: Check `docker compose logs <service>` — most issues are database connectivity. The services use [docker-compose-wait](https://github.com/ufoscout/docker-compose-wait) to wait for MariaDB, with a 300-second timeout for the first run.
- **World waiting for shared memory**: The `world` service waits for `/app/shared/spells` to exist (created by `shared_memory`). If `shared` exited with code 0, this file should be in the shared volume.
- **Zone processes crash with "Incompatible quest plugins"**: The zone binary requires `CheckHandin` to exist in both `/app/lua_modules/` and `/app/plugins/`. The Dockerfile creates symlinks from the Quests submodule directories. If you see this error, make sure the Quests submodule was cloned (`git submodule update --init`).
- **No zone servers available / OP_ZoneUnavail**: Check that the `launcher` table in the database has an entry matching the eqlaunch command. The default is `dynzone1` with 5 dynamic zones:
  ```sql
  INSERT INTO launcher (name, dynamics) VALUES ('dynzone1', 5);
  ```
- **eqlaunch not connecting to world**: The zone container uses `WORLD_TCP_IP=world` to connect to the world container's TCP port. The EQEmu config key is `server.world.tcp.ip` (not `host`). If zones aren't spawning, check `docker compose logs world` for "New Launcher connection" messages.

## Credits

- [EQEmulator](https://github.com/EQEmu/Server) — the server emulator
- [ProjectEQ](https://github.com/ProjectEQ) — database content and quest scripts
- [EQMacDocker](https://github.com/nickgal/EQMacDocker) — the Docker architecture this project is based on
- [db.eqemu.dev](https://db.eqemu.dev) — PEQ database archive hosting
