# Project Plan

This document tracks tasks, progress, and next steps for the project. After each modification or feature addition, update this file with the current status and any changes to the plan.

## Current Goal

스캐폴드에서 기능 구현 단계로 전환하여 컨트랙트/오라클/프론트를 실제 동작 수준으로 완성하고, 테스트/도커 환경을 정리해 데모 가능 상태로 만든다.

## Task List

- [x] 초기 스캐폴드: Foundry/Go/Svelte 구조 생성
- [x] 도커 컴포즈/환경파일 추가 및 README 갱신
- [x] .gitignore 추가
- [ ] 컨트랙트 구현 보강
  - [ ] Registrar ↔ Token 화이트리스트 연동 및 역할 권한 정리
  - [ ] PriceFeedProxy 서명 검증(ecrecover, 도메인 분리, round 단조, maxDelay)
  - [ ] LendingPool 이벤트/가드/정밀도 정리 및 기본 흐름 안정화
  - [ ] 배포/시드 스크립트(Deploy/SeedDemo) 구현 및 환경변수 연동
- [ ] 컨트랙트 테스트 확장(Foundry)
  - [ ] KYC/민트/소각 유닛 테스트
  - [ ] LTV/HF 경계(직전/직후), 청산 경로 테스트
  - [ ] 오라클 서명/스테일/라운드 재사용 거부 테스트
  - [ ] 가스리포트/커버리지 및 verbose 출력 확인
- [ ] 오라클 서버 구현(Go)
  - [ ] .env 로드(개발 전용), 설정 구조화
  - [ ] secp256k1 ECDSA 서명(keccak(abi.encode(...))) 구현
  - [ ] Deviation/Heartbeat 정책 + 온체인 submit 연동(재시도/백오프)
  - [ ] GET /price/latest 서명 포함 응답
  - [ ] 컨테이너 헬스체크/로그 보강
- [ ] 프론트 연결(Svelte + viem)
  - [ ] ABI JSON 정리 및 주소/체인 env 주입
  - [ ] readContract/writeContract로 borrow/repay/deposit/liq 플로우 연결
  - [ ] 스캔 링크, 기본 에러/로딩 상태 처리
  - [ ] (옵션) 지갑 UI(Web3Modal/Onboard 중 택1)
- [ ] 배포/운영 준비
  - [ ] 테스트넷 배포 및 주소/스캔 링크 문서화
  - [ ] README 운영 가이드 보강
