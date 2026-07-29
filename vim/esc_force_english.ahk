#NoEnv
#SingleInstance, force
SetBatchLines, -1
DetectHiddenWindows, On

; ─────────────────────────────────────────────────────────────────────────────
; Esc 를 누르면: 원래 Esc 동작 + IME 를 "무조건 영문으로" 설정한다.
;
; [이전 방식이 왜 틀렸나]
;   "지금 한글인지 검사 → 한글이면 한/영 토글키(vk15) 전송" 구조였다.
;   크로스프로세스로 IME 상태를 읽는 유일한 수단은
;   WM_IME_CONTROL(0x283) / IMC_GETCONVERSIONMODE(0x005) 인데,
;   이 값이 창·앱(특히 TSF 기반 Win11 IME)에 따라 실제 상태와 어긋난다.
;   검사가 틀린 상태에서 하는 동작이 하필 '토글'이라, 틀리는 즉시
;   영문인데 한글로 뒤집히거나(사용자 증상) 한글인데 그대로 남는다.
;
; [지금 방식]
;   검사해서 토글하지 않고, 그냥 "영문으로 설정"만 한다.
;   이미 영문이면 아무 일도 일어나지 않으므로(idempotent) 검사가 필요 없고,
;   상태를 잘못 읽어도 결과가 뒤집히지 않는다.
; ─────────────────────────────────────────────────────────────────────────────

$Esc::
    Send, {Esc}
    IME_SetEnglish()
    return

IME_SetEnglish() {
    WinGet, hWnd, ID, A
    if (!hWnd)
        return

    ; 주의: ImmGetContext/ImmSetConversionStatus 는 프로세스 로컬이라
    ;       남의 창에는 쓸 수 없다(핸들이 0으로 돌아옴). 그래서 IME 창에 메시지를 보낸다.
    hIME := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hWnd, "Ptr")
    if (!hIME)
        return

    ; 현재 변환 모드에서 IME_CMODE_NATIVE(0x1) 비트만 끈다 (전각/반각 등 나머지는 보존).
    ; 읽기가 실패해도 0(영문)으로 설정하면 되므로 결과는 항상 영문이다.
    SendMessage, 0x283, 0x005, 0, , ahk_id %hIME%, , , , 300      ; IMC_GETCONVERSIONMODE
    mode := ErrorLevel
    newMode := (mode = "FAIL" || mode = "") ? 0 : (mode & ~1)
    SendMessage, 0x283, 0x006, %newMode%, , ahk_id %hIME%, , , , 300  ; IMC_SETCONVERSIONMODE
    return
}
