# Workflow: apply

## Purpose

基于已有 change 的 tasks 执行实现，并把任务完成状态持续更新回 change。

## When To Use

- 已经有对应的 active change
- proposal / design / tasks 至少已达到可执行状态

## Preflight

```bash
./harness/bin/check
./harness/bin/status
./harness/bin/opsx apply [change-name]
```

## Steps

### 1. Load apply context

```bash
./harness/bin/opsx apply [change-name]
```

这一步会自动执行：

```bash
openspec status --change "<change-name>" --json
openspec instructions apply --change "<change-name>" --json
```

如果没有传入 change 名称，`opsx` 会：

- 自动选择唯一的 active change
- 在没有 active change 时直接报错
- 在有多个 active changes 时要求你显式传名

### 2. Read the context files listed by OpenSpec

至少应包含：

- proposal
- design
- tasks

### 3. Implement and keep tasks current

每完成一个任务后，更新 tasks 文件中的 checkbox，并重新查看状态：

```bash
openspec status --change "<change-name>" --json
```

### 4. Validate before claiming completion

```bash
openspec validate "<change-name>" --json
```

## Expected Outcome

- 变更对应的 tasks 被逐步勾选
- `openspec validate "<change-name>" --json` 不再报结构性错误
- change 可以进入 `archive`

## Failure Handling

- 如果 status 显示 blocked：先补 proposal/design/tasks
- 如果 apply 指令上下文不完整：先回到 spec/plan
- 如果实现中发现设计错误：先更新设计文档，再继续 apply
