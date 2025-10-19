export function formatAmountStr(s: string, decimals: number = 4): string {
  try {
    const n = Number(s);
    if (!isFinite(n)) return s;
    return n.toLocaleString(undefined, {
      minimumFractionDigits: 0,
      maximumFractionDigits: decimals,
    });
  } catch {
    return s;
  }
}

// Formats HF from a 1e18-scaled bigint into a readable string
export function formatHFFromWei(wei: bigint): string {
  try {
    // Using Number is acceptable here due to post-formatting and upper-bound cap
    const v = Number((wei as unknown) as any) / 1e18; // fallback if viem not available here
    if (!isFinite(v)) return '∞';
    if (v > 1_000_000) return '∞';
    return v.toLocaleString(undefined, { minimumFractionDigits: 0, maximumFractionDigits: 4 });
  } catch {
    return '∞';
  }
}

export function isZeroAddress(addr: string) {
  return /^0x0{40}$/i.test(addr);
}

export function isHexAddress(addr: string) {
  return /^0x[a-fA-F0-9]{40}$/.test(addr);
}
