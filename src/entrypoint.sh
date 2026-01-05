#!/usr/bin/env bash
# file: src/entrypoint.sh
# version: 1.0.0
# guid: e4c3d5b7-6a9f-4b8a-9c2f-1a0b2c3d4e5f

set -euo pipefail

: "${CONTEXT:=.}"
: "${DOCKERFILE:=Dockerfile}"
: "${PLATFORMS:=linux/amd64,linux/arm64}"
: "${REGISTRY:=docker.io}"
: "${IMAGE_NAME:?IMAGE_NAME is required}"
: "${TAG:=latest}"
: "${ADDITIONAL_TAGS:=}"
: "${PUSH_IMAGE:=true}"
: "${BUILD_ARGS:=}"
: "${CACHE_FROM:=}"
: "${CACHE_TO:=}"
: "${USERNAME:=}"
: "${PASSWORD:=}"

write_output() {
  name=$1
  value=$2
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    printf '%s=%s\n' "$name" "$value" >>"$GITHUB_OUTPUT"
  fi
}

write_summary() {
  text=$1
  if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    printf '%s\n' "$text" >>"$GITHUB_STEP_SUMMARY"
  fi
}

echo "Logging in to registry: $REGISTRY"
if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
  echo "$PASSWORD" | docker login "$REGISTRY" -u "$USERNAME" --password-stdin
else
  echo "No registry credentials provided; continuing without login"
fi

echo "Preparing metadata..."
TAGS="type=raw,value=${TAG}"
if [ -n "$ADDITIONAL_TAGS" ]; then
  TAGS="${TAGS}
${ADDITIONAL_TAGS}"
fi

meta_output=$(docker buildx imagetools inspect --raw || true)
echo "Metadata (ignored in docker path): ${meta_output:-none}"

echo "Building image..."
docker buildx build \
  --platform "$PLATFORMS" \
  --file "$DOCKERFILE" \
  --push "$PUSH_IMAGE" \
  "$(printf '%s\n' "$TAGS" | sed 's/^/--tag /' | xargs -r)" \
  "$(printf '%s\n' "$BUILD_ARGS" | sed 's/^/--build-arg /' | xargs -r)" \
  "$([ -n "$CACHE_FROM" ] && printf '%s\n' "$CACHE_FROM" | sed 's/^/--cache-from /' | xargs -r)" \
  "$([ -n "$CACHE_TO" ] && printf '%s\n' "$CACHE_TO" | sed 's/^/--cache-to /' | xargs -r)" \
  "$CONTEXT"

# Note: buildx doesn't emit digest easily across multiple tags; emit empty.
write_output "digest" ""
write_output "metadata" "{}"
write_output "tags" "$TAGS"

write_summary "## Docker Build Summary"
write_summary ""
write_summary "**Image:** ${REGISTRY}/${IMAGE_NAME}"
write_summary "**Tags:** ${TAGS}"
write_summary "**Platforms:** ${PLATFORMS}"
