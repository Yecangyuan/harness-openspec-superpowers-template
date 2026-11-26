# Workflow: verify

## Purpose

用仓库级门禁验证 Harness 和 OpenSpec 基线。归档前按 change 验收，核对文档、任务进度和每项验收证据。

## When To Use

- 工作流或模板改动完成后，运行仓库级 `verify`。
- 准备归档或复核一个 change 时，传入 `--change <name>`。

## Preflight

```bash
./harness/bin/check
./harness/bin/status
```

## Repository Verification

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

如果失败，先按输出所在 section 定位：

- `Preflight`：修仓库骨架、命令依赖或目录结构
- `Harness Tests`：修路由、适配器或脚本行为
- `OpenSpec Complete Changes`：修已完成 change 的 artifacts
- `OpenSpec Specs`：修主 specs 结构

用 `HARNESS_VERIFY_SKIP_TESTS=1` 可跳过 Harness 自测，用于检查路由或避免嵌套测试。

## Change Verification

1. 运行 `./harness/bin/opsx verify --change <name>`。这一步读取指定 change 的 OpenSpec 状态、apply 任务和 spec deltas，并执行 `openspec validate --type change --strict`。报告列出产物、未完成任务以及每个验收项的 ID。
2. 对照该 change 的 specs、设计、当前实现和测试。每项记录一个实现或测试位置，执行能覆盖该场景的命令或手工检查，并记录实际结果。对于 `REMOVED` 和 `RENAMED`，核对删除或重命名是否已反映在实现和调用方。无法执行的检查保留为 `UNVERIFIED`，在回复中注明原因。把影响归档的设计偏差单独报告。
3. 将本次核对取得的证据写入临时 JSON，用报告中的 ID 作为键。每项含 `status`（`passed` 或 `failed`）、`implementation`、`check` 和 `result`。同一次测试覆盖多个场景时，为每个实际覆盖的场景引用该结果。省略尚未验证的场景。

```json
{
  "a1b2c3d4e5f6": {
    "status": "passed",
    "implementation": "src/preferences.js:42",
    "check": "npm test -- preferences",
    "result": "退出码 0，重新打开页面后读到了已保存的设置"
  }
}
```

```bash
./harness/bin/opsx verify --change <name> --evidence /path/to/evidence.json
```

检查命令由验收者执行，`--evidence` 读取已经观察到的结果。规格修改后先重新生成基础报告，使用其中的 ID 和最新证据。报告完成后只执行用户请求的下一步。

| 结果 | 退出码 | 下一步 |
| --- | --- | --- |
| `READY` | `0` | 文档校验、任务和所有场景证据均通过，可以进入归档流程。 |
| `BLOCKED` | `1` | 根据报告补齐文档、完成任务、修复失败项，再复核。无效参数及 OpenSpec 调用错误也返回 `1`。 |
| `UNVERIFIED` | `2` | 补充缺失的任务、场景或验收证据。 |
