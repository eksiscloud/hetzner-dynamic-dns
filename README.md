# Dynamic DNS for Hetzner

It changes DNS of a domain to same what is your home IP.
This is kind of fork of this: https://github.com/jgillman/digital-ocean-dynamic-dns.git
but differend. And this one uses `systemd`.

You need
* a domain
* a server on Ubuntu (others may work too, I don't know) at home (Raspberry works fine)

`chmod +x` to all .sh

You can install everything to your home directory, if you want. All ir expects is sub directory `dynamic-dns`. You van change it easily, if you want.

## Setting up

First you should secure `secrets-hetzner`:
```
chmod 600 secrets-hetzner
```
You need DNS API from Hetzner. Not Cloud API, but DNS API. yes, they have two APIs. You find link for DNS API on sidebar of... DNS page.

Add it in `secrets-hetzner`.

At same time you should add your domain. There is commented line for sub domain. I`ve never tested it, but it should work.

Do 
```
./get-dns-hetzner.sh
```
Copy long'ish register number and it in the secrets too.

That`s it.

## systemd

Copy units
```
mkdir -p ~/.config/systemd/user
cp hetzner-ddns.* ~/.config/systemd/user/
```
* the timer triggers every 5th minutes

The timer will be loaded and activated:
```
systemctl --user daemon-reload
systemctl --user enable --now hetzner-ddns.timer
```
Enabe use without login:
```
loginctl enable-linger $USER
```

Load the daemon:
```
systemctl --user daemon-reload
```

Start the service:
```
systemctl --user start hetzner-ddns.service
```
Check the latest drive:
```
systemctl --user status hetzner-ddns.service
```
Check the status of the timer:
```
systemctl --user status hetzner-ddns.timer
systemctl --user list-timers
```
Now the IP of your domain should be same as your home IP.
