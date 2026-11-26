# Workflow: review-spec

在复杂 change 进入 `apply` 前评审 proposal、spec deltas、design 和 tasks。输出有出处的问题、需求覆盖情况和实施建议。先反馈评审结果，获得修改请求或确认决策后再更新原文档。

## 准备评审

```bash
./harness/bin/check
./harness/bin/opsx review-spec <change-name>
```

命令读取 `openspec status` 和 `openspec instructions apply`，再用 `openspec validate --type change --strict` 校验该 change。`Review inputs: AVAILABLE` 表示材料可读且结构校验通过。`NEED ATTENTION` 返回退出码 `1`，先处理列出的缺失文件、校验错误或空任务清单。读取报告里的原始文件，结合当前主 specs 和相关实现核对已有行为。

## 核对规格与任务

1. 对照用户请求和 proposal，确认目标、范围和受影响的能力一致。列出每条 `ADDED` / `MODIFIED` 需求及其验收场景。场景应有明确条件、触发行为和可观察结果，并覆盖规格要求的边界或失败行为。
2. 把每条需求和场景对应到 `tasks.md` 中的实现任务和验证任务。一项任务可以覆盖多个场景。没有任务的需求、没有验证任务的场景、没有规格依据的行为改动都要指出。对 `REMOVED` / `RENAMED` 对照主 specs，检查调用方、迁移和回归验证是否有落实。
3. 对照 design 里的约束、兼容性决策和任务顺序。引用矛盾两端的文件与行号。仅当缺少的信息会影响行为、范围或实施时列为待决问题，附上具体选项及影响。

## 交付评审结果

- **发现**按影响排序，给出 `文件:行号`、实际缺口和建议修改。能定位到多个文档时同时引用。
- **覆盖**按需求或场景列出对应任务，明确标注缺少实现或验证的项。
- **待决问题**记录需要确认的决策。以「可进入 apply」或「先修正规格」收尾，并说明依据。

收到修改请求或确认的决策后，把结果写回对应的 proposal、spec、design 或 tasks，再重跑评审。通过评审的 change 按 [apply 工作流](apply.md) 进入实现。
