# Workflow: propose

## Purpose

为一个新需求或新改动建立 `OpenSpec` change，并准备后续的 spec / design / tasks 产物生成路径。

## When To Use

- 你要新增功能
- 你要修复一个需要明确变更边界的 bug
- 你还没有对应的 active change

## Preflight

```bash
./harness/bin/check
./harness/bin/status
./harness/bin/opsx propose <change-name>
```

## Steps

### 1. Create the change

```bash
./harness/bin/opsx propose "<change-name>"
```

这一步会自动执行：

```bash
openspec new change "<change-name>"
openspec status --change "<change-name>" --json
```

### 2. Inspect generation instructions

```bash
openspec instructions proposal --change "<change-name>" --json
openspec instructions design --change "<change-name>" --json
openspec instructions tasks --change "<change-name>" --json
```

### 3. Validate the created change

```bash
openspec validate "<change-name>" --json
```

## Expected Outcome

- `openspec/changes/<change-name>/` 已创建
- `openspec status --change "<change-name>" --json` 能显示 artifact 状态
- 后续可以进入 `apply`

## Failure Handling

- 如果 change 名称冲突：先运行 `openspec list --json`
- 如果 status 输出缺少 artifact：检查 `openspec/config.yaml`
- 如果 validate 失败：先修 proposal/design/tasks，再进入实现
