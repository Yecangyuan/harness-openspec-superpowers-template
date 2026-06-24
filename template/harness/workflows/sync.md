# Workflow: sync

## Purpose

在不归档 change 的前提下，把 change 中的 delta spec 与主 specs 对齐，适合先同步规范、后继续实施的场景。

## When To Use

- 你想先更新主 specs
- 但还不想 archive 当前 change
- 或者你需要先审视 delta 内容再决定是否归档

## Preflight

```bash
./harness/bin/check
./harness/bin/status
./harness/bin/opsx sync [change-name]
```

## Steps

### 1. Load sync context

```bash
./harness/bin/opsx sync [change-name]
```

这一步会自动执行：

```bash
openspec status --change "<change-name>" --json
openspec list --specs
```

注意：OpenSpec 当前没有单独的 `sync` CLI 动作。`opsx sync` 做的是上下文拉取与预检查，不会自动改写主 specs。

只有在 proposal artifact 已存在时，才适合继续运行：

```bash
openspec show "<change-name>" --type change --deltas-only --json
```

### 2. Update the affected `openspec/specs/*` files

把 change delta 中已经确认稳定的内容同步到对应主 spec。

### 3. Validate specs

```bash
openspec validate --specs --json
```

## Expected Outcome

- `openspec/specs/*` 已与当前 change 的已确认 delta 对齐
- 当前 change 仍保留为 active

## Failure Handling

- 如果 proposal 还不存在：先回到 `propose` 或补 proposal/design/specs/tasks
- 如果不确定该同步哪些 requirement：先只看 `--deltas-only` 输出
- 如果 spec validate 失败：修复主 spec 结构后再继续
- 如果其实已经准备关闭 change：改用 `archive`
