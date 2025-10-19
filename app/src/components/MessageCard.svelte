<script lang="ts">
  export let poolConfigError = '';
  export let info = '';
  export let error = '';
</script>

<div class="card centered">
  <div class="stack center">
    {#if poolConfigError}
      <div class="status error">{poolConfigError}</div>
    {/if}
    {#if info}
      <div class="status ok">{info}</div>
    {/if}
    {#if error}
      <div class="status error">{error}</div>
    {/if}
  </div>
</div>
