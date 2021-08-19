<h1 align="center">
    <a href="https://github.com/huss4in7/speedtest-cli">
      <img src="https://img.shields.io/github/watchers/huss4in7/speedtest-cli?style=social&logo=github&label=Watchers"/>
    </a>
    <a href="https://github.com/huss4in7/speedtest-cli">
      <img src="https://img.shields.io/github/stars/huss4in7/speedtest-cli?style=social&logo=github&label=Stars"/>
    </a>
    <a href="https://github.com/huss4in7/speedtest-cli">
      <img src="https://img.shields.io/github/forks/huss4in7/speedtest-cli?style=social&logo=github&label=Forks"/>
    </a>
    ━
    <a href="https://hub.docker.com/r/huss4in7/speedtest-cli">
      <img src="https://img.shields.io/docker/stars/huss4in7/speedtest-cli?style=social&logo=docker&label=Stars"/>
    </a>
    <a href="https://hub.docker.com/r/huss4in7/speedtest-cli">
      <img src="https://img.shields.io/docker/pulls/huss4in7/speedtest-cli?style=social&logo=docker&label=Pulls"/>
    </a>
    <a href="https://hub.docker.com/r/huss4in7/speedtest-cli">
      <img src="https://img.shields.io/docker/image-size/huss4in7/speedtest-cli/latest?style=social&logo=docker&label=Image Size">
    </a>
</h1>
<h1 align="center">
  <a href="https://www.docker.com/">
    <img alt="Docker" src="https://i.imgur.com/nvTgxg3.png" width="200"/>
  </a>
  <a href="https://www.speedtest.net/apps/cli">
    <img alt="Speedtest®" src="https://i.imgur.com/fjCIjum.png" width="200"/>
  </a>
  <br>
  <a href="https://github.com/huss4in7/speedtest-cli/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/huss4in7/speedtest-cli"/>
  </a>
  <a href="https://github.com/huss4in7/speedtest-cli/releases">
    <img src="https://img.shields.io/github/release-date/huss4in7/speedtest-cli"/>
  </a>
  <a href="https://github.com/huss4in7/speedtest-cli/releases">
    <img src="https://img.shields.io/github/v/release/huss4in7/speedtest-cli"/>
  </a>
</h1>
<br>

### Build ⚒:

```bash
buildx.sh
```

### Test 🧪:

```bash
buildx.sh --test # or -t
```

### Deploy 🚀:

```bash
buildx.sh --push # or -p
```

<br><br>

## Usage ⚙

```sh
docker run --rm -ti --net host --name speedtest --init huss4in7/speedtest-cli
```

| [`Options`](https://docs.docker.com/engine/reference/commandline/run/#options) | Description                                                                                                                    |
| :----------------------------------------------------------------------------: | ------------------------------------------------------------------------------------------------------------------------------ |
|                                     `--rm`                                     | Automatically **remove** the container after it exits.                                                                         |
|                                     `-ti`                                      | Attack to container **terminal** and make it **interactive**.                                                                  |
|                                  `--net host`                                  | Connect the container to **host** network (for native performance).                                                            |
|                               `--name speedtest`                               | Assign **speedtest** to the container name                                                                                     |
|                                    `--init`                                    | Use **docker-init** as PID1, to make it possible to kill the process using (ctrl + c) or stop it with (docker stop #container) |

<br><br>

## To run with **_one_** command ⚙

### Add [`speedtest`](speedtest) to PATH

```sh
#!/bin/sh

docker run --rm - ti --net host --name speedtest --init huss4in7/speedtest-cli $@
```

### Make it executable

```sh
chmod +x speedtest
```

### Run from anywhere

```sh
speedtest
```

<br>

## Example ⚙

```sh
# Print usage information:

speedtest --help # or -h
```

<br><br>

# Note 📝

This Docker Image uses [**Ookla Speedtest CLI**](https://www.speedtest.net/apps/cli) and automatically accepts Ookla [License](https://www.speedtest.net/about/eula) and [Privacy](https://www.speedtest.net/about/privacy) terms.

## Ookla Speedtest License

This End User License Agreement (”Agreement”) is a binding agreement between you (”End User” or “you”) and Ookla, LLC (”Ookla”). This Agreement governs your use of the Speedtest Software, (including all related documentation, the “Software”). The Software is licensed, not sold, to you.

Your use of this Software is subject to the Terms of Use and Privacy Policy at at these URLs: https://www.speedtest.net/about/terms and https://www.speedtest.net/about/privacy.
