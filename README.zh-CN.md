# Harness OpenSpec Superpowers 模板

[English](README.md)

这是一个可复用的 `Harness + OpenSpec + Superpowers` 工作流启动模板。

## 一行安装

在目标 Git 项目目录粘贴下面这条命令。首次使用时会自动下载模板。

```bash
hosi_setup="$(curl -fsSL https://raw.githubusercontent.com/Yecangyuan/harness-openspec-superpowers-template/main/bootstrap.sh)" && bash -c "$hosi_setup" -- .
```

命令安装并登记当前项目，再把 `hosi` 链接到 `~/.local/bin`。默认的 `local` 模式会把工作流文件加入 `.gitignore`。团队共享时，把 `--shared` 加到命令末尾。

下载的模板默认保存在 `~/.local/share/hosi/template`，路径可通过 `HOSI_TEMPLATE_DIR` 指定。设置了 `XDG_DATA_HOME` 时，默认位置是 `$XDG_DATA_HOME/hosi/template`。

已经克隆模板仓库时，可以直接从目标项目运行本地入口。

```bash
"/path/to/template/hosi" . --install-system
```

## 是否开箱即用？

`hosi` 会把工作流文件复制到目标 Git 仓库。运行工作流还需要安装 OpenSpec 和至少一个支持的客户端。

最低依赖如下：

| 工具 | 是否必需 | 用途 |
| --- | --- | --- |
| `bash` | 必需 | 运行 `hosi`、`install.sh` 和 `harness/bin/*` |
| `git` | 必需 | 支持状态、diff、分支和评审工作流 |
| `curl` | GitHub 安装时需要 | 下载一行安装脚本 |
| Node.js `>= 22.20.0` 和 `npm` | 必需 | 推荐版本 OpenSpec 2.2.0 的运行要求 |
| `openspec` CLI | 必需 | 驱动 `check`、`status`、`opsx` 和 `verify` |
| Claude Code、Codex 或 Cursor | 至少选一个 | 读取对应的 `.claude`、`.codex` 或 `.cursor` 适配器 |
| Superpowers 插件 | 推荐 | 提供 brainstorming、planning、TDD 和 review 纪律 |
| `rtk` | 可选 | 本地命令代理；缺失时 `harness/bin/check` 只会给出 warning |

安装 OpenSpec：

```bash
npm install -g @fission-ai/openspec@2.2.0
openspec -V
```

如果使用 Claude Code，并希望启用完整 Superpowers 工作流，在 Claude Code 内安装插件：

```text
/plugin install superpowers@claude-plugins-official
```

新机器通常按这个顺序准备：

```bash
# 1. 安装 Node.js >= 22.20.0

# 2. 安装 OpenSpec
npm install -g @fission-ai/openspec@2.2.0

# 3. 安装你实际使用的 AI 客户端：Claude Code、Codex、Cursor，或多个都装

# 4. Claude Code 用户可选但推荐：安装 Superpowers
# /plugin install superpowers@claude-plugins-official
```

### 检查 `hosi` 命令

```bash
command -v hosi
hosi --help
```

安装会创建 `~/.local/bin/hosi`，链接到当前模板仓库。搬迁模板仓库或发现链接指向旧目录时，在当前模板仓库重跑 `./hosi --install-system`。

如果 zsh 仍找不到 `hosi`，在 `~/.zshrc` 中把 `~/.local/bin` 加入 `PATH`，然后打开新终端。

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## 升级已安装的项目

更新模板仓库后，可以从任意目录指定单个项目的路径进行升级。

```bash
hosi "/path/to/project" --upgrade
```

升级行为：

- 省略项目名、技术栈或安装模式时，沿用上次安装记录。没有安装模式字段的旧版记录按 `shared` 处理。
- 给目标项目补上缺失的托管 Harness 文件。
- 更新仍然等于上次安装版本的托管文件。
- 保留用户本地改过的托管文件，并把副本写入 `.harness-template-backups/<timestamp>/`。
- 写入 `.harness-template-version`，记录模板 commit、安装模式、安装时间、项目元数据和托管文件 hash。

升级后检查：

```bash
cd /path/to/project
git status --ignored
./harness/bin/check
./harness/bin/opsx verify
```

删除备份前先人工确认。如果你明确要覆盖本地 Harness 改动，使用 `--force`，不要使用 `--upgrade`。

### 批量升级已登记项目

`hosi` 安装或升级成功后，会把项目的绝对路径登记到当前用户的安装清单。更新模板仓库后，可从任意目录运行批量升级。

```bash
hosi --upgrade-all
```

如果通过一行命令下载了模板，先用 `git -C "$HOME/.local/share/hosi/template" pull --ff-only` 更新默认检出目录。

旧版 `hosi` 安装的项目可一次性补登记。补登记只更新本机清单。

```bash
hosi "/path/to/project" --register
```

补登记需要项目中已有 `.harness-template-version`。如果安装早于该清单，`--upgrade` 会创建清单，并对缺少历史哈希且与模板不同的文件先备份再替换。

清单中的项目链接默认位于 `~/.local/state/hosi/projects/`，可用 `ls -l` 查看。设置了 `XDG_STATE_HOME` 时使用 `$XDG_STATE_HOME/hosi`，也可以用 `HOSI_STATE_DIR` 指定状态目录。项目搬迁后，登记新路径即可纳入下次升级。

批量升级沿用各项目的安装模式和元数据，并保留本地修改及备份。目录或安装记录缺失时会跳过该项目。命令会尝试其余项目、汇总结果，并在有升级失败时返回非零退出码。

## 这个模板会安装什么？

- `harness/bin/*`：仓库级工作流命令
- `harness/workflows/*`：共享工作流文档
- `harness/skills/*`：项目内 `multi-review`、`compound-knowledge` 和 `tech-proposal` 工作流
- `openspec/config.yaml`：项目级 OpenSpec 配置
- `.codex/`、`.claude/`、`.cursor/`：轻量客户端适配器
- `.claude/settings.json`、`.claude/hooks/*` 和 `.claude/rules/*`：项目级 Claude Code 共享设置、工作流提醒和路径级补充规则
- `docs/superpowers/specs` 和 `docs/superpowers/plans`：规划文档目录
- `AGENTS.md`、`CLAUDE.md` 和 `HARNESS.md`：仓库入口说明
- `.harness-template-version`：已安装模板元数据、安装模式和托管文件 hash

默认 local 安装会把这些文件加入 `.gitignore`。如果使用 `--shared`，这些工作流文件会保留为普通 git 可跟踪文件。

## 指定项目名和技术栈

```bash
hosi "/path/to/project" --project-name "MyProject" --tech-stack "Android Kotlin Gradle"
```

只有在你明确要替换目标项目里已有的 Harness/OpenSpec 工作流时，才使用 `--force`。`install.sh --target <project-dir>` 仍然保留兼容入口，但推荐使用 `hosi`。

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

复杂变更进入实现前，运行 `./harness/bin/opsx review-spec <name>` 校验 OpenSpec 评审材料，再按 [规格评审流程](template/harness/workflows/review-spec.md) 核对验收场景、设计决策和任务覆盖。

归档前运行 `./harness/bin/opsx verify --change <name>`，查看任务进度、场景证据和归档建议。提交实际测试结果的方式见 [按 change 验收](template/harness/workflows/verify.md#change-verification)。

这是一个模板仓库。生成的 OpenSpec changes、归档后的 changes，以及具体项目自己的 specs，应该放在每个目标项目里，而不是放在这个模板仓库里。
