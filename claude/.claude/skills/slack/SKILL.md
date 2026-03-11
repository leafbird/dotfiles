---
name: slack
description: Slack 채널에 메시지 전송, 검색, 채널 목록 조회 등을 수행합니다. Use when the user mentions Slack, or wants to send a message, search messages, or interact with Slack channels.
argument-hint: [action] [args...]
allowed-tools: Bash, Read, WebFetch
---

# Slack 스킬

Slack Web API를 `slack_api.py` 헬퍼 스크립트로 호출합니다.

## 인증 정보
`~/.claude/credentials.json`에서 자동으로 읽는다.
```json
{
  "slack": {
    "bot_token": "xoxb-...",
    "my_user_id": "U...",
    "workspace": "studiobsidedev"
  }
}
```

## 핵심 규칙
- **curl 사용 금지.** Windows Git Bash에서 curl + 한글 JSON = `invalid_json` 에러 발생.
- **경로에서 `$HOME` 사용 금지.** `os.path.expanduser('~')` 사용. (스크립트에 내장됨)
- **메시지 전송 전 반드시 사용자에게 내용과 대상 채널을 확인받을 것.**

## 스크립트 위치
```
SCRIPT="$(dirname "$(readlink -f ~/.claude/skills/slack/SKILL.md)")/slack_api.py"
```
또는 직접 경로:
```
SCRIPT=~/.claude/skills/slack/slack_api.py
```

## 사용자 요청: $ARGUMENTS

## 명령어

### 메시지 전송
```bash
python3 "$SCRIPT" send <channel_id|me> <text>
```
- `me`를 쓰면 credentials의 `my_user_id`로 DM 전송

### Block Kit 리치 메시지
```bash
python3 "$SCRIPT" send_blocks <channel_id|me> '<json_blocks>'
```

### 스레드 답장
```bash
python3 "$SCRIPT" reply <channel_id> <thread_ts> <text>
```

### 채널 목록
```bash
python3 "$SCRIPT" channels [이름필터]
```

### 채널 히스토리
```bash
python3 "$SCRIPT" history <channel_id> [limit]
```

### 메시지 검색
```bash
python3 "$SCRIPT" search <검색어>
```

### 사용자 목록
```bash
python3 "$SCRIPT" users [이름필터]
```

### 리액션 추가
```bash
python3 "$SCRIPT" react <channel_id> <message_ts> <emoji_name>
```

### 봇 정보 확인
```bash
python3 "$SCRIPT" whoami
```

## 주의사항
- 채널 ID는 `C`로 시작 (예: `C01ABCDEF`), User ID는 `U`로 시작
- User ID를 channel에 넣으면 해당 사용자에게 DM 전송됨
- API 응답 `ok: false`이면 스크립트가 stderr에 에러를 출력하고 exit 1
- Rate limit 에러 시 잠시 후 재시도
