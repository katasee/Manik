#!/usr/bin/env bash
# PreToolUse guard for Write|Edit|MultiEdit.
# Blocks writing Manik-convention violations into .swift files.
# Denies via PreToolUse JSON (permissionDecision: deny). Never blocks non-swift files.

input=$(cat)

file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')
case "$file" in
  *.swift) ;;
  *) exit 0 ;;
esac

text=$(printf '%s' "$input" | jq -r '
  [ .tool_input.content,
    .tool_input.new_string,
    ( .tool_input.edits[]?.new_string ) ]
  | map(select(. != null)) | join("\n")')

[ -z "$text" ] && exit 0

base=$(basename "$file")
violations=""

check() {
  if printf '%s' "$text" | grep -Fq -- "$1"; then
    violations="${violations}"$'\n'"  • ${2}"
  fi
}

check '.font(.system('   'system font -> use Font.elmsSans(_:_:)'
check '.fontWeight('     '.fontWeight -> pick an ElmsSans weight inside Font.elmsSans'
check '.bold()'         '.bold() -> use Font.elmsSans(.bold, ...)'
check 'setData(from:'   'setData(from:) is fire-and-forget -> encode manually + setData(_:)'
check 'addDocument(from:' 'addDocument(from:) is fire-and-forget -> encode manually + addDocument(data:)'

if [ "$base" != "DateFormat.swift" ]; then
  check 'DateFormatter(' 'inline DateFormatter -> route through Utilities/DateFormat.swift'
fi

if [ -n "$violations" ]; then
  reason="Manik convention violation in ${base}:${violations}"
  jq -n --arg r "$reason" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
fi

exit 0
