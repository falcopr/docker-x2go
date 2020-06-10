# docker-x2go

Remote desktop [X2Go Server](http://wiki.x2go.org/doku.php) in a dock
Forked from [tatsuya6502/x2go](https://github.com/tatsuya6502/docker-x2go)

- X2Go Server
- Firefox
- MATE
- Arch Linux Base Image

## Prerequisites

In the docker host run the following to allow systemd to start (for e.g. relevant for boot2docker)
```
sudo mkdir /sys/fs/cgroup/systemd
sudo mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
```

## Build Image
```
docker build --tag docker-x2go:latest .
```

It will generate an ssh key at start up and add it to
`/home/docker/.ssh/authorized_keys` in the container.

```
== Use this private key to log in ==
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAxb5G8gR40hAGEoRb4t1QDR4+tWeVw3Vgh6N4BaUpxFRFZS3Y
T72VqyNeFTqywuuA2tgF8ZhV1UC+Qxi0EmxoeRQAnt62EUerj1HcVm+MzveT+VWa
...
...
...
-----END RSA PRIVATE KEY-----
```

If the key was not printed, try this command:

```
$ docker logs x2go
```

Save the key to your local PC.

```
# On your local PC
vi ~/x2go/x2go-key
chmod 600 ~/x2go/x2go-key
```

## Running the X2Go Server Container

Run the script as the followings. This will pull the Docker image and run it.

```
docker run -it -d -p 2222:22 --cap-add SYS_ADMIN -v /sys/fs/cgroup:/sys/fs/cgroup:ro --tmpfs /run --tmpfs /run/lock --tmpfs /tmp --name=x2go docker-x2go:latest
```

## Connect to the the X2Go Server

Start X2Go Client on you PC. Choose **Session** -> **New Session**,
and enter the following information to the **Session** tab.

- **Server**
  * Host: (The IP address of the server)
  * Login: `docker`
  * SSH port: `2222`
  * Use RSA/DSA key for ssh connection: `~/x2go/x2go-key`

- **Session Type**
  * Choose **Environment** `MATE`.

Double-click on the session panel to connect.

## Known Problems
- Video streams crash on firefox, use chromium instead
