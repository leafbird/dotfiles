#!/usr/bin/env python3
"""
카라비너가 무시하고 있는 키보드를 찾아 karabiner.json 에 자동 등록한다.

무선 기계식 키보드 상당수는 키보드이면서 동시에 마우스/포인터로도 HID 등록된다.
카라비너는 포인팅 디바이스를 기본적으로 무시하므로, 이런 키보드는 Devices 탭에서
"Modify events"를 켜주기 전까지 모든 리맵이 통째로 동작하지 않는다.

이 스크립트는 그 체크를 CLI로 대신해준다. 새 키보드를 연결한 뒤 한 번 실행하면 된다.

사용법:
    ./register-keyboards.py            # 등록 실행
    ./register-keyboards.py --dry-run  # 변경 없이 확인만
"""

import argparse
import datetime
import json
import os
import plistlib
import shutil
import subprocess
import sys

CONFIG = os.path.expanduser("~/.config/karabiner/karabiner.json")
BACKUP_DIR = os.path.expanduser("~/.config/karabiner/backups")

# HID usage (page, usage)
USAGE_KEYBOARD = (1, 6)
USAGE_POINTER = (1, 1)
USAGE_MOUSE = (1, 2)


def collect_devices():
    """ioreg 에서 키보드로 동작하는 HID 디바이스를 수집한다."""
    out = subprocess.run(
        ["ioreg", "-r", "-c", "IOHIDDevice", "-a", "-l"],
        capture_output=True,
    )
    if out.returncode != 0 or not out.stdout:
        sys.exit("ioreg 실행 실패")

    def walk(node):
        yield node
        for child in node.get("IORegistryEntryChildren", []) or []:
            yield from walk(child)

    # 같은 기기가 여러 노드로 잡히므로 제품명 기준으로 병합한다.
    devices = {}
    for root in plistlib.loads(out.stdout):
        for node in walk(root):
            pairs = node.get("DeviceUsagePairs")
            product = node.get("Product")
            if not pairs or not product:
                continue

            usages = {
                (p.get("DeviceUsagePage"), p.get("DeviceUsage")) for p in pairs
            }
            if USAGE_KEYBOARD not in usages:
                continue
            # 카라비너가 만드는 가상 키보드는 제외
            if product.startswith("Karabiner DriverKit"):
                continue

            dev = devices.setdefault(
                product,
                {
                    "product": product,
                    "vendor_id": 0,
                    "product_id": 0,
                    "address": None,
                    "transport": None,
                    "is_pointing": False,
                },
            )
            if node.get("VendorID"):
                dev["vendor_id"] = node["VendorID"]
            if node.get("ProductID"):
                dev["product_id"] = node["ProductID"]
            if node.get("DeviceAddress"):
                dev["address"] = node["DeviceAddress"]
            if node.get("Transport"):
                dev["transport"] = node["Transport"]
            if USAGE_MOUSE in usages or USAGE_POINTER in usages:
                dev["is_pointing"] = True

    return sorted(devices.values(), key=lambda d: d["product"])


def identifiers_for(dev):
    """카라비너 devices 항목에 쓸 identifiers 를 만든다.

    vendor/product id 가 있으면 그것으로 식별하고,
    0 인 BLE 기기는 블루투스 주소(device_address)로 식별한다.
    """
    ident = {
        "is_keyboard": True,
        "is_pointing_device": dev["is_pointing"],
        "product_id": dev["product_id"],
        "vendor_id": dev["vendor_id"],
    }
    if dev["vendor_id"] == 0 and dev["product_id"] == 0 and dev["address"]:
        ident["device_address"] = dev["address"]
    return ident


def same_device(existing, ident):
    """이미 등록된 항목인지 비교한다."""
    if "device_address" in ident:
        return existing.get("device_address") == ident["device_address"]
    return (
        existing.get("vendor_id") == ident["vendor_id"]
        and existing.get("product_id") == ident["product_id"]
    )


def main():
    parser = argparse.ArgumentParser(
        description="카라비너가 무시 중인 키보드를 찾아 자동 등록한다."
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="변경 없이 확인만 한다"
    )
    args = parser.parse_args()

    if not os.path.exists(CONFIG):
        sys.exit(f"설정 파일이 없다: {CONFIG}")

    with open(CONFIG) as f:
        config = json.load(f)

    devices = collect_devices()
    if not devices:
        sys.exit("키보드를 찾지 못했다.")

    added = []
    fixed = []

    for dev in devices:
        label = f"{dev['product']} ({dev['transport'] or 'unknown'})"

        if not dev["is_pointing"]:
            print(f"  [건너뜀] {label}")
            print("           키보드로만 인식되어 기본적으로 리맵이 적용된다.")
            continue

        ident = identifiers_for(dev)

        for profile in config.get("profiles", []):
            entries = profile.setdefault("devices", [])
            match = next(
                (
                    e
                    for e in entries
                    if same_device(e.get("identifiers", {}), ident)
                ),
                None,
            )
            if match is None:
                entries.append({"identifiers": ident, "ignore": False})
                added.append((label, profile.get("name", "?")))
            elif match.get("ignore"):
                match["ignore"] = False
                fixed.append((label, profile.get("name", "?")))

        if not any(label == a[0] for a in added + fixed):
            print(f"  [이미 등록됨] {label}")

    for label, profile in added:
        print(f"  [추가] {label}  → 프로필 '{profile}'")
    for label, profile in fixed:
        print(f"  [수정] {label}  → 프로필 '{profile}' (ignore 해제)")

    if not added and not fixed:
        print("\n변경할 내용이 없다.")
        return

    if args.dry_run:
        print("\n--dry-run 이므로 저장하지 않았다.")
        return

    os.makedirs(BACKUP_DIR, exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = os.path.join(BACKUP_DIR, f"karabiner-{stamp}.json")
    shutil.copy2(CONFIG, backup)

    with open(CONFIG, "w") as f:
        json.dump(config, f, indent=4, ensure_ascii=False)
        f.write("\n")

    print(f"\n저장했다. 백업: {backup}")
    print("카라비너가 자동으로 설정을 다시 읽는다. 바로 키를 눌러 확인하면 된다.")


if __name__ == "__main__":
    main()
