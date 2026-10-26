---
name: bash-box
description: Generate and display a new bash tip each run. Teaches bash syntax, tricks, and best practices through incremental learning, building a growing collection over time.
allowed-tools: Bash(pattern:*), Read(pattern:*), Write(pattern:*), Edit(pattern:*)
---

# Bash Box - Daily Bash Tips

Generate a fresh bash tip on each invocation and add it to the growing collection.

## When Invoked

1. **Load or create the tips collection** at `~/.claude/bash-box.json`
2. **Analyze existing tips** to determine what to generate next
3. **Generate a new unique bash tip**
4. **Add it to the collection** with timestamp
5. **Display the new tip** in formatted output
6. **Save the updated collection**

## Step 1: Load Tips Collection

Read `~/.claude/bash-box.json`. If it doesn't exist, create it with this structure:

```json
{
  "metadata": {
    "created": "2026-10-26",
    "total_tips": 0,
    "last_added": "2026-10-26",
    "category_counts": {}
  },
  "tips": []
}
```

If the file is corrupted, back it up and create a fresh one.

## Step 2: Analyze Existing Tips

Before generating a new tip:

1. **Count tips by category** to identify underrepresented areas
2. **Review existing tip IDs and titles** to avoid duplicates
3. **Select target category** - prioritize categories with fewer tips

## Step 3: Generate New Bash Tip

Create one original bash tip that is:
- **Practical and useful** - something the user will actually use
- **Well-explained** - clear syntax, explanation, example, and rationale
- **Unique** - not already in the collection

### Target Categories (rotate through)

- **Parameter Expansion**: `${var:-default}`, `${var#pattern}`, `${var%pattern}`, `${var/find/replace}`, `${#var}`
- **Conditionals & Tests**: `[[ ]]` tests, file operators (`-f`, `-d`, `-x`), string/numeric comparisons
- **Loops & Iteration**: `while read`, `for` loops, C-style loops, array iteration
- **String Manipulation**: substring extraction, case conversion, trimming
- **Command Shortcuts**: history expansion (`!!`, `!$`, `^old^new`), keyboard shortcuts (Ctrl+R, Alt+.)
- **Redirection & Pipes**: `&>`, `<<<`, `<()`, `>()`
- **Error Handling**: `set -e`, `set -u`, `set -o pipefail`, `trap`
- **Best Practices**: quoting variables, shellcheck recommendations, POSIX compatibility

### Tip Structure

Each tip must include:

```json
{
  "id": "unique-kebab-case-identifier",
  "category": "Category Name",
  "title": "Short Title (3-5 words)",
  "syntax": "bash syntax or pattern",
  "explanation": "What this does and how it works",
  "example": "Concrete usage example with context",
  "why": "Why this is useful and when to use it",
  "added": "2026-10-26T14:30:00Z"
}
```

**ID naming convention**: `{category-slug}-{topic-slug}` (e.g., `param-expansion-default-value`, `test-file-exists`, `loop-read-lines`)

## Step 4: Add to Collection

1. Append the new tip to the `tips` array
2. Increment `metadata.total_tips`
3. Update `metadata.last_added` with today's date
4. Update `metadata.category_counts` for the tip's category
5. Add ISO-8601 timestamp to tip's `added` field

## Step 5: Display the Tip

Format the new tip with box-drawing characters for clear visual structure:

```
╔═══════════════════════════════════════════════════════════════╗
║                      BASH TIP #{number}                       ║
╠═══════════════════════════════════════════════════════════════╣
║ Category: {category}                                          ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  {title}                                                      ║
║                                                               ║
║  SYNTAX:                                                      ║
║    {syntax}                                                   ║
║                                                               ║
║  WHAT IT DOES:                                                ║
║    {explanation - wrapped to ~60 chars per line}              ║
║                                                               ║
║  EXAMPLE:                                                     ║
║    {example - may be multiple lines}                          ║
║                                                               ║
║  WHY USE IT:                                                  ║
║    {why - wrapped to ~60 chars per line}                      ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  {category_counts summary} • Added {date}                     ║
╚═══════════════════════════════════════════════════════════════╝
```

**Width**: 65 characters for terminal readability
**Line wrapping**: Break long explanations into multiple lines, each indented with 4 spaces

## Step 6: Save Collection

Write the updated JSON back to `~/.claude/bash-box.json` with proper formatting (2-space indent).

## Quality Guidelines

**Do:**
- Generate practical, real-world useful tips
- Provide concrete, runnable examples
- Explain the "why" not just the "what"
- Use proper bash syntax (not POSIX sh unless specified)
- Reference shellcheck rules where relevant
- Include edge cases or gotchas in explanations

**Don't:**
- Generate duplicate or near-duplicate tips
- Use overly complex examples
- Recommend unsafe patterns
- Generate tips for deprecated syntax
- Fabricate bash features that don't exist

## Example Tips to Guide Generation

**Good tip example**:
```json
{
  "id": "param-expansion-default",
  "category": "Parameter Expansion",
  "title": "Use Default Value",
  "syntax": "${var:-default}",
  "explanation": "Returns the value of var if set and not null, otherwise returns default. The variable itself is not modified.",
  "example": "name=${1:-\"guest\"}\necho \"Hello, $name\"",
  "why": "Prevents errors from unset variables and provides sensible defaults without needing if/else blocks. Cleaner than: if [ -z \"$1\" ]; then name=\"guest\"; fi",
  "added": "2026-10-26T10:00:00Z"
}
```

**What makes it good:**
- Clear, specific syntax
- Explains behavior precisely
- Shows practical usage
- Compares to alternative approach
- Explains when/why to use it

## Category Balance Strategy

Rotate through categories to maintain variety:
1. Generate from category with fewest tips
2. If tied, pick randomly among tied categories
3. Track distribution in `metadata.category_counts`
4. Aim for roughly equal distribution across all 8 categories

## No User Interaction

This skill runs completely automatically - no questions, no confirmations. Just:
1. Generate tip
2. Display it
3. Save collection
4. Done

The user can run it multiple times in succession to build up their collection quickly.
