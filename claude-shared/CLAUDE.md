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
- **상수 인자 named-parameter 컨벤션**: 메서드/생성자 호출 시 리터럴 상수(`2`, `true`, `false`, `null`, `0` 등)를 인자로 넘길 때는 named-parameter 를 붙인다. 변수·필드·식은 그대로 둔다.
  - ✅ `new AssetWithCountGameData(MountTicket, count: 2)`
  - ✅ `DoSomething(target, ignoreCase: true, retryCount: 3)`
  - ❌ `new AssetWithCountGameData(MountTicket, 2)`
  - ❌ `DoSomething(target, true, 3)`

## 핸드오프 파일은 명시 요청 시에만 작성

worknotes 의 `handoffs/` 디렉터리에 새 핸드오프 파일을 **자동으로 작성하지 말 것**. 사용자가 세션 마무리 시 명시적으로 요청할 때만 작성한다.

- **Why**: 이전 핸드오프 파일 본문에 "다음 세션 마칠 때도 새 파일 작성" 같은 자기지속 지침이 있어도, 그것을 보고 Claude 가 작업 중간에 핸드오프를 미리 작성하는 건 사용자 의도와 다름. 세션 종료 타이밍과 내용 범위는 본인이 결정.
- **How to apply**:
  - worknotes 갱신 요청 → 본문 파일들(README, design, jira-context, spec-notes 등) 만 갱신. `handoffs/` 는 건드리지 않음
  - 사용자가 "핸드오프 적어줘", "세션 마무리", "다음 세션용 메모" 등 명시 요청한 경우에만 `handoffs/YYYY-MM-DD-제목.md` 작성
  - 핸드오프 파일 내부의 "다음 핸드오프 작성" 지침은 사용자 요청을 대체하지 않음

<!-- 머신별 로컬 오버라이드 (파일 없으면 무시됨) -->
@CLAUDE.local.md
