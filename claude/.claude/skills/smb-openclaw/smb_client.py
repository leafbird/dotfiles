#!/usr/bin/env python3
"""SMB OpenClaw - \\\\st-buildwatch SMB 공유 폴더 접근 클라이언트."""

import json
import os
import platform
import sys
from pathlib import Path

CREDENTIALS_PATH = os.path.join(os.path.expanduser("~"), ".claude", "credentials.json")
SMB_SERVER = "st-buildwatch"


def load_credentials():
    with open(CREDENTIALS_PATH, "r", encoding="utf-8") as f:
        creds = json.load(f)
    smb = creds.get("smb")
    if not smb:
        print("Error: credentials.json에 'smb' 키가 없습니다.", file=sys.stderr)
        print(f"  파일 위치: {CREDENTIALS_PATH}", file=sys.stderr)
        print('  필요한 형식: "smb": {"username": "...", "password": "...", "domain": "..."}', file=sys.stderr)
        sys.exit(1)
    return smb


def is_windows():
    return platform.system() == "Windows"


# ---------------------------------------------------------------------------
# Windows: UNC 경로 직접 접근
# ---------------------------------------------------------------------------

def unc_path(rel_path):
    """상대 경로를 UNC 경로로 변환."""
    rel_path = rel_path.replace("/", "\\")
    return f"\\\\{SMB_SERVER}\\{rel_path}"


def win_ls(rel_path):
    target = unc_path(rel_path) if rel_path else f"\\\\{SMB_SERVER}"
    p = Path(target)
    if not p.exists():
        print(f"Error: 경로를 찾을 수 없습니다: {target}", file=sys.stderr)
        sys.exit(1)
    for item in sorted(p.iterdir()):
        kind = "DIR " if item.is_dir() else "FILE"
        size = ""
        if item.is_file():
            size = f"  ({item.stat().st_size:,} bytes)"
        print(f"  {kind}  {item.name}{size}")


def win_read(rel_path):
    target = unc_path(rel_path)
    p = Path(target)
    if not p.exists():
        print(f"Error: 파일을 찾을 수 없습니다: {target}", file=sys.stderr)
        sys.exit(1)
    size = p.stat().st_size
    if size > 10 * 1024 * 1024:
        print(f"Warning: 대용량 파일 ({size:,} bytes)", file=sys.stderr)
    try:
        print(p.read_text(encoding="utf-8"))
    except UnicodeDecodeError:
        print(f"[바이너리 파일] 크기: {size:,} bytes", file=sys.stderr)
        sys.exit(1)


def win_write(rel_path, local_path):
    target = unc_path(rel_path)
    content = Path(local_path).read_bytes()
    Path(target).parent.mkdir(parents=True, exist_ok=True)
    Path(target).write_bytes(content)
    print(f"OK: {len(content):,} bytes -> {target}")


def win_write_stdin(rel_path):
    target = unc_path(rel_path)
    content = sys.stdin.buffer.read()
    Path(target).parent.mkdir(parents=True, exist_ok=True)
    Path(target).write_bytes(content)
    print(f"OK: {len(content):,} bytes -> {target}")


def win_cp(rel_path, local_path):
    target = unc_path(rel_path)
    import shutil
    shutil.copy2(target, local_path)
    print(f"OK: {target} -> {local_path}")


def win_info(rel_path):
    target = unc_path(rel_path)
    p = Path(target)
    if not p.exists():
        print(f"Error: 경로를 찾을 수 없습니다: {target}", file=sys.stderr)
        sys.exit(1)
    stat = p.stat()
    from datetime import datetime
    print(f"경로: {target}")
    print(f"타입: {'디렉토리' if p.is_dir() else '파일'}")
    print(f"크기: {stat.st_size:,} bytes")
    print(f"수정: {datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S')}")


# ---------------------------------------------------------------------------
# Linux: smbprotocol 사용
# ---------------------------------------------------------------------------

def ensure_smbprotocol():
    try:
        import smbclient  # noqa: F401
    except ImportError:
        print("smbprotocol 패키지 설치 중...", file=sys.stderr)
        os.system(f"{sys.executable} -m pip install smbprotocol -q")
        import smbclient  # noqa: F401


def smb_register(creds):
    import smbclient
    smbclient.register_session(
        SMB_SERVER,
        username=creds.get("username", ""),
        password=creds.get("password", ""),
    )


def smb_full_path(rel_path):
    rel_path = rel_path.replace("\\", "/")
    return f"\\\\{SMB_SERVER}\\{rel_path}"


def linux_ls(rel_path, creds):
    ensure_smbprotocol()
    import smbclient
    smb_register(creds)

    target = smb_full_path(rel_path) if rel_path else f"\\\\{SMB_SERVER}"

    if not rel_path:
        # 공유 목록 표시
        shares = smbclient.listdir(f"\\\\{SMB_SERVER}\\")
        for name in sorted(shares):
            if not name.startswith("."):
                print(f"  SHARE  {name}")
        return

    for item in sorted(smbclient.listdir(target)):
        if item in (".", ".."):
            continue
        full = f"{target}\\{item}"
        try:
            stat = smbclient.stat(full)
            import stat as stat_module
            is_dir = stat_module.S_ISDIR(stat.st_mode)
            kind = "DIR " if is_dir else "FILE"
            size = "" if is_dir else f"  ({stat.st_size:,} bytes)"
            print(f"  {kind}  {item}{size}")
        except Exception:
            print(f"  ????  {item}")


def linux_read(rel_path, creds):
    ensure_smbprotocol()
    import smbclient
    smb_register(creds)

    target = smb_full_path(rel_path)
    stat = smbclient.stat(target)
    if stat.st_size > 10 * 1024 * 1024:
        print(f"Warning: 대용량 파일 ({stat.st_size:,} bytes)", file=sys.stderr)

    with smbclient.open_file(target, mode="r", encoding="utf-8") as f:
        print(f.read())


def linux_write(rel_path, local_path, creds):
    ensure_smbprotocol()
    import smbclient
    smb_register(creds)

    target = smb_full_path(rel_path)
    content = Path(local_path).read_bytes()

    with smbclient.open_file(target, mode="wb") as f:
        f.write(content)
    print(f"OK: {len(content):,} bytes -> {target}")


def linux_write_stdin(rel_path, creds):
    ensure_smbprotocol()
    import smbclient
    smb_register(creds)

    target = smb_full_path(rel_path)
    content = sys.stdin.buffer.read()

    with smbclient.open_file(target, mode="wb") as f:
        f.write(content)
    print(f"OK: {len(content):,} bytes -> {target}")


def linux_cp(rel_path, local_path, creds):
    ensure_smbprotocol()
    import smbclient
    smb_register(creds)

    target = smb_full_path(rel_path)
    with smbclient.open_file(target, mode="rb") as src:
        Path(local_path).write_bytes(src.read())
    print(f"OK: {target} -> {local_path}")


def linux_info(rel_path, creds):
    ensure_smbprotocol()
    import smbclient
    import stat as stat_module
    smb_register(creds)

    target = smb_full_path(rel_path)
    stat = smbclient.stat(target)
    from datetime import datetime

    print(f"경로: {target}")
    print(f"타입: {'디렉토리' if stat_module.S_ISDIR(stat.st_mode) else '파일'}")
    print(f"크기: {stat.st_size:,} bytes")
    print(f"수정: {datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S')}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def usage():
    print("Usage: smb_client.py <command> [args...]")
    print()
    print("Commands:")
    print("  ls [path]                    디렉토리 목록")
    print("  read <path>                  파일 읽기")
    print("  write <smb_path> <local>     파일 쓰기")
    print("  write-stdin <smb_path>       stdin -> SMB 파일")
    print("  cp <smb_path> <local>        SMB -> 로컬 복사")
    print("  info <path>                  파일/디렉토리 정보")
    sys.exit(1)


def main():
    if len(sys.argv) < 2:
        usage()

    cmd = sys.argv[1]

    if is_windows():
        # Windows: UNC 직접 접근 (인증 불요 시 credentials 로드 안 함)
        if cmd == "ls":
            win_ls(sys.argv[2] if len(sys.argv) > 2 else "")
        elif cmd == "read":
            win_read(sys.argv[2])
        elif cmd == "write":
            win_write(sys.argv[2], sys.argv[3])
        elif cmd == "write-stdin":
            win_write_stdin(sys.argv[2])
        elif cmd == "cp":
            win_cp(sys.argv[2], sys.argv[3])
        elif cmd == "info":
            win_info(sys.argv[2])
        else:
            usage()
    else:
        # Linux: smbprotocol 사용
        creds = load_credentials()
        if cmd == "ls":
            linux_ls(sys.argv[2] if len(sys.argv) > 2 else "", creds)
        elif cmd == "read":
            linux_read(sys.argv[2], creds)
        elif cmd == "write":
            linux_write(sys.argv[2], sys.argv[3], creds)
        elif cmd == "write-stdin":
            linux_write_stdin(sys.argv[2], creds)
        elif cmd == "cp":
            linux_cp(sys.argv[2], sys.argv[3], creds)
        elif cmd == "info":
            linux_info(sys.argv[2], creds)
        else:
            usage()


if __name__ == "__main__":
    main()
