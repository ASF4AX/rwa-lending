<script lang="ts">
  import { onMount } from 'svelte';
  import { fetchLatestPrice, type PriceLatest } from '../lib/oracle';

  let data: PriceLatest | null = null;
  let loading = true;
  let error: string | null = null;
  let lastUpdated: Date | null = null;

  async function load() {
    loading = true;
    error = null;
    try {
      const controller = new AbortController();
      const t = setTimeout(() => controller.abort(), 8000);
      data = await fetchLatestPrice(controller.signal);
      lastUpdated = new Date();
      clearTimeout(t);
    } catch (e: any) {
      error = e?.message || 'failed to load oracle data';
    } finally {
      loading = false;
    }
  }

  onMount(load);

  function fmtTs(ts: number) {
    try { return new Date(ts * 1000).toISOString(); } catch { return String(ts); }
  }
  function short(sig: string) {
    if (!sig) return '';
    return sig.length > 12 ? `${sig.slice(0, 10)}…${sig.slice(-6)}` : sig;
  }
</script>

<section>
  <h2>Oracle Latest Price</h2>
  {#if loading}
    <p>Loading…</p>
  {:else if error}
    <p style="color:#b00">Error: {error}</p>
    <button on:click={load}>Retry</button>
  {:else if data}
    <div>
      <div>Round ID: <strong>{data.round_id}</strong></div>
      <div>Price: <strong>{data.price}</strong></div>
      <div>Timestamp: <strong>{data.timestamp}</strong> <small>({fmtTs(data.timestamp)})</small></div>
      <div>Signature: <code>{short(data.signature)}</code></div>
      {#if lastUpdated}
        <div style="margin-top:6px"><small>Last updated: {lastUpdated.toLocaleTimeString()}</small></div>
      {/if}
    </div>
    <button style="margin-top:8px" on:click={load}>Refresh</button>
  {/if}
</section>

<style>
  section { border: 1px solid #ddd; padding: 12px; border-radius: 8px; margin-top: 16px; }
  h2 { margin: 0 0 8px 0; font-size: 1.1rem; }
  code { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }
</style>
