<script lang="ts">
  let target = '';
  let repay = '0';
  let res = '';
  function simulate() { res = `Liquidated ${target} for ${repay} (mock)`; }
</script>

<h1>Liquidate</h1>
<div>
  <label>Address</label>
  <input type="text" bind:value={target} />
</div>
<div>
  <label>Repay</label>
  <input type="text" bind:value={repay} />
</div>
<button on:click={simulate}>Liquidate (mock)</button>
<p>{res}</p>

