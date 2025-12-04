# GitHub to Discord
This shell script is designed to poll push events from a designated GitHub user. If there is a new push event, the script will send a message to a Discord server with details about the push event.

## Set Up
1. Acquire a GitHub Personal Access Token (PAT) and a Discord webhook. Instructions for obtaining a Discord webhook are in the link at the bottom of the README
2. Clone this repo
    ```sh
    git clone https://github.com/djsingh52/github_to_discord.git
    cd github_to_discord
    ```
3. Set the token values in the Configuration section of the script
4. Update the permissions to execute the script
    ```sh
    chmod +x poll_github.sh
    ```
5. Run the script
    ```sh
    ./poll_github.sh
    ```

## Repo Webhook
There is also a webhook *attached to this repo*. Upon pushing to this repo, the webhook added to the repo settings triggers a message to a Discord server.

https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks
