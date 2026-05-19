# p4 / P4V 커스텀 툴

현재 등록된 컨텍스트 메뉴:

- **슬랙 공유 포맷** — submitted CL 정보를 ``` 로 감싸 클립보드 복사.
- **Jira 이슈 열기** — CL description 에서 `NF-####` 키를 찾아 Jira 브라우저로 점프.

## 슬랙 공유 포맷 (slack-share)

Submitted changelist 우클릭 컨텍스트 메뉴에서 한 번에 슬랙용 포맷을
클립보드로 복사한다.

### 출력 예시

```
Change: 69462
Date: 2026-05-19 PM 1:23
User: choisungki
Description:
[최성기] 서버 단위테스트 실패 수정
- 탈것 유닛테스트 로직 넣으면서 기존 순차발급 id의 순서가 밀려나서 ...
```

### 설치

1. `customtools.xml` 의 **Arguments 안 .ps1 절대경로** 를 현재 머신에 맞게 수정.
   - 기본값은 `C:\Users\choisungki\dotfiles\p4\slack-share.ps1`.
   - 사용자명이나 dotfiles 위치가 다르면 그에 맞춰 통째로 바꿔야 한다.
   - ⚠ **`%USERPROFILE%` 같은 환경변수는 못 쓴다.** P4V 가 `%U` 를 자기 치환
     토큰으로 오해해서 `%c` 와 충돌, "More than one replaceable file argument
     of type %X is not allowed" 에러로 실행 거부됨. 반드시 절대경로.
2. P4V 메뉴: **Tools → Manage Custom Tools... → Import Custom Tools...**
3. 수정한 `customtools.xml` 선택.
4. Submitted 탭/Submitted 패널에서 CL 우클릭하면 메뉴에 **슬랙 공유 포맷** 등장.

> P4V 가 이미 다른 커스텀 툴을 갖고 있다면 import 가 기존 정의를
> 덮어쓸 수 있으니, `%USERPROFILE%\.p4qt\customtools.xml` 을 백업한 뒤
> 머지하는 편이 안전하다. (이 경로 표기는 위 절대경로 규칙과 무관 —
> Windows 탐색기/PowerShell 에서는 `%USERPROFILE%` 가 정상 해석된다.)

### 동작

- `p4 -C utf8 change -o <CL>` 로 spec 받아 User/Date/Description 파싱.
- Date 는 `YYYY/MM/DD HH:MM:SS` → `YYYY-MM-DD PM H:MM` 으로 변환.
- ``` 로 감싼 텍스트를 `Set-Clipboard` 로 복사.

### 트러블슈팅

- 한글 깨짐: `p4 set P4CHARSET=utf8` 확인.
- 메뉴에 안 보임: P4V 의 Manage Custom Tools 다이얼로그에서
  **Add to applicable context menus** 체크 확인.
- PowerShell 창이 깜빡: `-WindowStyle Hidden` 으로 막아두었지만 일부 환경에서
  잠깐 보일 수 있다. `pwsh.exe` 가 있다면 `powershell.exe` 대신 써도 OK.

## Jira 이슈 열기 (jira-open)

선택한 CL 의 description 에서 첫 번째 `NF-\d+` 패턴을 찾아
`https://madngine.atlassian.net/browse/NF-####` 를 기본 브라우저로 연다.
패턴이 없으면 안내 메시지박스 표시.

- 스크립트: [`jira-open.ps1`](jira-open.ps1)
- Jira 인스턴스 호스트가 바뀌면 스크립트의 URL 상수만 수정.
