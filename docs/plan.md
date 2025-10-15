# Project Plan

This document tracks tasks, progress, and next steps for the project. After each modification or feature addition, update this file with the current status and any changes to the plan.

## Current Goal

오라클 서버에 EIP-712 TypedData 서명을 구현하고 `/price/latest` 응답에 서명을 포함하여, 온체인 `PriceFeedProxy.submit` 검증 경로를 end-to-end로 확인한다.

## Task List

- [x] 초기 스캐폴드: Foundry/Go/Svelte 구조 생성
- [x] 도커 컴포즈/환경파일 추가 및 README 갱신
- [x] .gitignore 추가
- [ ] 컨트랙트 구현 보강
  - [ ] Registrar ↔ Token 화이트리스트 연동 및 역할 권한 정리
  - [x] PriceFeedProxy 서명 검증(EIP-712 + OpenZeppelin, round 단조 증가, maxDelay)
  - [ ] LendingPool 이벤트/가드/정밀도 정리 및 기본 흐름 안정화
  - [ ] 배포/시드 스크립트(Deploy/SeedDemo) 구현 및 환경변수 연동
- [ ] 컨트랙트 테스트 확장(Foundry)
  - [x] PriceFeedProxy EIP-712 서명 검증 테스트(정상/스테일/라운드/사이너/도메인)
  - [ ] KYC/민트/소각 유닛 테스트
  - [ ] LTV/HF 경계(직전/직후), 청산 경로 테스트
  - [ ] 오라클 서명/스테일/라운드 재사용 거부 테스트
  - [ ] 가스리포트/커버리지 및 verbose 출력 확인
- [ ] 오라클 서버 구현(Go)
  - [x] .env 로드, 설정 구조화
  - [x] EIP-712 TypedData 서명(도메인: name/version/chainId/contract)
  - [ ] Deviation/Heartbeat 정책 + 온체인 submit 연동(재시도/백오프)
  - [x] GET /price/latest 서명 포함 응답
  - [ ] 컨테이너 헬스체크/로그 보강
- [ ] 프론트 연결(Svelte + viem)
  - [x] 오라클 최신 가격(서명 포함) UI 표시
  - [ ] ABI JSON 정리 및 주소/체인 env 주입
  - [ ] readContract/writeContract로 borrow/repay/deposit/liq 플로우 연결
  - [ ] 스캔 링크, 기본 에러/로딩 상태 처리
  - [ ] (옵션) 지갑 UI(Web3Modal/Onboard 중 택1)
- [ ] 배포/운영 준비
  - [ ] 테스트넷 배포 및 주소/스캔 링크 문서화
  - [ ] README 운영 가이드 보강
