# NR7_SHADOW_ATTRIBUTION_AND_EDGE_QUALITY_INTEGRATION_DESIGN_V1

**Status:** OFFLINE_FIRST_RECOMMENDED
**Date:** 2026-05-11
**Scope:** Gate 3 shadow-attribution design only. No source changes. No compile. No Codex. No MT5 reload.
**Predecessor:** NR7_VCR_GATE2_DESIGN_AND_EXECUTION_FEASIBILITY_REVIEW_V1 (GATE2_COMPLETE)
**Authority:** MT5 = runtime authority. Nautilus = research/certification lab only. All dev flags confirmed FALSE.

---

## A. Executive Verdict

```
NR7_SHADOW_ATTRIBUTION_OFFLINE_FIRST_RECOMMENDED
```

NR7 is fully deterministic from OHLCV. All required attribution measurements — VCR regime fit,
LOCATION proximity, STOP_GEOMETRY counterfactual — can be performed offline by reconstructing NR7
state from historical bar data and aligning with existing OL/PJ timestamps. No new runtime fields
are justified at this stage.

**Hard constraints driving this verdict:**

1. **Insufficient live N:** Current live OL count ~53–54 records. Attribution requires ≥30
   NR7-context trades and ≥30 non-NR7 trades for a meaningful split. This threshold is not met.
   Adding instrumentation before the threshold is met creates runtime overhead with no attribution
   payoff until the sample grows.

2. **Offline reconstruction is fully feasible:** NR7 state at any past OL timestamp is deterministic
   from OHLCV archive — 7 bar ranges, one comparison. No probabilistic reconstruction. No proxies.

3. **Field minimalism directive:** "Reuse first. Derive second. Add fields only when necessary."
   Every proposed runtime field fails the minimalism test against offline derivability.

**Recommended path:**

| Stage | Action | Authorized? |
|---|---|---|
| Gate 3A0 | Execute offline Python attribution scripts (OHLCV + OL + PJ) | YES — zero source changes |
| Gate 3B | Stop counterfactual extension (offline Python) | YES — follow-on to 3A0 |
| Gate 3A1 | Add nr7_active bool to OL at runtime | DEFERRED — await N≥30 confirmed + APPROVAL_GATE_3A1 |
| Gate 3C | Advisory NR7 annotation in council environment | NOT AUTHORIZED |
| Gate 3D | Live stop geometry override | NOT AUTHORIZED — requires Gate 3B evidence + APPROVAL_GATE_3D |
| Gate 3E | OCO ALPHA_TRIGGER strategy | NOT AUTHORIZED — OCO infrastructure + council capacity increase required |

---

## B. Source Architecture State (Inherited from Gate 2)

The following are Gate 2 findings relevant to shadow attribution design. No re-reading of source
files was required — these are carried forward from the Gate 2 review.

| Component | Gate 2 Finding | Attribution Relevance |
|---|---|---|
| `core_trade_engine.mqh:299-300` | Market orders only. Stop = `MathMax(brokerMinDistance, atrRaw * atrMultiplier)` | STOP_GEOMETRY counterfactual: compare `box_range + 2×cost` vs actual ATR stop |
| `council_mode_types.mqh:10` | `COUNCIL_MAX_STRATEGIES = 17` — at hard capacity | Any runtime NR7 strategy signal requires s18 slot (not authorized) |
| `council_aggregator.mqh:172` | OBSERVE_ONLY → weight × 0.15 | Unfiltered NR7 (30.89/day) distorts aggregate; box ≤ 40% ATR filter mandatory |
| `level_awareness_brake.mqh:77` | NR7 family = UNKNOWN → default ALLOW verdict | No LAB rule protects against NR7 over-voting until family designated |
| `runtime_honesty_surfaces.mqh` | All dev flags = FALSE confirmed | `runtime_authority_status = "NONE"` in all NR7 artifacts |
| Live OL count | ~53–54 records | Insufficient for meaningful NR7-context vs non-NR7 WR split |
| INEC results (inherited) | NR7 WR=58.3% (OCO), 69.3% (box ≤ 40% ATR filter), N=5,498 | VCR ALPHA_TRIGGER evidence already strong; INEC attribution is available now |

---

## C. Attribution Objectives

Seven functional attribution questions drive this design:

| # | Objective | Packet Role | Current Gap | NR7 Attribution Method |
|---|---|---|---|---|
| 1 | VCR regime NR7 fit | ALPHA_TRIGGER | VCR = PLAYBOOK_NOT_PRESENT | INEC: WR=69.3% at ATR filter confirmed; confirmatory OL split when N grows |
| 2 | LOCATION_PACKET evidence | LOCATION | event_order_valid=false everywhere | Offline: was NR7 box active at OL decision timestamp? |
| 3 | STOP_GEOMETRY counterfactual | STOP_GEOMETRY | stop_geometry_state=UNKNOWN | Offline: box_stop vs actual ATR stop vs MAE in PJ records |
| 4 | BREAKOUT_EXPANSION timing | TIMING | No TIMING_PACKET certified | Offline: NR7 bar present in T−N bars before breakout signal in OL |
| 5 | CONFIRMATION_PACKET evidence | CONFIRMATION | Zero CONFIRMATION_PACKETs certified | Offline: NR7 co-presence with existing signals in OL outcomes |
| 6 | Pre-decision context quality | LOCATION/TIMING | No pre-decision structure anchor | Offline: does NR7 context correlate with council quality scores? |
| 7 | Existing trade quality during NR7 | STOP_GEOMETRY/LOCATION | No structure annotation on PJ | Offline: PJ outcome split — NR7 active vs inactive at decision bar |

---

## D. Design Questions A–G

### Question A: Minimal Data for Offline Attribution

**What is the minimum data required to perform complete offline NR7 attribution?**

| Data Source | Required Fields | Availability | Notes |
|---|---|---|---|
| OHLCV M5 archive | timestamp, open, high, low, close | nautilus_lab export | ≥7 bars per decision point required |
| OL records | decision_timestamp, outcome, regime, zone, strategy_id, council quality fields | `MQL5/Files/AI/opportunity_ledger*.csv` | ~53–54 records |
| PJ records | entry_timestamp, entry_price, sl_price, tp_price, mae_pips | `MQL5/Files/AI/position_journal*.csv` | Links to OL via timestamp |

**NR7 reconstruction algorithm (offline, per decision timestamp T):**

```
1. Load M5 OHLCV bars at T, T-1, T-2, T-3, T-4, T-5, T-6
2. range[i] = high[i] - low[i] for each bar
3. nr7_active = (range[T] < min(range[T-1], range[T-2], ..., range[T-6]))
4. If nr7_active:
     box_high = high[T]
     box_low  = low[T]
     box_size = range[T]
     atr14    = ATR(14) at T from prior 14 ranges
     box_pct_atr = box_size / atr14
```

Nothing else needed. This is the complete data requirement. Fully deterministic. No ambiguity.

---

### Question B: VCR Attribution

**How do we establish NR7's fit in the VOLATILITY_COMPRESSION_RELEASE regime offline?**

The INEC certification already provides strong evidence:

| Metric | Value | Source |
|---|---|---|
| NR7 WR (baseline OCO) | 58.3% | INEC Variant A |
| NR7 WR (box ≤ 40% ATR filter) | 69.3% | INEC rate-limit analysis |
| NR7 fire rate at filter | ~5.4/day | INEC |
| Walk-forward: train WR | 57.8% | INEC walk-forward |
| Walk-forward: test WR | 59.0% | INEC walk-forward |
| All months positive | YES | INEC monthly breakdown |
| NR7 = compression definition | Box = NR7 high/low = compression range | By mathematical construction |

**VCR attribution verdict:** INEC evidence alone is sufficient to classify NR7 as ALPHA_TRIGGER_PACKET
for VCR regime. The offline OL split will be confirmatory only — it cannot add to this evidence until
VCR regime OL records grow from near-zero (VCR = PLAYBOOK_NOT_PRESENT means almost no VCR trades
exist yet in live OL).

**Runtime field requirement:** NONE.

---

### Question C: LOCATION Attribution

**How do we measure NR7 as a LOCATION_PACKET offline?**

**Hypothesis:** If an NR7 box was active at the council decision bar, the trade has pre-decision
structural context (price is compressed within a defined range). This should improve subsequent WR
by ≥+3pp vs trades without NR7 context.

**Offline measurement design:**

```
For each OL record at timestamp T:
  1. Reconstruct NR7 state (Question A algorithm)
  2. Record: nr7_at_decision = true/false
  3. Record: proximity_to_box = distance(open[T], nearest box boundary) / box_size
             (only meaningful if nr7_at_decision = true)

Split outcomes:
  WR(nr7_active)   vs   WR(nr7_inactive)
  E[R](nr7_active) vs   E[R](nr7_inactive)

Secondary: proximity buckets
  Bucket A: open[T] within 0.5× box_size of boundary
  Bucket B: open[T] within 1.0× box_size of boundary
  Bucket C: open[T] beyond 1.0× box_size of boundary
```

**Acceptance threshold (LOCATION_PACKET):** WR lift ≥+3pp, N ≥30 NR7-context records.

**Current feasibility:** With ~53 total OL records, the NR7-context subsample likely contains 10–20
records (rough estimate based on NR7 fire rate vs bar count). The methodology is ready. The measurement
should be run now as a baseline; significance is unlikely but direction will be informative.

**Runtime field requirement:** NONE — all derivable offline from OHLCV + OL timestamp.

---

### Question D: STOP_GEOMETRY Attribution

**How do we measure NR7 STOP_GEOMETRY_PACKET quality offline?**

**Hypothesis:** When NR7 is active, replacing the ATR-based stop with `box_range + 2×cost` produces
tighter, structurally-sound stops that reduce MAE without increasing premature stop-outs.

**Offline counterfactual design:**

```
For each PJ trade with entry timestamp T:
  1. Reconstruct NR7 state at T
  2. If nr7_active:
       box_stop_distance = box_size + 2 × spread_cost  (10pt + 2pt = 12pt base cost model)
       actual_stop_distance = abs(entry_price - sl_price)  [from PJ record]
       mae = mae_pips × pip_value  [from PJ record]

Compute metrics for NR7-active trades:
  tighter_stop_rate        = fraction where box_stop_distance < actual_stop_distance
  box_contains_mae_rate    = fraction where mae < box_stop_distance
  premature_stop_rate      = fraction of stopped trades where stop < box_size
                             (i.e., stop was triggered within compression range)
```

**Acceptance threshold (STOP_GEOMETRY_PACKET):** MAE reduction ≥−0.10R (vs ATR stop baseline),
no WR decrease, `box_contains_mae_rate` ≥60%.

**Even with small N:** Stop counterfactual is directional — even 10–15 NR7-context PJ trades give
useful signal. Run Gate 3B alongside 3A0.

**Runtime field requirement:** NONE — PJ has entry_price + sl_price (sufficient for ATR stop distance).
MAE available in PJ. NR7 box reconstructed offline.

---

### Question E: BREAKOUT/TIMING Attribution

**How do we measure NR7 as a TIMING_PACKET for BREAKOUT_EXPANSION regime offline?**

**Hypothesis:** If an NR7 bar appeared N bars before a breakout signal fired, the subsequent trade
has better timing (compression preceded expansion). This should improve WR by ≥+2pp.

**Offline measurement design:**

```
Filter OL records where zone = BREAKOUT or regime = BREAKOUT_EXPANSION

For each such record at timestamp T:
  Reconstruct NR7 state at T-1, T-2, T-3, T-5, T-10
  Define: nr7_preceded[N] = true if NR7 bar existed within N bars before T

Split BREAKOUT zone outcomes by nr7_preceded:
  WR(nr7_preceded, N=1) vs WR(not_preceded)
  WR(nr7_preceded, N=3) vs WR(not_preceded)
  WR(nr7_preceded, N=5) vs WR(not_preceded)
```

**Current feasibility:** BREAKOUT_EXPANSION regime OL records are likely sparse. Methodology is
ready. Blocked by insufficient N.

**Runtime field requirement:** NONE.

---

### Question F: Pre-Decision Context Quality

**How do we measure whether NR7 context improves council decision quality offline?**

**Hypothesis:** NR7 compression signals coherent price structure. When NR7 is active at decision
time, the council's environment report may be more reliable — tighter range correlates with cleaner
zone identification and higher zone_confidence.

**Offline measurement design:**

```
For each OL record at timestamp T:
  1. Reconstruct NR7 state
  2. Extract from OL: consensus_score, env_score, zone_confidence, council_quality_composite

Compare distributions:
  council_quality_composite: NR7 active vs inactive
  zone_confidence:           NR7 active vs inactive
  consensus_score:           NR7 active vs inactive
  env_score:                 NR7 active vs inactive

Test: does NR7 active → higher zone_confidence?
      does NR7 active → tighter consensus_score distribution?
```

This analysis has no minimum N threshold for running — even with N=53 total, distributional
comparison is informative. It does not require significance to be actionable: a consistent
directional signal across all 4 quality metrics supports LOCATION_PACKET candidacy.

**Runtime field requirement:** NONE — all council quality fields are already in OL records.

---

### Question G: Runtime Burden Assessment

**What is the runtime cost of each attribution option?**

| Option | Runtime Cost | Attribution Value | Recommendation |
|---|---|---|---|
| Gate 3A0 — Offline only | ZERO | Full historical attribution | RECOMMENDED NOW |
| Gate 3A1 — nr7_active bool in OL | Negligible (~0.1ms at bar-close) | Eliminates need for OHLCV sync at N≥30 | DEFERRED — not justified until N≥30 |
| Gate 3B — Stop counterfactual | ZERO (offline Python) | MAE vs box_stop measurement | FOLLOW-ON to 3A0 |
| Gate 3C — Advisory NR7 in council env | Medium (NR7 computed every M5 bar) | Council-level annotation | NOT AUTHORIZED |
| Gate 3D — Live stop override | Medium + production risk | Production quality change | NOT AUTHORIZED |
| Gate 3E — OCO ALPHA_TRIGGER | High + infrastructure rebuild | Full edge deployment | NOT AUTHORIZED |

**Verdict on runtime burden:** Gate 3A0 has zero overhead and provides full attribution value.
No new runtime fields are justified until live OL records accumulate to ≥30 NR7-context trades.
Adding instrumentation early does not accelerate accumulation — accumulation rate is governed by
live trading frequency, not by logging infrastructure.

---

## E. Offline Attribution Pipeline Design (Gate 3A0)

### E1. Python Implementation Specification

**Script 1:** `nautilus_lab/nr7_attribution_offline.py`

```python
# NR7 offline attribution pipeline — OHLCV + OL alignment
# Purpose: Reconstruct NR7 state at each OL decision timestamp
#          Output: enriched OL with nr7_active, box_high, box_low, box_size, box_pct_atr
# Source changes: NONE. Read-only.

def reconstruct_nr7(ohlcv_df, timestamp):
    """
    Returns NR7 state at given timestamp.
    Requires 7 bars: bar at T and T-1 through T-6.
    """
    bars = ohlcv_df.loc[:timestamp].tail(7)
    if len(bars) < 7:
        return None  # insufficient history
    ranges = (bars['high'] - bars['low']).values
    current_range = ranges[-1]
    prior_ranges  = ranges[:-1]
    nr7_active = current_range < prior_ranges.min()
    return {
        'nr7_active':     nr7_active,
        'box_high':       bars['high'].iloc[-1] if nr7_active else None,
        'box_low':        bars['low'].iloc[-1]  if nr7_active else None,
        'box_size':       current_range          if nr7_active else None,
        'box_pct_atr':    current_range / compute_atr14(bars) if nr7_active else None,
    }

def run_attribution(ohlcv_path, ol_path, output_path):
    ohlcv = pd.read_csv(ohlcv_path, parse_dates=['timestamp'])
    ol    = pd.read_csv(ol_path,    parse_dates=['decision_timestamp'])

    enriched = []
    for _, record in ol.iterrows():
        state = reconstruct_nr7(ohlcv.set_index('timestamp'),
                                record['decision_timestamp'])
        enriched.append({**record.to_dict(), **(state or {})})

    pd.DataFrame(enriched).to_csv(output_path, index=False)

    # Attribution summary
    df = pd.DataFrame(enriched)
    nr7_on  = df[df['nr7_active'] == True]
    nr7_off = df[df['nr7_active'] == False]

    print(f"Total OL records:  {len(df)}")
    print(f"NR7 active:        {len(nr7_on)} ({100*len(nr7_on)/len(df):.1f}%)")
    print(f"WR (NR7 active):   {nr7_on['outcome_win'].mean():.3f}")
    print(f"WR (NR7 inactive): {nr7_off['outcome_win'].mean():.3f}")
    print(f"WR lift:           {nr7_on['outcome_win'].mean() - nr7_off['outcome_win'].mean():+.3f}")
```

**Script 2:** `nautilus_lab/nr7_stop_counterfactual.py`

```python
# NR7 stop geometry counterfactual — OHLCV + PJ alignment
# Purpose: Compare box_stop vs actual ATR stop vs MAE for each PJ trade
# Source changes: NONE. Read-only.

SPREAD_COST = 10  # points (from INEC cost model)
SLIP_COST   =  2  # points

def run_stop_counterfactual(ohlcv_path, pj_path, output_path):
    ohlcv = pd.read_csv(ohlcv_path, parse_dates=['timestamp'])
    pj    = pd.read_csv(pj_path,    parse_dates=['entry_timestamp'])

    results = []
    for _, trade in pj.iterrows():
        state = reconstruct_nr7(ohlcv.set_index('timestamp'),
                                trade['entry_timestamp'])
        actual_stop = abs(trade['entry_price'] - trade['sl_price'])
        mae         = trade['mae_pips'] * pip_value(trade['symbol'])
        box_stop    = (state['box_size'] + SPREAD_COST + SLIP_COST
                       if state and state['nr7_active'] else None)
        results.append({
            **trade.to_dict(),
            'nr7_active':          state['nr7_active'] if state else False,
            'box_stop':            box_stop,
            'actual_stop':         actual_stop,
            'tighter':             (box_stop < actual_stop) if box_stop else None,
            'box_contains_mae':    (mae < box_stop)         if box_stop else None,
        })

    df = pd.DataFrame(results)
    nr7_trades = df[df['nr7_active'] == True]
    print(f"NR7-context trades:    {len(nr7_trades)}")
    print(f"Tighter stop rate:     {nr7_trades['tighter'].mean():.3f}")
    print(f"Box contains MAE rate: {nr7_trades['box_contains_mae'].mean():.3f}")
    df.to_csv(output_path, index=False)
```

### E2. Data File Paths

| File | Path | Notes |
|---|---|---|
| OHLCV M5 | `MQL5/Files/AI/xauusd_m5_ohlcv.csv` | Re-export from nautilus_lab if >30 days stale |
| OL records | `MQL5/Files/AI/opportunity_ledger*.csv` | ~53–54 records currently |
| PJ records | `MQL5/Files/AI/position_journal*.csv` | Links to OL via entry_timestamp |
| Attribution output | `nautilus_lab/nr7_attribution_results.csv` | New file; not a runtime artifact |
| Stop counterfactual output | `nautilus_lab/nr7_stop_counterfactual_results.csv` | New file; not a runtime artifact |

### E3. Accumulation Thresholds

| Threshold | Meaning | Current Status |
|---|---|---|
| N ≥ 30 NR7-context OL records | Minimum for LOCATION attribution significance | NOT MET — run 3A0 to measure actual count |
| N ≥ 30 non-NR7 OL records | Control group for WR split | POSSIBLY MET |
| N ≥ 15 NR7-context PJ trades | Minimum for directional stop counterfactual | LIKELY NOT MET |
| N ≥ 50 NR7-context OL records | ADEQUATE attribution evidence | NOT MET |

Run 3A0 immediately to determine actual NR7-context count. Even if below threshold, the directionality
of the split is informative and establishes the baseline for future measurement.

---

## F. Required Matrices

### Matrix 1: Functional Gap → NR7 Evidence Matrix

| System Gap | Gap Severity | NR7 Packet Role | Evidence Type | Attribution Method | Current Evidence Quality | Gate |
|---|---|---|---|---|---|---|
| ZERO CONFIRMATION_PACKET | CRITICAL | CONFIRMATION | Co-presence WR lift ≥+2pp AND E[R] lift ≥+0.04R | OL split: NR7 active AND existing signal present | INSUFFICIENT (N~53 total; split likely N<10) | 3A0 baseline |
| VCR playbook absent | HIGH | ALPHA_TRIGGER | Regime WR ≥40%, N≥50 | INEC (N=5,498) — already measured, WR=69.3% at ATR filter | STRONG — INEC sufficient | Already available |
| event_order_valid=false | HIGH | LOCATION | Pre-decision WR lift ≥+3pp | OL split: nr7_active at decision timestamp | INSUFFICIENT (N~53; run 3A0 to measure) | 3A0 |
| room_state=UNKNOWN | MEDIUM | ROOM | Box range vs target distance ratio | PJ: box_size vs tp_distance | PARTIAL — run 3B | 3B |
| stop_geometry_state=UNKNOWN | MEDIUM | STOP_GEOMETRY | MAE reduction ≥−0.10R; box_contains_mae ≥60% | PJ counterfactual: box_stop vs ATR stop | PARTIAL — run 3B | 3B |
| BREAKOUT timing gap | MEDIUM | TIMING | WR lift ≥+2pp for nr7_preceded trades | OL BREAKOUT zone: NR7 in T−N bars | INSUFFICIENT (sparse BREAKOUT records) | 3A0 |
| EXHAUSTION/FAILURE signal | MEDIUM | FAILURE_MODE | E[R] degradation ≥−0.06R | OL: does NR7 active → worse in reversal regime? | INSUFFICIENT — diagnostic only | 3A0 |

### Matrix 2: Field Minimalism Matrix

For each candidate runtime field, the minimalism decision test:

| Field | Description | In Existing OL Schema? | Derivable Offline from OHLCV? | Runtime Cost | Compact Encoding | Minimum Condition to Add | Decision |
|---|---|---|---|---|---|---|---|
| `nr7_active` (bool) | Was NR7 bar present at decision | NO | YES — deterministic from 7 OHLCV bars | Negligible (1 bool write at bar-close) | 1 bit | Live N≥30 NR7-context in OL unreachable without tagging AND offline confirms directional signal | DEFER: run 3A0 first; reconsider at confirmed N≥20 |
| `nr7_box_high` (double) | NR7 box ceiling | NO | YES — bar.high if nr7_active | Low | double | Only needed for Gate 3D live stop override | NOT NOW — Gate 3D not authorized |
| `nr7_box_low` (double) | NR7 box floor | NO | YES | Low | double | Same as nr7_box_high | NOT NOW |
| `nr7_box_size_pct_atr` (float) | Box as % of ATR | NO | YES | Low | float16 sufficient | Only needed for advisory rate-limit enforcement (Gate 3C) | NOT NOW — Gate 3C not authorized |
| `nr7_bars_since` (int) | Bars since last NR7 | NO | YES — derivable from OHLCV scan | Negligible | int8 | Only needed for TIMING_PACKET lookback window | NOT NOW |
| `council_nr7_context` (struct) | NR7 annotation on council environment | NO | NO — requires runtime | Medium (compute every bar) | New struct field | Gate 3C advisory only | NOT AUTHORIZED |
| `stop_override` (double) | Modified stop distance when NR7 active | NO | NO — requires runtime context | Medium + production risk | double | Gate 3D live override; requires Gate 3B evidence first | NOT AUTHORIZED |

**Summary: Zero new runtime fields are justified now.** All attribution measurements can be
performed offline. The only conditionally-acceptable minimal field is `nr7_active` (1 bool),
but it is not needed until offline attribution confirms directional signal AND N≥20 NR7-context
OL records are confirmed present.

### Matrix 3: Attribution Measurement Matrix

| Measurement | Source Data | Offline Method | Accept Threshold | Current N | Feasibility | Action |
|---|---|---|---|---|---|---|
| WR split: NR7 active vs inactive | OL outcomes + OHLCV | Reconstruct NR7 at each OL timestamp; split by nr7_active | ≥+3pp WR lift (LOCATION_PACKET) | ~53 total; NR7-context unknown | DEFERRED — run 3A0, expect N < threshold | Run 3A0 immediately |
| E[R] split: NR7 active vs inactive | OL E[R] + OHLCV | Same split | ≥+0.04R lift | Same | DEFERRED | Run 3A0 immediately |
| Stop geometry counterfactual | PJ + OHLCV | box_stop vs ATR stop; MAE comparison | MAE reduction ≥−0.10R; box_contains_mae ≥60% | PJ trades; ~N/A | DIRECTIONAL — run 3B even at small N | Run 3B after 3A0 |
| VCR regime NR7 presence | INEC (existing) | Already measured — N=5,498 | WR ≥40% in VCR regime | 5,498 INEC records | AVAILABLE NOW — no additional measurement needed | Reference INEC |
| BREAKOUT timing (NR7 preceded) | OL BREAKOUT zone + OHLCV | NR7 in T−N bars before breakout signal | ≥+2pp WR lift | Sparse BREAKOUT records | DEFERRED — diagnostic only | Run 3A0 as baseline |
| CONFIRMATION co-presence | OL + OHLCV | NR7 active AND existing signal fired at same bar | ≥+2pp WR lift; co-presence rate <80% | ~53 total | DEFERRED — run 3A0 to count co-presence events | Run 3A0 immediately |
| Council quality correlation | OL quality fields + OHLCV | Correlate nr7_active with quality scores | Any consistent direction | ~53 total | RUN NOW — no minimum N for correlation | Run 3A0 immediately |
| Pre-decision event order | OL event_order + OHLCV | Does nr7_active precede trigger correctly? | Diagnostic — no threshold | ~53 total | RUN NOW — diagnostic | Run 3A0 immediately |

### Matrix 4: Implementation Envelope Matrix

| Gate | Name | Scope | Source Files Changed | New OL Fields | Runtime Overhead | Operator Authorization Required | Status |
|---|---|---|---|---|---|---|---|
| 3A0 | Offline attribution only | Python scripts in nautilus_lab; read-only | NONE | NONE | ZERO | Not required | AUTHORIZED — RECOMMENDED NOW |
| 3A1 | Minimal OL annotation | Write nr7_active bool at OL record creation | `council_mode_runtime.mqh` (1 bool write) | `nr7_active` (1 bool) | Negligible | APPROVAL_GATE_3A1 required | DEFERRED — await 3A0 results + N≥20 confirmed |
| 3B | Stop geometry counterfactual | Offline Python extension of 3A0 | NONE | NONE | ZERO | Not required | AUTHORIZED — follow-on to 3A0 |
| 3C | Advisory NR7 in council environment | Read-only annotation of council env struct | `council_mode_types.mqh` + `council_mode_runtime.mqh` | NR7 env fields | Medium (NR7 computed every M5 bar) | APPROVAL_GATE_3C | NOT AUTHORIZED |
| 3D | Live stop geometry override | Replace ATR stop with box stop when NR7 active | `core_trade_engine.mqh:299-300` | Box context fields | Medium + production risk | APPROVAL_GATE_3D | DEFERRED — requires Gate 3B evidence; separate Codex mission |
| 3E | OCO ALPHA_TRIGGER strategy | New pending-order strategy slot | New OCO module + all council files + s18 slot | Strategy slot expansion | High + infrastructure | APPROVAL_GATE_3E | DEFERRED — OCO infrastructure not built; COUNCIL_MAX_STRATEGIES increase required |

---

## G. Gate 3A0 — What to Run Now

The following analyses are executable immediately with zero source changes:

| Analysis | Script | Inputs | Output | Expected Finding |
|---|---|---|---|---|
| NR7 state reconstruction + WR split | `nr7_attribution_offline.py` | OHLCV M5 + OL CSV | `nr7_context_per_ol_record.csv` + `attribution_summary.csv` | ~10–25% of OL records may have NR7 active; split likely N < threshold but directional |
| Council quality correlation | Same script, additional section | OHLCV + OL quality fields | `quality_correlation.csv` | Diagnostic — no threshold |
| Stop counterfactual | `nr7_stop_counterfactual.py` | OHLCV M5 + PJ CSV | `stop_geometry_counterfactual.csv` | Directional: box_stop likely tighter than ATR stop for most NR7-context trades |
| BREAKOUT timing | `nr7_attribution_offline.py`, breakout section | OHLCV + OL (BREAKOUT zone filter) | `breakout_timing_attribution.csv` | Likely N too sparse; record as baseline |
| INEC VCR confirmation | Reference existing INEC results | INEC output | N/A | WR=69.3% at ATR filter — already confirmed |

---

## H. Gate 3A1 Trigger Conditions

Gate 3A1 (adding `nr7_active` bool to OL records at runtime) is conditionally valid if ALL of:

1. **N condition:** Gate 3A0 offline attribution confirms ≥20 NR7-context OL records have accumulated
   (indicating offline method will reach the 30-record threshold within 1–2 months of live trading)
2. **Value condition:** At least one attribution measurement shows consistent directional signal
   (even if not statistically significant at N=20)
3. **Cost condition:** The only source change is writing 1 bool to the OL record in
   `council_mode_runtime.mqh` — no new compute, no council pipeline changes, no struct changes
4. **Operator authorization:** APPROVAL_GATE_3A1 explicitly granted after reviewing Gate 3A0 results

**Gate 3A1 is not authorized by this document.** It is a future checkpoint defined here so its
scope is unambiguous when the time comes.

---

## I. STOP_GEOMETRY_PACKET — Gate 3D Design Reference (Deferred)

This section documents the live implementation integration point so it is ready when authorized.
This is design-only — no authorization claimed.

**Source change required:** `core_trade_engine.mqh:299-300`

Current code:
```cpp
double atrDistance    = atrRaw * atrMultiplier;                       // line 299
double finalStopDist  = MathMax(brokerMinDistance, atrDistance);      // line 300
```

Gate 3D override (when authorized — not now):
```cpp
double baseDistance;
if(nr7_ctx.active && (nr7_ctx.box_size + 2*COST) < atrRaw * atrMultiplier)
    baseDistance = nr7_ctx.box_size + 2 * COST;   // STOP_GEOMETRY_PACKET: box_range + 2×cost
else
    baseDistance = atrRaw * atrMultiplier;         // existing ATR logic unchanged
double finalStopDist = MathMax(brokerMinDistance, baseDistance);
```

**Gate 3D authorization requires in sequence:**
1. Gate 3B stop counterfactual completed: `box_contains_mae_rate` ≥60% confirmed in PJ data
2. N ≥30 NR7-context PJ trades with counterfactual evidence
3. Operator explicit APPROVAL_GATE_3D authorization
4. Separate Codex implementation mission (not this document)

---

## J. Forbidden Actions in This Mission

This is a read-only design document. The following are explicitly excluded:

- No source (.mqh) file changes of any kind
- No compile
- No MT5 reload
- No new runtime fields added to any file
- No strategy added to council pipeline
- No council pipeline modifications
- No stop geometry override activated
- No advisory NR7 signal wired into council
- No Codex implementation tasks
- No APPROVAL_GATE_3A1/3C/3D/3E claims
- `runtime_authority_status = "NONE"` in all NR7 artifacts

---

## K. Next Actions

| Priority | Action | Authorized? | Gate | Requires |
|---|---|---|---|---|
| 1 | Execute Gate 3A0: run offline NR7 attribution Python scripts | YES | 3A0 | OHLCV export, OL + PJ CSVs |
| 2 | Execute Gate 3B: stop geometry counterfactual extension | YES | 3B | Follows 3A0 |
| 3 | Monitor OL accumulation — check NR7-context count monthly | YES — passive | Ongoing | Live trading continuation |
| 4 | Gate 3A1: request APPROVAL_GATE_3A1 when N≥20 NR7-context confirmed offline | NOT YET | 3A1 | Gate 3A0 results + operator authorization |
| 5 | Gate 3D: STOP_GEOMETRY live override | NOT AUTHORIZED | 3D | Gate 3B evidence + APPROVAL_GATE_3D + Codex mission |
| 6 | Gate 3C: advisory NR7 in council | NOT AUTHORIZED | 3C | Separate operator authorization |
| 7 | Gate 3E: OCO ALPHA_TRIGGER | NOT AUTHORIZED | 3E | OCO infrastructure + COUNCIL_MAX_STRATEGIES increase |

---

## L. Verdict Summary

```
VERDICT:   NR7_SHADOW_ATTRIBUTION_OFFLINE_FIRST_RECOMMENDED

RATIONALE:
  1. NR7 is deterministic from OHLCV — no ambiguity in offline reconstruction
  2. Current OL count (~53) is insufficient for WR attribution regardless of instrumentation
  3. Offline methodology covers all 7 attribution objectives (D1–D7) without runtime cost
  4. Field minimalism test: every proposed field is either derivable offline or not yet authorized
  5. Operator stated preference: "Do not implement any new NR7 runtime fields yet"
  6. Gate 3A0 + 3B are executable immediately with zero source changes

BLOCKED BY:
  - Gate 3A1: insufficient N; offline first
  - Gate 3C: not authorized; council modification required
  - Gate 3D: not authorized; requires Gate 3B evidence first
  - Gate 3E: not authorized; OCO infrastructure absent

NEXT GATE:  GATE_3A0 — Offline attribution scripts in nautilus_lab (no authorization required)
```

---

## M. Metadata

```
DOCUMENT_ID:                NR7_SHADOW_ATTRIBUTION_AND_EDGE_QUALITY_INTEGRATION_DESIGN_V1
DATE:                       2026-05-11
PREDECESSOR:                NR7_VCR_GATE2_DESIGN_AND_EXECUTION_FEASIBILITY_REVIEW_V1
STATUS:                     DESIGN_COMPLETE
VERDICT:                    NR7_SHADOW_ATTRIBUTION_OFFLINE_FIRST_RECOMMENDED
SOURCE_CHANGED:             NO
COMPILE_RUN:                NO
MT5_RELOAD:                 NO
RUNTIME_FILES_MODIFIED:     NO
NEW_RUNTIME_FIELDS:         NONE
CODEX_INVOLVED:             NO
PRODUCTION_READY_CLAIMED:   NO
RUNTIME_AUTHORITY_STATUS:   NONE
SYSTEM_STATUS:              DEVELOPING
GATE_3A0_STATUS:            AUTHORIZED_PENDING_EXECUTION
GATE_3A1_STATUS:            DEFERRED — await 3A0 results + N≥20 NR7-context OL confirmed + APPROVAL_GATE_3A1
GATE_3B_STATUS:             AUTHORIZED_PENDING_EXECUTION — follow-on to 3A0
GATE_3C_STATUS:             NOT_AUTHORIZED
GATE_3D_STATUS:             NOT_AUTHORIZED — requires Gate 3B evidence + APPROVAL_GATE_3D
GATE_3E_STATUS:             NOT_AUTHORIZED — OCO infrastructure absent + council capacity at cap
```
