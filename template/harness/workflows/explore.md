# Workflow: explore

## Purpose

在不直接实现的前提下，探索现状、梳理需求、分析 change 或 spec 的边界。

## When To Use

- 你还在澄清需求
- 你需要先理解现有 change / spec
- 你希望先调查再决定 propose 或 apply

## Preflight

```bash
./harness/bin/check
./harness/bin/status
./harness/bin/opsx explore [change-name]
```

## Steps

### 1. List active changes

```bash
./harness/bin/opsx explore
```

这一步会自动执行：

```bash
openspec list --json
```

### 2. Inspect a change when needed

```bash
./harness/bin/opsx explore "<change-name>"
```

这一步至少会自动执行：

```bash
openspec status --change "<change-name>" --json
```

### 3. Inspect current specs when needed

```bash
openspec list --specs
openspec show "<spec-id>" --type spec
```

## Expected Outcome

- 你知道下一步应该是 `propose`、`apply`、`sync` 还是 `archive`
- 你能说清当前 change 或 spec 的边界

## Failure Handling

- 如果 change 太多无法判断：先缩小到一个明确主题
- 如果现有 spec 缺失：先进入 `propose`
- 如果探索结果已经足够明确：退出 explore，进入下一个动作
