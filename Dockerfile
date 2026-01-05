FROM docker:27.3.1-cli-alpine@sha256:2b0d3e65fddeaaf7a0d10fd43116f0ed4b5a7303a7e0be39a0ddcaa2dd7f60ce

WORKDIR /repo

COPY src /action/src
COPY action.yml /action/action.yml

ENTRYPOINT ["sh", "-c", "cd /repo && sh /action/src/entrypoint.sh"]
