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

## 스레드 읽기
`slack_api.py`에 replies 명령이 없으므로 직접 API 호출:
```python
import json, os, urllib.request, urllib.parse
cred_path = os.path.join(os.path.expanduser('~'), '.claude', 'credentials.json')
with open(cred_path) as f:
    cred = json.load(f)['slack']
url = 'https://slack.com/api/conversations.replies?' + urllib.parse.urlencode({
    'channel': '<channel_id>', 'ts': '<thread_ts>', 'limit': 50
})
req = urllib.request.Request(url, headers={'Authorization': f'Bearer {cred["bot_token"]}'})
data = json.loads(urllib.request.urlopen(req).read())
for msg in data.get('messages', []):
    print(f"[{msg['ts']}] {msg.get('user','?')}: {msg.get('text','')}")
```

## Table Block (테이블 메시지)
Slack table block으로 구조화된 테이블을 보낼 수 있다.

### 핵심 규칙
- **메시지당 테이블 1개만 허용.** 2개 이상 시 `invalid_attachments` (only_one_table_allowed) 에러.
- **테이블은 반드시 `attachments[0].blocks`에 배치.** 본문 `blocks`에 넣으면 `invalid_blocks` 에러.
- **셀 타입은 `rich_text`만 유효.** 문서의 `raw_text`는 실제로 동작하지 않음.
- **빈 셀에도 공백 문자 필수.** 빈 문자열(`""`)이면 validation 에러.
- 최대 100행, 20열.

### 셀 헬퍼 함수
```python
def cell(text):
    t = text if text else ' '
    return {'type':'rich_text','elements':[{'type':'rich_text_section','elements':[{'type':'text','text':t}]}]}

def bold_cell(text):
    return {'type':'rich_text','elements':[{'type':'rich_text_section','elements':[{'type':'text','text':text,'style':{'bold':True}}]}]}
```

### 전체 전송 예시
```python
import json, os, urllib.request

cred_path = os.path.join(os.path.expanduser('~'), '.claude', 'credentials.json')
with open(cred_path) as f:
    cred = json.load(f)['slack']

blocks = [
    {'type':'header','text':{'type':'plain_text','text':'제목'}},
    {'type':'section','text':{'type':'mrkdwn','text':'본문 내용'}},
]

table = {
    'type':'table',
    'column_settings':[
        {'align':'left'},
        {'align':'left','is_wrapped':True},
        {'align':'right'},
    ],
    'rows':[
        [bold_cell('헤더1'), bold_cell('헤더2'), bold_cell('헤더3')],
        [cell('값1'), cell('값2'), cell('값3')],
        [cell(''), cell('값4'), cell('값5')],  # 빈 셀 = 공백
        [bold_cell('합계'), bold_cell(''), bold_cell('99')],
    ],
}

payload = json.dumps({
    'channel': '<channel_id>',
    'thread_ts': '<thread_ts>',  # 스레드 reply 시
    'blocks': blocks,
    'attachments': [{'blocks': [table]}],
    'text': 'fallback text',
}).encode('utf-8')

req = urllib.request.Request('https://slack.com/api/chat.postMessage', data=payload, headers={
    'Authorization': f'Bearer {cred["bot_token"]}',
    'Content-Type': 'application/json; charset=utf-8',
})
resp = json.loads(urllib.request.urlopen(req).read())
```

### column_settings 옵션
| 속성 | 값 | 기본값 |
|------|-----|--------|
| `align` | `"left"`, `"center"`, `"right"` | `"left"` |
| `is_wrapped` | `true`/`false` | `false` |

### 테이블 2개 이상 필요할 때
별도 메시지(reply)로 분리하여 전송. 각 메시지에 테이블 1개씩.

## 주의사항
- 채널 ID는 `C`로 시작 (예: `C01ABCDEF`), User ID는 `U`로 시작
- User ID를 channel에 넣으면 해당 사용자에게 DM 전송됨
- API 응답 `ok: false`이면 스크립트가 stderr에 에러를 출력하고 exit 1
- Rate limit 에러 시 잠시 후 재시도
- `slack_api.py`에 UTF-8 인코딩 처리가 내장되어 있으므로 `PYTHONIOENCODING` 불필요. 인라인 스크립트 작성 시에는 `python3 -X utf8 -c "..."` + `sys.stdout.reconfigure(encoding='utf-8')` 적용 필요.
