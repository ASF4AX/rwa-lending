import { createPublicClient, createWalletClient, http } from 'viem';

declare global {
  interface Window { ethereum?: any }
}

export const rpcUrl = import.meta.env.VITE_RPC_URL || 'http://localhost:8545';

export const publicClient = createPublicClient({ transport: http(rpcUrl) });

export const walletClient = typeof window !== 'undefined' && window.ethereum
  ? createWalletClient({ transport: http(), chain: undefined })
  : undefined;

