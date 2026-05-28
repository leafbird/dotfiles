# User Preferences (Shared)

## Language
- 사용자에게 설명할 때는 항상 한국어로 답변한다.
- 말투는 가벼운 존댓말을 사용한다 (예: "~합니다", "~할까요?").

## 용어 약속
- **"글로벌 설정"** = `~/.claude/CLAUDE.md` (이 파일)
- **"내 dotfile 푸시해줘"** = `~/dotfiles` repo의 변경사항을 커밋 + 푸시
- **"워크노트"**, **"핸드오프"** = `claude-shared/agents-worknotes.md` 에서 정의 (아래 import)

## Tool Preferences
- MCP 방식 비선호. 가능하면 커스텀 스킬(slash command) + REST API 직접 호출 방식을 사용한다.

## 코드 수정 규칙 (C# 프로젝트 한정)
- C# 프로젝트에서는 코드 수정(Edit/Write)을 실행하기 전에 반드시 사용자에게 변경 내용을 설명하고 승인을 받는다. bypass permissions 모드와 무관하게 항상 적용.
- 조사/탐색/빌드/테스트 등 코드 수정이 아닌 도구 사용은 자유롭게 진행한다.
- **상수 인자 named-parameter 컨벤션**: 메서드/생성자 호출 시 리터럴 상수(`2`, `true`, `false`, `null`, `0` 등)를 인자로 넘길 때는 named-parameter 를 붙인다. 변수·필드·식은 그대로 둔다.
  - ✅ `new AssetWithCountGameData(MountTicket, count: 2)`
  - ✅ `DoSomething(target, ignoreCase: true, retryCount: 3)`
  - ❌ `new AssetWithCountGameData(MountTicket, 2)`
  - ❌ `DoSomething(target, true, 3)`

<!-- 워크노트 + 핸드오프 워크플로우 정의 (단일 원본). -->
<!-- 동일 파일이 각 머신의 {worknote-root}/AGENTS.md 로도 심볼릭 링크되어 -->
<!-- 워크노트 폴더에서 다른 에이전트(Cursor/Codex/Gemini 등)도 자동 픽업한다. -->
@claude-shared/agents-worknotes.md

<!-- 머신별 로컬 오버라이드 (파일 없으면 무시됨) -->
@CLAUDE.local.md
