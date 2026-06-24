# Workflow: archive

## Purpose

在 change 完成后归档它，并把主 specs 更新到最新状态。

## When To Use

- tasks 已完成
- 变更已经验证通过
- 需要关闭当前 change

## Preflight

```bash
./harness/bin/check
./harness/bin/status
openspec status --change "<change-name>" --json
./harness/bin/opsx archive [change-name] -y
```

## Steps

### 1. Validate one last time

```bash
openspec validate "<change-name>" --json
```

### 2. Archive and update main specs

```bash
./harness/bin/opsx archive [change-name] -y
```

这一步会自动执行：

```bash
openspec archive "<change-name>" -y
```

### 3. Re-check the change list

```bash
openspec list --json
```

## Expected Outcome

- change 从 active 列表中消失
- main specs 已同步更新
- archive 目录中保留归档记录

## Failure Handling

- 如果只想归档但跳过 spec 更新：使用 `openspec archive "<change-name>" -y --skip-specs`
- 如果 validate 失败：先回到 `apply`
- 如果 archive 需要人工确认细节：不要使用 `-y`
