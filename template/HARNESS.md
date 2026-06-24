# Harness

`Harness` 是这个仓库的统一工作流外壳：它把仓库入口、预检、状态查看、`OpenSpec` 动作路径和三端客户端适配收敛到一套仓库内可读、可执行的约定里。

## Quick Start

第一次进入仓库，先跑这三个命令：

```bash
./harness/bin/check
./harness/bin/status
./harness/bin/opsx help
```

这三步分别回答：

- 这个仓库的工作流骨架是否齐全
- 当前 `Harness + OpenSpec + Superpowers` 是否就绪
- 有哪些统一动作入口可用

## Core Commands

```bash
./harness/bin/check
./harness/bin/status
./harness/bin/verify
./harness/bin/opsx [action]
```

`opsx` 支持的动作：

- `propose <change-name>`：创建 change 并立刻展示 status
- `apply [change-name]`：拉取 status 与 apply instructions
- `archive [change-name] [flags]`：执行真实 archive 流程
- `sync [change-name]`：拉取 sync 所需上下文
- `explore [change-name]`：列出 active changes 或查看单个 change 状态
- `verify`：运行 Harness 预检、Harness 测试和 OpenSpec 验证门禁

## Responsibility Boundary

### Harness

负责：

- 仓库统一入口
- 环境预检
- 状态汇总
- 仓库级共享 workflow 文档
- `Claude` / `Cursor` / `Codex` 的薄适配基线

### OpenSpec

负责：

- change 生命周期
- artifact 状态
- status / instructions / validate / archive 等 CLI 能力

### Superpowers

负责：

- 设计 spec
- 实施 plan
- 执行纪律

## Standard Path

### 1. Preflight

```bash
./harness/bin/check
```

### 2. Inspect current state

```bash
./harness/bin/status
```

### 3. Choose a workflow

```bash
./harness/bin/opsx propose <change-name>
./harness/bin/opsx apply [change-name]
./harness/bin/opsx archive [change-name] -y
./harness/bin/opsx sync [change-name]
./harness/bin/opsx explore
./harness/bin/opsx verify
```

### 4. Read the matching workflow doc

Shared workflow truth lives in:

- `harness/workflows/propose.md`
- `harness/workflows/apply.md`
- `harness/workflows/archive.md`
- `harness/workflows/sync.md`
- `harness/workflows/explore.md`
- `harness/workflows/verify.md`

`opsx` 现在会直接执行对应的 `OpenSpec` CLI 流程，不再只是打印建议命令。workflow 文档仍然是流程真相，用于解释动作边界、失败处理和手动兜底路径。

## Client Adapters

这些客户端入口不是主规范来源，只是薄适配：

- `.claude/`
- `.cursor/`
- `.codex/`

Codex 额外有两层仓库级约束：

- `.codex/skills/harness/SKILL.md`：让 Codex 在本仓库任务中优先触发 Harness。
- `AGENTS.md`：让 Codex 进入仓库时知道本项目的第一入口是 Harness。

如果要改流程，先改：

- `HARNESS.md`
- `harness/README.md`
- `harness/workflows/*.md`
- `harness/bin/*`

不要先改客户端适配器。

## Troubleshooting

### `./harness/bin/check` 失败

先看失败项是：

- 仓库文件缺失
- `openspec` 缺失
- 目录结构不完整

### `./harness/bin/status` 卡住或输出异常

优先检查：

```bash
openspec list --json
openspec status --change "<name>" --json
```

### 不知道下一步动作

先看：

```bash
./harness/bin/opsx help
```

再打开对应 workflow 文档。

### `apply` / `archive` / `sync` 没传 change 名称

`opsx` 会自动处理三种情况：

- 没有 active change：直接报错并提示先 `propose`
- 只有一个 active change：自动选中它
- 有多个 active changes：要求显式传入名称
