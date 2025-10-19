import { createPublicClient, createWalletClient, http, custom, defineChain } from 'viem';

declare global {
  interface Window { ethereum?: any }
}

export const rpcUrl = import.meta.env.VITE_RPC_URL || 'http://localhost:8545';

export const publicClient = createPublicClient({ transport: http(rpcUrl) });

export const walletClient = typeof window !== 'undefined' && window.ethereum
  ? createWalletClient({ transport: custom(window.ethereum) })
  : undefined;

export async function getChain() {
  const id = await publicClient.getChainId();
  return defineChain({
    id,
    name: `chain-${id}`,
    nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
    rpcUrls: {
      default: { http: [rpcUrl] },
      public: { http: [rpcUrl] },
    },
  });
}
