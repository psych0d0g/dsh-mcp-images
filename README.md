# dsh-mcp-images

Container images for the MCP servers that deepseek-harness (ns `synapse`,
TalosCluster) reaches over Streamable HTTP instead of spawning them inside
its own container. Built by Woodpecker into `harbor.crystalnet.org/library/`.

| Dir    | Image          | What                                                          |
| ------ | -------------- | ------------------------------------------------------------- |
| `git/` | `dsh-mcp-git`  | `mcp-server-git` behind `mcp-proxy`                           |
| `rea/` | `dsh-mcp-rea`  | REA (`rea-agents`) behind `mcp-proxy`, with Ghidra and JDK 21 |

Servers that ship their own HTTP-capable image (mcp-kubernetes-ro,
mcp-victoriametrics, Playwright MCP) use the upstream images directly; their
manifests live in `k8s_cluster/deployments/dsh-mcp/`.

## Conventions

- Every image serves Streamable HTTP on `:8080/mcp`; `mcp-proxy` also answers
  `GET /status` for probes.
- The images run as uid/gid 1000. The pods mount the workspace PVC that the
  harness and vscode share at `/workspace`, so all three must keep the same
  uid, or each restart re-chowns the whole tree.
- Versions are `ARG`s in each Dockerfile. A `# renovate:` comment above an ARG
  lets Renovate bump it. Each image is tagged `<versions>,latest`, built from
  those ARGs by `.woodpecker/tags.sh`, so every bump yields a new tag.
- `GHIDRA_*` in `rea/Dockerfile` has no Renovate comment on purpose: it must
  stay on the Ghidra line REA verifies against (see the comment there).
