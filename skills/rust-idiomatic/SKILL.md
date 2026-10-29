---
name: rust-idiomatic
description: Use this skill whenever working with Rust code, .rs files, Cargo.toml, or when the user mentions Rust, cargo, rustc, clippy, or rustfmt. Ensures Rust code is idiomatic, makes good use of the standard library, and follows community best practices. Triggers on any Rust-related task including writing new code, reviewing existing code, refactoring, or debugging Rust projects.
allowed-tools:
  - AskUserQuestion(pattern:*)
  - Bash(pattern:*)
  - Read(pattern:*)
  - Agent(pattern:*)
---

# Rust Idiomatic Code Review

## Overview

Idiomatic Rust is not about syntax tricks. It is about using the language as it was designed.

**Core principle:** Better semantics unlock nicer syntax. Improve the design, not just the style.

Writing another language's idioms in Rust will never feel right. Rust has its own patterns that make code safer, clearer, and more maintainable.

## The Iron Law

```
ALWAYS USE THE STANDARD LIBRARY BEFORE REINVENTING
```

If std has a method for what you need, use it. Manual implementations hide intent and introduce bugs.

## When to Use

Use this skill for ANY Rust work:
- Writing new Rust code
- Reviewing existing Rust code
- Refactoring Rust projects
- Debugging Rust issues
- Code review before commits
- Learning idiomatic patterns

**Use this ESPECIALLY when:**
- Coming from another language (Python, JavaScript, Java, C++)
- Code feels verbose or awkward
- Fighting the borrow checker
- Reaching for `unwrap()` frequently
- Writing manual loops instead of iterators
- Creating "stringly-typed" APIs

## The Three Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Gather References

**BEFORE analyzing code:**

1. **Ask for Additional Resources**

   Use AskUserQuestion to check if the user has reference links:
   
   "Do you have any Rust reference links, blog posts, or documentation you'd like me to include in my knowledge base for this review?"

   If yes, note them for scraping. If no, proceed with built-in references.

2. **Fetch Current Documentation**

   Spawn DocRabbit agent to fetch current Rust standard library documentation for relevant modules based on what the code uses:
   - `std::fs` for file operations
   - `std::io` for I/O operations
   - `std::collections` for data structures
   - `std::iter` for iteration patterns
   - `std::error` for error handling
   - `std::convert` for type conversions

   This ensures recommendations match the current stable Rust release.

3. **Load Reference Materials**

   Read the bundled reference files in this skill's `references/` directory:
   - `anti-patterns.md` - Common anti-patterns to avoid
   - `std-library-patterns.md` - Standard library patterns to prefer

### Phase 2: Analyze for Anti-Patterns

**For each Rust file, check for these issues:**

#### Error Handling Anti-Patterns
- [ ] Excessive `unwrap()` or `expect()` calls
- [ ] Silently dropping errors with `let _ = result;`
- [ ] Printing errors instead of returning them
- [ ] Not using `?` operator for error propagation
- [ ] Missing error context

#### Type System Anti-Patterns
- [ ] "Stringly-typed" code (nested `Result<Option<(String, String)>>`)
- [ ] Manual indexing without bounds checking
- [ ] Not using pattern matching on enums
- [ ] Unnecessary type annotations where inference works
- [ ] Missing newtype wrappers for domain concepts

#### Mutability Anti-Patterns
- [ ] Unnecessary `mut` bindings
- [ ] Not shadowing for transformations
- [ ] Imperative style where functional style fits
- [ ] Manual index loops instead of iterators

#### Standard Library Anti-Patterns
- [ ] Manual byte handling instead of `read_to_string()`
- [ ] Splitting on `\n` instead of using `lines()`
- [ ] Manual indexing instead of `split_once()`
- [ ] `len() == 0` instead of `is_empty()`
- [ ] Manual loops instead of iterator methods
- [ ] Reinventing stdlib functionality

#### Lifetime and Ownership Anti-Patterns
- [ ] Explicit lifetime annotations where elision works
- [ ] Excessive cloning to avoid borrow checker
- [ ] Not using references where appropriate
- [ ] Over-complicated lifetime bounds

#### API Design Anti-Patterns
- [ ] Accepting file paths instead of generic readers (`BufRead`)
- [ ] Exposing concrete types instead of traits
- [ ] Not using builder patterns for complex construction
- [ ] Missing `TryFrom` for fallible conversions

### Phase 3: Suggest Idiomatic Alternatives

**For each anti-pattern found:**

1. **Explain the Issue**
   - Why is this problematic?
   - What bugs or maintenance issues can it cause?
   - What Rust principle does it violate?

2. **Show the Standard Library Solution**
   - What stdlib type/method/pattern should be used?
   - Link to relevant std documentation
   - Explain how it improves safety or clarity

3. **Provide Concrete Refactoring**
   - Show before and after code
   - Explain the transformation
   - Highlight the semantic improvement

4. **Consider Edge Cases**
   - Empty values
   - Unicode handling
   - Platform differences (Windows line endings)
   - Invalid input

## Red Flags

Watch for these rationalizations:

- "It's just a small script" - Small scripts become production code
- "I know this won't fail" - Famous last words before a panic
- "The error doesn't matter here" - All errors matter
- "This is how I'd write it in Python/JS/Java" - You're writing Rust now
- "Clippy is too strict" - Clippy catches real bugs

## Quick Reference

### Error Handling

❌ **Avoid:**
```rust
let content = fs::read_to_string(path).unwrap();
```

✅ **Prefer:**
```rust
let content = fs::read_to_string(path)?;
```

### Iteration

❌ **Avoid:**
```rust
let mut i = 0;
while i < items.len() {
    process(items[i]);
    i += 1;
}
```

✅ **Prefer:**
```rust
for item in &items {
    process(item);
}
```

### Pattern Matching

❌ **Avoid:**
```rust
let parts: Vec<&str> = line.split('=').collect();
let key = parts[0];
let value = parts[1];
```

✅ **Prefer:**
```rust
let (key, value) = line.split_once('=')
    .ok_or("missing '=' separator")?;
```

### Type Design

❌ **Avoid:**
```rust
fn parse(s: String) -> Option<(String, String)> { ... }
```

✅ **Prefer:**
```rust
struct KeyValue { key: String, value: String }

impl TryFrom<&str> for KeyValue {
    type Error = ParseError;
    fn try_from(s: &str) -> Result<Self, Self::Error> { ... }
}
```

## Tooling Recommendations

If `cargo clippy` is not installed, recommend installing it:

```bash
rustup component add clippy
```

Run these checks before suggesting code is ready:
- `cargo fmt --check` - Formatting
- `cargo clippy` - Linting
- `cargo test` - Tests pass
- `cargo build --release` - Release build succeeds

## Remember

Idiomatic Rust emerges from thinking in expressions, immutability, iterators, and types. The standard library already solved most problems you face. Use it.
