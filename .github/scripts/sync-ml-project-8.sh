#!/usr/bin/env bash
# Sync GitHub org project #8 (Vlang ML Roadmap) with issue open/closed state.
# Requires: gh auth with scopes read:project, project
set -euo pipefail

OWNER=vlang
PROJECT_NUMBER=8
PROJECT_ID="PVT_kwDOAsQ3Cs4BYswy"
STATUS_FIELD="PVTSSF_lADOAsQ3Cs4BYswyzhTwqXI"
DONE_ID="98236657"
IN_PROGRESS_ID="47fc9ee4"
TODO_ID="f75ad846"

# Optional: keep these open issues visible as In Progress on the board
IN_PROGRESS_ISSUES="vlang/vtl#41 vlang/vsl#225 vlang/vtl#63"

echo "Fetching project $PROJECT_NUMBER items..."
items=$(gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --limit 200)

count_done=0
count_ip=0

while IFS='|' read -r item_id num repo; do
	[[ -z "$num" || "$num" == "null" ]] && continue
	state=$(gh issue view "$num" --repo "$repo" --json state -q .state 2>/dev/null || echo OPEN)
	key="${repo}#${num}"

	if [[ "$state" == "CLOSED" ]]; then
		gh project item-edit --id "$item_id" --project-id "$PROJECT_ID" \
			--field-id "$STATUS_FIELD" --single-select-option-id "$DONE_ID" >/dev/null
		echo "Done: $key"
		count_done=$((count_done + 1))
	elif [[ " ${IN_PROGRESS_ISSUES} " == *" ${key} "* ]]; then
		gh project item-edit --id "$item_id" --project-id "$PROJECT_ID" \
			--field-id "$STATUS_FIELD" --single-select-option-id "$IN_PROGRESS_ID" >/dev/null
		echo "In Progress: $key"
		count_ip=$((count_ip + 1))
	fi
done < <(echo "$items" | jq -r '.items[] | select(.content.number != null) | "\(.id)|\(.content.number)|\(.content.repository)"')

echo "Updated: $count_done → Done, $count_ip → In Progress"
