# Dynamic DNS for Hetzner

It changes DNS of a domain to same what is your home IP.
This is kind of fork of this: https://github.com/jgillman/digital-ocean-dynamic-dns.git
but differend. And this one uses `systemd`.

You need
* a domain
* a server on Ubuntu (others may work too, I don't know) at home (Raspberry works fine)

`chmod +x` to all .sh

You can install everything to your home directory, if you want. All ir expects is sub directory `dynamic-dns`. You van change it easily, if you want.

Check the latest drive:
```
systemctl --user status hetzner-ddns.service
```

Check the status of the timer:
```
systemctl --user status hetzner-ddns.timer
systemctl --user list-timers
```
