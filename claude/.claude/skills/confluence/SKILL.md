---
name: confluence
description: Confluence 위키 페이지를 탐색, 검색, 작성, 수정합니다. Use when the user mentions Confluence, wiki, or wants to document something on the wiki.
argument-hint: [action] [args...]
allowed-tools: Bash, Read, Write, WebFetch
---

# Confluence Wiki 스킬

Confluence REST API를 사용하여 위키 페이지를 관리합니다.

## 인증 정보
인증 정보는 `~/.claude/credentials.json`에서 읽는다.
```bash
# credentials.json에서 인증 정보 추출
CONF_EMAIL=$(python3 -c "import json; d=json.load(open('$HOME/.claude/credentials.json')); print(d['confluence']['email'])")
CONF_TOKEN=$(python3 -c "import json; d=json.load(open('$HOME/.claude/credentials.json')); print(d['confluence']['token'])")
CONF_AUTH="$CONF_EMAIL:$CONF_TOKEN"
```

- Domain: `starsavior.atlassian.net`
- Base URL: `https://starsavior.atlassian.net/wiki`
- Default Space Key: `QkL2rjCmJyjr` (스타 테크)
- Homepage ID: `24281301`

## curl 공통 패턴
모든 API 호출에 credentials.json에서 읽은 인증 정보를 사용:
```bash
CONF_AUTH="$(python3 -c "import json; d=json.load(open('$HOME/.claude/credentials.json')); print(d['confluence']['email']+':'+d['confluence']['token'])")"
curl -s -u "$CONF_AUTH" "https://starsavior.atlassian.net/wiki/rest/api/..." -H "Accept: application/json"
```

## 사용자 요청: $ARGUMENTS

## 지원 액션

### list - 페이지 목록
스페이스의 페이지 목록을 조회합니다.
```bash
curl -s -u "$CONF_AUTH" "$BASE/rest/api/content?spaceKey=QkL2rjCmJyjr&type=page&limit=50&expand=ancestors" -H "Accept: application/json"
```

### search - 페이지 검색
CQL(Confluence Query Language)로 검색합니다.
```bash
# 텍스트 검색
curl -s -u "$CONF_AUTH" "$BASE/rest/api/content/search?cql=space=QkL2rjCmJyjr+AND+text~\"검색어\"&limit=20" -H "Accept: application/json"
# 제목 검색
curl -s -u "$CONF_AUTH" "$BASE/rest/api/content/search?cql=space=QkL2rjCmJyjr+AND+title~\"제목\"&limit=20" -H "Accept: application/json"
```

### read - 페이지 읽기
페이지 ID로 내용을 조회합니다. body.storage 형식(Confluence 저장 포맷)으로 반환됩니다.
```bash
curl -s -u "$CONF_AUTH" "$BASE/rest/api/content/{pageId}?expand=body.storage,version,ancestors" -H "Accept: application/json"
```

### create - 페이지 생성
새 페이지를 생성합니다. parentId를 지정하지 않으면 홈페이지(24281301) 하위에 생성합니다.
```bash
curl -s -u "$CONF_AUTH" "$BASE/rest/api/content" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "page",
    "title": "페이지 제목",
    "space": {"key": "QkL2rjCmJyjr"},
    "ancestors": [{"id": PARENT_PAGE_ID}],
    "body": {
      "storage": {
        "value": "<p>HTML 내용</p>",
        "representation": "storage"
      }
    }
  }'
```

### update - 페이지 수정
기존 페이지를 수정합니다. **반드시 현재 version 번호 + 1**을 지정해야 합니다.
```bash
# 1. 먼저 현재 버전 조회
curl -s -u "$CONF_AUTH" "$BASE/rest/api/content/{pageId}?expand=version" -H "Accept: application/json"

# 2. 버전 +1로 업데이트
curl -s -X PUT -u "$CONF_AUTH" "$BASE/rest/api/content/{pageId}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "page",
    "title": "페이지 제목",
    "version": {"number": CURRENT_VERSION + 1},
    "body": {
      "storage": {
        "value": "<p>수정된 HTML 내용</p>",
        "representation": "storage"
      }
    }
  }'
```

## 주의사항
- 페이지 내용은 Confluence Storage Format(XHTML)으로 작성
- 업데이트 시 반드시 현재 버전을 먼저 조회하여 version+1로 지정
- 한글 검색어는 URL 인코딩 필요 (curl이 자동 처리)
- 결과가 길면 핵심 내용만 요약하여 사용자에게 보여줌
- 페이지 생성/수정 전 사용자에게 내용을 확인받음

## 향후 보강 가능 기능
참고: https://github.com/SpillwaveSolutions/confluence-skill
- 대용량(10KB+) 문서 및 이미지 첨부 업로드 (Python 스크립트)
- 페이지 다운로드 → Markdown 변환
- Wiki Markup ↔ Markdown 양방향 변환
- Mermaid/PlantUML 다이어그램 렌더링
