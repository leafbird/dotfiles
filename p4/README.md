# p4 / P4V 커스텀 툴

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

1. P4V 메뉴: **Tools → Manage Custom Tools... → Import Custom Tools...**
2. 이 폴더의 `customtools.xml` 선택.
3. Submitted 탭/Submitted 패널에서 CL 우클릭하면 메뉴에 **슬랙 공유 포맷** 등장.

> P4V 가 이미 다른 커스텀 툴을 갖고 있다면 import 가 기존 정의를
> 덮어쓸 수 있으니, `%USERPROFILE%\.p4qt\customtools.xml` 을 백업한 뒤
> 머지하는 편이 안전하다.

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
