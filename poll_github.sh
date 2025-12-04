#!/usr/bin/env bash

# -------------------------------
# Configuration
# -------------------------------

# ---- GitHub ---- #
GITHUB_USER=""          # GitHub username to watch
POLL_INTERVAL=10        # seconds between checks
GITHUB_TOKEN=""         # GitHub Personal Access Token (PAT)

# ---- Discord ---- #
DISCORD_WEBHOOK=""

# -------------------------------
# Internal variables
# -------------------------------

LAST_COMMIT_FILE=".last_commit_id"

if [[ ! -f "$LAST_COMMIT_FILE" ]]; then
    echo "none" > "$LAST_COMMIT_FILE"
fi

echo "Watching GitHub user: $GITHUB_USER"
echo "Polling every $POLL_INTERVAL seconds..."
echo "Last known commit: $LAST_COMMIT_ID"
echo

send_discord_notification() {
  local author=$1
  local repo=$2
  local push_id=$3
  local time=$4
  local url="https://github.com/$repo"
  
  # Construct payload
  local payload=$(cat <<EOF
{
  "content": "\`$author\` pushed (\`#$push_id\`) to \`$repo\` at \`$time\` ❤️ $url"
}
EOF
)

  # Send POST request to Discord Webhook
  curl -H "Content-Type: application/json" -X POST -d "$payload" $DISCORD_WEBHOOK
}

# -------------------------------
# Main loop
# -------------------------------

while true; do
    
    # Fetch most recent commit across all repos
    EVENTS=$(curl -H "Authorization: Bearer $GITHUB_TOKEN" -s "https://api.github.com/users/$GITHUB_USER/events")
    LATEST_COMMIT_ID=$(echo "$EVENTS" | jq -r 'map(select(.type=="PushEvent")) | .[0].payload.push_id // empty')

    if [[ -z "$LATEST_COMMIT_ID" ]]; then
        echo "$(date): No commit found yet."
    else
        LAST_COMMIT_ID=$(cat "$LAST_COMMIT_FILE")
        if [[ "$LATEST_COMMIT_ID" != "$LAST_COMMIT_ID" ]]; then
            echo "$(date): New commit detected! $LATEST_COMMIT_ID"

            # Save new commit ID
            echo "$LATEST_COMMIT_ID" > "$LAST_COMMIT_FILE"

            # Extract push properties
            REPO_NAME=$(echo "$EVENTS" | jq -r 'map(select(.type=="PushEvent")) | .[0].repo.name // empty')
            PUSH_TIME=$(echo "$EVENTS" | jq -r 'map(select(.type=="PushEvent")) | .[0].created_at // empty')
            
            # POST request to Discord Webhook
            send_discord_notification "$GITHUB_USER" "$REPO_NAME" "$LATEST_COMMIT_ID" "$PUSH_TIME"
            echo "Discord message sent."

        else
            echo "$(date): No new commits."
        fi
    fi

    sleep "$POLL_INTERVAL"
done
