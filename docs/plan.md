# Project Plan

This document tracks tasks, progress, and next steps for the project. After each modification or feature addition, update this file with the current status and any changes to the plan.

## Current Goal

프로덕션 강화: PriceFeedProxy 접근제어 추가, Registrar↔Token 연동, 배포/시드 스크립트 완성, 프론트 환경/스캔 링크 정리, 오라클 헬스체크 도입. KYC·민트·소각 테스트 보강 및 커버리지(옵션).

## Task List

- [x] 초기 스캐폴드: Foundry/Go/Svelte 구조 생성
- [x] 도커 컴포즈/환경파일 추가 및 README 갱신
- [x] .gitignore 추가
- [ ] 컨트랙트 구현 보강
  - [ ] Registrar ↔ Token 화이트리스트 연동 및 역할 권한 정리
  - [x] PriceFeedProxy 서명 검증(EIP-712 + OpenZeppelin, round 단조 증가, maxDelay)
  - [x] PriceVerifier(라이브러리/내부 함수) 도입 및 LendingPool 경로에 _verifyPrice() 연동 (Pull-Style)
  - [ ] PriceFeedProxy 접근제어(관리자 롤) 구현 및 테스트(setMaxDelay/setSigner 보호)
  - [ ] 배포/시드 스크립트(Deploy/SeedDemo) 구현 및 환경변수 연동
- [ ] 컨트랙트 테스트 확장(Foundry)
  - [x] PriceFeedProxy EIP-712 서명 검증 테스트(정상/스테일/라운드/사이너/도메인)
  - [x] Lending/Borrow 액션에 오라클 서명 번들 검증(Pull) 성공/실패 케이스 추가
  - [x] Repay/Withdraw 플로우 유닛 테스트(부분상환/초과상환 캡, HF 유지/하락)
  - [ ] KYC/민트/소각 유닛 테스트
  - [x] LTV/HF 경계(직전/직후) 정밀 테스트 및 청산 경로 기본 케이스
  - [x] 오라클 서명/스테일/라운드 재사용 거부 테스트
- [ ] 오라클 서버 구현(Go)
  - [x] .env 로드, 설정 구조화
  - [x] EIP-712 TypedData 서명(도메인: name/version/chainId/contract)
  - [x] GET /price/latest 서명 포함 응답 (스키마 고정)
  - [ ] 컨테이너 헬스체크/로그 보강
- [ ] 프론트 연결(Svelte + viem)
  - [x] 오라클 최신 가격(서명 포함) UI 표시
  - [x] ABI JSON 정리 및 주소/체인 env 주입
  - [x] /price/latest → 서명 번들 포함하여 writeContract(lend/borrow 등) 호출
  - [ ] 스캔 링크 추가, 기본 에러/로딩 상태 보강
- [ ] 배포/운영 준비
  - [ ] 테스트넷 배포 및 주소/스캔 링크 문서화
  - [ ] README 운영 가이드 보강
