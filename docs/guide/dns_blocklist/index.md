# DNS Blocklist

In addition to [uBlock Origins](https://ublockorigin.com/) :heart: for [Firefox](https://www.mozilla.org/en-US/firefox/new/) :heart:, some devices, such as the YouTube app on my Android TV, do not use Firefox, so I've added a DNS blocklist to restrict trackers.

## How it's setup ?

Every day at 00:00, a systemd unit timer is triggered, which downloads a list of `RPZ` files from a text file located at `/etc/powerdns/rpz-sync.txt`.  
The files are then placed in the `/etc/powerdns/rpz` folder, and the Lua configuration is reloaded using the command `/usr/bin/rec_control reload-lua-config /etc/powerdns/recursor-rpz.lua`.

## Blocklist used

* [Github hagezi/dns-blocklists](https://github.com/hagezi/dns-blocklists) :heart:
