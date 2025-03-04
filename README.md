# Docker Polkadot
My personal unprivileged Polkadot Docker image.

[![Latest Github release][github-release-badge]][github-release-link] [![GitHub Workflow Status (branch)][github-actions-badge]][github-actions-link]

Usage:
```sh
docker run -d \
  --restart=always \
  --net=host \
  --name=polkadot \
  -v /path/to/polkadot:/data \
  ghcr.io/bunkerlab-net/polkadot \
    --base-path=/data ${EXTRA_POLKADOT_ARGS}
```

### Nonroot
The nonroot user has a U/GID of `65532`.

If you are having IO permission issues then make sure that the persistent volume has permissions set to allow this user Read/Write access.

If using [Podman](https://podman.io/) - `podman unshare chown -R 65532:65532 /path/to/polkadot/storage`

### Where can I download the image?
I'm using Github Actions to build and publish this image to:
* [ghcr.io/bunkerlab-net/polkadot](https://ghcr.io/bunkerlab-net/polkadot)

### I want to buy you a coffee
This is just a hobby project for me, if you really want to buy me a coffee, thank you :)

Monero: `83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh`

![XMR Address](https://api.qrserver.com/v1/create-qr-code/?data=83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh&amp;size=150x150 "83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh")

### I don't have Polkadot
You should read their [Lightpaper](https://polkadot.network/Polkadot-lightpaper.pdf) and check it out!
* [paritytech/polkadot](https://github.com/paritytech/polkadot) (_archived_)
* [paritytech/polkadot-sdk](https://github.com/paritytech/polkadot-sdk)
* [Polkadot.Network](https://polkadot.network/)
* [/r/polkadot](https://www.reddit.com/r/polkadot)


[github-release-badge]: https://img.shields.io/github/v/release/bunkerlab-net/docker-polkadot "Latest Github tag"
[github-release-link]: https://github.com/bunkerlab-net/docker-polkadot/releases
[github-actions-badge]: https://img.shields.io/github/actions/workflow/status/bunkerlab-net/docker-polkadot/docker.yml?branch=master "Github Workflow Status (master)"
[github-actions-link]: https://github.com/bunkerlab-net/docker-polkadot/actions?query=workflow%3ADocker
