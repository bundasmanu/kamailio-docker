# kamailio-docker

Custom Kamailio Container to be used as a generic backbone on multiple purposes (Edge Proxy, Core Server, Registrar Server, etc).

- [kamailio-docker](#kamailio-docker)
  - [Purpose](#purpose)
  - [What offers?](#what-offers)
  - [.env file](#env-file)
  - [Networks](#networks)
  - [PostgreSQL](#postgresql)
  - [Homer](#homer)
  - [Build image](#build-image)
  - [Run Kamailio](#run-kamailio)
    - [Run Multiple Instances](#run-multiple-instances)
  - [Test Kamailio code](#test-kamailio-code)
  - [Sngrep for troubleshooting purposes](#sngrep-for-troubleshooting-purposes)
  - [kamcmd](#kamcmd)
  - [psql interface - inside container](#psql-interface---inside-container)
  - [Workaround on OSX to allow receiveing UDP requests without restrictions in length](#workaround-on-osx-to-allow-receiveing-udp-requests-without-restrictions-in-length)

## Purpose

The main reasons behind the need to create this repo, are mainly:

- The need to get a easy way to switch between different `Kamailio` versions;
- The need to make easy the process to install and use only the needed packages;
- The need to get a functional `backbone` that contains the main modules shared across different possible purposes like: `Edge Proxy`, `Core Proxy`, etc;

## What offers?

- `Kamailio` working in a container;
- Easy way to manage and switch between different `Kamailio` versions;
- Easy way to manage `Kamailio` packages;
- Easy way to run multiple `Kamailio` instances at same time, with same codebase;
- `kamcmd` integration;
- `dispatcher` integration implemented;
- `PostgreSQL` integration implmented - [postgres-kamailio-docker](https://github.com/bundasmanu/postgres-kamailio-docker);
- `Homer` integration implemented - tested with Homer7 and Homer10;
- Log file managing;

## .env file

- `DISTRO_IMAGE`: Debian version to be used to build the image;
- `KAMAILIO_VERSION`: Kamailio Debian repo version to be used to get the packages. We can see the availables versions here: [Kamailio Deb](https://deb.kamailio.org/);
- `KAMAILIO_PACKAGES`: List of `Kamailio` packages to be installed. The packages must be spearated by a comma;
- `STARTER_KAM_USER`: User to run `kamailio`;
- `STARTER_KAM_GROUP`: Group to run `kamailio`;
- `SHM_MEMORY`: Shared memory to be allocated;
- `PKG_MEMORY`: Private memory to be allocated;
- `CONFIGS_FOLDER`: Path to store the `Kamailio` configuration files (mount volume);
- `CFGFILE`: Starter `Kamailio` configuration file;
- `TMP_FILE_LOCATION`: Path to store temporary files (`.pid`, `.fifo`, `.sock`);
- `LOG_FILE_DIR`: Path to store the `kanailio` generated logs (mount volume);
- `LOG_FILE_NAME`: Name of the log file;
- `DB_CONNECTION`: Connection to the `Postgres` database;
- `LISTEN_IP`: IP address to add to `kamailio` listen address (this logic must be addressed by other tools, like: `ansible`);
- `HEPLIFY_IP`: IP address of `heplify-server` to send `HEP/SIP` requests and logs;
- `HEP_CAPTURE_ID`: `HEP` capture id to be used when sending `HEP/SIP` requests and logs;

## Networks

By default, this build was used and thinked for a local environment. But could be used for other purposes, should only be needed to changes the networks on `docker-compose` file and change the IP address on `.env` file.

But in this setup:

- `common-network`: This is a external network used in common with `postgres` container. More details about how to create the network are described in: [postgres-kamailio-docker](https://github.com/bundasmanu/postgres-kamailio-docker);
- `all_in_one`: Should point to the `docker` network used by `Homer` containers;

## PostgreSQL

All details to handle PostgreSQL container are described in: [postgres-kamailio-docker](https://github.com/bundasmanu/postgres-kamailio-docker).

If needed, you can execute you custom `sql` scripts or execute more `kamailio sql scripts` to add more needed tables. But, the current implementation supports all the needed modules;
Adapt only the values to be added on the tables;

In short:

```sh
git clone https://github.com/bundasmanu/postgres-kamailio-docker
docker network create --opt com.docker.network.driver.mtu=9000 --subnet=172.25.0.0/24 common-network ## if not created
docker compose build
docker compose up -d
```

## Homer

At this phase, i advise to use `Homer 7`. By default, the created network will assume the name pointed in `docker-compose` file (`hom7-prom-all_default`), but if the name is not the same please adjust;

To deploy `Homer 7`:

```bash
git clone https://github.com/sipcapture/homer7-docker
cd homer7-docker/heplify-server/hom7-prom-all
docker-compose up -d
```

## Build image

```sh
docker compose build kamailio
```

## Run Kamailio

```sh
docker compose run kamailio
```

### Run Multiple Instances

When running multiple instances, you should change three  environment variables:

- `LISTEN_IP`;
- `LOG_FILE_NAME`;
- `HEP_CAPTURE_ID`;

After that, run container as usual:

```sh
docker compose run kamailio
```

## Test Kamailio code

This command is useful when developing, we can easy troubleshoot problems;

```sh
docker compose run kamailio test
```

## Sngrep for troubleshooting purposes

```sh
docker exec -it <container_id> sngrep
```

## kamcmd

```sh
docker exec -it <container_id> kamcmd <command>
```

## psql interface - inside container

```sh
docker exec -it <container_id> psql -h 172.25.0.2 -U postgres -d kamailio
```

## Workaround on OSX to allow receiveing UDP requests without restrictions in length

```sh
sysctl -w net.inet.udp.maxdgram=9216
```
