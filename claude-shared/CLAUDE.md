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
- 이 파일은 git 으로 동기화되지 않는다. 새 장비에는 기존 장비에서 `scp` 로 복사하고 0600 으로 맞춘다.

## 공유 스킬
- 여러 장비가 함께 쓰는 자작 스킬은 **claude-synchronizer** repo 의 `shared-skills/<name>/` 에 둔다 (dotfiles 아님).
- repo 위치는 장비·OS 마다 다르다: `$CLAUDE_WORKSPACE_DIR/claude-synchronizer` (Windows `$env:CLAUDE_WORKSPACE_DIR`).
  변수가 없으면 설치된 공용 스킬 심링크를 따라가 찾는다 (예: `readlink ~/.claude/skills/worknote`).
- 설치: repo 의 `scripts/install-skill.sh <name> --agent claude` (Windows `install-skill.ps1`) → `~/.claude/skills/<name>` 심링크. 장비 로컬 전용 스킬만 `~/.claude/skills/` 에 직접 둔다.
- 공유 스킬 작성 규칙(hooks 금지, stdlib 우선 등)은 repo 의 `CLAUDE.md` 참조.

## Tool Preferences
- MCP 방식 비선호. 가능하면 커스텀 스킬(slash command) + REST API 직접 호출 방식을 사용한다.

## 작업 방식
- 되돌리기 쉬운 작업(CL 생성·description 수정, 워크노트 편집, 메모리 저장 등)은 확인 없이 진행하고 끝난 뒤 보고한다.
  묻는 건 의도가 추론되지 않거나 후보를 골라야 할 때, 그리고 삭제·force-push·외부 게시처럼 되돌리기 어려운 작업일 때뿐이다.
- 스케줄·크론·감시 스크립트 같은 상시 장치는 필요가 실제로 생겼을 때 만든다. 더 단순한 방법이 생기면
  기존 장치는 남겨 두지 말고 없앤다(재현용 스크립트는 두고 스케줄만 지운다).
- 답변·문서에 동그라미 숫자(①②③)를 쓰지 않는다. 터미널에서 판독이 안 된다. `1.` 이나 굵은 라벨을 쓴다.

## 코드 주석
- 기본은 안 단다. 달면 메서드당 XML doc 2~3줄 + 비자명한 "왜" 한 줄이 상한이다. 설계 경위는 CL description 이나 대화에 둔다.
- 이모지를 쓰지 않는다(로그 메시지 포함). 기존 코드에 있던 것은 건드리지 않는다.
- "없다·안 읽는다·하나뿐이다" 같은 사실 주장은 grep 이나 코드로 확인하고 쓴다. 반사실("비워 두면 ~된다")을 현재 동작처럼 쓰지 않는다.

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
