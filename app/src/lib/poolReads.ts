import { publicClient } from './web3';
import { poolAbi } from './abi/pool';

export type UserState = {
  collateral: bigint;
  debt: bigint;
  lastRoundId: bigint;
  maxLtv: bigint;
  liqThreshold: bigint;
};

export async function readUserState(
  poolAddress: `0x${string}`,
  account: `0x${string}`
): Promise<UserState> {
  const [coll, deb, lr, ltv, liq] = await Promise.all([
    publicClient.readContract({ address: poolAddress, abi: poolAbi, functionName: 'collateral', args: [account] }),
    publicClient.readContract({ address: poolAddress, abi: poolAbi, functionName: 'debt', args: [account] }),
    publicClient.readContract({ address: poolAddress, abi: poolAbi, functionName: 'lastRoundId' }),
    publicClient.readContract({ address: poolAddress, abi: poolAbi, functionName: 'MAX_LTV' }),
    publicClient.readContract({ address: poolAddress, abi: poolAbi, functionName: 'LIQ_THRESHOLD' }),
  ]);

  return {
    collateral: coll as bigint,
    debt: deb as bigint,
    lastRoundId: lr as bigint,
    maxLtv: ltv as bigint,
    liqThreshold: liq as bigint,
  };
}
