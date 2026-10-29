# Rust Anti-Patterns

This document catalogs common anti-patterns in Rust code, based on community experience and the article "Ugly Rust" from corrode.dev.

## Core Problem

**Writing another language's idioms in Rust is the root of most ugliness.**

Code written this way will never feel right. Rust has its own patterns that make code safer and clearer.

## Error Handling

### Overusing `unwrap()`

**Problem:** Panics on any error instead of propagating it.

```rust
// ❌ Anti-pattern
let content = fs::read_to_string(path).unwrap();
```

**Why it's bad:**
- Turns recoverable errors into crashes
- Hides error handling requirements from caller
- Makes code fragile and hard to reuse

**Idiomatic solution:**

```rust
// ✅ Idiomatic
let content = fs::read_to_string(path)?;
```

### Silently Skipping Errors

**Problem:** Errors are dropped or just printed instead of returned.

```rust
// ❌ Anti-pattern
if let Err(e) = parse_line(&line) {
    eprintln!("Error: {}", e);
    continue;
}
```

**Why it's bad:**
- Caller can't handle errors appropriately
- Silent data loss
- Debugging becomes harder

**Idiomatic solution:**

```rust
// ✅ Idiomatic
let parsed = parse_line(&line)
    .map_err(|e| format!("line {}: {}", line_num, e))?;
```

## Mutability

### Unnecessary `mut`

**Problem:** Variables marked mutable where they never change.

```rust
// ❌ Anti-pattern
let mut result = compute_value();
return result;
```

**Why it's bad:**
- Suggests code might mutate when it doesn't
- Harder to reason about data flow
- Compiler warning noise

**Idiomatic solution:**

```rust
// ✅ Idiomatic
let result = compute_value();
result
```

### Not Using Shadowing

**Problem:** Creating cryptic new names for transformed values.

```rust
// ❌ Anti-pattern
let line_raw = reader.read_line();
let line_trimmed = line_raw.trim();
let line_lower = line_trimmed.to_lowercase();
```

**Why it's bad:**
- Name pollution
- No indication which variable is "current"
- Tempts accidental use of old value

**Idiomatic solution:**

```rust
// ✅ Idiomatic
let line = reader.read_line();
let line = line.trim();
let line = line.to_lowercase();
```

## Standard Library Misuse

### Manual Byte Handling

**Problem:** Reading bytes and converting to UTF-8 manually.

```rust
// ❌ Anti-pattern
let mut bytes = Vec::new();
file.read_to_end(&mut bytes)?;
let content = String::from_utf8(bytes)?;
```

**Why it's bad:**
- Verbose
- Hides intent
- Stdlib already provides this

**Idiomatic solution:**

```rust
// ✅ Idiomatic
let content = fs::read_to_string(path)?;
```

### Splitting on `\n`

**Problem:** Breaks on Windows line endings, treats strings as byte arrays.

```rust
// ❌ Anti-pattern
for line in content.split('\n') {
    process(line);
}
```

**Why it's bad:**
- Wrong on Windows (`\r\n`)
- Doesn't handle different line ending types
- Stdlib has a better way

**Idiomatic solution:**

```rust
// ✅ Idiomatic
for line in content.lines() {
    process(line);
}
```

### Manual Indexing

**Problem:** Accessing array elements without bounds checking.

```rust
// ❌ Anti-pattern
let parts: Vec<&str> = line.split('=').collect();
let key = parts[0];
let value = parts[1];
```

**Why it's bad:**
- Panics if split returns fewer than 2 parts
- Compiler can't catch this bug
- Hides the fallible nature of the operation

**Idiomatic solution:**

```rust
// ✅ Idiomatic
let (key, value) = line
    .split_once('=')
    .ok_or("missing '=' separator")?;
```

### Verbose Emptiness Checks

**Problem:** Using `len() == 0` where `is_empty()` exists.

```rust
// ❌ Anti-pattern
if vec.len() == 0 {
    return;
}
```

**Why it's bad:**
- Less readable
- `is_empty()` is the standard method
- Some types implement `is_empty()` more efficiently

**Idiomatic solution:**

```rust
// ✅ Idiomatic
if vec.is_empty() {
    return;
}
```

## Iteration

### Imperative Index Loops

**Problem:** Manual counter instead of iterators.

```rust
// ❌ Anti-pattern
let mut i = 0;
while i < items.len() {
    process(&items[i]);
    i += 1;
}
```

**Why it's bad:**
- Verbose
- Error-prone (off-by-one, bounds checking)
- Hides the iteration pattern

**Idiomatic solution:**

```rust
// ✅ Idiomatic
for item in &items {
    process(item);
}

// Or with indices when needed
for (i, item) in items.iter().enumerate() {
    process(i, item);
}
```

## Type System

### "Stringly-Typed" Code

**Problem:** Nested generic types like `Result<Option<(String, String)>>` suggest missing abstraction.

```rust
// ❌ Anti-pattern
fn parse_config(s: &str) -> Result<Option<(String, String)>, String> {
    // ...
}
```

**Why it's bad:**
- Hard to understand
- Easy to mix up tuple positions
- Missing domain concept

**Idiomatic solution:**

```rust
// ✅ Idiomatic
#[derive(Debug)]
struct ConfigEntry {
    key: String,
    value: String,
}

#[derive(Debug, thiserror::Error)]
enum ParseError {
    #[error("missing '=' separator")]
    MissingSeparator,
    #[error("empty key")]
    EmptyKey,
}

impl TryFrom<&str> for ConfigEntry {
    type Error = ParseError;
    
    fn try_from(s: &str) -> Result<Self, Self::Error> {
        let (key, value) = s
            .split_once('=')
            .ok_or(ParseError::MissingSeparator)?;
        
        if key.is_empty() {
            return Err(ParseError::EmptyKey);
        }
        
        Ok(ConfigEntry {
            key: key.to_string(),
            value: value.to_string(),
        })
    }
}
```

### Redundant Type Annotations

**Problem:** Writing out types when inference handles it.

```rust
// ❌ Anti-pattern
let config: HashMap<String, String> = HashMap::new();
```

**Why it's bad:**
- Noise
- Brittle when refactoring
- Inference is part of Rust

**Idiomatic solution:**

```rust
// ✅ Idiomatic
let mut config = HashMap::new();
config.insert("key".to_string(), "value".to_string());
// Type is inferred from usage
```

### Explicit Lifetime Annotations

**Problem:** Adding lifetime annotations where elision works.

```rust
// ❌ Anti-pattern
fn first_word<'a>(s: &'a str) -> &'a str {
    s.split_whitespace().next().unwrap_or("")
}
```

**Why it's bad:**
- Noise when not needed
- Elision rules cover common cases
- Makes code harder to read

**Idiomatic solution:**

```rust
// ✅ Idiomatic
fn first_word(s: &str) -> &str {
    s.split_whitespace().next().unwrap_or("")
}
```

## API Design

### Accepting Concrete File Paths

**Problem:** Taking `&Path` instead of generic readers.

```rust
// ❌ Anti-pattern
fn parse_config(path: &Path) -> Result<Config> {
    let content = fs::read_to_string(path)?;
    // ...
}
```

**Why it's bad:**
- Hard to test (needs filesystem)
- Can't reuse for strings, network, etc.
- Forces caller's hand

**Idiomatic solution:**

```rust
// ✅ Idiomatic
fn parse_config<R: BufRead>(reader: R) -> Result<Config> {
    for line in reader.lines() {
        // ...
    }
}

// Can now test with:
let input = "key=value\n";
let config = parse_config(input.as_bytes())?;
```

### Exposing Internal Collections

**Problem:** Returning `HashMap` directly without wrapper.

```rust
// ❌ Anti-pattern
fn load_config() -> HashMap<String, String> {
    // ...
}
```

**Why it's bad:**
- Exposes internal representation
- Can't change implementation later
- Hard to add validation

**Idiomatic solution:**

```rust
// ✅ Idiomatic
struct Config {
    entries: HashMap<String, String>,
}

impl Config {
    fn get(&self, key: &str) -> Option<&str> {
        self.entries.get(key).map(|s| s.as_str())
    }
    
    fn set(&mut self, key: String, value: String) -> Option<String> {
        self.entries.insert(key, value)
    }
}
```

## Summary

The central insight: **Better semantics unlock nicer syntax.**

Improving the design, rather than the syntax, is what removes ugliness. Think in:
- Expressions, not statements
- Immutability by default
- Iterators over manual loops  
- Types that encode invariants
- Standard library first

When code feels ugly, it's usually signaling a design problem, not a syntax problem.
