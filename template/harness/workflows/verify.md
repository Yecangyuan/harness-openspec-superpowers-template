# Workflow: verify

## Purpose

运行仓库级工作流门禁，确认 Harness 骨架、Harness 行为测试、已完成 OpenSpec changes 和主 specs 都处于可验证状态。

## When To Use

- 你准备声明工作流改动完成
- 你准备 archive completed change
- 你想快速确认 `Harness + OpenSpec` 基线没有漂移

## Preflight

```bash
./harness/bin/check
./harness/bin/status
./harness/bin/opsx verify
```

## Steps

### 1. Run the unified gate

```bash
./harness/bin/opsx verify
```

这一步会自动执行：

```bash
./harness/bin/check
bash harness/tests/test_harness.sh
openspec validate "<complete-change>" --json
openspec validate --specs --json
```

`verify` 只校验状态为 `complete` 的 active changes。仍在 proposal/design/tasks 阶段的 active change 可以继续保留，不会阻塞普通工作流门禁。

### 2. Inspect failures

如果失败，先按输出所在 section 定位：

- `Preflight`：修仓库骨架、命令依赖或目录结构
- `Harness Tests`：修路由、适配器或脚本行为
- `OpenSpec Complete Changes`：修已完成 change 的 artifacts
- `OpenSpec Specs`：修主 specs 结构

## Expected Outcome

- Harness 自测通过
- 已完成 active changes 可通过 OpenSpec validate
- 主 specs 可通过 OpenSpec validate

## Failure Handling

- 如果某个 change 尚未准备完成，不要把 tasks 全部勾选为 complete
- 如果主 specs 为空但命令通过，可以继续；归档 completed change 后应重新运行 verify
- 如果只需要检查路由，可用 `HARNESS_VERIFY_SKIP_TESTS=1 ./harness/bin/opsx verify` 避免嵌套测试
