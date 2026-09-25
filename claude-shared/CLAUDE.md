# User Preferences (Shared)

## Language
- 사용자에게 설명할 때는 항상 한국어로 답변한다.
- 말투는 가벼운 존댓말을 사용한다 (예: "~합니다", "~할까요?").

## 용어 약속
- **"글로벌 설정"** = `~/.claude/CLAUDE.md` (이 파일)
- **"내 dotfile 푸시해줘"** = `~/dotfiles` repo의 변경사항을 커밋 + 푸시
- **"워크노트"**, **"핸드오프"** = `worknote` 스킬에서 정의. 워크노트·핸드오프·todo·진행 문서를 다루거나 워크노트 root(`CLAUDE.local.md` 에 정의) 안에서 작업할 때는 먼저 이 스킬을 읽는다.

## 시크릿 관리
- 모든 스킬의 비밀번호·API 키·토큰은 **`~/.claude/skill-secrets.json`** 한 곳에 모은다. (0600, gitignore 됨)
- 스킬 문서·스크립트·worknotes 에 시크릿을 평문으로 적지 않는다. 필요하면 이 파일에서 읽는다.
  ```bash
  jq -r '."asus-router".password' ~/.claude/skill-secrets.json
  ```
- 새 시크릿이 생기면 기존 키 네이밍(서비스명 소문자-하이픈)을 따라 이 파일에 추가한다.

## Tool Preferences
- MCP 방식 비선호. 가능하면 커스텀 스킬(slash command) + REST API 직접 호출 방식을 사용한다.

## Orca 오케스트레이션
- Orca 워커를 스폰하거나 오케스트레이션(Run/Task/Dispatch)을 다루기 **전에** `orca-worker` 스킬을 먼저 읽는다.
  실제로 겪은 함정과 대응이 거기 있다 — 성급한 stall 판정, 디스패치 id 갈림, 에이전트별 특성.

## 코드 수정 규칙 (C# 프로젝트 한정)
- C# 프로젝트에서 **여러 파일에 걸친 변경, 설계·구조 변경, public API·시그니처 변경, 파일 삭제**는 실행 전에 변경 내용을 설명하고 승인을 받는다. bypass permissions 모드와 무관하게 적용.
- 한두 파일 안의 국소 수정(버그 수정, 컨벤션 적용 등)은 바로 진행하고, 끝난 뒤 무엇을 바꿨는지 보고한다.
- 조사/탐색/빌드/테스트 등 코드 수정이 아닌 도구 사용은 자유롭게 진행한다.
- **상수 인자 named-parameter 컨벤션**: 메서드/생성자 호출 시 리터럴 상수(`2`, `true`, `false`, `null`, `0` 등)를 인자로 넘길 때는 named-parameter 를 붙인다. 변수·필드·식은 그대로 둔다.
  - ✅ `new AssetWithCountGameData(MountTicket, count: 2)`
  - ✅ `DoSomething(target, ignoreCase: true, retryCount: 3)`
  - ❌ `new AssetWithCountGameData(MountTicket, 2)`
  - ❌ `DoSomething(target, true, 3)`

<!-- 머신별 로컬 오버라이드 (파일 없으면 무시됨) -->
@CLAUDE.local.md
