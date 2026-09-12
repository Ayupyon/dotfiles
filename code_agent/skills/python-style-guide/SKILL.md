---
name: python-style-guide
description: Apply the default global Python coding style when writing, modifying, refactoring, or reviewing Python code. Follow the Google Python Style Guide with Ruff and basedpyright unless project-local instructions or configuration override these defaults.
---

# Python Style Guide

Apply these rules to Python work.

## Resolve Local Overrides

Before choosing conventions or validation commands, inspect the applicable project
instructions and configuration, including `AGENTS.md`, `pyproject.toml`,
`ruff.toml`, `.ruff.toml`, `pyrightconfig.json`, task-runner commands, pre-commit
hooks, and CI configuration.

- Follow user instructions and more-specific project rules before this guide.
- Treat an existing project tool choice, rule set, type-checking mode, target
  version, or wrapper command as an override. Do not replace it merely to impose
  these fallback defaults.
- Preserve the established style of surrounding code where the project makes an
  intentional local choice.

## Default Style and Tools

- Follow the [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html).
- Where that guide specifies Pylint, use Ruff instead. Do not add or run Pylint
  solely because the Google guide mentions it. Translate applicable checks and
  suppressions to Ruff equivalents, such as `# noqa: <rule-code>`. Keep every
  suppression narrowly scoped and explain it when the reason is not obvious.
- Use Ruff as the default linter.
- Use basedpyright as the default type checker. Use pyright when a project selects
  it or when the user explicitly chooses it as a fallback.
- Require each new or modified Python script to pass the checker's `standard`
  type-checking mode. Set `typeCheckingMode` to `"standard"` explicitly when no
  project configuration establishes the effective mode; do not assume a tool's
  built-in default is standard.

## Validate Python Changes

Prefer the project's configured commands because they preserve its environment,
paths, and plugins. In the absence of local overrides:

1. Check that Ruff and basedpyright are available in the intended environment
   without triggering a package installation or download.
2. If either tool is unavailable, report exactly which tool is missing and which
   validation could not run. Let the user install it, or wait for an explicit
   request to install it. Never install the tool automatically, add it to project
   dependencies, or run an installer without that request.
3. Do not silently substitute pyright for a missing basedpyright installation.
   Use pyright only when the project already selects it or the user explicitly
   chooses that fallback after being informed that basedpyright is missing.
4. Lint the affected Python targets with `ruff check <targets>`.
5. Type-check them with the selected checker in `standard` mode.
6. Resolve diagnostics rather than weakening checks or adding broad suppressions.

If persistent checker configuration is outside the task's scope, use a temporary
configuration for validation rather than modifying the project solely to set
`typeCheckingMode = "standard"`. If the selected checker is unavailable, state
that type checking was not run; do not claim that it passed.
