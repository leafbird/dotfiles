# p4 / P4V 커스텀 툴

현재 등록된 컨텍스트 메뉴:

- **슬랙 공유 포맷** — submitted CL 정보를 ``` 로 감싸 클립보드 복사.
- **Jira 이슈 열기** — CL description 에서 `NF-####` 키를 찾아 Jira 브라우저로 점프.

## 설치

**P4V 를 종료한 상태에서** 아래 한 줄을 PowerShell 에 붙여넣습니다.

```powershell
irm https://raw.githubusercontent.com/leafbird/dotfiles/main/p4/install.ps1 | iex
```

이 repo 를 이미 클론해 뒀다면 그 폴더에서 직접 실행해도 됩니다.

```powershell
.\install.ps1
```

설치가 끝나면 P4V 를 켜고 Submitted CL 을 우클릭하면 두 메뉴가 보입니다.

### install.ps1 이 해주는 것

- **머지** — 기존 커스텀 툴은 그대로 두고 같은 이름의 항목만 갈아끼웁니다.
  P4V 의 `Import Custom Tools...` 는 **전체를 덮어쓰므로** 쓰던 툴이 날아갑니다.
- **멱등** — 이미 올바로 등록돼 있으면 파일을 아예 건드리지 않습니다. 몇 번을
  돌려도 결과가 같습니다. 스크립트를 다른 폴더로 옮겼을 때 다시 돌리면 경로만
  갱신됩니다.
- **경로 자동 결정** — `.ps1` 절대경로를 그 머신 기준으로 박아 넣습니다. 클론해
  뒀으면 그 폴더를, 웹에서 바로 실행했으면 `%USERPROFILE%\.p4tools` 로 받아서
  그쪽을 가리킵니다.
- **백업** — 실제로 내용을 바꿀 때만 `customtools.xml.bak` 을 남깁니다.
- **점검** — `p4.exe` 가 PATH 에 있는지, `P4CHARSET` 이 `utf8` 인지 확인해 경고합니다.

### P4V 는 반드시 닫고

P4V 는 `customtools.xml` 을 **시작할 때 읽고 종료할 때 되씁니다.** 켜둔 채로 설치하면
P4V 를 닫는 순간 예전 내용으로 덮여 설치가 조용히 사라집니다. 스크립트가 이걸 검사해
P4V 가 떠 있으면 멈춥니다. `-Force` 로 넘길 수는 있지만 그 뒤엔 P4V 를 재시작해야 합니다.

### 옵션

| 옵션 | 뜻 |
|---|---|
| `-SourceDir <경로>` | `.ps1` 을 여기서 가져다 씁니다. 생략하면 자동 판단 |
| `-ToolsDir <경로>` | 웹에서 받을 때 놓을 위치. 기본 `%USERPROFILE%\.p4tools` |
| `-CustomToolsPath <경로>` | P4V 정의 파일. 기본 `%USERPROFILE%\.p4qt\customtools.xml` |
| `-Force` | P4V 가 떠 있어도 진행 |

### 손으로 넣으려면

`customtools.xml` 을 P4V 의 **Tools → Manage Custom Tools... → Import Custom Tools...**
로 넣을 수도 있습니다. 단 위에 적은 대로 **기존 커스텀 툴이 덮어써지고**, `Arguments`
안의 `.ps1` 절대경로를 그 머신에 맞게 손으로 고쳐야 합니다.

> ⚠ `%USERPROFILE%` 같은 환경변수는 쓸 수 없습니다. P4V 가 `%U` 를 자기 치환 토큰으로
> 오해해 `%c` 와 충돌하고, "More than one replaceable file argument of type %X is not
> allowed" 에러로 실행을 거부합니다. 반드시 절대경로여야 하며, 그래서 install.ps1 이
> 설치 시점에 경로를 박아 넣습니다.

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
