# Octodns

## What is Octodns ?

[Octodns](https://github.com/octodns/octodns) gives the ability to manage DNS agnostically across multiple providers.


## Usage

### Internal

Configuration is stored in `octodns/internal` folder.

`MIKROTIK_USER` and `MIKROTIK_PASSWORD` represent the username and password used to connect to your MikroTik router to manage your DNS zone.

```sh
export MIKROTIK_USER=<MIKROTIK_USER>
export MIKROTIK_PASSWORD=<MIKROTIK_PASSWORD>
uv run task octodns:sync-internal
```

### External

You should not normally use it by hand it's running in a Github action.

Configuration is stored in `octodns/external` folder.

`INFOMANIAK_TOKEN` represents the API token to manage your DNS zone

```sh
export INFOMANIAK_TOKEN=<INFOMANIAK_TOKEN>
uv run task octodns:sync-external
```
