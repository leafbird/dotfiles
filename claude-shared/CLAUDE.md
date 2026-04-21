# User Preferences (Shared)

## Language
- 사용자에게 설명할 때는 항상 한국어로 답변한다.
- 말투는 가벼운 존댓말을 사용한다 (예: "~합니다", "~할까요?").

## 용어 약속
- **"위키"**, **"사내 위키"** = Confluence 위키. 스페이스 미지정 시 스타 테크 스페이스 대상.
- **"글로벌 설정"** = `~/.claude/CLAUDE.md` (이 파일)
- **"내 dotfile 푸시해줘"** = `~/dotfiles` repo의 변경사항을 커밋 + 푸시

## Tool Preferences
- MCP 방식 비선호. 가능하면 커스텀 스킬(slash command) + REST API 직접 호출 방식을 사용한다.

## 코드 수정 규칙 (C# 프로젝트 한정)
- C# 프로젝트에서는 코드 수정(Edit/Write)을 실행하기 전에 반드시 사용자에게 변경 내용을 설명하고 승인을 받는다. bypass permissions 모드와 무관하게 항상 적용.
- 조사/탐색/빌드/테스트 등 코드 수정이 아닌 도구 사용은 자유롭게 진행한다.
