#!/usr/bin/env python3
"""Slack Web API CLI helper for Claude Code skill.

Usage:
    python3 slack_api.py <command> [args...]

Commands:
    send <channel> <text>           Send a message (channel ID or user ID for DM)
    send_blocks <channel> <json>    Send a Block Kit message (json string)
    reply <channel> <thread_ts> <text>  Reply in thread
    channels [query]                List channels (optional name filter)
    history <channel> [limit]       Get channel history (default: 20)
    search <query>                  Search messages
    users [query]                   List users (optional name filter)
    react <channel> <ts> <emoji>    Add reaction
    whoami                          Show bot and user info
    my_id                           Print my_user_id from credentials
"""

import json
import os
import sys
import urllib.request
import urllib.parse

sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')


def load_credentials():
    cred_path = os.path.join(os.path.expanduser("~"), ".claude", "credentials.json")
    with open(cred_path) as f:
        return json.load(f)["slack"]


def api_call(method, token, payload=None, as_get=False):
    url = f"https://slack.com/api/{method}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json; charset=utf-8",
    }

    if as_get:
        if payload:
            url += "?" + urllib.parse.urlencode(payload)
        req = urllib.request.Request(url, headers=headers)
    else:
        data = json.dumps(payload or {}).encode("utf-8")
        req = urllib.request.Request(url, data=data, headers=headers)

    resp = urllib.request.urlopen(req)
    result = json.loads(resp.read())

    if not result.get("ok"):
        print(f"ERROR: {result.get('error', 'unknown')}", file=sys.stderr)
        sys.exit(1)

    return result


def cmd_send(args):
    channel, text = args[0], " ".join(args[1:])
    cred = load_credentials()
    if channel == "me":
        channel = cred["my_user_id"]
    result = api_call("chat.postMessage", cred["bot_token"], {"channel": channel, "text": text})
    print(f"Sent to {result['channel']} (ts: {result['ts']})")


def cmd_send_blocks(args):
    channel, blocks_json = args[0], " ".join(args[1:])
    cred = load_credentials()
    if channel == "me":
        channel = cred["my_user_id"]
    blocks = json.loads(blocks_json)
    fallback = blocks[0].get("text", {}).get("text", "") if blocks else ""
    result = api_call("chat.postMessage", cred["bot_token"], {"channel": channel, "blocks": blocks, "text": fallback})
    print(f"Sent to {result['channel']} (ts: {result['ts']})")


def cmd_reply(args):
    channel, thread_ts, text = args[0], args[1], " ".join(args[2:])
    cred = load_credentials()
    result = api_call("chat.postMessage", cred["bot_token"], {"channel": channel, "thread_ts": thread_ts, "text": text})
    print(f"Replied in {result['channel']} (ts: {result['ts']})")


def cmd_channels(args):
    query = args[0].lower() if args else None
    cred = load_credentials()
    result = api_call("conversations.list", cred["bot_token"], {"types": "public_channel,private_channel", "limit": 200})
    for ch in result.get("channels", []):
        if query is None or query in ch["name"].lower():
            print(f"{ch['id']}\t#{ch['name']}")


def cmd_history(args):
    channel = args[0]
    limit = int(args[1]) if len(args) > 1 else 20
    cred = load_credentials()
    result = api_call("conversations.history", cred["bot_token"], {"channel": channel, "limit": limit})
    for msg in reversed(result.get("messages", [])):
        user = msg.get("user", msg.get("bot_id", "?"))
        text = msg.get("text", "")[:200]
        print(f"[{msg['ts']}] {user}: {text}")


def cmd_search(args):
    query = " ".join(args)
    cred = load_credentials()
    result = api_call("search.messages", cred["bot_token"], {"query": query, "count": 20, "sort": "timestamp", "sort_dir": "desc"}, as_get=True)
    matches = result.get("messages", {}).get("matches", [])
    for m in matches:
        ch = m.get("channel", {}).get("name", "?")
        print(f"[{m['ts']}] #{ch} - {m.get('username', '?')}: {m.get('text', '')[:200]}")


def cmd_users(args):
    query = args[0].lower() if args else None
    cred = load_credentials()
    result = api_call("users.list", cred["bot_token"], {"limit": 200})
    for u in result.get("members", []):
        if u.get("is_bot") or u.get("deleted"):
            continue
        name = u.get("real_name", u["name"])
        if query is None or query in name.lower() or query in u["name"].lower():
            print(f"{u['id']}\t{u['name']}\t{name}")


def cmd_react(args):
    channel, ts, emoji = args[0], args[1], args[2]
    cred = load_credentials()
    api_call("reactions.add", cred["bot_token"], {"channel": channel, "timestamp": ts, "name": emoji})
    print(f"Added :{emoji}: reaction")


def cmd_whoami(_args):
    cred = load_credentials()
    result = api_call("auth.test", cred["bot_token"])
    print(json.dumps(result, indent=2, ensure_ascii=False))
    print(f"\nmy_user_id: {cred.get('my_user_id', 'NOT SET')}")


def cmd_my_id(_args):
    cred = load_credentials()
    print(cred.get("my_user_id", "NOT SET"))


COMMANDS = {
    "send": cmd_send,
    "send_blocks": cmd_send_blocks,
    "reply": cmd_reply,
    "channels": cmd_channels,
    "history": cmd_history,
    "search": cmd_search,
    "users": cmd_users,
    "react": cmd_react,
    "whoami": cmd_whoami,
    "my_id": cmd_my_id,
}


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in COMMANDS:
        print(__doc__)
        sys.exit(1)
    COMMANDS[sys.argv[1]](sys.argv[2:])
