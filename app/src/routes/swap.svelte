<script lang="ts">
  import { publicClient } from '../lib/web3';
  let amount = '0';
  let message = '';
  function onSwap() {
    message = `Mock swap executed for ${amount}`;
  }
</script>

<h1>Swap (RWA ↔ MockUSD)</h1>
<input type="text" bind:value={amount} placeholder="Amount" />
<button on:click={onSwap}>Swap (mock)</button>
<p>{message}</p>

