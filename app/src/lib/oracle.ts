export type PriceLatest = {
  round_id: number;
  price: string;
  timestamp: number;
  signature: string;
};

const ORACLE_URL = import.meta.env.VITE_ORACLE_URL || 'http://localhost:8088';

export async function fetchLatestPrice(signal?: AbortSignal): Promise<PriceLatest> {
  const res = await fetch(`${ORACLE_URL}/price/latest`, { signal });
  if (!res.ok) throw new Error(`oracle http ${res.status}`);
  return res.json();
}
