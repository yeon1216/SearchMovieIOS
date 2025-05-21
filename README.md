# SearchMovie

영화 검색 iOS 애플리케이션입니다.

## 기능

- OMDB API를 활용한 영화 검색
- 영화 상세 정보 조회
- 즐겨찾기 기능

## 프로젝트 정보
- **Xcode**: 16.02
- **Swift**: 6.1
- **Deployment Target**: iOS 16.0

## 시작하기

### 설치 방법

1. 저장소를 클론합니다.
```bash
git clone https://github.com/yeon1216/SearchMovieIOS.git
```

2. 프로젝트를 Xcode에서 엽니다.

3. API 키 설정
   - `SearchMovie/Data/Config/AppConfig.swift` 파일을 엽니다.
   - OMDB API 키를 발급받습니다 (https://www.omdbapi.com/apikey.aspx)
   - `AppConfig.API.key`에 발급받은 API 키를 입력합니다.

4. 프로젝트를 빌드하고 실행합니다.

## 프로젝트 소개
OMDB API를 활용한 영화 검색 및 즐겨찾기 iOS 앱입니다.

## 주요 기능
### 검색 탭
- 영화 검색
- 2열 그리드 형태의 영화 목록
- 무한 스크롤
- 즐겨찾기 추가/제거

### 즐겨찾기 탭
- 즐겨찾기 영화 목록
- 즐겨찾기 제거

## 기술 스택
- **UI**: SwiftUI
- **아키텍처**: MVVM + Clean Architecture
- **비동기**: Combine, Swift Concurrency (async/await)
- **API**: OMDB API

## 프로젝트 구조
```
SearchMovie/
├── Presentation/  # UI 관련
├── Domain/        # 비즈니스 로직
├── Data/          # 데이터 처리
└── Resource/      # 리소스 파일
```


## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

