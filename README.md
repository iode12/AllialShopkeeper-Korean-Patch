# AllialShopkeeper 한글 대사 패치

Slay the Spire 2의 [신비한 백발 여상인 모드](https://steamcommunity.com/sharedfiles/filedetails/?id=3802714533)에서 상인 16개, 가짜 상인 28개, 총 **44개 대사**를 한글로 표시하는 비공식 패치입니다.

## 다운로드

**[한글 패치 ZIP 다운로드](https://github.com/iode12/AllialShopkeeper-Korean-Patch/releases/latest/download/AllialShopkeeper_Korean_Patch.zip)**

[릴리스 페이지](https://github.com/iode12/AllialShopkeeper-Korean-Patch/releases/latest)에서 `AllialShopkeeper_Korean_Patch.zip`을 선택해도 됩니다.

## 설치 방법

1. 원본 모드 **0.1.0**과 원본 모드에 필요한 의존 모드를 설치합니다.
2. 게임을 완전히 종료합니다.
3. 패치 ZIP의 파일을 모두 같은 폴더에 압축 해제합니다.
4. **Apply-Korean.cmd**를 실행합니다.
5. 파일 선택 창에서 자신의 모드 폴더 안에 있는 **AllialShopkeeper.pck**를 선택합니다.
6. `SUCCESS: 44 Korean dialogue lines installed.`가 표시되면 게임을 한국어로 실행합니다.

Steam 창작마당 설치 파일은 일반적으로 다음 위치에 있습니다.

```text
[Steam 설치 폴더 또는 SteamLibrary]\steamapps\workshop\content\2868840\3802714533\AllialShopkeeper.pck
```

드라이브와 설치 위치가 달라도 직접 파일을 선택하면 됩니다. Windows 기본 PowerShell을 사용하며 Python이나 Node.js는 필요하지 않습니다.

## 백업 및 복구

패치 시 같은 폴더에 `AllialShopkeeper.pck.original-backup`으로 원본을 자동 백업합니다. 기존 백업은 덮어쓰지 않습니다.

복구하려면 게임을 종료한 뒤 백업 파일을 복사하여 이름을 `AllialShopkeeper.pck`로 바꾸고 모드의 PCK를 덮어쓰세요.

이전에 배포한 초기 한글 패치를 적용했다면 원본 백업을 유지한 상태에서 이 패치를 다시 실행하면 됩니다. 이미 최신 패치가 적용된 경우 중복 설치를 건너뜁니다.

## 지원 범위

- 대상: 창작마당 ID `3802714533`, 원본 모드 버전 `0.1.0`.
- 번역: 상인·가짜 상인의 모드 대사 44개.
- 음성과 DLL에 포함된 중국어 설정 메뉴는 번역하지 않습니다.
- 원본 파일과 결과 파일의 SHA-256을 확인하며, 지원하지 않는 버전에는 적용하지 않습니다.
- 모드 업데이트·재다운로드 후에는 번역이 풀릴 수 있습니다.
- 대사 키, 효과 태그, PCK 리소스 무결성과 설치 과정을 검사했습니다. 실제 게임 화면에서의 표시는 아직 확인하지 못했습니다.

## 파일 구성

- `events.json`, `merchant_room.json`: 번역 데이터.
- `Apply-Korean.cmd`, `Apply-Korean.ps1`: 적용 스크립트.
- `README_KO.txt`: 한국어 안내문.
- `AllialShopkeeper_Korean_Patch.zip`: 위 파일을 묶은 배포용 압축파일.

원본 모드의 PCK·DLL·이미지·음성은 포함하지 않습니다. 원본 모드는 별도로 설치해야 합니다.

원본 모드 제작: 叨叨丸 & no-nonsense. 이 저장소는 원본 제작자의 공식 배포물이 아닙니다.

ZIP SHA-256: `5a66f857f3fd140e88f8b1c5e744bab3be3c9479cf326bf47ab4a536c296b709`

