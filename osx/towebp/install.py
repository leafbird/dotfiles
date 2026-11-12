#!/usr/bin/env python3
"""towebp 의 Finder 빠른 동작과 Dock 용 앱(WebP 변환.app)을 만든다. 재실행하면 덮어쓴다."""
import os, plistlib, shutil, subprocess, uuid
from pathlib import Path

HERE = Path(__file__).resolve().parent
HOME = Path.home()
TEMPLATE_ACTION_ARGS = [
    ("inputMethod", 0), ("CheckedForUserDefaultShell", False), ("source", ""),
    ("COMMAND_STRING", ""), ("shell", "/bin/sh"),
]


def shell_action(command):
    u = lambda: str(uuid.uuid4()).upper()
    return {
        "action": {
            "AMAccepts": {"Container": "List", "Optional": True, "Types": ["com.apple.cocoa.path"]},
            "AMActionVersion": "2.0.3",
            "AMApplication": ["Automator"],
            "AMParameterProperties": {k: {} for k, _ in TEMPLATE_ACTION_ARGS},
            "AMProvides": {"Container": "List", "Types": ["com.apple.cocoa.string"]},
            "ActionBundlePath": "/System/Library/Automator/Run Shell Script.action",
            "ActionName": "Run Shell Script",
            "ActionParameters": {
                "COMMAND_STRING": command, "CheckedForUserDefaultShell": True,
                "inputMethod": 1, "shell": "/bin/zsh", "source": "",
            },
            "BundleIdentifier": "com.apple.RunShellScript",
            "CFBundleVersion": "2.0.3",
            "CanShowSelectedItemsWhenRun": False,
            "CanShowWhenRun": True,
            "Category": ["AMCategoryUtilities"],
            "Class Name": "RunShellScriptAction",
            "InputUUID": u(), "OutputUUID": u(), "UUID": u(),
            "UnlocalizedApplications": ["Automator"],
            "arguments": {
                str(i): {"default value": d, "name": n, "required": "0", "type": "0", "uuid": str(i)}
                for i, (n, d) in enumerate(TEMPLATE_ACTION_ARGS)
            },
            "isViewVisible": 1,
            "nibPath": "/System/Library/Automator/Run Shell Script.action/Contents/Resources/Base.lproj/main.nib",
        },
        "isViewVisible": 1,
    }


def wflow(command, meta):
    return {
        "AMApplicationBuild": "534", "AMApplicationVersion": "2.10", "AMDocumentVersion": "2",
        "actions": [shell_action(command)], "connectors": {}, "workflowMetaData": meta,
    }


def install_quick_action():
    path = HOME / "Library/Services/WebP로 변환.workflow"
    shutil.rmtree(path, ignore_errors=True)
    (path / "Contents").mkdir(parents=True)
    meta = {
        "applicationBundleID": "com.apple.finder",
        "applicationBundleIDsByPath": {"/System/Library/CoreServices/Finder.app": "com.apple.finder"},
        "applicationPath": "/System/Library/CoreServices/Finder.app",
        "applicationPaths": ["/System/Library/CoreServices/Finder.app"],
        "inputTypeIdentifier": "com.apple.Automator.fileSystemObject.image",
        "outputTypeIdentifier": "com.apple.Automator.nothing",
        "presentationMode": 15, "processesInput": False,
        "serviceApplicationBundleID": "com.apple.finder",
        "serviceApplicationPath": "/System/Library/CoreServices/Finder.app",
        "serviceInputTypeIdentifier": "com.apple.Automator.fileSystemObject.image",
        "serviceOutputTypeIdentifier": "com.apple.Automator.nothing",
        "serviceProcessesInput": False,
        "systemImageName": "NSActionTemplate",
        "useAutomaticInputType": False,
        "workflowTypeIdentifier": "com.apple.Automator.servicesMenu",
    }
    cmd = f'"{HERE}/towebp-gui" "$@"'
    plistlib.dump(wflow(cmd, meta), open(path / "Contents/document.wflow", "wb"))
    plistlib.dump({"NSServices": [{
        "NSMenuItem": {"default": "WebP로 변환"},
        "NSMessage": "runWorkflowAsService",
        "NSRequiredContext": {"NSApplicationIdentifier": "com.apple.finder"},
        "NSSendFileTypes": ["public.image"],
        "NSIconName": "NSActionTemplate",
    }]}, open(path / "Contents/Info.plist", "wb"))
    return path


def install_app():
    path = HOME / "Applications/WebP 변환.app"
    shutil.rmtree(path, ignore_errors=True)
    path.parent.mkdir(exist_ok=True)
    # copytree/ditto 는 시스템 파일의 restricted 플래그까지 옮기려다 EPERM 이 난다. 평범한 cp 로 복사.
    subprocess.run(["cp", "-R", "/System/Library/CoreServices/Automator Application Stub.app", str(path)], check=True)
    shutil.rmtree(path / "Contents/_CodeSignature", ignore_errors=True)
    meta = {
        "applicationBundleIDsByPath": {}, "applicationPaths": [],
        "inputTypeIdentifier": "com.apple.Automator.fileSystemObject",
        "outputTypeIdentifier": "com.apple.Automator.nothing",
        "presentationMode": 15, "processesInput": False,
        "useAutomaticInputType": False,
        "workflowTypeIdentifier": "com.apple.Automator.application",
    }
    cmd = f'"{HERE}/towebp-gui" -o "$HOME/Downloads/WebP" "$@"'
    plistlib.dump(wflow(cmd, meta), open(path / "Contents/document.wflow", "wb"))
    info_path = path / "Contents/Info.plist"
    info = plistlib.load(open(info_path, "rb"))
    info.update({
        "CFBundleIdentifier": "local.leafbird.towebp",
        "CFBundleName": "WebP 변환",
        "CFBundleDocumentTypes": [{
            "CFBundleTypeName": "Image", "CFBundleTypeRole": "Viewer",
            "LSHandlerRank": "Alternate", "LSItemContentTypes": ["public.image"],
        }],
    })
    plistlib.dump(info, open(info_path, "wb"))
    subprocess.run(["codesign", "--force", "--deep", "--sign", "-", str(path)], check=True)
    subprocess.run(["/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister", "-f", str(path)], check=True)
    return path


if __name__ == "__main__":
    for p in (install_quick_action(), install_app()):
        print("installed:", p)
    subprocess.run(["/System/Library/CoreServices/pbs", "-update"])
