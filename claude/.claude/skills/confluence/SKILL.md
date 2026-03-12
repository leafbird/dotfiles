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

- Domain: `starsavior.atlassian.net`
- Base URL: `https://starsavior.atlassian.net/wiki`
- Default Space Key: `QkL2rjCmJyjr` (스타 테크)
- Homepage ID: `24281301`

## 환경 제약 (Windows + Git Bash)

**반드시 지켜야 할 규칙:**

1. **한글이 포함된 JSON을 전송할 때는 curl을 사용하지 않는다.** Windows Git Bash에서 curl이 한글 데이터를 CP949로 변환하여 `Invalid UTF-8 start byte` 오류가 발생한다. 대신 Python 스크립트 파일을 작성하여 `requests` 라이브러리로 전송한다.
2. **Python에서 `$HOME`을 사용하지 않는다.** Python `open()`은 셸 변수를 확장하지 않으므로 반드시 `C:/Users/choisungki/.claude/credentials.json` 절대 경로를 사용한다.
3. **`/tmp/` 경로나 현재 작업 디렉토리를 사용하지 않는다.** Windows에서 `/tmp/`는 Git Bash 가상 경로로 Python에서 접근 불가하고, 작업 디렉토리는 P4 client가 감지하여 자동 add를 건다. 임시 파일은 Python `tempfile` 모듈로 OS 표준 temp 경로에 생성한다: `import tempfile; f = tempfile.NamedTemporaryFile(suffix='.py', delete=False)`
4. **Python 코드를 Bash 인라인(`python3 -c "..."`)으로 작성하지 않는다.** `!`, `"`, `\` 등 특수문자가 Bash와 Python 사이에서 이스케이프 충돌을 일으킨다. 반드시 `.py` 파일로 작성 후 실행한다.
5. **Python `requests` 모듈이 없을 수 있다.** 스크립트 실행 전 `pip install requests -q 2>/dev/null` 을 선행한다.

## 읽기 전용 작업 (curl 사용 가능)

한글이 URL 파라미터에만 있는 **읽기 전용** 작업은 curl로 수행할 수 있다. 단, 결과 파싱은 Python 파일로 한다.

### 인증 변수 설정 (curl용)
```bash
CONF_AUTH="$(python3 -c "import json; d=json.load(open('C:/Users/choisungki/.claude/credentials.json')); print(d['confluence']['email']+':'+d['confluence']['token'])")"
```

### search - 페이지 검색
```bash
curl -s -u "$CONF_AUTH" "https://starsavior.atlassian.net/wiki/rest/api/content/search?cql=space=QkL2rjCmJyjr+AND+title~%22검색어%22&limit=20" -H "Accept: application/json"
```

### read - 페이지 읽기
```bash
curl -s -u "$CONF_AUTH" "https://starsavior.atlassian.net/wiki/rest/api/content/{pageId}?expand=body.storage,version,ancestors" -H "Accept: application/json"
```

### list - 페이지 목록
```bash
curl -s -u "$CONF_AUTH" "https://starsavior.atlassian.net/wiki/rest/api/content?spaceKey=QkL2rjCmJyjr&type=page&limit=50&expand=ancestors" -H "Accept: application/json"
```

## 쓰기 작업 (Python 스크립트 필수)

페이지 생성/수정은 **반드시 Python 스크립트 파일**로 수행한다.

### 공통 패턴

OS 표준 temp 경로에 임시 `.py` 파일을 작성하여 실행하고, 완료 후 삭제한다. Write 도구로 파일 생성 시 경로는 `C:/Users/choisungki/AppData/Local/Temp/conf_XXXX.py` 형식을 사용한다.

```python
import json
import requests

creds = json.load(open('C:/Users/choisungki/.claude/credentials.json'))
auth = (creds['confluence']['email'], creds['confluence']['token'])
BASE = 'https://starsavior.atlassian.net/wiki/rest/api/content'

# API 호출
r = requests.post(BASE, json=data, auth=auth, headers={'Accept': 'application/json'})
# 또는
r = requests.put(f'{BASE}/{page_id}', json=data, auth=auth, headers={'Accept': 'application/json'})

result = r.json()
if r.status_code == 200:
    print(f"Success: id={result['id']}, title={result['title']}")
    print(f"URL: {result['_links']['base']}{result['_links']['webui']}")
else:
    print(f"Error: {r.status_code} - {result.get('message', result)}")
```

### create - 페이지 생성
```python
data = {
    'type': 'page',
    'title': '페이지 제목',
    'space': {'key': 'QkL2rjCmJyjr'},
    'ancestors': [{'id': PARENT_PAGE_ID}],  # 미지정 시 24281301 (홈)
    'body': {
        'storage': {
            'value': '<p>Confluence Storage Format HTML</p>',
            'representation': 'storage'
        }
    }
}
r = requests.post(BASE, json=data, auth=auth, headers={'Accept': 'application/json'})
```

### update - 페이지 수정
```python
# 1. 현재 버전 조회
r = requests.get(f'{BASE}/{page_id}', params={'expand': 'version'}, auth=auth, headers={'Accept': 'application/json'})
current_version = r.json()['version']['number']

# 2. 버전 +1로 업데이트
data = {
    'type': 'page',
    'title': '페이지 제목',
    'version': {'number': current_version + 1},
    'body': {
        'storage': {
            'value': '<p>수정된 내용</p>',
            'representation': 'storage'
        }
    }
}
r = requests.put(f'{BASE}/{page_id}', json=data, auth=auth, headers={'Accept': 'application/json'})
```

## 사용자 요청: $ARGUMENTS

## 경로 탐색 규칙

사용자가 `'A/B/C'` 형태로 경로를 지정하면, 각 경로 요소(A, B 등)는 **페이지(page)**일 수도 있고 **폴더(folder)**일 수도 있다. Confluence에서 폴더도 콘텐츠 타입의 하나이므로, 부모 노드를 찾을 때 **type을 page로 한정하지 말고 페이지와 폴더를 모두 검색**해야 한다.

```bash
# 제목으로 부모 찾기 — type 필터 없이 검색
cql=space=QkL2rjCmJyjr AND title="클로드 코드"
```

검색 결과가 여러 개면 `type` 필드를 확인하여 `folder`와 `page`를 구분하고, **폴더가 있으면 폴더를 우선** 부모로 사용한다. 동일 이름의 페이지를 새로 만들지 않는다.

## 실행 절차

1. 사용자 요청 분석 (읽기 vs 쓰기)
2. 읽기: curl로 바로 실행
3. 쓰기:
   - 경로에 부모가 지정되어 있으면 **페이지+폴더 모두 검색**하여 기존 노드를 찾는다
   - 기존 노드가 있으면 그 id를 부모로 사용, 없으면 새로 생성
   - OS temp 경로에 `.py` 임시 파일 작성 → `pip install requests -q 2>/dev/null && python3 <file>` → 임시 파일 삭제

## 주의사항
- 페이지 내용은 Confluence Storage Format(XHTML)으로 작성
- 업데이트 시 반드시 현재 버전을 먼저 조회하여 version+1로 지정
- 결과가 길면 핵심 내용만 요약하여 사용자에게 보여줌
- 코드 블록은 `<ac:structured-macro ac:name="code">` 형식 사용

## 향후 보강 가능 기능
참고: https://github.com/SpillwaveSolutions/confluence-skill
- 대용량(10KB+) 문서 및 이미지 첨부 업로드 (Python 스크립트)
- 페이지 다운로드 → Markdown 변환
- Wiki Markup ↔ Markdown 양방향 변환
- Mermaid/PlantUML 다이어그램 렌더링
