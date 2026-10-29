# Standard Library Patterns

Common patterns from Rust's standard library that solve frequent problems idiomatically.

## File and I/O Operations

### Reading Files

| Instead of | Use |
|------------|-----|
| Manual byte buffer + UTF-8 conversion | `fs::read_to_string(path)` |
| `File::open()` + manual buffer | `BufReader::new(file)` |
| Reading line by line manually | `BufRead::lines()` |

**Example:**

```rust
use std::fs;
use std::io::{BufRead, BufReader};

// Read entire file
let content = fs::read_to_string("config.txt")?;

// Read lines
let file = fs::File::open("data.txt")?;
let reader = BufReader::new(file);
for line in reader.lines() {
    let line = line?;
    println!("{}", line);
}
```

### Writing Files

| Instead of | Use |
|------------|-----|
| Manual buffer writes | `fs::write(path, content)` |
| Open + write loop | `writeln!(writer, "{}", line)` |

**Example:**

```rust
use std::fs;
use std::io::Write;

// Write entire content
fs::write("output.txt", "Hello, world!")?;

// Write formatted lines
let mut file = fs::File::create("log.txt")?;
writeln!(file, "Entry: {}", entry)?;
```

## String Operations

### Line Handling

| Instead of | Use |
|------------|-----|
| `split('\n')` | `str::lines()` |
| Manual `\r\n` handling | `str::lines()` (handles both) |
| Checking last char for newline | `str::trim_end()` |

**Example:**

```rust
let text = "line1\nline2\r\nline3";

// Correctly handles different line endings
for line in text.lines() {
    println!("{}", line);
}

// Trimming
let trimmed = line.trim();
let left = line.trim_start();
let right = line.trim_end();
```

### Splitting and Parsing

| Instead of | Use |
|------------|-----|
| `split().collect(); vec[0], vec[1]` | `split_once()` |
| `split().next().unwrap()` | `split_once().map(\|(first, _)\| first)` |
| Manual parsing with index | Pattern matching on `split_once()` |

**Example:**

```rust
let input = "key=value";

// Safe splitting
if let Some((key, value)) = input.split_once('=') {
    println!("key: {}, value: {}", key, value);
}

// With error handling
let (key, value) = input
    .split_once('=')
    .ok_or("missing separator")?;
```

### String Checking

| Instead of | Use |
|------------|-----|
| `s.len() == 0` | `s.is_empty()` |
| `s.chars().next() == Some('x')` | `s.starts_with('x')` |
| Manual suffix check | `s.ends_with("suffix")` |
| Contains with iteration | `s.contains("substring")` |

**Example:**

```rust
let s = "hello world";

if s.is_empty() { /* ... */ }
if s.starts_with("hello") { /* ... */ }
if s.ends_with("world") { /* ... */ }
if s.contains("lo wo") { /* ... */ }
```

## Collections

### Creation and Population

| Instead of | Use |
|------------|-----|
| `Vec::new(); loop { vec.push() }` | `Iterator::collect()` |
| Manual HashMap insertion loop | `HashMap::from_iter()` |
| Checking `len() == 0` | `is_empty()` |

**Example:**

```rust
use std::collections::HashMap;

// Collect from iterator
let numbers: Vec<i32> = (1..10).filter(|x| x % 2 == 0).collect();

// Build HashMap
let pairs = vec![("a", 1), ("b", 2)];
let map: HashMap<_, _> = pairs.into_iter().collect();

// Check emptiness
if map.is_empty() {
    println!("No entries");
}
```

### HashMap Access

| Instead of | Use |
|------------|-----|
| `if map.contains_key(k) { map[k] }` | `map.get(k)` |
| Manual default insertion | `map.entry(k).or_insert(default)` |
| Separate check and insert | `map.entry(k).or_insert_with(\|\| compute())` |

**Example:**

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

// Get with Option
if let Some(score) = scores.get("player1") {
    println!("Score: {}", score);
}

// Insert if absent
scores.entry("player1").or_insert(0);

// Update or insert
*scores.entry("player2").or_insert(0) += 10;
```

## Iteration

### Basic Patterns

| Instead of | Use |
|------------|-----|
| `for i in 0..vec.len() { vec[i] }` | `for item in &vec { ... }` |
| Manual index counter | `enumerate()` |
| Nested loops for pairs | `Iterator::zip()` |
| Building new vec in loop | `map().collect()` |

**Example:**

```rust
let items = vec![1, 2, 3];

// Simple iteration
for item in &items {
    println!("{}", item);
}

// With index
for (i, item) in items.iter().enumerate() {
    println!("{}: {}", i, item);
}

// Parallel iteration
let names = vec!["a", "b", "c"];
let values = vec![1, 2, 3];
for (name, value) in names.iter().zip(values.iter()) {
    println!("{}: {}", name, value);
}

// Transform
let doubled: Vec<_> = items.iter().map(|x| x * 2).collect();
```

### Common Iterator Methods

| Method | Use |
|--------|-----|
| `filter()` | Keep elements matching predicate |
| `map()` | Transform each element |
| `filter_map()` | Filter and transform in one step |
| `find()` | First element matching predicate |
| `any()` | Check if any element matches |
| `all()` | Check if all elements match |
| `fold()` | Reduce to single value |
| `take()` | First n elements |
| `skip()` | Skip first n elements |
| `chain()` | Concatenate iterators |

**Example:**

```rust
let numbers = vec![1, 2, 3, 4, 5];

// Filter and map
let even_doubled: Vec<_> = numbers
    .iter()
    .filter(|x| *x % 2 == 0)
    .map(|x| x * 2)
    .collect();

// Find first
if let Some(first_even) = numbers.iter().find(|x| *x % 2 == 0) {
    println!("First even: {}", first_even);
}

// Check conditions
let has_three = numbers.iter().any(|x| *x == 3);
let all_positive = numbers.iter().all(|x| *x > 0);

// Sum
let total: i32 = numbers.iter().sum();
```

## Error Handling

### Result Patterns

| Instead of | Use |
|------------|-----|
| `unwrap()` | `?` operator |
| `match result { Ok(v) => v, Err(e) => return Err(e) }` | `result?` |
| Nested `match` for multiple Results | Chain `?` operators |
| `if let Err` to log and continue | `map_err()` for context |

**Example:**

```rust
// Propagate errors
fn read_config(path: &str) -> Result<Config, Error> {
    let content = fs::read_to_string(path)?;
    let config = parse_config(&content)?;
    Ok(config)
}

// Add context
fn load() -> Result<Config, Error> {
    fs::read_to_string("config.txt")
        .map_err(|e| Error::ConfigRead(e))?;
    // ...
}

// Transform errors
fn parse() -> Result<Value, ParseError> {
    let num: i32 = s.parse()
        .map_err(|_| ParseError::InvalidNumber)?;
    Ok(Value::Number(num))
}
```

### Option Patterns

| Instead of | Use |
|------------|-----|
| `if option.is_some() { option.unwrap() }` | `if let Some(v) = option` |
| Manual default | `unwrap_or(default)` |
| Unwrap with computed default | `unwrap_or_else(\|\| compute())` |
| Convert None to error | `ok_or(error)` |

**Example:**

```rust
let maybe_value: Option<i32> = Some(42);

// Extract with pattern
if let Some(v) = maybe_value {
    println!("Value: {}", v);
}

// Defaults
let value = maybe_value.unwrap_or(0);
let value = maybe_value.unwrap_or_else(|| expensive_default());

// Convert to Result
let result = maybe_value.ok_or("no value provided")?;
```

## Type Conversions

### Standard Traits

| Instead of | Use |
|------------|-----|
| Manual conversion function | Implement `From`/`Into` |
| Fallible manual conversion | Implement `TryFrom`/`TryInto` |
| Custom `as_*` methods | Use `AsRef`/`AsMut` |
| Manual reference conversion | `Borrow`/`BorrowMut` |

**Example:**

```rust
use std::convert::TryFrom;

#[derive(Debug)]
struct UserId(u32);

impl TryFrom<&str> for UserId {
    type Error = ParseError;
    
    fn try_from(s: &str) -> Result<Self, Self::Error> {
        let id: u32 = s.parse()
            .map_err(|_| ParseError::InvalidId)?;
        Ok(UserId(id))
    }
}

// Usage
let user_id = UserId::try_from("123")?;
```

## Path Operations

| Instead of | Use |
|------------|-----|
| String concatenation | `path.join(component)` |
| Manual path parsing | `path.file_name()`, `path.extension()` |
| String comparison | `path.ends_with("suffix")` |

**Example:**

```rust
use std::path::Path;

let base = Path::new("/usr/local");
let full = base.join("bin").join("tool");

if let Some(name) = full.file_name() {
    println!("Filename: {:?}", name);
}

if let Some(ext) = full.extension() {
    println!("Extension: {:?}", ext);
}
```

## Key Principle

**The standard library already solved your problem.**

Before writing custom logic:
1. Check if `std` has a method
2. Read the docs for the type you're working with
3. Look at iterator methods
4. Consider if a trait provides the conversion

Stdlib methods are:
- Well-tested
- Optimized
- Handle edge cases
- Self-documenting
- Maintained

Use them.
