# Harness Directory

`harness/` 是仓库级工作流核心层。这里保存唯一真相；客户端目录只做薄适配。

## Structure

```text
harness/
├── bin/         # 统一命令入口
├── skills/      # project-local review/knowledge/proposal skill truth
├── lib/         # 共享 shell helper
├── tests/       # 自包含 shell tests
└── workflows/   # propose/apply/archive/sync/explore/verify 共享说明
```

## Maintenance Rules

### 1. Core truth stays here

如果工作流有变化，先改：

- `HARNESS.md`
- `harness/bin/*`
- `harness/workflows/*.md`
- `harness/skills/*.md`

再同步客户端薄适配。

### 2. Client adapters stay thin

`.claude/`、`.cursor/`、`.codex/` 不应再维护一套完整的长篇流程说明。它们应该：

- 指向 `HARNESS.md`
- 要求先运行 `./harness/bin/check`
- 指向匹配的 `harness/workflows/*.md`
- 指向匹配的 `harness/skills/*.md`

### 3. Shared shell logic stays in `lib/`

只要两个以上脚本会复用某个 shell 逻辑，就放进 `harness/lib/common.sh`，不要在 `bin/` 脚本里复制粘贴。

### 4. Workflow docs must stay actionable

每个 workflow 文档都必须包含：

- 什么时候用
- 前置条件
- 真实可运行的 `openspec` 命令
- 出错时怎么处理

`harness/bin/opsx` 现在会直接执行这些动作对应的 CLI 流程，所以文档必须和脚本行为一致，不能只写理想流程。

## Extending Harness

新增动作时，按这个顺序：

1. 新增 `harness/workflows/<action>.md`
2. 更新 `harness/bin/opsx`
3. 更新 `HARNESS.md`
4. 更新客户端薄适配
5. 更新 `harness/tests/test_harness.sh`

新增跨客户端 skill 时，按这个顺序：

1. 新增或更新 `harness/skills/<skill-name>/SKILL.md`
2. 只在 `.claude/skills`、`.cursor/skills`、`.codex/skills` 中放薄适配
3. 如有流程说明，新增 `harness/workflows/<skill-name>.md`
4. 更新安装测试
