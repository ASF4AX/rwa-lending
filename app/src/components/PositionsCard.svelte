<script lang="ts">
  export let posCollateralDisp = '0';
  export let posDebtDisp = '0';
  export let currentHF = '';
  export let projectedHF: string | '' = '';
  export let hfSafe = true;

  function toNumberSafe(v: string): number {
    try { return Number(v.replace(/,/g, '')); } catch { return NaN; }
  }
  $: projSafe = projectedHF === '∞' || (projectedHF !== '' && toNumberSafe(projectedHF) >= 1.0);
</script>

<div class="card">
  <h3 class="section-title">Positions</h3>
  <div class="row">
    <div class="inline kv">
      <span class="label">Collateral (RWA)</span>
      <span class="value">{posCollateralDisp}</span>
    </div>
    <div class="inline kv">
      <span class="label">Debt (USD)</span>
      <span class="value">{posDebtDisp}</span>
    </div>
    <div class="inline">
      <span class="pill {hfSafe ? 'good' : 'bad'}">HF: {currentHF}</span>
      {#if projectedHF}
        <span class="pill {projSafe ? 'good' : 'bad'}">Projected HF: {projectedHF}</span>
      {/if}
    </div>
  </div>
</div>
