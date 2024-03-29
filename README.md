# XMind 8 KasmVNC Wrapper

## What

[XMind 8](https://www.xmind.net/xmind8-pro) is a cross-platform mind mapping program, which this repository enables you to run as a Docker container accessible via Remote Desktop or any web browser.

The source code and license for XMind 8 can be found [here](https://github.com/xmindltd/xmind), and if you can use Flatpak, it is also [available from Flathub](https://flathub.org/apps/details/net.xmind.XMind8) for Linux desktop installs.

## Why

I found myself needing to go through an entire folder of XMind files from 2016 onwards to figure out which ones to convert, but without an updated install--or an easy way to open them that didn't entail installing stuff I didn't want to run.

And since I've had my fill of [file format archaeology](https://taoofmac.com/space/blog/2020/10/24/2100), I decided to see if it was possible to "snapshot" the app in an easy to consume way for occasional use on any platform.

Using it via a browser is hardly ideal, but it works well enough. Fortunately there are Linux binaries and it saved me the trouble of adding WINE to the mix..

## Application Setup

This image sets up the XMind desktop app and makes its interface available in the browser. The interface is available at `http://your-ip:8080` or `https://your-ip:8181`.

By default, there is no password set for the main gui. Optional environment variable `PASSWORD` will allow setting a password for the user `abc`, via http auth.

### Options in all KasmVNC based GUI containers

This container is based on [Docker Baseimage KasmVNC](https://github.com/linuxserver/docker-baseimage-kasmvnc) which means there are additional environment variables and run configurations to enable or disable specific functionality.

#### Optional environment variables

| Variable | Description |
| :----: | --- |
| CUSTOM_PORT | Internal port the container listens on for http if it needs to be swapped from the default 3000. |
| CUSTOM_HTTPS_PORT | Internal port the container listens on for https if it needs to be swapped from the default 3001. |
| CUSTOM_USER | HTTP Basic auth username, abc is default. |
| PASSWORD | HTTP Basic auth password, abc is default. If unset there will be no auth |
| SUBFOLDER | Subfolder for the application if running a subfolder reverse proxy, need both slashes IE `/subfolder/` |
| TITLE | The page title displayed on the web browser, default "KasmVNC Client". |
| FM_HOME | This is the home directory (landing) for the file manager, default "/config". |
| START_DOCKER | If set to false a container with privilege will not automatically start the DinD Docker setup. |
| DRINODE | If mounting in /dev/dri for [DRI3 GPU Acceleration](https://www.kasmweb.com/kasmvnc/docs/master/gpu_acceleration.html) allows you to specify the device to use IE `/dev/dri/renderD128` |

## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose (recommended, [click here for more info](https://docs.linuxserver.io/general/docker-compose))

```yaml
---
version: "2.1"
services:
  xmind:
    image: ghcr.io/rcarmo/docker-xmind:latest
    container_name: xmind
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Lisbon
      - PASSWORD= #optional
      - CLI_ARGS= #optional
    volumes:
      - /path/to/data:/config
    ports:
      - 8080:8080
    restart: unless-stopped
```

### docker cli ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=xmind \
  --security-opt seccomp=unconfined `#optional` \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e PASSWORD= `#optional` \
  -e CLI_ARGS= `#optional` \
  -p 8080:8080 \
  -v /path/to/data:/config \
  --restart unless-stopped \
  ghcr.io/rcarmo/docker-xmind:latest

```
## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8080` | Xmind desktop gui. |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Etc/UTC` | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-e PASSWORD=` | Optionally set a password for the gui. |
| `-e CLI_ARGS=` | Optionally pass cli start arguments. |
| `-v /config` | Where XMind should store its data. |
| `--security-opt seccomp=unconfined` | For Docker Engine only, many modern gui apps need this to function as syscalls are unknown to Docker. |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```bash
-e FILE__PASSWORD=/run/secrets/mysecretpassword
```

Will set the environment variable `PASSWORD` based on the contents of the `/run/secrets/mysecretpassword` file.

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```bash
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```

## Credits

* [@plembo](https://github.com/plembo/xmind8) and [@mriza](https://github.com/mriza/XMind-Linux-Installer) for Linux installation steps, as well as parts of this `README`.
* [@dimMaryanto93](https://gist.github.com/dimMaryanto93/17bea110ec8e49b5eed28c89640a49d9) for a neater, cleaner `.ini` file that saved me the trouble of messing about with Eclipse settings.
* [@linuxserver](https://github.com/linuxserver/docker-calibre) for the original `Dockerfile`, which uses their VNC wrapper (and all steps of the `README` related to the container bits).
