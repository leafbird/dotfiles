---
name: smb-openclaw
description: SMB 공유 폴더(\\st-buildwatch)에 접근하여 파일을 읽기/쓰기/목록 조회합니다. Use when the user mentions st-buildwatch, SMB share, build watch, or wants to access shared network files.
argument-hint: [action] [path] [args...]
allowed-tools: Bash, Read, Write
---

# SMB OpenClaw 스킬

`\\st-buildwatch` SMB 공유 폴더에 접근하는 스킬입니다.

## 인증 정보

`~/.claude/credentials.json`의 `smb` 키에서 읽습니다.

## 헬퍼 스크립트

```
SCRIPT=~/.claude/skills/smb-openclaw/smb_client.py
```

## 사용자 요청: $ARGUMENTS

## 환경 제약

### Windows
- UNC 경로(`\\st-buildwatch\...`)에 직접 접근 가능
- 인증이 필요한 경우 `net use` 또는 Python 스크립트 사용

### Linux
- `smbprotocol` 패키지 사용 (순수 Python SMB 클라이언트)
- 스크립트 최초 실행 전: `pip install smbprotocol -q 2>/dev/null`

## 명령어

### ls - 디렉토리 목록 조회
```bash
python3 "$SCRIPT" ls [경로]
```
- 경로 미지정 시 루트(`\\st-buildwatch`) 공유 목록 표시
- 예: `python3 "$SCRIPT" ls "Share/L10nChangeScanner"`

### read - 파일 읽기
```bash
python3 "$SCRIPT" read <경로>
```
- 텍스트 파일 내용을 stdout으로 출력
- 예: `python3 "$SCRIPT" read "Share/L10nChangeScanner/history.json"`

### write - 파일 쓰기
```bash
python3 "$SCRIPT" write <경로> <로컬파일경로>
```
- 로컬 파일을 SMB 경로에 업로드
- 예: `python3 "$SCRIPT" write "Share/output/result.json" /tmp/result.json`

### write-stdin - stdin에서 읽어서 쓰기
```bash
echo '{"data": 1}' | python3 "$SCRIPT" write-stdin <경로>
```
- stdin 내용을 SMB 파일로 저장

### cp - SMB 파일을 로컬로 복사
```bash
python3 "$SCRIPT" cp <SMB경로> <로컬경로>
```

### info - 파일/디렉토리 정보
```bash
python3 "$SCRIPT" info <경로>
```
- 크기, 수정 시간, 타입 등 메타데이터 표시

## 경로 규칙
- SMB 경로는 `\\st-buildwatch` 이후의 상대 경로로 지정
- 예: `ST_Share/Published/Server/Tool` → `\\st-buildwatch\ST_Share\Published\Server\Tool`
- 슬래시(`/`) 사용 가능 (스크립트가 자동 변환)

## 주의사항
- **쓰기 작업 전 반드시 사용자에게 확인받을 것**
- 대용량 파일(10MB+) 읽기 시 경고 출력
- 바이너리 파일 read 시 사이즈 정보만 출력
