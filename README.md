# RWAChain – RWA 담보 대출 프로토타입

실물자산(RWA) 발행/전송제한 + 담보 대출/상환/청산 + Go 오라클(가격 서명·검증)의 E2E 데모. 프론트는 Svelte + viem 기반의 최소 기능 UI를 제공합니다.

## Stack

- Solidity + Foundry (contracts, tests, scripts)
- Golang 1.21+ (Oracle REST: ECDSA 서명, Heartbeat/Deviation)
- Svelte + Vite + viem (프론트)
- Docker Compose (anvil, oracle, app)

## Prerequisites

- Foundry (forge/cast/anvil)
  - macOS: `curl -L https://foundry.paradigm.xyz | bash && foundryup`
  - Verify: `forge --version`, `anvil --version`, `cast --version`
- Node.js 20 LTS
  - `brew install node@20` 또는 `brew install volta && volta install node@20`
- Go 1.21+
  - `brew install go` (또는 최신 1.22)
- Docker & Docker Compose (선택, 컨테이너 실행용)

## Repository Structure (tl;dr)

- `contracts/` Solidity 컨트랙트 (RWAAssetToken, RWARegistrar, RWALendingPool, PriceFeedProxy)
- `script/` Foundry 배포/시드 스크립트
- `test/` Foundry 테스트 (기본 유닛/리퀴데이션/오라클 저장)
- `oracle-go/` 오라클 서버 (REST `/price/latest` 목업)
- `app/` Svelte + Vite + viem 프론트
- `docker-compose.yml`, `.env.example`, `foundry.toml`

## Quick Start (Local)

1) 환경 변수 준비

- 루트에 복사 후 수정: `cp .env.example .env`
- 기본값: `RPC_URL=http://localhost:8545` (anvil)

2) 로컬 노드 실행

- anvil: `anvil -p 8545 -m "test test test test test test test test test test test junk"`

3) Foundry 의존성 설치 및 테스트

- 표준 라이브러리 설치: `forge install foundry-rs/forge-std`
- 테스트 실행: `forge test --gas-report`

4) 오라클 서버 실행 (목업)

- 환경: `cp oracle-go/.env.example oracle-go/.env` 후 필요 시 값 설정
- 실행: `cd oracle-go && go run ./cmd/oracle`
- 확인: `curl http://localhost:8088/price/latest`

5) 프론트 실행

- 의존성 설치: `cd app && npm i`
- 개발 서버: `npm run dev`
- 접속: http://localhost:5173

## Quick Start (Docker Compose)

1) `.env` 준비: `cp .env.example .env`

2) 빌드/실행: `docker compose up --build`

- anvil: `:8545`
- oracle: `:8088`
- app: `:5173`

## Testing

- Unit/Gas: `forge test --gas-report`
- 커버리지(원하면): `forge coverage` (환경에 따라 추가 설정 필요할 수 있음)

## Deployment (예시)

- 테스트넷 배포 예시: `forge script script/Deploy.s.sol --broadcast --verify --rpc-url $RPC_URL`
- 데모 시드: `forge script script/SeedDemo.s.sol --broadcast --rpc-url $RPC_URL`

## Notes & Current Limitations

- PriceFeedProxy는 서명 검증(ecrecover) 로직이 TODO 상태로, 현재는 타임스탬프/라운드 증가만 검증합니다.
- 오라클 서버는 `GET /price/latest` 목업 응답을 반환합니다. signer/체인 도메인 분리, Heartbeat/Deviation 로직은 순차 구현 예정입니다.
- 프론트 라우트(`/swap`, `/borrow`, `/liquidate`)는 초기 목업이며, ABI 연결 및 실제 트랜잭션 연결은 차차 연동합니다.

## Reference

- 작업 계획: `docs/plan.md`
- Foundry config: `foundry.toml`
