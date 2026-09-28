---
name: conventional-commits
description: Write or review Git commit messages using Conventional Commits 1.0.0. Use when drafting commit subjects or full messages, or when checking a message for conformance.
---

# Conventional Commits

Write commit messages in the Conventional Commits 1.0.0 format:

```text
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

Use a type that accurately describes the change. The specification requires a
type but permits types beyond `feat` and `fix`; examples include `build`,
`chore`, `ci`, `docs`, `perf`, `refactor`, `style`, and `test`. Use `feat` for
a new feature and `fix` for a bug fix. Do not treat the example list as
exhaustive or assume other types imply a version bump.

Add an optional scope in parentheses when it clarifies the affected part of the
codebase, such as `fix(parser): handle empty input`. Follow an established
project or team type and scope vocabulary when one exists. Otherwise, choose a
concise, accurate type and scope from the change itself.

Make the description a short summary of the change. Base the message on the
actual changes, inspecting the staged diff when available; do not infer work
that is not present. Keep any body focused on context or rationale that the
subject cannot convey. Separate the body from the subject with a blank line.

Mark every breaking change either with `!` immediately before the colon, or
with a `BREAKING CHANGE: <description>` footer. The marker can accompany any
type, for example `refactor(api)!: remove the legacy endpoint`. When using the
footer, describe the compatibility impact. Both forms may be used together.

Put footers after a blank line. A footer uses a token followed by `: ` or
` #`, for example `Refs: #123` or `Reviewed-by: Name`. Use hyphens instead of
spaces in footer tokens, except that the breaking-change token is written
`BREAKING CHANGE` (or `BREAKING-CHANGE`).

Do not present optional style preferences, such as lowercase types or
imperative wording, as requirements of the specification. Preserve a
repository's additional conventions when they do not conflict with the
requested format.

When reviewing a message, check that the type and colon-space prefix are
present, the optional scope is parenthesized, the description follows the
prefix, and any body or footers are separated by blank lines. Check that a
breaking change is explicitly marked. Point out non-conformance and suggest a
corrected message without changing the commit unless the user asks for that
action.

See the [Conventional Commits 1.0.0 specification](https://www.conventionalcommits.org/en/v1.0.0/)
for the complete rules and examples.
