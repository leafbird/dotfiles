# towebp

사진을 메신저 공유용 WebP 로 바꾼다. 긴 변 2048px, 품질 80, sRGB 변환, 메타데이터(위치 등) 제거. `cwebp` 필요(`brew install webp`).

- `towebp [-s 긴변] [-q 품질] [-o 폴더] 파일...` — CLI. `~/.local/bin/towebp` 로 심링크.
- `python3 install.py` — 아래 두 가지를 설치(재실행하면 덮어씀).
  - **WebP 변환.app** (`~/Applications`, Dock 에 두고 씀)
    - 사진 앱에서 사진 선택 → Dock 아이콘 클릭: 선택한 사진을 내보내 변환
    - 사진/파일을 Dock 아이콘에 드래그: 드롭한 것 변환
    - 결과는 `~/Downloads/WebP`
  - **WebP로 변환** 빠른 동작 — Finder 에서 이미지 우클릭 > 빠른 동작. 결과는 원본 옆.
- 어느 쪽이든 끝나면 결과 파일이 클립보드에 들어가고(메신저에서 Cmd+V) Finder 에서 선택된다.
