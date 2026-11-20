---
name: cpp-style-guide
description: Apply the default C++ style when writing, modifying, refactoring, or reviewing C++ sources and headers without specific project guidance. Follow the Google C++ Style Guide with name-attached pointer/reference declarations, multiline non-empty blocks, clang-format, and cpplint.
---

# C++ Style Guide

Use this skill as the fallback for C++ work. Follow the
[Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html), with
the overrides below.

## Resolve Local Overrides

Inspect applicable project instructions and configuration before choosing style
or validation commands, including `AGENTS.md`, `.clang-format`, `_clang-format`,
`.clang-format-ignore`, `CPPLINT.cfg`, build scripts, pre-commit hooks, and CI.

- Follow user instructions and more-specific project guidance first. Apply this
  skill where that guidance leaves a choice unspecified.
- Use the project's configured formatter, linter commands, and options when
  specified. Preserve its selected C++ standard.
- Keep changes within the task's scope; use the bundled format configuration
  directly when needed instead of adding or replacing project configuration.

## Style Overrides

- Attach `*`, `&`, and `&&` to the declared name: `Widget *pointer`,
  `const Widget &reference`, and `Widget &&value`. Apply the same alignment to
  parameters and function declarations, such as `Widget *FindWidget()`.
  Declare pointer and reference variables separately.
- Use braces for control-flow bodies. Write every non-empty statement block,
  function body, and lambda body over multiple lines, even when it contains only
  one statement. Keep Google's attached opening braces, with statements and the
  closing brace of non-empty bodies on following lines. Apply this to constructors,
  destructors, inline member functions, branches, and loops as well.
  Braced initializer lists may stay on one line.

```cpp
void AppendSuffix(const std::string &suffix, std::string *text) {
  if (text != nullptr) {
    text->append(suffix);
  }
}

void DoNothing() {}
```

## Format C++ Changes

1. Check for `clang-format` on `PATH` without triggering an installation. If it is
   missing, tell the user that formatting could not run. Do not install, download,
   or upgrade it automatically.
2. Use the project's format configuration when present. Otherwise, resolve the
   bundled [assets/.clang-format](assets/.clang-format) relative to this skill
   and pass its absolute path with `--style=file:<path>`. The reference file uses
   options supported by clang-format 13 and newer; report an incompatible version
   or configuration error rather than silently ignoring those options.
3. Format every new C++ source and header in full. Format modified files in full
   by default as well. For example, with the fallback configuration:

   ```sh
   clang-format --style="file:/absolute/path/to/cpp-style-guide/assets/.clang-format" \
     -i path/to/file.cc path/to/file.h
   ```

4. Preview formatting for existing files before applying it. Skip whole-file
   formatting only when it would produce a huge diff that rewrites substantial
   unrelated portions of the source and obscures the intended change. In that
   case, try formatting the edited line ranges with
   `--lines=<start>:<end>` first and review the result, since formatting may expand
   to surrounding constructs. If that still creates a huge diff, keep the new
   code manually consistent with the applicable style and report the file and
   why formatting was skipped.
5. Review the final diff for the two style overrides as well as formatting.
   clang-format's layout settings do not insert missing control-flow braces.

## Lint C++ Changes

After formatting, check newly written or modified C++ sources and headers with
the [cpplint.py implementation](https://raw.githubusercontent.com/cpplint/cpplint/HEAD/cpplint.py)
specified for this skill.

1. Look for `cpplint.py` on `PATH`; also accept the installed `cpplint` entry point
   from the same project. If neither is available, tell the user that cpplint is
   missing from `PATH` and linting could not run. Do not install, download, vendor,
   or add it to project dependencies automatically.
2. Prefer the project's configured cpplint command and options. Otherwise, pass
   the affected C++ source and header paths explicitly:

   ```sh
   cpplint.py path/to/file.cc path/to/file.h
   ```

   Substitute `cpplint` when that is the available entry point. Honor applicable
   `CPPLINT.cfg` files and use `--extensions` if needed for the project's C++ file
   extensions.
3. Resolve diagnostics introduced by the change. Keep suppressions narrow and
   justified; report pre-existing findings separately. Check the custom pointer
   and block rules during review even when cpplint reports no issues.
4. Report formatting and lint results, including missing tools or any checks that
   could not run. Continue available checks when either tool is missing.
