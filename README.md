# RWAChain – RWA 담보 대출 프로토타입

실물자산(RWA) 발행/전송제한 + 담보 대출/상환/청산 + Go 오라클(가격 서명·검증)의 E2E 데모. 프론트는 Svelte + viem 기반의 최소 기능 UI를 제공합니다.

## Stack

- Solidity + Foundry (contracts, tests, scripts)
- Golang 1.21+ (Oracle REST: ECDSA 서명, Heartbeat/Deviation)
- Svelte + Vite + viem (프론트)
- Docker Compose (anvil, oracle, app)

## Repository Structure

- `contracts/` Solidity 컨트랙트 (RWAAssetToken, RWARegistrar, RWALendingPool, PriceFeedProxy)
- `script/` Foundry 배포/시드 스크립트
- `test/` Foundry 테스트 (기본 유닛/리퀴데이션/오라클 저장)
- `oracle-go/` 오라클 서버 (REST `/price/latest` 목업)
- `app/` Svelte + Vite + viem 프론트
- `docker-compose.yml`, `.env.example`, `foundry.toml`

## Getting Started

- Local Development: 로컬 툴체인(Foundry/Node/Go)으로 개발·디버깅
- Docker Compose: Docker로 빠르게 전체 스택 실행

## Local Development

### Prerequisites

- Foundry (forge/cast/anvil)
  - 설치: `curl -L https://foundry.paradigm.xyz | bash && foundryup`
  - 확인: `forge --version`, `anvil --version`, `cast --version`
- Node.js 20 LTS (프론트)
- Go 1.21+ (오라클)

### Setup

- 환경 변수 파일: `cp .env.example .env`
- Foundry 의존성: `forge soldeer update`

### Run

- Anvil 노드
  - `source .env`
  - `anvil -p 8545 -m "$ANVIL_MNEMONIC"`
- 오라클 서버(목업)
  - `cp oracle-go/.env.example oracle-go/.env`
  - `cd oracle-go && go run ./cmd/oracle`
  - 확인: `curl http://localhost:8088/price/latest`
- 프론트엔드
  - `cd app && pnpm i --frozen-lockfile && pnpm dev`
  - 접속: http://localhost:5173

### Test

- `forge test --gas-report`

## Docker Compose

### Prerequisites

- Docker & Docker Compose

### Setup

- 환경 변수 파일: `cp .env.example .env`

### Run

- 전체 스택 실행: `docker compose up -d`

## Deployment (예시)

- 테스트넷 배포 예시: `forge script script/Deploy.s.sol --broadcast --verify --rpc-url $RPC_URL`
- 데모 시드: `forge script script/SeedDemo.s.sol --broadcast --rpc-url $RPC_URL`

## Notes & Current Limitations

- 오라클 서버는 `GET /price/latest` 목업 응답을 반환합니다. signer/체인 도메인 분리, Heartbeat/Deviation 로직은 순차 구현 예정입니다.
- 프론트 라우트(`/swap`, `/borrow`, `/liquidate`)는 초기 목업이며, ABI 연결 및 실제 트랜잭션 연결은 차차 연동합니다.

## Reference

- 작업 계획: `docs/plan.md`
- Foundry config: `foundry.toml`
