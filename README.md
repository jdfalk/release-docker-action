<!-- file: README.md -->
<!-- version: 1.0.0 -->
<!-- guid: 2b8e4f7a-3c9d-4e5b-a1f8-6d3e9c2a4b7e -->

# Release Docker Image Action

GitHub Action for building and publishing multi-platform Docker images to
container registries, with optional dockerized execution.

## Features

- 🐳 Multi-platform builds (amd64, arm64)
- 📦 Push to any Docker registry (Docker Hub, GHCR, ECR, etc.)
- 🚀 Build caching support
- 🏷️ Flexible tagging strategies
- 📊 Build summaries in workflow output

## Usage

### Basic Example

```yaml
- name: Build and push Docker image
  uses: jdfalk/release-docker-action@v1
  with:
    image-name: myapp
    tag: v1.0.0
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
```

### Advanced Example

```yaml
- name: Build and push Docker image
  uses: jdfalk/release-docker-action@v1
  with:
    context: ./app
    dockerfile: ./app/Dockerfile
    platforms: linux/amd64,linux/arm64,linux/arm/v7
    registry: ghcr.io
    image-name: ${{ github.repository }}
    tag: ${{ github.ref_name }}
    additional-tags: |
      type=semver,pattern={{version}}
      type=semver,pattern={{major}}.{{minor}}
      type=sha
    build-args: |
      BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
      VCS_REF=${{ github.sha }}
    cache-from: type=registry,ref=ghcr.io/${{ github.repository }}:buildcache
    cache-to:
      type=registry,ref=ghcr.io/${{ github.repository }}:buildcache,mode=max
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

### Force Docker Execution

```yaml
- uses: jdfalk/release-docker-action@v1
  with:
    use-docker: true
    docker-image: ghcr.io/jdfalk/release-docker-action:main
    image-name: myorg/myapp
    tag: v1.2.3
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
```

## Inputs

| Input             | Description                                                      | Required | Default                                     |
| ----------------- | ---------------------------------------------------------------- | -------- | ------------------------------------------- |
| `context`         | Docker build context directory                                   | No       | `.`                                         |
| `dockerfile`      | Path to Dockerfile                                               | No       | `Dockerfile`                                |
| `platforms`       | Comma-separated list of platforms                                | No       | `linux/amd64,linux/arm64`                   |
| `registry`        | Docker registry                                                  | No       | `docker.io`                                 |
| `image-name`      | Docker image name                                                | Yes      | -                                           |
| `tag`             | Docker image tag                                                 | No       | `latest`                                    |
| `additional-tags` | Additional tags (comma-separated)                                | No       | -                                           |
| `push`            | Whether to push the image                                        | No       | `true`                                      |
| `build-args`      | Build arguments (key=value)                                      | No       | -                                           |
| `cache-from`      | Cache source                                                     | No       | -                                           |
| `cache-to`        | Cache destination                                                | No       | -                                           |
| `username`        | Registry username                                                | No       | -                                           |
| `password`        | Registry password/token                                          | No       | -                                           |
| `use-docker`      | Run the action inside the published container image              | No       | `false`                                     |
| `docker-image`    | Docker image reference (tag or digest) when `use-docker` is true | No       | `ghcr.io/jdfalk/release-docker-action:main` |

## Outputs

| Output     | Description           |
| ---------- | --------------------- |
| `digest`   | Image digest          |
| `metadata` | Build result metadata |
| `tags`     | Generated tags        |

## Examples

### Push to Docker Hub

```yaml
- uses: jdfalk/release-docker-action@v1
  with:
    image-name: username/myapp
    tag: v1.0.0
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
```

### Push to GitHub Container Registry

```yaml
- uses: jdfalk/release-docker-action@v1
  with:
    registry: ghcr.io
    image-name: ${{ github.repository }}
    tag: ${{ github.ref_name }}
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

### Multi-platform with Caching

```yaml
- uses: jdfalk/release-docker-action@v1
  with:
    image-name: myapp
    tag: latest
    platforms: linux/amd64,linux/arm64,linux/arm/v7
    cache-from: type=registry,ref=myapp:buildcache
    cache-to: type=registry,ref=myapp:buildcache,mode=max
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
```

## License

MIT

## Contributing

Contributions are welcome! Please open an issue or PR. GitHub Action for
building and publishing Docker images
