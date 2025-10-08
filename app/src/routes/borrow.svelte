<script lang="ts">
  import { publicClient } from '../lib/web3';
  let collateral = '0';
  let borrowAmt = '0';
  let info = '';
  function deposit() { info = `Deposited ${collateral} (mock)`; }
  function borrow() { info = `Borrowed ${borrowAmt} (mock)`; }
</script>

<h1>Borrow</h1>
<div>
  <label>Collateral</label>
  <input type="text" bind:value={collateral} />
  <button on:click={deposit}>Deposit</button>
</div>
<div>
  <label>Borrow</label>
  <input type="text" bind:value={borrowAmt} />
  <button on:click={borrow}>Borrow</button>
</div>
<p>{info}</p>

