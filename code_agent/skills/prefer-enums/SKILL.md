---
name: prefer-enums
description: Prefer enum types for closed sets of named values instead of unrestricted strings, and arrays indexed by safe enum-to-integer conversions. Use dictionaries for integer-convertible enums only when their ranges are large and sparsely populated. Apply when writing, refactoring, or reviewing code that models or indexes statuses, modes, kinds, or other finite domain choices.
---

# Prefer Enums

Represent a closed set of named domain values with an enum. For example, model
job states such as `pending`, `running`, and `done` with a `JobState` enum, and
use its members in application logic.

## Choose the Type

- Use an enum when the application defines the allowed alternatives. A few
  observed string values alone do not establish a closed set.
- Reuse an existing enum for the same domain concept. Prefer the language's
  native enum support and standard library over custom wrappers or dependencies.
- If native enums are unavailable or explicitly disallowed by project rules,
  use the project's equivalent closed-set type, such as a literal union.
- Keep free-form text, arbitrary names, paths, and externally extensible
  identifiers as strings.

## Carry the Type Through the Code

- Use the enum in fields, parameters, return types, collection keys, and defaults
  that represent the same choice. Compare and branch on enum members.
- Name the enum and members after their domain meaning, following the language
  and repository conventions. An alias for an unrestricted string does not
  constrain the allowed values.
- Keep serialized values explicit and stable. Preserve existing API, database,
  configuration, and command-line representations; avoid serializing member
  names or ordinal positions unless the contract requires them.
- Parse and validate external strings at the boundary, use enum values
  internally, and serialize at the output boundary. Preserve established handling
  of unknown values; an unchecked cast does not validate input.

## Index Data by Enum Values

When the language supports a safe, lossless enum-to-integer conversion, prefer
using the converted integer to index data associated with an enum value.

- Prefer an array or equivalent sequence for the usual small integer range.
  Choose a dictionary or map only when the integer range is large and the
  values that need entries are sparse within that range.
- Size the array from the actual integer range, not member count alone.
  Use a simple offset for a nonzero minimum when needed, prove or validate that
  indices are nonnegative and in bounds, and preserve missing-entry behavior
  for gaps or partial tables.
- Keep enum types in domain interfaces and convert at the indexing operation.
  Preserve existing integer values and serialization contracts; do not renumber
  enum members to fit an array.

## Update Existing Code

Keep conversions within the requested scope. Update affected callers, exports,
defaults, comparisons, tests, and fixtures together so the enum type reaches its
consumers without leaving a mixture of enum values and raw strings internally.

Use relevant type checks and tests to verify member handling, invalid boundary
input, index bounds, missing entries, and serialization compatibility. Add
focused coverage when the conversion changes these behaviors.
