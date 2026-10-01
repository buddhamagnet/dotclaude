---
name: running-log
description: Interactive running log to track shin pain patterns. Collects run data (date, time, location, shoes, food, distance, hydration, pain level) and automatically analyzes correlations to identify what conditions lead to pain-free vs painful runs.
allowed-tools: Bash(pattern:*), Read(pattern:*), Write(pattern:*), Edit(pattern:*), AskUserQuestion(pattern:*)
---

# Running Log & Shin Pain Tracker

This skill helps track running data and shin pain levels to identify patterns and triggers.

## When Invoked

1. **Collect run data interactively** using AskUserQuestion
2. **Store the entry** in `~/.claude/running-log.json`
3. **Analyze all data** and display pattern insights

## Data Collection Steps

### Step 1: Ask for run details

Use AskUserQuestion to collect:
- Date (default to today, allow override)
- Time of run (format: HH:MM)
- Location (free text)
- Shoe type (road or trail)
- Food eaten before run (free text)
- Distance (numeric, in km or miles)
- Hydration level (low, medium, high)
- Shin pain level (0-10 scale)

Structure the questions efficiently - group related fields where possible.

### Step 2: Load existing log or create new

Read `~/.claude/running-log.json`. If it doesn't exist, create with structure:
```json
{
  "runs": [],
  "metadata": {
    "created": "YYYY-MM-DD",
    "total_entries": 0
  }
}
```

### Step 3: Append new entry

Add the collected data as a new object in the `runs` array:
```json
{
  "date": "2026-10-01",
  "time": "07:00",
  "location": "park trail",
  "shoes": "trail",
  "food": "banana, coffee",
  "distance": 5.2,
  "distance_unit": "km",
  "hydration": "high",
  "pain": 2
}
```

Update `metadata.total_entries`.

### Step 4: Analyze patterns

After saving, immediately analyze all data and display insights.

## Analysis Algorithm

Calculate and display:

### Overall Statistics
- Total runs logged
- Pain level distribution: average, min, max
- Pain-free runs (pain = 0): count and percentage
- Recent trend: last 7 days average pain vs overall average

### Pattern Analysis by Variable

For each variable, group runs and calculate:
- Count of runs in each group
- Average pain per group
- Pain-free percentage per group
- Highlight best and worst performers

**Variables to analyze:**
1. **Shoe type** (road vs trail)
2. **Hydration level** (low, medium, high)
3. **Distance ranges** (group into: <5km, 5-10km, >10km or equivalent miles)
4. **Time of day** (group into: morning 05:00-11:59, afternoon 12:00-17:59, evening 18:00-23:59, night 00:00-04:59)
5. **Location** (top 3 most frequent locations)

### Correlation Insights

Identify and highlight:
- "Pain-free pattern": What combination of factors appears most in pain level 0-2 runs?
- "High pain warning": What factors appear most in pain level 6-10 runs?
- "Recent change": Has pain increased/decreased in last 7 days compared to previous period?

## Output Format

Display results in clean, scannable format:

```
✓ Run logged (#XX total)

━━━ PAIN OVERVIEW ━━━
Average pain: X.X/10
Last 7 days: X.X/10 (trend: ↑/↓/→)
Pain-free runs: XX (XX%)

━━━ PATTERNS ━━━

SHOE TYPE
  Trail: X.X avg pain | XX% pain-free (XX runs)
  Road:  X.X avg pain | XX% pain-free (XX runs)
  → Best: Trail shows XX% lower pain

HYDRATION
  High:   X.X avg pain | XX% pain-free
  Medium: X.X avg pain | XX% pain-free
  Low:    X.X avg pain | XX% pain-free
  → Best: High hydration

DISTANCE
  < 5km:    X.X avg pain (XX runs)
  5-10km:   X.X avg pain (XX runs)
  > 10km:   X.X avg pain (XX runs)

TIME OF DAY
  Morning:   X.X avg pain (XX runs)
  Afternoon: X.X avg pain (XX runs)
  Evening:   X.X avg pain (XX runs)

TOP LOCATIONS
  Location1: X.X avg pain (XX runs)
  Location2: X.X avg pain (XX runs)
  Location3: X.X avg pain (XX runs)

━━━ KEY INSIGHTS ━━━
• [Highlight the most significant pattern]
• [Highlight warning if high pain runs share common factors]
• [Note recent trends]
```

## Important Notes

- Always show analysis after each entry (automatic daily summary)
- If fewer than 3 entries exist, note "Need more data for reliable patterns"
- Round pain averages to 1 decimal place
- Calculate percentages as integers
- Use arrows for trends: ↑ increasing, ↓ decreasing, → stable
- Keep output concise but insightful
- If a pattern is very clear (>50% difference), emphasize it

## Error Handling

- If log file is corrupted, back it up and create fresh one
- If user enters invalid data (non-numeric distance/pain), re-prompt
- Handle missing fields gracefully in analysis (skip that run or use "unknown" category)
