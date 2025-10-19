<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  export let priceDisplay = '0.0000';
  export let priceRound = '0';
  export let priceAge = '';
  const dispatch = createEventDispatcher();
  function refresh() { dispatch('refresh'); }
</script>

<div class="card compact">
  <h3 class="section-title">Oracle Price</h3>
  <div class="row">
    <div class="price-xl">{priceDisplay}<span class="price-sub">(round {priceRound}, {priceAge})</span></div>
    <button class="btn secondary" on:click={refresh}>Refresh</button>
  </div>
</div>

