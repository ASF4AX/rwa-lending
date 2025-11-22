import { parseEther } from 'viem';
import { poolAbi } from './abi/pool';
import { walletClient, getChain } from './web3';
import { fetchLatestPrice } from './oracle';

function ensureWallet() {
  if (!walletClient) throw new Error('No wallet (window.ethereum)');
}

export async function deposit(poolAddress: `0x${string}`, amount: string): Promise<string> {
  ensureWallet();
  const [addr] = await walletClient!.getAddresses();
  const account = addr as `0x${string}`;
  const chain = await getChain();
  const hash = await walletClient!.writeContract({
    address: poolAddress,
    abi: poolAbi,
    functionName: 'depositCollateral',
    args: [parseEther(amount || '0')],
    account,
    chain,
  });
  return hash;
}

export async function borrow(poolAddress: `0x${string}`, amount: string): Promise<string> {
  ensureWallet();
  const latest = await fetchLatestPrice();
  const px = {
    roundId: BigInt(latest.round_id),
    price: BigInt(latest.price),
    timestamp: BigInt(latest.timestamp),
    signature: latest.signature as `0x${string}`,
  } as const;
  const [addr] = await walletClient!.getAddresses();
  const account = addr as `0x${string}`;
  const chain = await getChain();
  const hash = await walletClient!.writeContract({
    address: poolAddress,
    abi: poolAbi,
    functionName: 'borrow',
    args: [parseEther(amount || '0'), px],
    account,
    chain,
  });
  return hash;
}

export async function withdraw(poolAddress: `0x${string}`, amount: string): Promise<string> {
  ensureWallet();
  const latest = await fetchLatestPrice();
  const px = {
    roundId: BigInt(latest.round_id),
    price: BigInt(latest.price),
    timestamp: BigInt(latest.timestamp),
    signature: latest.signature as `0x${string}`,
  } as const;
  const [addr] = await walletClient!.getAddresses();
  const account = addr as `0x${string}`;
  const chain = await getChain();
  const hash = await walletClient!.writeContract({
    address: poolAddress,
    abi: poolAbi,
    functionName: 'withdraw',
    args: [parseEther(amount || '0'), px],
    account,
    chain,
  });
  return hash;
}

export async function repay(poolAddress: `0x${string}`, amount: string): Promise<string> {
  ensureWallet();
  const [addr] = await walletClient!.getAddresses();
  const account = addr as `0x${string}`;
  const chain = await getChain();
  const hash = await walletClient!.writeContract({
    address: poolAddress,
    abi: poolAbi,
    functionName: 'repay',
    args: [parseEther(amount || '0')],
    account,
    chain,
  });
  return hash;
}

export async function liquidate(
  poolAddress: `0x${string}`,
  callerOrTarget: `0x${string}` | undefined,
  repayAmount: string
): Promise<string> {
  ensureWallet();
  const latest = await fetchLatestPrice();
  const px = {
    roundId: BigInt(latest.round_id),
    price: BigInt(latest.price),
    timestamp: BigInt(latest.timestamp),
    signature: latest.signature as `0x${string}`,
  } as const;
  const [addr] = await walletClient!.getAddresses();
  const account = addr as `0x${string}`;
  const user = (callerOrTarget && callerOrTarget.length > 0) ? callerOrTarget : account;
  const chain = await getChain();
  const hash = await walletClient!.writeContract({
    address: poolAddress,
    abi: poolAbi,
    functionName: 'liquidate',
    args: [user, parseEther(repayAmount || '0'), px],
    account,
    chain,
  });
  return hash;
}
