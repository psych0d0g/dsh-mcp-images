# mcp-server-git (stdio) behind mcp-proxy, served as Streamable HTTP on
# :8080/mcp (health: /status). Runs next to deepseek-harness in ns synapse
# with the shared workspace PVC mounted at /workspace - repo paths the agent
# passes are the same on both sides.
FROM python:3.13-slim-trixie

# renovate: datasource=pypi depName=mcp-server-git
ARG MCP_SERVER_GIT_VERSION=2026.10.10
# renovate: datasource=pypi depName=mcp-proxy
ARG MCP_PROXY_VERSION=0.13.0
# Bump for image-only changes (packages, entrypoint) without a version
# bump above: it is part of the tag, so the cluster pulls the new image.
ARG IMAGE_REVISION=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends git tini ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Both pin mcp<2 themselves (mcp-proxy <0.13 broke against mcp 2.x).
RUN pip install --no-cache-dir \
      "mcp-server-git==${MCP_SERVER_GIT_VERSION}" \
      "mcp-proxy==${MCP_PROXY_VERSION}" \
    && mcp-proxy --help >/dev/null \
    && python -c "import mcp_server_git"

# Workspace repos are created by the harness and vscode (both uid 1000, same
# as this container), but repos cloned or restored by other means must not
# be refused as "dubious ownership".
RUN git config --system safe.directory '*'

# HOME=/workspace like the harness: commits pick up the same ~/.gitconfig
# identity the harness and vscode use.
ENV HOME=/workspace
USER 1000:1000
EXPOSE 8080
ENTRYPOINT ["tini", "--", "mcp-proxy", "--host", "0.0.0.0", "--port", "8080", "--pass-environment", "--", "mcp-server-git"]
