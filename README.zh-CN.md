# Harness OpenSpec Superpowers 模板

[English](README.md)

这是一个可复用的 `Harness + OpenSpec + Superpowers` 工作流启动模板。

## 是否开箱即用？

模板文件可以直接安装到目标项目中，但完整工作流不是零依赖。`install.sh` 只负责把 Harness 文件复制到目标仓库，不会安装全局 CLI 或编辑器应用。

最低依赖如下：

| 工具 | 是否必需 | 用途 |
| --- | --- | --- |
| `bash` | 必需 | 运行 `install.sh` 和 `harness/bin/*` |
| `git` | 必需 | 支持状态、diff、分支和评审工作流 |
| Node.js `>= 20.19.0` 和 `npm` | 必需 | 安装和运行 OpenSpec |
| `openspec` CLI | 必需 | 驱动 `check`、`status`、`opsx` 和 `verify` |
| Claude Code、Codex 或 Cursor | 至少选一个 | 读取对应的 `.claude`、`.codex` 或 `.cursor` 适配器 |
| Superpowers 插件 | 推荐 | 提供 brainstorming、planning、TDD 和 review 纪律 |
| `rtk` | 可选 | 本地命令代理；缺失时 `harness/bin/check` 只会给出 warning |

安装 OpenSpec：

```bash
npm install -g @fission-ai/openspec@latest
openspec -V
```

如果使用 Claude Code，并希望启用完整 Superpowers 工作流，在 Claude Code 内安装插件：

```text
/plugin install superpowers@claude-plugins-official
```

新机器通常按这个顺序准备：

```bash
# 1. 安装 Node.js >= 20.19.0

# 2. 安装 OpenSpec
npm install -g @fission-ai/openspec@latest

# 3. 安装你实际使用的 AI 客户端：Claude Code、Codex、Cursor，或多个都装

# 4. Claude Code 用户可选但推荐：安装 Superpowers
# /plugin install superpowers@claude-plugins-official
```

依赖准备好后，把这个模板安装到目标项目并验证：

```bash
./install.sh \
  --target /path/to/project \
  --project-name "MyProject" \
  --tech-stack "Android Kotlin Gradle"

cd /path/to/project
./harness/bin/check
./harness/bin/opsx verify
```

## 这个模板会安装什么？

- `harness/bin/*`：仓库级工作流命令
- `harness/workflows/*`：共享工作流文档
- `harness/skills/*`：项目内 `multi-review`、`compound-knowledge` 和 `tech-proposal` 工作流
- `openspec/config.yaml`：项目级 OpenSpec 配置
- `.codex/`、`.claude/`、`.cursor/`：轻量客户端适配器
- `.claude/settings.json` 和 `.claude/hooks/*`：项目级 Claude Code 工作流提醒
- `docs/superpowers/specs` 和 `docs/superpowers/plans`：规划文档目录
- `AGENTS.md`、`CLAUDE.md` 和 `HARNESS.md`：仓库入口说明

## 安装到项目

```bash
./install.sh \
  --target /path/to/project \
  --project-name "MyProject" \
  --tech-stack "Android Kotlin Gradle"
```

只有在你明确要替换目标项目里已有的 Harness/OpenSpec 工作流时，才使用 `--force`。

## 验证这个模板

```bash
bash tests/test_install.sh
```

## 验证已安装的项目

```bash
cd /path/to/project
./harness/bin/check
./harness/bin/opsx verify
```

## 说明

这是一个模板仓库。生成的 OpenSpec changes、归档后的 changes，以及具体项目自己的 specs，应该放在每个目标项目里，而不是放在这个模板仓库里。
