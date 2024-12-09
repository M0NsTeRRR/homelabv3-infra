# Octodns

## What is Octodns ?

[Octodns](https://github.com/octodns/octodns) gives the ability to manage DNS agnostically across multiple providers.

## List of supported providers

* [Scaleway](https://www.scaleway.com/en/)

## Usage

### Internal

Configuration is stored in `octodns/internal` folder.

`POWERDNS_API_KEY` represents the API token to manage your DNS zone

```sh
export POWERDNS_API_KEY=<POWERDNS_API_KEY>
task octodns:sync-internal
```

### External

You should not normally use it by hand it's running in a Github action.

Configuration is stored in `octodns/external` folder.

`SCALEWAY_SECRET_KEY` represents the API token to manage your DNS zone

```sh
export SCALEWAY_SECRET_KEY=<SCALEWAY_SECRET_KEY>
task octodns:sync-external
```
