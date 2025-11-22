# Project Plan

This document tracks tasks, progress, and next steps for the project. After each modification or feature addition, update this file with the current status and any changes to the plan.

## Current Goal

아키텍처 정렬(Proxy 단일 검증 · 소비자는 조회만) 및 하이브리드 운용 경로(atomic lazy-push → 즉시 소비) 반영. 이후 접근제어/운영 훅 정리, 배포·테스트·프론트 연동 업데이트.

## Task List

- [x] 초기 스캐폴드: Foundry/Go/Svelte 구조 생성
- [x] 도커 컴포즈/환경파일 추가 및 README 갱신
- [x] .gitignore 추가
- [ ] 컨트랙트 구현 보강
  - [ ] Registrar ↔ Token 화이트리스트 연동 및 역할 권한 정리
  - [x] 아키텍처 리팩토링 완료: SSOT(EIP712Schema), Proxy upsertFromSig/latest(uint80), IPriceFeed 정렬, Pool 소비자‑조회 경로 전환
  - [ ] 운영 훅/접근제어: `setPriceFeed`, `setMaxStaleness`, Proxy `setMaxDelay/setSigner`, `pause` + 테스트
  - [ ] nonReentrant + CEI 패턴 적용
  - [ ] 배포/시드 스크립트(Deploy/SeedDemo) 업데이트: 새 ABI/인터페이스 반영
- [ ] 컨트랙트 테스트 확장(Foundry)
  - [x] 기본 커버리지: digest 동형성, 원자 경로, idempotency
  - [ ] 정책/운영/경합 테스트 묶음: ERC-1271(mock), MEV 경합, 소비자 `maxStaleness`, Pause/Signer 회전, Fork/체인ID 도메인 일치성
  - [ ] KYC/민트/소각 유닛 테스트
- [ ] 오라클 서버 구현(Go)
  - [x] 기본 구성 완료: env, EIP‑712 TypedData, /price/latest
  - [ ] 컨테이너 헬스체크/로그 보강
- [ ] 프론트 연결(Svelte + viem)
  - [x] PriceMsg 전달·ABI 반영·latest() 반환 순서 업데이트
  - [ ] UI 오류/로딩/스캔 링크 보강
- [ ] 배포/운영 준비
  - [ ] 테스트넷 배포 및 주소/스캔 링크 문서화
  - [x] 문서 갱신: README/다이어그램, 운영 가이드 보강
  - [ ] 업그레이드 플레이북 명시: 도메인/버전 변경 시 "새 Proxy 배포 → Pool의 feed 주소 교체"
  - [ ] 가스 스냅샷 업데이트: `upsertFromSig(신규/구라운드)`, `borrow/repay/liquidate`
