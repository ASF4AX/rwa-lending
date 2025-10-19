<script lang="ts">
  
  import { onMount, onDestroy } from 'svelte';
  import { fetchLatestPrice } from '../lib/oracle';
  import OraclePriceCard from '../components/OraclePriceCard.svelte';
  import PositionsCard from '../components/PositionsCard.svelte';
  import CollateralCard from '../components/CollateralCard.svelte';
  import DebtCard from '../components/DebtCard.svelte';
  import LiquidateCard from '../components/LiquidateCard.svelte';
  import MessageCard from '../components/MessageCard.svelte';
  import { formatEther } from 'viem';
  import { formatAmountStr, isHexAddress, isZeroAddress } from '../lib/utils/format';
  import { computeLimits } from '../lib/limits';
  import * as poolActions from '../lib/poolActions';
  import { readUserState } from '../lib/poolReads';

  const POOL_ADDRESS = (import.meta.env.VITE_POOL_ADDRESS || '').trim();
  const ORACLE_URL = (import.meta.env.VITE_ORACLE_URL || 'http://localhost:8088').trim();

  let collateral = '0';
  let borrowAmt = '0';
  let withdrawAmt = '0';
  let repayAmt = '0';
  let liqUser = '';
  let liqRepayAmt = '0';
  let info = '';
  let error = '';
  let account: `0x${string}` | undefined;
  let loading = false;
  let connecting = false;
  let posCollateral = '0';
  let posDebt = '0';
  let posLastRound = '0';
  let priceRound = '0';
  let priceNow = '0';
  let priceAge = '';
  let priceDisplay = '0.0000';
  let lastPriceTsSec = 0;
  let ageTimer: any;
  let maxBorrow = '0';
  let maxWithdraw = '0';
  let currentHF = '∞';
  let projectedHF = '';
  let maxLtv: bigint | undefined;
  let liqTh: bigint | undefined;
  let lastColl: bigint = 0n;
  let lastDebt: bigint = 0n;
  let lastPrice: bigint = 0n;
  let borrowOver = false;
  let withdrawOver = false;
  let hfSafe = true;

  $: posCollateralDisp = formatAmountStr(posCollateral);
  $: posDebtDisp = formatAmountStr(posDebt);
  $: maxBorrowDisp = formatAmountStr(maxBorrow);
  $: maxWithdrawDisp = formatAmountStr(maxWithdraw);
  $: poolConfigError = (() => {
    if (!POOL_ADDRESS) return 'VITE_POOL_ADDRESS missing';
    if (!isHexAddress(POOL_ADDRESS)) return 'VITE_POOL_ADDRESS invalid format';
    if (isZeroAddress(POOL_ADDRESS)) return 'VITE_POOL_ADDRESS is zero address — set deployed RWALendingPool';
    return '';
  })();

  async function connect() {
    try {
      connecting = true; error = ''; info='';
      const { walletClient } = await import('../lib/web3');
      if (!walletClient) throw new Error('No wallet (window.ethereum)');
      const addrs = await walletClient.requestAddresses();
      account = addrs?.[0] as `0x${string}`;
      await refreshPositions();
    } catch (e: any) {
      error = e?.shortMessage || e?.message || String(e);
    } finally {
      connecting = false;
    }
  }

  async function deposit() {
    error = '';
    info = '';
    try {
      loading = true;
      if (poolConfigError) throw new Error(poolConfigError);
      const hash = await poolActions.deposit(POOL_ADDRESS as `0x${string}`, collateral || '0');
      info = `Deposit tx: ${hash}`;
      collateral = '0';
      await refreshPositions();
    } catch (e: any) {
      error = e?.shortMessage || e?.message || String(e);
    } finally { loading = false; }
  }

  async function borrow() {
    error = '';
    info = '';
    try {
      loading = true;
      if (poolConfigError) throw new Error(poolConfigError);
      const hash = await poolActions.borrow(POOL_ADDRESS as `0x${string}`, borrowAmt || '0');
      info = `Borrow tx: ${hash}`;
      borrowAmt = '0';
      await refreshPositions();
    } catch (e: any) {
      error = e?.shortMessage || e?.message || String(e);
    } finally { loading = false; }
  }

  async function withdraw() {
    error = '';
    info = '';
    try {
      loading = true;
      if (poolConfigError) throw new Error(poolConfigError);
      const hash = await poolActions.withdraw(POOL_ADDRESS as `0x${string}`, withdrawAmt || '0');
      info = `Withdraw tx: ${hash}`;
      withdrawAmt = '0';
      await refreshPositions();
    } catch (e: any) {
      error = e?.shortMessage || e?.message || String(e);
    } finally { loading = false; }
  }

  async function repay() {
    error = '';
    info = '';
    try {
      loading = true;
      if (poolConfigError) throw new Error(poolConfigError);
      const hash = await poolActions.repay(POOL_ADDRESS as `0x${string}`, repayAmt || '0');
      info = `Repay tx: ${hash}`;
      repayAmt = '0';
      await refreshPositions();
    } catch (e: any) {
      error = e?.shortMessage || e?.message || String(e);
    } finally { loading = false; }
  }

  async function liquidate() {
    error = '';
    info = '';
    try {
      loading = true;
      if (poolConfigError) throw new Error(poolConfigError);
      const hash = await poolActions.liquidate(
        POOL_ADDRESS as `0x${string}`,
        (liqUser && liqUser.length > 0) ? (liqUser as `0x${string}`) : undefined,
        liqRepayAmt || '0'
      );
      info = `Liquidate tx: ${hash}`;
      liqUser = '';
      liqRepayAmt = '0';
      await refreshPositions();
    } catch (e: any) {
      error = e?.shortMessage || e?.message || String(e);
    } finally { loading = false; }
  }

  function updatePriceAge() {
    if (lastPriceTsSec > 0) {
      const ageSec = Math.max(0, Math.floor(Date.now() / 1000 - lastPriceTsSec));
      priceAge = `${ageSec}s ago`;
    }
  }

  async function refreshPrice() {
    try {
      const latest = await fetchLatestPrice();
      priceRound = String(latest.round_id);
      lastPrice = BigInt(latest.price);
      priceNow = formatEther(lastPrice);
      lastPriceTsSec = latest.timestamp;
      updatePriceAge();
      try { priceDisplay = Number(priceNow).toFixed(4); } catch { priceDisplay = priceNow; }
      if (account && POOL_ADDRESS) { updateLimits(); }
    } catch (e) {
      // ignore price fetch errors on initial load
    }
  }

  function updateLimits() {
    const res = computeLimits(
      lastColl,
      lastDebt,
      lastPrice,
      maxLtv ?? 0n,
      liqTh ?? 0n,
      { borrowAmt, withdrawAmt, repayAmt, collateral }
    );
    maxBorrow = res.maxBorrow;
    maxWithdraw = res.maxWithdraw;
    currentHF = res.currentHF;
    projectedHF = res.projectedHF;
    borrowOver = res.borrowOver;
    withdrawOver = res.withdrawOver;
    hfSafe = res.hfSafe;
  }

  async function refreshPositions() {
    try {
      error = '';
      // Always refresh price for display, even without wallet
      await refreshPrice();
      if (!account || !POOL_ADDRESS) return;
      const state = await readUserState(POOL_ADDRESS as `0x${string}`, account as `0x${string}`);
      lastColl = state.collateral;
      lastDebt = state.debt;
      posCollateral = formatEther(lastColl);
      posDebt = formatEther(lastDebt);
      posLastRound = String(state.lastRoundId);
      maxLtv = state.maxLtv;
      liqTh = state.liqThreshold;
      updateLimits();
    } catch (e: any) {
      // ignore read errors, show best-effort
    }
  }

  // Recompute projections when inputs change
  function recalcLimits() { updateLimits(); }
  $: updateLimits();
  // Also recompute when user edits inputs (without requiring Refresh)
  $: (borrowAmt, withdrawAmt, repayAmt, collateral, recalcLimits());

  onMount(() => {
    // Show price on first paint and start age ticker
    refreshPrice();
    ageTimer = setInterval(updatePriceAge, 1000);
  });

  onDestroy(() => {
    if (ageTimer) clearInterval(ageTimer);
  });
</script>

<div class="container">
  <div class="header">
    <div>
      <div class="brand">RWA Lending Demo</div>
      <div class="subtle">Oracle: {ORACLE_URL}</div>
    </div>
    <div class="inline">
      {#if account}
        <span class="pill">{account.slice(0,6)}…{account.slice(-4)}</span>
      {:else}
        <button class="btn" on:click={connect} disabled={connecting}>
          {#if connecting}<span class="spinner"></span>{/if}
          Connect Wallet
        </button>
      {/if}
    </div>
  </div>

  <OraclePriceCard {priceDisplay} {priceRound} {priceAge} on:refresh={refreshPrice} />

  <PositionsCard {posCollateralDisp} {posDebtDisp} {currentHF} {projectedHF} {hfSafe} {posLastRound} />

  <div class="grid grid-2">
    <CollateralCard bind:collateral bind:withdrawAmt {maxWithdrawDisp} {withdrawOver}
      disabled={loading || !account || !!poolConfigError}
      on:deposit={deposit} on:withdraw={withdraw} />

    <DebtCard bind:borrowAmt bind:repayAmt {maxBorrowDisp} {borrowOver}
      disabled={loading || !account || !!poolConfigError}
      on:borrow={borrow} on:repay={repay} />
  </div>

  <LiquidateCard bind:liqUser bind:liqRepayAmt on:liquidate={liquidate}
    disabled={loading || !account || !!poolConfigError} />

  <MessageCard {poolConfigError} {info} {error} />

</div>
