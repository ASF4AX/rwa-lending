<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  export let collateral = '';
  export let withdrawAmt = '';
  export let maxWithdrawDisp = '';
  export let withdrawOver = false;
  export let disabled = false;
  const dispatch = createEventDispatcher();
</script>

<div class="card">
  <h3 class="section-title">Collateral</h3>
  <div class="row">
    <div>
      <label for="collateral-input">Deposit (RWA)</label>
      <input id="collateral-input" name="collateral" type="text" bind:value={collateral} placeholder="100.0" />
    </div>
    <button class="btn" on:click={() => dispatch('deposit')} disabled={disabled}>Deposit</button>
    <div class="help">Increase collateral to raise HF</div>
  </div>
  <div class="row">
    <div>
      <label for="withdraw-input">Withdraw (RWA)</label>
      <input id="withdraw-input" name="withdraw" type="text" bind:value={withdrawAmt} placeholder="10.0" />
    </div>
    <button class="btn secondary" on:click={() => dispatch('withdraw')} disabled={disabled || withdrawOver}>Withdraw</button>
    <div class="help">Max Withdraw: {maxWithdrawDisp} {#if withdrawOver}<span class="warn">(over)</span>{/if}</div>
  </div>
</div>
