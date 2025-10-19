<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  export let liqUser = '';
  export let liqRepayAmt = '';
  export let disabled = false;
  const dispatch = createEventDispatcher();
</script>

<div class="card">
  <h3 class="section-title">Liquidate</h3>
  <div class="row three">
    <div>
      <label for="liq-user">Target User</label>
      <input id="liq-user" name="liqUser" type="text" placeholder="0x… (optional)" bind:value={liqUser} />
    </div>
    <div>
      <label for="liq-repay">Repay Amount (USD)</label>
      <input id="liq-repay" name="liqRepayAmt" type="text" bind:value={liqRepayAmt} placeholder="100.0" />
    </div>
    <button class="btn danger" on:click={() => dispatch('liquidate')} disabled={disabled}>Liquidate</button>
    <div class="help">Executes only when HF &lt; 1.0</div>
  </div>
</div>
