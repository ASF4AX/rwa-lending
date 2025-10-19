import { formatEther, parseEther } from 'viem';
import { formatHFFromWei } from './utils/format';

export type LimitInputs = {
  borrowAmt?: string;
  withdrawAmt?: string;
  repayAmt?: string;
  collateral?: string;
};

export type LimitResult = {
  maxBorrow: string;
  maxWithdraw: string;
  currentHF: string;
  projectedHF: string;
  borrowOver: boolean;
  withdrawOver: boolean;
  hfSafe: boolean;
};

export function computeLimits(
  coll: bigint,
  deb: bigint,
  price: bigint,
  maxLtv: bigint = 0n,
  liqTh: bigint = 0n,
  inputs: LimitInputs = {}
): LimitResult {
  const ONE = 10n ** 18n;
  const { borrowAmt = '', withdrawAmt = '', repayAmt = '', collateral = '' } = inputs;

  // collateralUsd = coll * price / 1e18
  const collateralUsd = (coll * price) / ONE;
  // maxDebt = collateralUsd * MAX_LTV / 1e18
  const maxDebt = (collateralUsd * maxLtv) / ONE;
  const available = maxDebt > deb ? maxDebt - deb : 0n;
  const maxBorrow = formatEther(available);

  // HF (scaled 1e18): (collateralUsd * LIQ_THRESHOLD) / debt
  let currentHF = '∞';
  let hfSafe = true;
  if (deb === 0n) {
    currentHF = '∞';
    hfSafe = true;
  } else {
    const hfScaled = (collateralUsd * liqTh) / deb;
    currentHF = formatHFFromWei(hfScaled);
    try {
      const curNum = currentHF === '∞' ? Infinity : Number(currentHF.replace(/,/g, ''));
      hfSafe = curNum >= 1.0;
    } catch {
      hfSafe = true;
    }
  }

  // maxWithdraw to keep HF >= 1
  let maxWithdraw: string;
  let withdrawOver = false;
  if (deb === 0n) {
    maxWithdraw = formatEther(coll);
  } else {
    const denom = price * liqTh;
    if (denom === 0n) {
      maxWithdraw = '0';
    } else {
      const num = deb * (ONE * ONE);
      const collReq = (num + denom - 1n) / denom; // ceil
      const canW = coll > collReq ? coll - collReq : 0n;
      maxWithdraw = formatEther(canW);
      try {
        const wd = withdrawAmt ? parseEther(withdrawAmt) : 0n;
        withdrawOver = wd > canW;
      } catch {
        withdrawOver = false;
      }
    }
  }

  // projected HF after input
  let projectedHF = '';
  let borrowOver = false;
  try {
    const w = borrowAmt ? parseEther(borrowAmt) : 0n;
    const ww = withdrawAmt ? parseEther(withdrawAmt) : 0n;
    const rr = repayAmt ? parseEther(repayAmt) : 0n;
    const dd = collateral ? parseEther(collateral) : 0n;
    borrowOver = w > available;
    if (w > 0n) {
      const newDebt = deb + w;
      if (newDebt === 0n) projectedHF = '∞';
      else {
        const newHfScaled = (collateralUsd * liqTh) / newDebt;
        projectedHF = formatHFFromWei(newHfScaled);
      }
    } else if (ww > 0n) {
      const newColl = coll > ww ? coll - ww : 0n;
      const newCollUsd = (newColl * price) / ONE;
      if (deb === 0n) projectedHF = '∞';
      else {
        const newHfScaled = (newCollUsd * liqTh) / deb;
        projectedHF = formatHFFromWei(newHfScaled);
      }
    } else if (rr > 0n) {
      const newDebt = deb > rr ? deb - rr : 0n;
      if (newDebt === 0n) projectedHF = '∞';
      else {
        const newHfScaled = (collateralUsd * liqTh) / newDebt;
        projectedHF = formatHFFromWei(newHfScaled);
      }
    } else if (dd > 0n) {
      const newColl = coll + dd;
      const newCollUsd = (newColl * price) / ONE;
      if (deb === 0n) projectedHF = '∞';
      else {
        const newHfScaled = (newCollUsd * liqTh) / deb;
        projectedHF = formatHFFromWei(newHfScaled);
      }
    }
  } catch {
    // ignore projection errors
  }

  return { maxBorrow, maxWithdraw, currentHF, projectedHF, borrowOver, withdrawOver, hfSafe };
}
