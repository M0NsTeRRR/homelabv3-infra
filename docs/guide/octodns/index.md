# Octodns

## What is Octodns ?

[Octodns](https://github.com/octodns/octodns) gives the ability to manage DNS agnostically across multiple providers.

## List of supported providers

* [Scaleway](https://www.scaleway.com/en/)

## Usage

You should not normally use it by hand it's running in a Github action.

Configuration is stored in `octodns` folder.

`SCALEWAY_SECRET_KEY` represents the API token to manage your DNS zone

```sh
export SCALEWAY_SECRET_KEY=<SCALEWAY_SECRET_KEY>
octodns-sync --config-file=./octodns/config.yaml --doit --force
```
