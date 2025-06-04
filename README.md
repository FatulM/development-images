# Development Images

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/FatulM/development-images/.github%2Fworkflows%2Fdocker.yml)

:boom: **THIS PROJECT IS NOT INTENDED FOR PUBLIC USE** :boom:

Some docker images for use in developing Java and Python apps.
It includes needed utilities and libraries.

I will build for the following architectures, and push them on GitHub registry:

- linux/amd64
- linux/arm64

You can get the image by pulling from GitHub registry:

```shell
docker pull ghcr.io/FatulM/development-images:latest
```

This image includes:

- Java 21 (OpenJDK)
- Python 3.12
- Maven 3
- build-essential
- Git
- curl
- wget
- jq
- ssh client and server
- and many other libs ...

You can run the images using something like:

```shell
docker run -it --rm -v $(pwd):/root/workspace -w /root/workspace ghcr.io/FatulM/development-images:latest
```

Test folder contains a dockerfile to test the built image.
