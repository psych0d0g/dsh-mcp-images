# REA (rea-agents, "Reverse Engineer Anything") `rea mcp` (stdio) behind
# mcp-proxy, served as Streamable HTTP on :8080/mcp (health: /status), with
# Ghidra + JDK 21 for native-binary analysis. Runs next to deepseek-harness in
# ns synapse with the shared workspace PVC mounted at /workspace, so paths the
# agent passes are the same on both sides.
FROM node:24-trixie-slim

# renovate: datasource=npm depName=rea-agents
ARG REA_VERSION=6.4.0
# renovate: datasource=pypi depName=mcp-proxy
ARG MCP_PROXY_VERSION=0.13.0
# Must stay on the release line REA verifies its Ghidra bridge against
# (SUPPORTED_GHIDRA_VERSION / SUPPORTED_GHIDRA_JAVA_MAJOR in rea-agents'
# dist/ghidra/GhidraInstallationPolicy.js): 12.1.x on JDK 21 as of 6.4.0.
# Bump together with REA, never through Renovate alone.
ARG GHIDRA_VERSION=12.1.4
ARG GHIDRA_BUILD_DATE=20260921
ARG GHIDRA_SHA256=ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db
# Bump for image-only changes (packages, entrypoint) without a version
# bump above: it is part of the tag, so the cluster pulls the new image.
ARG IMAGE_REVISION=2

# procps: REA tracks the Ghidra process group it launches with
# `ps -axo pid=,ppid=,pgid=,...`; without it every Ghidra launch fails
# ("Ghidra headless launch failed", spawn ps ENOENT).
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      openjdk-21-jdk-headless python3 python3-venv tini ca-certificates curl unzip procps \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/ghidra.zip \
      "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_BUILD_DATE}.zip" \
    && echo "${GHIDRA_SHA256}  /tmp/ghidra.zip" | sha256sum -c - \
    && unzip -q /tmp/ghidra.zip -d /opt \
    && mv "/opt/ghidra_${GHIDRA_VERSION}_PUBLIC" /opt/ghidra \
    && rm /tmp/ghidra.zip \
    && test -x /opt/ghidra/support/analyzeHeadless

RUN python3 -m venv /opt/mcp-proxy \
    && /opt/mcp-proxy/bin/pip install --no-cache-dir "mcp-proxy==${MCP_PROXY_VERSION}" \
    && /opt/mcp-proxy/bin/mcp-proxy --help >/dev/null

RUN npm install --global --no-audit --no-fund "rea-agents@${REA_VERSION}" \
    && test "$(node -p "require('/usr/local/lib/node_modules/rea-agents/package.json').version")" = "${REA_VERSION}" \
    && command -v rea

ENV GHIDRA_INSTALL_DIR=/opt/ghidra \
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 \
    HOME=/home/node
# The node image's own uid 1000 - matches the harness and vscode, which share
# the workspace PVC (a different uid would trigger a recursive chown).
USER 1000:1000
EXPOSE 8080
ENTRYPOINT ["tini", "--", "/opt/mcp-proxy/bin/mcp-proxy", "--host", "0.0.0.0", "--port", "8080", "--pass-environment", "--", "rea", "mcp"]
