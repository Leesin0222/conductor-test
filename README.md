# Perth 🐱

macOS 메뉴바에 사는 보안 펫 앱. 클립보드를 실시간 감시하여 민감한 개인정보가 감지되면 펫이 경고해줍니다.

## 감지 패턴

| 패턴 | 예시 |
|------|------|
| API 키 | AWS, GitHub, Slack, Google, OpenAI 토큰 |
| 비밀번호 | `password=`, `secret=` 등 |
| 개인 키 | RSA, SSH, PGP 프라이빗 키 |
| 신용카드 | Luhn 검증 포함 13-19자리 |
| 주민등록번호 | 체크섬 검증 포함 |
| 이메일+비밀번호 | `email:password` 조합 |
| JWT 토큰 | `eyJ...` 형식 |
| 접속 문자열 | JDBC, MongoDB, PostgreSQL URI 등 |

## 빌드 & 실행

```bash
# 빌드
swift build

# 직접 실행
swift run Perth

# .app 번들 생성
make bundle
open .build/Perth.app
```

## 요구사항

- macOS 14.0+
- Swift 5.9+

## 사용법

1. 앱을 실행하면 메뉴바에 🐱 아이콘이 나타납니다
2. 클립보드에 민감한 정보를 복사하면 🙀로 변하며 알림을 보냅니다
3. 메뉴바 아이콘을 클릭하면 펫 상태와 최근 알림을 확인할 수 있습니다
4. 설정에서 감시 주기와 감지 패턴을 조절할 수 있습니다
