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
<h2 align="center">
  <a href="https://www.docker.com/">
    <img alt="Docker" src="https://i.imgur.com/nvTgxg3.png" width="200"/>
  </a>
  <a href="https://www.speedtest.net/apps/cli">
    <img alt="Speedtest®" src="https://i.imgur.com/fjCIjum.png" width="200"/>
  </a>
</h2>
<p align="center">
  <a href="https://github.com/huss4in7/speedtest-cli/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/huss4in7/speedtest-cli?style=flat-&label=License&logo=paper&labelColor=0b0c1b&color=white"/>
  </a>
  <a href="https://github.com/huss4in7/speedtest-cli/releases">
    <img src="https://img.shields.io/github/release-date/huss4in7/speedtest-cli?style=flat-&label=Release%20Date&labelColor=0b0c1b&color=white"/>
  </a>
  <a href="https://github.com/huss4in7/speedtest-cli/releases">
    <img src="https://img.shields.io/github/v/release/huss4in7/speedtest-cli?style=flat-&label=Release&logo=speedtest&labelColor=0b0c1b&color=white"/>
  </a>
</p>

## Usage ⚙

```sh
docker run -ti --rm --init --net host --name speedtest huss4in7/speedtest-cli --accept-license
```

| [`Options`](https://docs.docker.com/engine/reference/commandline/run/#options) | Description                                                                                                                                       |
| :----------------------------------------------------------------------------: | ------------------------------------------------------------------------------------------------------------------------------------------------- |
|                                     `-ti`                                      | Attack to container **terminal** and make it **interactive**.                                                                                     |
|                                     `--rm`                                     | Automatically **remove** the container after it exits.                                                                                            |
|                                    `--init`                                    | Use **docker-init** as **PID1**, to make it possible to **kill** the process using (**ctrl + c**) or **stop** it with (**docker stop speedtest**) |
|                                  `--net=host`                                  | Connect the container to **host network** (for **native performance**).                                                                           |
|                               `--name=speedtest`                               | Assign **speedtest** to the container **name**                                                                                                    |
|                               `--accept-license`                               | **Accept** Ookla Speedtest **License**                                                                                                            |

<br>

<details>

<summary><strong>Building</strong> ⚒, <strong>Testing</strong> 🧪, and <strong>Deploying</strong> 🚀</summary>

## ⚒ Build:

```bash
./buildx.sh
```

## 🧪 Test:

#### Test all platforms:
```bash
./buildx.sh --test # or -t
```
#### Test specific platforms:
```bash
./buildx.sh --test linux/amd64,linux/arm64
```

## 🚀 Deploy:

```bash
./buildx.sh --push # or -p
```

<br>

</details>
<br>
<details>

<summary>To run with <strong>one command</strong> ⚙</summary>

### Add [`speedtest`](speedtest) to PATH

```sh
#!/bin/sh

docker run -ti --rm --init --net host --name speedtest huss4in7/speedtest-cli --accept-license $@
```

### Make it executable

```sh
chmod +x speedtest
```

### Run from anywhere

```sh
speedtest
```

## Example

```sh
# Print usage information:

speedtest --help # or -h
```

</details>

<br>

## Note 📝

This Docker Image uses [**Ookla Speedtest CLI**](https://www.speedtest.net/apps/cli) and accepts Ookla [License](https://www.speedtest.net/about/eula) and [Privacy](https://www.speedtest.net/about/privacy) terms.

<details>

<summary>Ookla Speedtest License</summary>

This End User License Agreement (”Agreement”) is a binding agreement between you (”End User” or “you”) and Ookla, LLC (”Ookla”). This Agreement governs your use of the Speedtest Software, (including all related documentation, the “Software”). The Software is licensed, not sold, to you.

Your use of this Software is subject to the Terms of Use and Privacy Policy at these URLs: <br> https://www.speedtest.net/about/terms and https://www.speedtest.net/about/privacy.

</details>
