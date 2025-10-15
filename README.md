# RWAChain – RWA 담보 대출 프로토타입

> 실물자산(RWA) 발행·전송제한, 담보 대출/상환/청산, Go 오라클(가격 서명·검증)서버로 구성된 E2E 데모. Svelte + viem 기반 UI.

## 기능 개요

* **RWA 토큰화**: `RWAAssetToken` (전송 제한/허용 리스트 기반)
* **등록/권한**: `RWARegistrar` (발행/민팅 권한 관리)
* **대출 풀**: `RWALendingPool` (담보 예치, 차입, 상환, 청산 로직)
* **오라클 프록시**: `PriceFeedProxy` (서명 검증·Heartbeat/Deviation 규칙 적용 예정)
* **오라클 서버**: Go(REST) – `GET /price/latest` 목업 → 이후 ECDSA 서명, 도메인분리(EIP-712), Heartbeat/Deviation 추가 예정
* **프론트**: Svelte + viem – `/swap`, `/borrow`, `/liquidate` 기본 흐름 (트랜잭션 연동 점진 통합)

---

## 리포지토리 구조

```
contracts/         # Solidity 컨트랙트 (RWAAssetToken, RWARegistrar, RWALendingPool, PriceFeedProxy)
script/            # Foundry 배포/시드 스크립트
test/              # Foundry 테스트 (유닛/리퀴데이션/오라클 저장)
oracle-go/         # Go 오라클 서버 (REST)
  ├─ cmd/oracle/   # main 패키지
  └─ internal/     # signer, api, config 등
app/               # Svelte + Vite + viem 프론트
broadcast/         # 배포 아티팩트 (자동 생성)
docker-compose.yml
foundry.toml
.env.example
```

---

## 개발 환경

| 컴포넌트    | 버전                           | 용도                                 |
| -------- | ------------------------------ | ------------------------------------ |
| Foundry  | latest | 컨트랙트/스크립트/테스트 (forge/cast/anvil 포함) |
| Node.js  | 20 LTS                  | 프론트 빌드/개발 서버   |
| Go       | 1.24+                   | 오라클 서버            |
| Docker   | latest | 컨테이너/Compose 실행  |

---

## 환경 변수 (.env)

| 키                | 예시 값                               | 설명                  |
| ---------------- | ---------------------------------- | ------------------- |
| `RPC_URL`        | `http://localhost:8545`            | Anvil/테스트넷 RPC                     |
| `CHAIN_ID`       | `31337`                             | 네트워크 체인ID (Anvil 로그 또는 `cast chain-id --rpc-url $RPC_URL` 확인) |
| `ANVIL_MNEMONIC` | `test test ... junk`               | 개발용 12단어 니모닉                   |
| `PRIVATE_KEY`    | `0x<hex-private-key>`              | 배포·트랜잭션 서명용 (Anvil 로그 또는 `cast wallet private-key "$ANVIL_MNEMONIC" 0` 확인) |
| `FEED_ADDRESS`   | `0x<pricefeed-address>`            | 배포된 PriceFeedProxy 주소 (`broadcast/Deploy.s.sol/<CHAIN_ID>/run-latest.json`) |

---

## 로컬 개발

### Foundry 설치

```bash
# 설치 & 확인
curl -L https://foundry.paradigm.xyz | bash && foundryup
forge --version && anvil --version && cast --version

# 의존성 설치/업데이트 (Soldeer)
forge soldeer update
```

### Anvil 실행 및 배포

```bash
source .env
anvil -p 8545 -m "$ANVIL_MNEMONIC"

# 컨트랙트 배포
forge script script/Deploy.s.sol --broadcast --rpc-url "$RPC_URL"
cat broadcast/Deploy.s.sol/$(cast chain-id --rpc-url "$RPC_URL")/run-latest.json
```

### 오라클 서버 실행

```bash
cd oracle-go
go run ./cmd/oracle

# 엔드포인트 확인
curl http://localhost:8088/price/latest
```

응답 스키마 예시

```json
{
  "round_id": 1,
  "price": "1000000000000000000",
  "timestamp": 1710000000,
  "signature": "0x..."
}
```

### 프론트엔드 실행

```bash
cd app
pnpm i --frozen-lockfile
pnpm dev

# 접속 확인
# http://localhost:5173
```

---

## Docker Compose

```bash
cp .env.example .env  # 필요시 .env 수정
docker compose up -d
```

---

## 테스트

```bash
forge test --gas-report
```
