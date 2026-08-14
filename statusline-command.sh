#!/bin/bash

# Read JSON input from Claude Code
input=$(cat)

# Extract model display name
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# Extract current directory and truncate to last 3 components
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // ""')
if [ -n "$current_dir" ]; then
  # Truncate to last 3 path components
  dir_display=$(echo "$current_dir" | awk -F/ '{
    n = NF
    if (n <= 3) print $0
    else printf ".../%s/%s/%s", $(n-2), $(n-1), $n
  }')
  # Replace home directory with ~
  dir_display="${dir_display/#$HOME/\~}"
else
  dir_display=$(pwd | awk -F/ '{
    n = NF
    if (n <= 3) print $0
    else printf ".../%s/%s/%s", $(n-2), $(n-1), $n
  }' | sed "s|^$HOME|~|")
fi

# Check for plan mode
plan_mode_indicator=""
settings_file="$HOME/.claude/settings.json"
if [ -f "$settings_file" ]; then
  default_mode=$(jq -r '.permissions.defaultMode // ""' "$settings_file" 2>/dev/null)
  if [ "$default_mode" = "plan" ]; then
    plan_mode_indicator=" $(printf '\033[1;33m[PLAN]\033[0m')"
  fi
fi

# Check for active agents/background tasks
agent_indicator=""
# Check if there's an active agent from the JSON input
active_agent=$(echo "$input" | jq -r '.agent.name // ""')
if [ -n "$active_agent" ]; then
  agent_indicator=" $(printf '\033[1;36m[🔄 agent: %s]\033[0m' "$active_agent")"
else
  # Check for background tasks/agents from JSON input
  background_count=$(echo "$input" | jq -r '.background_tasks // [] | length' 2>/dev/null)
  if [ -n "$background_count" ] && [ "$background_count" -gt 0 ]; then
    if [ "$background_count" -eq 1 ]; then
      agent_indicator=" $(printf '\033[1;36m[🔄 1 agent]\033[0m')"
    else
      agent_indicator=" $(printf '\033[1;36m[🔄 %s agents]\033[0m' "$background_count")"
    fi
  fi
fi

# Get git information (skip if not in a repo)
git_info=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  # Get current branch
  branch=$(git branch --show-current --no-optional-locks 2>/dev/null)

  if [ -n "$branch" ]; then
    # Check for dirty status
    if ! git diff --quiet --no-optional-locks 2>/dev/null || ! git diff --cached --quiet --no-optional-locks 2>/dev/null; then
      dirty="*"
    else
      dirty=""
    fi

    # Check ahead/behind
    ahead_behind=$(git rev-list --left-right --count HEAD...@{u} --no-optional-locks 2>/dev/null || echo "0	0")
    ahead=$(echo "$ahead_behind" | awk '{print $1}')
    behind=$(echo "$ahead_behind" | awk '{print $2}')

    arrows=""
    [ "$ahead" -gt 0 ] && arrows="↑${ahead}"
    [ "$behind" -gt 0 ] && arrows="${arrows}↓${behind}"

    git_info=" $(printf '\033[2m[\033[0m')${branch}${dirty}${arrows}$(printf '\033[2m]\033[0m')"
  fi
fi

# Output the status line
printf '\033[2m[\033[0m'
printf '%s' "$model"
printf '\033[2m]\033[0m'
printf '%s' "$plan_mode_indicator"
printf '%s' "$agent_indicator"
printf ' '
printf '\033[2m[\033[0m'
printf '%s' "$dir_display"
printf '\033[2m]\033[0m'
printf '%s' "$git_info"
printf '\n'
