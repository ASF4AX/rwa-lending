export const poolAbi = [
  {
    type: 'function',
    stateMutability: 'view',
    name: 'MAX_LTV',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    stateMutability: 'view',
    name: 'LIQ_THRESHOLD',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    stateMutability: 'nonpayable',
    name: 'depositCollateral',
    inputs: [{ name: 'amount', type: 'uint256' }],
    outputs: [],
  },
  {
    type: 'function',
    stateMutability: 'view',
    name: 'collateral',
    inputs: [{ name: 'user', type: 'address' }],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    stateMutability: 'view',
    name: 'debt',
    inputs: [{ name: 'user', type: 'address' }],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    stateMutability: 'nonpayable',
    name: 'borrow',
    inputs: [
      { name: 'amount', type: 'uint256' },
      {
        name: 'px',
        type: 'tuple',
        components: [
          { name: 'roundId', type: 'uint256' },
          { name: 'price', type: 'int256' },
          { name: 'timestamp', type: 'uint256' },
          { name: 'signature', type: 'bytes' },
        ],
      },
    ],
    outputs: [],
  },
  {
    type: 'function',
    stateMutability: 'nonpayable',
    name: 'withdraw',
    inputs: [
      { name: 'amount', type: 'uint256' },
      {
        name: 'px',
        type: 'tuple',
        components: [
          { name: 'roundId', type: 'uint256' },
          { name: 'price', type: 'int256' },
          { name: 'timestamp', type: 'uint256' },
          { name: 'signature', type: 'bytes' },
        ],
      },
    ],
    outputs: [],
  },
  {
    type: 'function',
    stateMutability: 'nonpayable',
    name: 'repay',
    inputs: [
      { name: 'amount', type: 'uint256' },
    ],
    outputs: [],
  },
  {
    type: 'function',
    stateMutability: 'nonpayable',
    name: 'liquidate',
    inputs: [
      { name: 'user', type: 'address' },
      { name: 'repayAmount', type: 'uint256' },
      {
        name: 'px',
        type: 'tuple',
        components: [
          { name: 'roundId', type: 'uint256' },
          { name: 'price', type: 'int256' },
          { name: 'timestamp', type: 'uint256' },
          { name: 'signature', type: 'bytes' },
        ],
      },
    ],
    outputs: [],
  },
  {
    type: 'function',
    stateMutability: 'view',
    name: 'priceFeed',
    inputs: [],
    outputs: [{ name: '', type: 'address' }],
  },
] as const;
