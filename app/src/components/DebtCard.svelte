<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  export let borrowAmt = '';
  export let repayAmt = '';
  export let maxBorrowDisp = '';
  export let borrowOver = false;
  export let disabled = false;
  const dispatch = createEventDispatcher();
</script>

<div class="card">
  <h3 class="section-title">Debt</h3>
  <div class="row">
    <div>
      <label for="borrow-input">Borrow (USD)</label>
      <input id="borrow-input" name="borrow" type="text" bind:value={borrowAmt} placeholder="50.0" />
    </div>
    <button class="btn" on:click={() => dispatch('borrow')} disabled={disabled || borrowOver}>
      Borrow
    </button>
    <div class="help">Max Borrow: {maxBorrowDisp} {#if borrowOver}<span class="warn">(over)</span>{/if}</div>
  </div>
  <div class="row">
    <div>
      <label for="repay-input">Repay (USD)</label>
      <input id="repay-input" name="repay" type="text" bind:value={repayAmt} placeholder="10.0" />
    </div>
    <button class="btn secondary" on:click={() => dispatch('repay')} disabled={disabled}>Repay</button>
    <div class="help">Repay to raise HF (Requires HF ≥ 1.0)</div>
  </div>
</div>
