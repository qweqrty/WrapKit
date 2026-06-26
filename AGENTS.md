# AGENTS.md

This file is the working contract for AI coding agents contributing to WrapKit.
WrapKit is a reusable Swift UI/infrastructure library. Treat it like an open-source package: changes must be small, documented by tests, and safe for downstream apps.

## Repository Role

WrapKit provides shared UI infrastructure and output abstractions used by multiple iOS products and feature modules.

Primary goals:
- keep UI primitives stable and predictable;
- avoid product-specific behavior inside WrapKit;
- preserve binary/source compatibility where practical;
- make snapshot regressions visible instead of silently changing visuals;
- keep APIs ergonomic for downstream feature modules.

WrapKit is not the place for product flows, business routing, backend DTO decisions, or app-specific UI hacks.

## Core Principles

- Prefer small, explicit API changes over broad abstractions.
- Preserve existing behavior unless the task explicitly asks for a behavior change.
- If a component is shared, assume one line can affect many screens.
- Do not hide visual changes. Update or add snapshot tests when UI changes intentionally.
- Do not introduce UIKit dependencies into platform-agnostic/domain layers of downstream projects.
- Keep components configurable through presentable models and outputs, not hardcoded downstream view logic.
- If a caller passes an exact value, respect it exactly. Example: an inset of `4` must render as `4`, not an approximate value affected by implicit layout defaults.
- Avoid temporary hacks that only make one screenshot pass. Fix the reusable component contract.

## Code Style

- Follow the existing style in nearby files before adding new patterns.
- Keep naming consistent with existing components: `CardView`, `MapView`, `TitledView`, `Button`, etc.
- Prefer clear model names and small value types.
- Keep UIKit implementation details inside UIKit-specific files.
- Avoid new global state unless the repository already uses that pattern for the same problem.
- Avoid comments that restate the code. Add comments only for non-obvious behavior, compatibility quirks, or platform-specific constraints.
- Keep files ASCII unless the file already uses non-ASCII or the change requires localized strings.

## UI Component Rules

- Shared UI must be driven by explicit models and outputs.
- Do not add product-specific assets or strings to WrapKit.
- Do not make a component infer product behavior from image names, titles, or colors.
- If a component supports both old UIKit APIs and modern configuration APIs, verify parity carefully. UIKit `UIButton.Configuration` can change default title colors, image layout, content mode, corner style, and highlight behavior compared with legacy button APIs.
- When adding iOS-version-specific behavior, keep older OS rendering stable.
- For iOS 26 / Liquid Glass changes, do not assume defaults match iOS 18. Snapshot both versions when possible.
- Border and corner radius must be applied to the actual rendered layer/path. If a border is drawn separately from the view layer, it must follow the same corner style.

## Snapshot Tests

Snapshot tests are part of the public API of UI components.

When changing UI:
- run relevant snapshot tests before considering the task done;
- inspect failed images visually, not only numeric deltas;
- keep iOS 18.5 and iOS 26+ behavior in mind when the component uses modern UIKit APIs;
- do not update snapshots blindly;
- if a visual change is intentional, explain what changed and why.

Useful workflow:
1. Run the narrow failing test first.
2. Compare `origin.png` and `new.png` visually.
3. Fix component behavior if the diff is unintended.
4. Record snapshots only after the visual result is accepted.
5. Re-run the relevant suite.

If a helper script collects failed snapshots, prefer a flat folder of images that can be opened and browsed quickly.

## Build And Test Commands

Common commands:

```bash
make project
```

Use targeted Xcode tests for local validation when possible. Prefer narrow test runs during iteration, then run the broader affected suite before final reporting.

Do not claim tests passed unless they were actually run in the current turn.
If a test/build was not run, state that clearly.

## Git Rules

- Never commit or push unless the user explicitly asks.
- Before editing, inspect `git status --short`.
- If there are unexpected unrelated changes, stop and ask how to proceed.
- Do not revert user changes.
- Do not use destructive commands like `git reset --hard` or checkout-away changes unless explicitly approved.
- Prefer non-interactive git commands.
- After changes, run `git diff --check` when practical.
- Always provide a concise commit message suggestion if changes were made and not committed.

## Multi-Repository NUR Workflow

WrapKit is commonly consumed by:
- `NUR.DesignSystem`
- `NUR.Features`
- `algaios`

Typical dependency chain:

```text
WrapKit -> NUR.DesignSystem -> NUR.Features -> algaios
```

When a WrapKit change must reach downstream projects:

1. Check branches and dirtiness in every involved repo.
2. Keep all repos on the intended task branch, usually the Jira key branch such as `MYO-6102`.
3. Do not commit unrelated work just to make the chain clean. Ask first if unrelated dirt exists.
4. Commit WrapKit only after tests/snapshots relevant to the change are acceptable.
5. Create a patch tag in WrapKit using the repo's existing tag command/workflow.
6. Update DesignSystem to the new WrapKit tag.
7. Run/generate DesignSystem project and validate affected snapshots if UI changed.
8. Commit/tag DesignSystem.
9. Update Features to the new DesignSystem tag.
10. Run/generate Features project and relevant UI tests/screenshots if product UI changed.
11. Commit/tag Features.
12. Update algaios to the new Features tag and verify integration.

Do not skip a layer in the chain. If Features resolves an old WrapKit version through DesignSystem, update DesignSystem first and create a new tag.

## Patch Tag Workflow

Use the repository's existing `make patch-tag` when available.

Before creating a tag:
- ensure the intended files are committed;
- ensure the working tree is clean or only contains intentionally uncommitted unrelated files;
- confirm the previous tag and the next tag from command output;
- confirm downstream packages resolve to the new tag and revision.

After creating a tag:
- update the next repository in the chain;
- run project generation or package resolution;
- verify `Package.resolved` contains the expected version and revision;
- do not assume `Package.swift` exact version is enough.

## Human-Factor Checklist For Agents

Before doing cross-repo work, run a lightweight audit:

```bash
for repo in WrapKit NUR.DesignSystem NUR.Features algaios; do
  echo "--- $repo"
  git -C /Applications/work/$repo branch --show-current
  git -C /Applications/work/$repo status --short
  git -C /Applications/work/$repo log -1 --oneline
  echo
done
```

If the user wants everything on a task branch:
- check each repo branch first;
- do not silently switch branches with dirty work;
- if dirty work exists, identify whether it belongs to the current task;
- if it belongs to the task and the user asked to commit, commit it with a focused message;
- if it does not belong to the task, ask before touching it.

When updating tags across repos, report exact versions:

```text
WrapKit: 3.1.xxx
DesignSystem: 1.0.xxxx
Features: 0.0.xxxx
algaios: uses Features 0.0.xxxx
```

## Downstream Integration Expectations

When changing WrapKit UI used by NUR.Features/Cabinet:
- validate WrapKit snapshots first;
- then validate the feature screenshot/UI test that motivated the change;
- compare with `algaios` when preserving behavior is required;
- avoid product-specific fixes in WrapKit if the component API is the actual problem.

For MYO-6102/Cabinet-style work:
- `algaios` is the behavioral reference;
- `NUR.Features` should keep feature code style and module boundaries;
- routing should use explicit flows/closures, not temporary alerts if real flow is available;
- `display(model: nil)` should hide the block; shimmer state should be driven separately by the screen/content view;
- one UI test should represent one user story/scenario;
- scenario JSON should be organized by scenario, with common fixtures only when truly common.

## Reporting Format

Keep reports short and concrete:

```text
Done:
- changed ...
- tag ...
- verified ...

Not done:
- ...

Check manually:
- ...
```

Avoid vague statements like "should work". Say what was verified and what was not.

## Good Agent Prompts For This Workspace

### Cross-repo tag chain

```text
Update the MYO-6102 dependency chain cleanly.
Check WrapKit, NUR.DesignSystem, NUR.Features, and algaios branches/status first.
Commit only task-related changes, create patch tags through the repo workflow, update downstream Package.swift and Package.resolved, run make project where available, and report exact tags/revisions.
Do not touch unrelated dirty files.
```

### UI regression fix

```text
Fix the shared component behavior, not the product screen.
Inspect existing component APIs and snapshot tests first.
Add or update the narrow snapshot test that reproduces the regression.
Run the narrow snapshot test and show what changed.
Do not update snapshots blindly.
```

### Cabinet parity task

```text
Preserve algaios behavior while keeping NUR.Features code style.
Do not add UIKit to presenters/domain.
Use output models and existing flows.
Check UI tests/screenshots for the affected scenarios.
Report any behavior that cannot be matched without a product decision.
```

### Review task

```text
Review as a code reviewer.
Prioritize bugs, regressions, missing tests, and module-boundary violations.
Findings first, with file/line references.
If no findings, state residual risks and missing validation.
```
