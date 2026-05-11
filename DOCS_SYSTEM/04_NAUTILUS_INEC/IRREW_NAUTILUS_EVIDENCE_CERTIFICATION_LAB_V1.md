# IRREW_NAUTILUS_EVIDENCE_CERTIFICATION_LAB_V1

**Lab type:** OFFICIAL_EVIDENCE_CERTIFICATION_ENVIRONMENT
**Short name:** INEC_LAB_V1
**Date established:** 2026-05-09
**Authority:** EVIDENCE_ONLY — No MT5 source change. No runtime change. No strategy change. No weight change.
**Governed by:** PROJECT_INTELLIGENCE_MEMORY_LAYER.md (PIML) — sole authoritative project memory
**System status:** DEVELOPING — unchanged
**Runtime authority:** V1 (MT5 EA) — permanent; not transferred to this lab or any lab output
**Lab path:** `C:\Users\INFINTY GROUP\Documents\nautilus_lab\`
**Engine:** NautilusTrader | Python 3.14.3
**Data:** XAUUSD M1 + M5 OHLCV (2025-11-07 → 2026-05-07)

---

## 1. Executive Summary

This document is the official definition and operational specification of the **IRREW Nautilus Evidence Certification Lab V1** (INEC_LAB_V1) — the reusable offline evidence and certification environment for the MT5/IRREW project.

The lab exists to solve a structural problem in evidence-based system development: MT5 can only produce live evidence when the market is open, when conditions match the strategy's trigger context, and when enough bars have elapsed to accumulate statistically meaningful samples. This creates a working constraint in which architecture decisions are regularly blocked by evidence gaps that cannot be closed quickly through live trading alone.

INEC_LAB_V1 addresses this by providing a structured, repeatable, source-faithful offline replay environment capable of generating certification-grade evidence across four levels: standalone strategy certification, packet and playbook certification, system compatibility assessment, and shadow policy candidate evaluation.

**What this lab is:**
- The official reusable Nautilus-based evidence environment for the MT5/IRREW project
- A structured offline certification layer that generates evidence to inform (but never replace) MT5 runtime validation
- A blocking screen for new strategy admission — no strategy enters MT5 without passing through this lab
- An evidence source for all shadow policy candidate evaluation (SPC-001 through SPC-010 and future SPCs)
- A regression replay surface for verifying that source changes did not alter strategy behavior

**What this lab is not:**
- A runtime authority of any kind
- A strategy admission approval (evidence here is input to operator decision, not authorization itself)
- A replacement for MT5 live runtime validation
- A weight-change, gate-change, or posture-change authority
- A production-readiness certification body

**Current lab state:** 8 strategies formally edge-classified; 1 strategy Nautilus-run but DATA_INSUFFICIENT; 9 strategies uncertified; 1 strategy FROZEN (no Nautilus run needed). Three playbooks registered: RBSR = PLAYBOOK_FORMING; TPC = PLAYBOOK_FORMING; VCR = PLAYBOOK_NOT_PRESENT. Composite RBSR playbook pilot test completed. VWAP candidate tested and rejected. TSMOM benchmark completed. System status: DEVELOPING.

---

## 2. Lab Identity and Naming

### 2.1 Official Name

```
IRREW_NAUTILUS_EVIDENCE_CERTIFICATION_LAB_V1
```

### 2.2 Short Name

```
INEC_LAB_V1
```

### 2.3 Why This Name Supersedes NAUTILUS_PCEA_OFFLINE_VALIDATION_LAB_V1

The prior informal name was too narrow in three ways:

| Limitation | Old framing | INEC_LAB_V1 framing |
|---|---|---|
| Scope | PCEA-only — implied only playbook shadow validation | Full lab — strategy, packet, playbook, SPC, regression, admission |
| System tie | Not tied to the current phase | Tied to IRREW architecture phase explicitly |
| Reusability | One-time or per-task framing | Permanent reusable environment for all future certifications |
| Evidence authority | Validation-sounding (implies authority) | Certification-sounding (implies evidence without authority) |
| Production evidence | Not referenced | Explicitly supports production-readiness evidence accumulation |

### 2.4 Identity Fields

| Field | Value |
|---|---|
| Official name | IRREW_NAUTILUS_EVIDENCE_CERTIFICATION_LAB_V1 |
| Short name | INEC_LAB_V1 |
| Version | V1 |
| Lab path | `C:\Users\INFINTY GROUP\Documents\nautilus_lab\` |
| Engine | NautilusTrader |
| Python version | 3.14.3 |
| Data symbol | XAUUSD |
| Data timeframes | M1 + M5 |
| Data source | GC=F (CME Gold Futures proxy — PARTIAL_REPLICATION for all certs) |
| Data range (current) | 2025-11-07 to 2026-05-07 (daily extension required as time passes) |
| MT5 data export method | MetaEditor64 → CSV |
| Cost model | Spread = 10pt; Slippage = 2pt; SL = ATR14(M1,Wilder,shift=1) × 1.20; RR = 1.50 |
| Breakeven WR | 40.0% |
| Authority | EVIDENCE_ONLY — no MT5 source, weight, gate, or execution authority |
| PIML governed | YES — every certification finding must be traceable to PIML or registry entry |

---

## 3. Lab Mission

To produce **repeatable, source-faithful, evidence-disciplined offline certifications** that determine, for any strategy, packet, playbook, or shadow policy candidate:

1. Whether the strategy has standalone or segment-qualified edge value
2. Whether the strategy contributes measurable value inside a playbook causal chain
3. Whether the strategy or packet is compatible with the MT5/IRREW architecture
4. Whether a proposed shadow policy would have helped historically without creating starvation or hidden authority risk

All lab output is evidence. No lab output is authorization.

---

## 4. Lab Scope and Non-Scope

### 4.1 Allowed

- Historical OHLCV replay (M1 + M5) against clean XAUUSD/GC=F data
- Source-faithful strategy trigger replication in Python
- Proxy replication with documented proxy gaps (classified PARTIAL_REPLICATION or BEHAVIORAL_PROXY)
- Standalone strategy certification (variants A/B/C/D as needed)
- Regime, direction, month, session, early/late segmentation
- Slippage stress testing (+10pt spread above base)
- Walk-forward splits (60/40) when N ≥ 30
- Outlier exclusion sensitivity testing (best/worst 3 trades)
- Co-presence analysis for packet and playbook certification
- Causal chain contribution measurement
- Shadow policy simulation from ledger records
- Rejection rule testing (verify that a strategy fails the expected rejection criterion)
- Benchmarking against naive regime-direction baseline (TSMOM proxy)
- Composite playbook replay (multiple strategies co-present)
- VWAP and other alternative candidate screening (before admission consideration)
- Regime-conditioned eligibility matrix (RCEM) evidence generation
- Data-period robustness (extending data range)
- Broker/cost sensitivity analysis

### 4.2 Forbidden

- Any MT5 source file changes (`council_strategies.mqh`, `council_mode_runtime.mqh`, `council_mode_types.mqh`, all other `.mqh` files, `main_ea.mq5`, all `.set` files)
- Any runtime JSON/JSONL file changes (`ai_opportunity_ledger.jsonl`, `ai_strategy_memory.json`, `ai_performance_journal.jsonl`, `ai_opportunity_summary.json`, any other runtime file)
- Runtime authority transfer to any Nautilus output
- Strategy promotion, demotion, or weight change based on lab output alone
- Gate, score, or CRR/DSN changes based on lab output alone
- Live trading within the lab environment
- Using synthetic or inventedprices as data
- Claiming production-ready status from any lab result
- Automatic strategy admission (operator authorization always required separately)
- Circumventing PIML governance rules (REG.1–REG.9, GF-1 through GF-12)

---

## 5. Lab Architecture

### 5.1 Layer Model

```
┌─────────────────────────────────────────────────────┐
│ INEC_LAB_V1 Architecture                            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Layer 1 — DATA LAYER                               │
│  Clean XAUUSD M1 + M5 OHLCV CSV                     │
│  Spread/cost model. Broker proxy caveat documented. │
│                                                     │
│  Layer 2 — SOURCE REPLICATION LAYER                 │
│  Python faithful replication of MQL5 trigger logic  │
│  Replication class assigned per strategy            │
│  Proxy gaps documented per field                    │
│                                                     │
│  Layer 3 — CERTIFICATION LAYER                      │
│  Standalone strategy cert (Level 1)                 │
│  Packet + playbook cert (Level 2)                   │
│  Shadow policy evaluation (Level 4)                 │
│                                                     │
│  Layer 4 — SYSTEM COMPATIBILITY LAYER               │
│  Registry fit, playbook fit, EOC fit (Level 3)      │
│  Runtime visibility, starvation, authority risk     │
│                                                     │
│  Layer 5 — REPORTING LAYER                          │
│  Standardized MD reports, JSON metrics, CSV trades  │
│  Manifests, templates, compatibility reports        │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 5.2 Data Layer Details

| Component | Detail |
|---|---|
| Primary data source | `XAUUSD_M1_20251107_20260507.csv` (in `nautilus_lab/data/`) |
| Secondary data source | `XAUUSD_M5_20251107_20260507.csv` (in `nautilus_lab/data/`) |
| Proxy status | GC=F CME Gold Futures — PARTIAL_REPLICATION proxy for XAUUSD (broker spread differences) |
| M1 bar count | SOURCE_READ_REQUIRED (check CSV row count) |
| M5 bar count | SOURCE_READ_REQUIRED (check CSV row count) |
| Cost model | Spread: 10pt; Slippage: 2pt; Total cost: 12pt = 0.12 price per trade (round trip) |
| ATR model | ATR14 Wilder M1 shift=1 (completed bar, not current bar) |
| Stop model | SL = ATR14 × 1.20; TP = SL × RR; RR = 1.50 |
| Breakeven WR | 40.0% = 1 / (1 + RR) × (1 + cost adjustment) |
| Data extension | Required: re-export from MetaEditor64 when data is >30 days stale |

### 5.3 Replication Classification

Every strategy must be assigned a replication class before certification can be accepted.

| Class | Meaning | Impact on findings |
|---|---|---|
| SOURCE_FAITHFUL | Python trigger logic reproduces MQL5 trigger faithfully, bar-for-bar | Full confidence in N and WR figures |
| PARTIAL_REPLICATION | Core trigger logic matches but proxies used for some conditions (e.g., zone from EMA instead of council_environment classifier) | Findings valid for standalone edge; playbook/system conclusions carry proxy caveat |
| BEHAVIORAL_PROXY | Trigger approximates strategy behavior but significant divergence present | Findings are directional indicators only; N and WR are estimates |
| PROXY_GAP | A specific gap in the proxy is documented and its expected directional bias is stated | Proxy gap must be disclosed in every citation of the cert |
| NOT_REPLICABLE | Trigger requires runtime context unavailable offline (tick data, internal EA state, etc.) | Certification cannot be run; classify DATA_REQUIRED |

### 5.4 Certification Level Summary

| Level | Question | Primary Output |
|---|---|---|
| 1 — Strategy Certification | Does this strategy have standalone edge? | WR, E[R], PF, regime split, cert label |
| 2 — Packet / Playbook Certification | Does it contribute within a causal chain? | Marginal WR/E[R] lift, packet status, chain state |
| 3 — System Compatibility | Is it safe for the MT5/IRREW architecture? | Starvation risk, authority risk, EOC fit |
| 4 — Shadow Policy Evaluation | Would a policy based on it have helped? | would_have_triggered rate, delta outcome, starvation rate |

---

## 6. Standard Folder Structure

### 6.1 Current Lab State (As Found)

```
C:\Users\INFINTY GROUP\Documents\nautilus_lab\
│
├── data\                            [PRESENT — 2 files]
│   ├── XAUUSD_M1_20251107_20260507.csv
│   └── XAUUSD_M5_20251107_20260507.csv
│
├── scripts\                         [PRESENT — 14 cert scripts + utilities]
│   ├── cert_bollinger_reclaim_xauusd_v1.py
│   ├── cert_breakdown_momentum_v1_xauusd_v1.py
│   ├── cert_lower_high_rejection_v1_xauusd_v1.py
│   ├── cert_mfi_reversal_assist_xauusd_v1.py
│   ├── cert_micro_structure_reentry_v1_xauusd_v1.py
│   ├── cert_range_edge_fade_xauusd_v1.py
│   ├── cert_sweep_reversal_xauusd_v1.py
│   ├── cert_trend_momentum_variant_a/b/c/d.py  (4 files)
│   ├── cert_trend_pullback_cont_v1.py
│   ├── cert_tsmom_proxy_benchmark_v1.py
│   ├── cert_vwap_regime_reclaim_xauusd_v1.py
│   ├── composite_reversal_reclaim_playbook_v1.py
│   └── ref_sell_trend_down_isolation_v1.py
│
├── outputs\                         [PRESENT — 25+ JSON/CSV files]
│   ├── bollinger_reclaim_xauusd_v1_metrics.json
│   ├── bollinger_reclaim_xauusd_v1_trades.csv
│   ├── breakdown_momentum_v1_xauusd_v1_metrics.json
│   ├── breakdown_momentum_v1_xauusd_v1_trades.csv
│   ├── breakdown_momentum_v1_overlay_v1.json
│   ├── breakdown_momentum_v1_packet_classification_v1.json
│   ├── cert_lhr_v1_metrics.json
│   ├── composite_rbsr_v1_metrics.json
│   ├── composite_rbsr_v1_packets.json
│   ├── composite_rbsr_v1_trades.csv (+ v1 variant)
│   ├── mfi_reversal_assist_xauusd_v1_metrics.json
│   ├── mfi_reversal_assist_xauusd_v1_trades.csv
│   ├── mfi_reversal_assist_threshold_sensitivity_v1.csv
│   ├── mfi_reversal_assist_veto_overlay_v1.json
│   ├── micro_structure_reentry_v1_xauusd_v1_metrics.json
│   ├── micro_structure_reentry_v1_xauusd_v1_trades.csv
│   ├── micro_structure_reentry_v1_overlay_v1.json
│   ├── micro_structure_reentry_v1_packet_classification_v1.json
│   ├── range_edge_fade_xauusd_v1_metrics.json
│   ├── range_edge_fade_xauusd_v1_trades.csv
│   ├── range_edge_fade_xauusd_v1_packet_classification_v1.json
│   ├── ref_sell_trend_down_isolation_v1_metrics.json
│   ├── ref_sell_trend_down_isolation_v1_trades.csv
│   ├── sweep_reversal_xauusd_v1_metrics.json
│   ├── sweep_reversal_xauusd_v1_trades.csv
│   ├── sweep_reversal_degradation_split_v1.json
│   ├── sweep_reversal_regime_breakdown_v1.csv
│   ├── trend_momentum_variant_[a/b/c/d]_metrics.json (4 files)
│   ├── trend_momentum_variant_[a/b/c/d]_trades.csv (4 files)
│   ├── trend_momentum_variant_d_overextension_session.csv
│   ├── trend_pullback_cont_v1_metrics.json
│   ├── trend_pullback_cont_v1_trades.csv
│   ├── trend_pullback_cont_v1_depth_sensitivity.csv
│   ├── trend_pullback_cont_v1_overlap_trend_momentum.csv
│   ├── tsmom_proxy_benchmark_v1_metrics.json
│   ├── tsmom_proxy_benchmark_v1_trades.csv
│   ├── vwap_regime_reclaim_xauusd_v1_metrics.json
│   ├── vwap_regime_reclaim_xauusd_v1_trades.csv
│   └── vwap_vs_bollinger_reclaim_comparison_v1.json
│
├── certifications\                  [PRESENT — 17 MD certification files]
│   ├── certification_bollinger_reclaim_xauusd_v1.md
│   ├── certification_breakdown_momentum_v1_xauusd_v1.md
│   ├── certification_composite_rbsr_v1.md
│   ├── certification_lower_high_rejection_v1_xauusd_v1.md
│   ├── certification_mfi_reversal_assist_xauusd_v1.md
│   ├── certification_micro_structure_reentry_v1_xauusd_v1.md
│   ├── certification_range_edge_fade_xauusd_v1.md
│   ├── certification_ref_sell_trend_down_isolation_v1.md
│   ├── certification_sweep_reversal_xauusd_v1.md
│   ├── certification_trend_momentum_variant_a/b/c/d.md (4 files)
│   ├── certification_trend_pullback_cont_v1.md
│   ├── certification_tsmom_proxy_benchmark_v1.md
│   ├── certification_vwap_regime_reclaim_xauusd_v1.md
│   └── vwap_vs_bollinger_reclaim_comparison_v1.md
│
├── [root utility scripts]           [PRESENT]
│   ├── bollinger_reclaim_strategy.py
│   ├── br_analysis.py
│   ├── download_xauusd_m1.py
│   ├── extract_journal.py
│   ├── run_br_backtest.py
│   ├── validate_exports.py
│   └── verify_b.py
│
├── [root data/analysis files]       [PRESENT]
│   ├── br_backtest_results.json
│   ├── br_trades_extracted.json
│   └── journal_copy.jsonl
│
└── [MISSING — to be created]
    ├── system_lab\
    │   ├── manifests\
    │   ├── templates\
    │   ├── registry_snapshots\
    │   ├── compatibility_reports\
    │   └── run_logs\
    └── [scripts/ and outputs/ currently flat — subfoldering deferred to Bootstrap package]
```

### 6.2 Recommended Target Structure (Post-Bootstrap)

```
nautilus_lab/
│
├── data/                           [EXISTING — maintain as-is]
│
├── scripts/                        [EXISTING — add subfolders without moving existing files]
│   ├── [existing flat files — do not move]
│   ├── strategy_cert/              [new: future strategy cert scripts here]
│   ├── playbook_cert/              [new: future playbook cert scripts here]
│   ├── shadow_policy/              [new: future SPC evaluation scripts here]
│   └── system_compat/              [new: future system compatibility scripts here]
│
├── outputs/                        [EXISTING — add subfolders without moving existing files]
│   ├── [existing flat files — do not move]
│   ├── strategy_cert/              [new: future strategy cert outputs here]
│   ├── playbook_cert/              [new: future playbook cert outputs here]
│   ├── shadow_policy/              [new: future SPC evaluation outputs here]
│   └── system_compat/              [new: future compatibility outputs here]
│
├── certifications/                 [EXISTING — maintain as-is, append only]
│
├── system_lab/                     [NEW — created by Bootstrap package]
│   ├── manifests/                  [run_manifest.json per lab run]
│   ├── templates/                  [standardized cert report template, metrics schema]
│   ├── registry_snapshots/         [PIML/registry state at time of cert run]
│   ├── compatibility_reports/      [system_compat output per strategy]
│   └── run_logs/                   [lab run logs]
│
└── [root utility files — maintain existing, no reorganization needed]
```

**Structural principle:** Do not move existing files. Add new subfolders forward-only. Existing flat structure in scripts/ and outputs/ is preserved; new work goes into subfolders. This prevents breaking any existing references or scripts that use flat paths.

---

## 7. Standard Certification Workflow

Every new strategy certification — whether Phase 3 completion, new admission test, or re-cert — follows this 8-step workflow. No step may be skipped.

### Step 1 — Source Read

Before writing any Python, read the MQL5 source function for the strategy in full.

Record:
- `strategy_id` (exact string from `council_strategies.mqh`)
- `family` (from `CouncilAssignStrategyMeta()` call)
- `role` (SCOUT / CONFIRM / TREND_JUDGE / EXHAUSTION_JUDGE / GUARD / FROZEN)
- `vote_weight` (from weight constant or parameter)
- `direction_bias` (BOTH / BUY_ONLY / SELL_ONLY)
- `zone_eligibility` (from zone guard block)
- `trigger_logic` (exact conditions: indicators, thresholds, candle patterns)
- `score_logic` (quality formula if present)
- `degradation_hints` (any ATR/distance guards or timing conditions)
- `known_runtime_status` (from PIML and registry: ACTIVE / RESEARCH_ONLY / DATA_INSUFFICIENT / FROZEN)

This step cannot be abbreviated. Trigger logic that is not fully understood will produce a misclassified replication.

### Step 2 — Replication Classification

Using the trigger logic from Step 1, classify the replication before running:

| Component | Source-Faithful? | Proxy Used? | Proxy Bias? |
|---|---|---|---|
| Trigger condition 1 | Y/N | Describe proxy | BUY/SELL/NEUTRAL |
| Zone context | Y/N | EMA-based vs council_environment | Unknown |
| Regime label | Y/N | GC=F vs broker XAUUSD | Slight spread diff |
| Candle pattern | Y/N | OHLCV only vs tick-derived | Conservative |
| Score/quality | Y/N | Approximate formula | Directional only |

Assign final replication class: SOURCE_FAITHFUL / PARTIAL_REPLICATION / BEHAVIORAL_PROXY / PROXY_GAP / NOT_REPLICABLE.

Document proxy gaps in the cert report. Every citation of this cert must include the replication class and any PROXY_GAP notes.

### Step 3 — Standalone Certification

Run all applicable variants:

| Variant | Description | Required? |
|---|---|---|
| A — Unrestricted | No regime or direction filter | Always |
| B — Primary filter | One key structural filter (regime, direction, or zone) | Yes if B hypothesis exists |
| C — Subset | Counter-trend, specific regime, or direction subset | Yes if C subset plausible |
| D — Stress | +10pt spread above base cost model | Always |
| E — Walk-forward | 60/40 split (if N ≥ 30) | Yes if N ≥ 30 |

Metrics required per variant:

| Metric | Formula | Notes |
|---|---|---|
| N | count(closed_trades) | Minimum 30 for MARGINAL; 50 for ADEQUATE; 100 for SUFFICIENT |
| WR | wins / (wins + losses) | Excludes open trades; no flat/ambiguous outcomes |
| E[R] | mean(outcome_in_R) | R = 1 unit of risk; positive = above breakeven |
| PF | gross_profit / gross_loss | Profit factor; >1.0 = positive |
| Max consecutive losses | max(consecutive_loss_run) | Risk monitoring |
| MAE | mean(max_adverse_excursion_in_pts) | From DIRECT_TICK or BAR_M1 data |
| MFE | mean(max_favorable_excursion_in_pts) | Positive expectation proxy |
| Monthly stability | WR by calendar month (if ≥2 months data) | Temporal robustness |

### Step 4 — Segmentation

Run regime, direction, period, and cost segmentation:

| Segment | Subsets | Purpose |
|---|---|---|
| Regime | TREND_UP / TREND_DOWN / RANGE_NEUTRAL / RANGE_MEAN_RECLAIM (era proxy) | Identify hostile vs favorable regimes |
| Direction | BUY / SELL | Detect asymmetry |
| Early/Late | 60/40 walk-forward split | Detect temporal instability |
| Month | Calendar month breakdown | Detect seasonal or regime-period effects |
| Cost sensitivity | Base vs +5pt vs +10pt spread | Measure cost fragility |
| Outlier sensitivity | Remove best 3 + worst 3 trades | Check if result depends on extreme outliers |

Report format per segment: N | WR | E[R] | Label

### Step 5 — Packet Classification

Based on Variant A (unrestricted) and best segment results, evaluate each packet type against acceptance and rejection rules from PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md §3:

| Packet type | Evaluate? | Threshold | Reject if |
|---|---|---|---|
| ALPHA_TRIGGER_PACKET | Always | WR ≥ 40% OR E[R] > 0 with N ≥ 50 | E[R] negative all conditions; geometric constraint |
| CONFIRMATION_PACKET | If co-presence data available | Co-presence WR lift ≥ +2pp AND E[R] lift ≥ +0.04R | Co-presence ubiquitous (>80%) OR degrades outcomes |
| FAILURE_MODE_PACKET | If counter-condition testable | E[R] degradation ≥ −0.06R OR WR degradation ≥ −3pp when active | Below both thresholds |
| LOCATION_PACKET | If zone filter testable | Gated WR lift ≥ +2pp OR gated E[R] lift ≥ +0.04R | Gating degrades vs ungated |
| TIMING_PACKET | If temporal pattern present | Period WR ≥ 40%, E[R] ≥ 0, N ≥ 50 across ≥2 sub-windows | Target period worse than baseline |
| REGIME_PACKET | If regime pattern present | Regime WR ≥ 40%, E[R] ≥ 0, N ≥ 50, mechanically plausible | Geometric sampling artifact |
| DIRECTION_PACKET | If direction asymmetry ≥ +2pp WR | Direction WR lift ≥ +2pp AND E[R] positive vs baseline, N ≥ 50 | Both directions below breakeven |
| RESEARCH_ONLY_PACKET | If positive E[R] or WR ≥ 40% in one condition only | Positive but below formal threshold | N/A — only upgrades or archives |
| REJECTED_PACKET | If acceptance rule explicitly violated | N/A | Applied per acceptance rule violation |
| DATA_INSUFFICIENT_PACKET | If N < 30 | N/A | Applied when sample inadequate |

Assign one primary packet status per cert. Note all tested types in report.

### Step 6 — Playbook Compatibility

For the strategy's assigned playbook (RBSR / TPC / VCR):

1. Identify chain role (ALPHA / CONFIRM / FAILURE_MODE / LOCATION / TIMING / other)
2. Evaluate co-presence with playbook anchor strategy (if possible from data)
3. Determine which causal chain links are satisfied by this strategy's evidence
4. Determine which links are missing
5. Determine if any links are contradicted by the evidence
6. Assess co-presence rate: ubiquitous (>80%) = non-discriminating for CONFIRM role

Report format:
- Playbook: [RBSR / TPC / VCR / UNASSIGNED]
- Chain role: [role]
- Completed links: [list]
- Missing links: [list]
- Contradicted links: [list]
- Co-presence rate: [%]
- WR lift from co-presence: [pp]
- E[R] lift from co-presence: [R]
- Playbook contribution: [ACCEPTED_CHAIN_LINK / REJECTED_CHAIN_LINK / DATA_INSUFFICIENT_CHAIN / RESEARCH_ONLY_CHAIN]

### Step 7 — System Compatibility Assessment

For every strategy or packet that passes Level 1, assess Level 3 compatibility:

| Question | Assessment | Risk |
|---|---|---|
| Can MT5 observe this evidence before decision? | Yes / No / Partially | Runtime observability |
| Is the trigger sparse? | If co-presence <10% → HIGH starvation | Starvation risk |
| Does it require unavailable timestamps? | If pre-decision EOC impossible → flag | Event Order Contract fit |
| Does it belong to Alpha, Risk, Execution, Attribution, or Environment layer? | State layer | Layer ownership |
| Could it leak into score/gate authority? | If fed to council_quality or filter → YES | Authority risk |
| What ledger fields would be needed to observe this? | List required fields | Layer 1 dependency |
| Would it require source changes? | Y/N | Implementation cost |
| Does it create a same-family CRR problem? | If CONFIRM same family as ALPHA → YES | Structural gate risk |

### Step 8 — Verdict

Assign final certification verdict:

| Verdict | Criteria |
|---|---|
| CERTIFIED_EDGE_CONTRIBUTOR | ALPHA_TRIGGER or CONFIRMATION_PACKET formally accepted; N ≥ ADEQUATE; E[R] > 0 |
| ACCEPTED_PACKET | Specific packet type formally accepted per §3 thresholds |
| RESEARCH_ONLY_PACKET | Positive signal in one condition but below formal threshold; specific next hypothesis |
| REJECTED_PACKET | Acceptance rule explicitly violated; specific rejection reason stated |
| DATA_INSUFFICIENT | N < 30 in relevant subset or simulation window < 14 days |
| PENDING_CERTIFICATION | Cert not yet run; strategy is queued |
| SYSTEM_INCOMPATIBLE | Cert evidence cannot transfer to MT5 runtime (NOT_REPLICABLE + observability gap) |
| EDGE_SUPPORTED | WR ≥ 43% AND E[R] ≥ +0.04R in primary tested condition with N ≥ ADEQUATE |
| EDGE_WEAK_BUT_RECOVERABLE | WR 38–43% OR E[R] −0.04R to +0.04R; identified hostile regime filter improves outcomes |
| EDGE_NOT_CONFIRMED | WR 35–38% OR E[R] −0.08R to −0.04R; no clear recovery path |
| EDGE_REJECTED | WR < 35% OR E[R] < −0.08R with N ≥ ADEQUATE |

---

## 8. Strategy Admission / New Strategy Testing Protocol

No strategy may enter MT5/IRREW without completing this protocol. The protocol is the blocking screen for all new strategy admissions.

### 8.1 Required Protocol Steps (All Mandatory)

| Step | Deliverable | Blocked by |
|---|---|---|
| 1 | Source Read — full trigger logic, family, role, zone eligibility documented | Nothing — read before writing Python |
| 2 | Replication Classification — SOURCE_FAITHFUL / PARTIAL / PROXY / NOT_REPLICABLE | Step 1 |
| 3 | Standalone Certificate — Variants A + D at minimum; B/C/E as applicable | Step 2 |
| 4 | Segmentation — regime, direction, early/late, cost sensitivity | Step 3 |
| 5 | Packet Classification — packet type and verdict per §3 rules | Step 3 + 4 |
| 6 | Playbook Compatibility — chain role, completed/missing/contradicted links | Step 5 |
| 7 | System Compatibility — observability, starvation, authority, EOC fit | Step 6 |
| 8 | Rejection Rule Test — verify strategy produces the expected rejection trigger under known failure conditions | Step 5 |
| 9 | Certification Report (MD) — full cert report per §12 standard | Steps 1–8 |
| 10 | Operator Review — operator reads cert report and decides whether to authorize Codex task | Step 9 |
| 11 | Authorized Codex Task — bounded one-file source change with compile + static validation | Operator authorization only |

### 8.2 Admission Rules (Absolute)

- No strategy enters MT5 because its narrative sounds good
- No strategy enters MT5 without at least RESEARCH_ONLY_PACKET verdict from lab
- No strategy enters MT5 without a defined rejection rule (what would cause it to be frozen)
- No strategy enters MT5 without playbook or packet role assignment
- No strategy enters MT5 without Event Order Contract fit assessment
- No strategy enters MT5 without a starvation risk assessment
- No strategy enters MT5 without proving measurable marginal contribution (packet contribution) OR a bounded research reason (DATA_INSUFFICIENT, RESEARCH_ONLY_PACKET — with monitoring plan)
- The factory admission lock (strategy_transfer_runtime_freeze = ACTIVE) is not overridden by any lab result
- PIML strategy count (17) is the current cohort limit; expansion requires separate operator authorization

### 8.3 Fast-Track Criteria (Optional)

A strategy that meets all of the following may receive expedited admission review:
- Variant A WR ≥ 43% with N ≥ ADEQUATE (50+) in at least one tested condition
- No geometric sampling artifact (direction × regime combination is physically observable)
- System compatibility: MT5 can observe the trigger in the current architecture without source changes to decision path
- Playbook role is clear and fills a documented gap in the current causal chain

Fast-track does not bypass the 11-step protocol. It means the operator review (Step 10) can proceed immediately rather than requiring additional testing rounds.

---

## 9. Existing Strategy Re-Certification Mode

The 17 council strategies have varying cert states. This section defines how the lab handles the existing cohort: which strategies need re-certification, which are complete, and what triggers a re-cert.

### 9.1 Current Cert State (as of 2026-05-09)

| strategy_id | Lab Cert Status | Cert Label | Cert File | Re-cert Trigger |
|---|---|---|---|---|
| sweep_reversal | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE | certification_sweep_reversal_xauusd_v1.md | Data period extension >6mo; live WR <35% |
| bollinger_reclaim | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE (overall); RANGE = EDGE_NOT_CONFIRMED | certification_bollinger_reclaim_xauusd_v1.md | Phase 5A runtime validation may trigger NAUTILUS_CHALLENGED status |
| trend_momentum | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE | certification_trend_momentum_variant_[a-d].md | Variants A-D complete; no trigger without new data |
| trend_pullback_cont_v1 | CERTIFIED | EDGE_SUPPORTED (standalone, sparse) | certification_trend_pullback_cont_v1.md | Phase 4A architecture decision may need co-presence re-run |
| mfi_reversal_assist | CERT_RUN — DATA_INSUFFICIENT | DATA_INSUFFICIENT | certification_mfi_reversal_assist_xauusd_v1.md | Re-run after ≥5 live entries confirm threshold; also veto overlay exists |
| breakdown_momentum_v1 | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE (aggregate) / NOT_CONFIRMED (TC proxy) | certification_breakdown_momentum_v1_xauusd_v1.md | BDM Variant A exact metrics listed SOURCE_READ_REQUIRED; fill before using for weight decisions |
| lower_high_rejection_v1 | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE | certification_lower_high_rejection_v1_xauusd_v1.md | REF isolation sub-cert also exists; no trigger |
| micro_structure_reentry_v1 | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE (SELL) / NOT_CONFIRMED (BUY) | certification_micro_structure_reentry_v1_xauusd_v1.md | FAILURE_MODE_PACKET accepted; overlay cert also exists |
| range_edge_fade | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE | certification_range_edge_fade_xauusd_v1.md | REF+CONTRADICTED result important; SPC evaluation may need re-run |
| momentum_breakout_cont_v1 | FROZEN (no lab run needed) | EDGE_REJECTED (live 9.1% WR) | N/A | No re-cert until separate redesign plan authorized |
| mean_reversion_bounce | PENDING_CERTIFICATION | DATA_INSUFFICIENT | — | Phase 3 uncertified; cert when labeled research priority |
| fake_break_reversal | PENDING_CERTIFICATION | DATA_INSUFFICIENT | — | Phase 3 uncertified |
| range_compression_breakout | PENDING_CERTIFICATION | DATA_INSUFFICIENT | — | VCR family; cert when COMPRESSION zone activity observed live |
| volatility_squeeze_release | PENDING_CERTIFICATION | DATA_INSUFFICIENT | — | VCR family |
| volatility_breakout | PENDING_CERTIFICATION | DATA_INSUFFICIENT | — | VCR family |
| expansion_continuation | PENDING_CERTIFICATION | DATA_INSUFFICIENT | — | VCR/EXP family |
| micro_range_expansion | PENDING_CERTIFICATION | DATA_INSUFFICIENT | — | VCR/EXP family |

### 9.2 Re-Certification Triggers

Do NOT re-certify a strategy unless one of these conditions is met:

| Trigger | Action |
|---|---|
| Registry gap exists (packet status UNKNOWN or missing chain link) | Run targeted packet test only — not full re-cert |
| Data period extended >6 months since cert date | Re-run Variant A; compare to prior cert |
| Shadow policy needs the cert data | Check if existing outputs are sufficient before re-running |
| Contradiction found between cert findings and live runtime behavior | Run targeted test for the contradicting condition |
| Phase blocker requires specific evidence gap to be filled | Run minimum targeted test only |
| Live WR has declined materially vs cert WR (>5pp sustained over 30+ trades) | Re-run Variant A as check; report findings to operator |
| bollinger_reclaim NAUTILUS_CHALLENGED resolution requested | Run targeted RANGE-era subset to resolve Phase 5A authority question |

Do NOT re-run micro-tests for their own sake. The registry records cert history. Returning to the micro-test swamp is forbidden by GF-11.

---

## 10. Playbook Certification Mode

Each of the three registered playbooks has a defined causal chain that can be partially evaluated offline. This section defines how each playbook is certified and what Nautilus can and cannot determine.

### 10.1 RBSR — Range Boundary Sweep Reversal

**Playbook state:** PLAYBOOK_FORMING
**Anchor strategy:** sweep_reversal (RESEARCH_ONLY ALPHA_TRIGGER — counter-trend E[R]=+0.012R, positive but below +0.04R threshold)

**Causal chain:**
```
[Step 1] Sweep beyond range boundary (new high/low)
[Step 2] sweep_reversal: ALPHA trigger — bearish/bullish rejection at extreme
[Step 3] bollinger_reclaim / range_edge_fade: CONFIRM — price reclaims range interior
[Step 4] mfi_reversal_assist: FAILURE_MODE guard — exhaustion signal strength
```

**Current evidence:**
- Step 2 (sweep_reversal): CERTIFIED — RESEARCH_ONLY ALPHA (counter-trend positive E[R]; not formally accepted)
- Step 3 (bollinger_reclaim): CERTIFIED — REJECTED as CONFIRMATION_PACKET (RANGE era E[R]=−0.052R; co-presence 88–94% ubiquitous)
- Step 3 (range_edge_fade): CERTIFIED — REJECTED (zone proxy degrades; SR/BR co-presence contradicted)
- Step 4 (mfi_reversal_assist): CERT_RUN — DATA_INSUFFICIENT (0 live entries at cert time; veto overlay exists)

**Composite test:** `certification_composite_rbsr_v1.md` exists — playbook-level pilot

**What Nautilus can evaluate:**
- Counter-trend sweep anchor performance (done)
- Bollinger reclaim co-presence lift (done — rejected)
- Range edge fade co-presence lift (done — rejected)
- MFI veto overlay degradation (partial — veto_overlay_v1.json exists but data insufficient)
- Alternative CONFIRM candidates from MEAN_RECLAIM family (mean_reversion_bounce, fake_break_reversal — NOT_CERTIFIED)

**What only MT5 runtime can validate:**
- Whether the PLAYBOOK_FORMING state correctly predicts live trade outcome distributions
- Whether the co-presence ubiquity finding holds in live XAUUSD vs GC=F proxy
- Whether Phase 5A (bollinger_reclaim SELL-in-TREND_UP gate) changes RBSR outcomes

**Next packet needed for PLAYBOOK_VALID:**
A cross-family CONFIRM with co-presence WR lift ≥ +2pp AND E[R] lift ≥ +0.04R AND co-presence rate < 80%. No such strategy is currently certified within the RBSR chain. mean_reversion_bounce and fake_break_reversal are the next candidates.

**Lab work needed:**
- Certify mean_reversion_bounce (Phase 3 uncertified)
- Certify fake_break_reversal (Phase 3 uncertified)
- Re-run mfi_reversal_assist after ≥5 live signal strength readings available
- Update composite_rbsr cert after mean_reversion_bounce/fake_break_reversal certs complete

---

### 10.2 TPC — Trend Pullback Continuation

**Playbook state:** PLAYBOOK_FORMING
**Anchor strategy:** trend_momentum (RESEARCH_ONLY ALPHA — strongest alpha evidence in system; RANGE_NEUTRAL×SELL = EDGE_SUPPORTED with E[R]=+0.109R, N=1,402)

**Causal chain:**
```
[Step 1] Zone = TREND_CONTINUATION (TC) — established trend environment
[Step 2] trend_momentum: ALPHA LEAD — EMA + momentum confluence directional signal
[Step 3] trend_pullback_cont_v1: CONFIRM — ATR-bounded pullback detection and reclaim
[Step 4] Supporting TC-CONFIRM: LHR / MSR / BDM (secondary confirmation)
[Step 5] mfi_reversal_assist: FAILURE_MODE GUARD — exhaustion monitoring
```

**Current evidence:**
- Step 2 (trend_momentum): CERTIFIED — RESEARCH_ONLY ALPHA (condition-dependent; strongest system alpha)
- Step 3 (trend_pullback_cont_v1): CERTIFIED — CONFIRM_PACKET_SPARSE (EDGE_SUPPORTED standalone; 1.4% TM co-presence = structural sparsity)
- Step 4 (breakdown_momentum_v1): CERTIFIED — ALL PACKETS REJECTED (regime inversion; TC proxy NOT_CONFIRMED; LATE=EDGE_REJECTED)
- Step 4 (lower_high_rejection_v1): CERTIFIED — RESEARCH_ONLY (TC proxy E[R]=+0.0037R; SELL×TREND_DOWN best direction)
- Step 4 (micro_structure_reentry_v1): CERTIFIED — FAILURE_MODE_PACKET ACCEPTED for LHR E[R] degradation (−0.068R; N=4,268 SUFFICIENT)
- Step 5 (mfi_reversal_assist): DATA_INSUFFICIENT

**Architecture blocker:** TPC co-presence with trend_momentum is 1.4% (114 of 7,940 TM trades in Nautilus). This is structural — TPC fires only when a pullback occurs within ATR×0.70 of EMA, while TM fires on any EMA alignment. Phase 4A cross-family CRR redesign is blocked on architecture decision (Option F selected; implementation path not chosen).

**What Nautilus can evaluate:**
- trend_momentum standalone variants A–D (done)
- TPC standalone (done — EDGE_SUPPORTED)
- TPC-TM co-presence rate (done — 1.4%; overlap file exists)
- LHR TC proxy performance (done)
- MSR FAILURE_MODE for LHR (done — accepted)
- BDM regime breakdown (done — severe instability found)
- TPC depth/ATR sensitivity (done — sensitivity file exists)

**What only MT5 runtime can validate:**
- TPC live trigger frequency after Package 2 (ATR×0.70 widening)
- Whether 1.4% Nautilus co-presence matches live co-presence
- Phase 4A architectural solution effectiveness

**Next work:**
- Architecture decision for Phase 4A before any further TPC cert work
- LHR DIRECTION_PACKET formal upgrade (needs E[R] lift to +0.04R threshold from current +0.0037R)

---

### 10.3 VCR — Volatility Compression Release

**Playbook state:** PLAYBOOK_NOT_PRESENT
**Anchor strategy:** range_compression_breakout (PENDING_CERTIFICATION — DATA_INSUFFICIENT)

**Causal chain (design intent only — zero evidence):**
```
[Step 1] COMPRESSION zone — ATR compressing, price range narrowing
[Step 2] range_compression_breakout: SCOUT/ALPHA — directional breakout trigger
[Step 3] volatility_squeeze_release: CONFIRM — squeeze confirmation
[Step 4] volatility_breakout / expansion_continuation: TREND_JUDGE — continuation lead
[Step 5] micro_range_expansion: SCOUT secondary — micro-structure follow-through
```

**Current evidence:** None. All 5 VCR strategies have 0 Nautilus runs and 0 live closed trades. COMPRESSION and EXP zones have not been observed in live V1C window (7h11m review). VCR chain is a design hypothesis only.

**What Nautilus can evaluate:**
- range_compression_breakout standalone (pending cert run)
- volatility_squeeze_release co-presence with range_compression_breakout (pending)
- Volatility squeeze detection accuracy vs GC=F proxy

**Minimum prerequisite for VCR playbook certification:**
- range_compression_breakout Phase 3 cert as absolute first step
- COMPRESSION zone live entry accumulation in MT5 runtime (at least 10 records in V1C ledger)
- Only then: co-presence test against volatility_squeeze_release

**Lab work needed:**
- range_compression_breakout: Phase 3 cert (PENDING_CERTIFICATION — deferred after RBSR/TPC priorities)
- Do NOT cert VCR family before COMPRESSION zone activity confirmed live

---

## 11. Shadow Policy Evaluation Mode

This section defines how the lab evaluates Shadow Policy Candidates (SPC-001 through SPC-010, per SHADOW_POLICY_CANDIDATE_DESIGN_PACKAGE_V1.md) offline using Nautilus and V1C ledger data.

### 11.1 Evaluation Framework

A shadow policy evaluation is a counterfactual simulation: given historical V1C ledger records and historical Nautilus trade data, would the proposed policy have fired, and would its effect have been positive?

Shadow policy evaluation **never produces runtime authority**. The evaluation produces a probability assessment of policy value, not implementation authorization.

### 11.2 Standard Shadow Policy Evaluation Record

Per evaluation run, produce:

```json
{
  "policy_id": "SPC-XXX",
  "policy_type": "FAILURE_MODE_SHADOW | CONFIRMATION_SHADOW | ...",
  "evaluation_date": "YYYY-MM-DD",
  "ledger_records_used": 0,
  "records_policy_would_have_triggered": 0,
  "trigger_rate": 0.0,
  "actual_outcome_when_triggered": {"wins": 0, "losses": 0, "wr": 0.0},
  "actual_outcome_when_not_triggered": {"wins": 0, "losses": 0, "wr": 0.0},
  "outcome_delta_wr_pp": 0.0,
  "outcome_delta_er": 0.0,
  "starvation_rate": 0.0,
  "false_positive_rate": 0.0,
  "false_negative_rate": 0.0,
  "sample_adequacy": "INSUFFICIENT | MARGINAL | ADEQUATE | SUFFICIENT",
  "policy_verdict": "REJECT | CONTINUE_RESEARCH | CANDIDATE_FOR_DESIGN_REVIEW",
  "caveats": [],
  "runtime_authority_status": "NONE"
}
```

### 11.3 SPC Evaluation Requirements and Blockers

| SPC | Policy Type | Min Sample | Current Status | Earliest Action |
|---|---|---|---|---|
| SPC-001 | MISSING_LINK_SHADOW (TPC confirm absent) | 50 TC decisions + 10 TPC co-fires | BLOCKED — TPC trigger_seen=0 live | After TPC accumulates ≥10 co-fires |
| SPC-002 | FAILURE_MODE_SHADOW (TPC CONTRADICTED outcomes) | 30 CONTRADICTED records | EARLY_RESEARCH — 1 CONTRADICTED record | After 30+ TPC CONTRADICTED records |
| SPC-003 | CONFIRMATION_SHADOW (RBSR required evidence) | 50 RBSR records | READY_TO_ACCUMULATE — 15 records | After 50+ RBSR V1C records (post-cleanup) |
| SPC-004 | PLAYBOOK_STATE_SHADOW (FORMING vs NOT_PRESENT) | 40+ each state | READY_TO_ACCUMULATE | After 80+ V1C records across states |
| SPC-005 | FAILURE_MODE_SHADOW (mfi_reversal_assist same-direction) | 5 live MFI entries | EARLY_RESEARCH — 2 entries | After 5 MFI entries |
| SPC-006 | FAILURE_MODE_SHADOW (mfi_reversal_assist counter-direction) | 3 post-cleanup records | POST_CLEANUP_MONITORING — 0 counter-direction records | After reload — next MFI counter-direction trigger |
| SPC-007 | ATTRIBUTION_ONLY_SHADOW (VCR activity classification) | 10 VCR zone records | BLOCKED — 0 VCR records | After COMPRESSION/EXP zone activity |
| SPC-008 | EVENT_ORDER_SHADOW (event_order_valid patterns) | 50+ PLAYBOOK_VALID records | BLOCKED — 0 PLAYBOOK_VALID records | After PLAYBOOK_VALID emission begins (V1D+) |
| SPC-009 | REGIME_CONTEXT_SHADOW (RBSR zone concentration) | 50+ RBSR records + zone_label field | BLOCKED — zone_label not in V1C schema | After ledger schema adds zone_label field |
| SPC-010 | CONFIRMATION_SHADOW (weak vs strong RBSR evidence) | 30+ each weak/strong group | READY_TO_ACCUMULATE — 15 records; schema field needed | After 30+ RBSR records with strength signal |

**Priority order for evaluation:** SPC-006 → SPC-005 → SPC-003 → SPC-004 → SPC-010 → SPC-002 → SPC-009 → SPC-001 → SPC-008 → SPC-007

### 11.4 Shadow Policy Governance Firewall

| Rule | Constraint |
|---|---|
| GFS-1 | SPC evaluation does NOT authorize implementation. Positive result from evaluation requires a separate bounded Codex task with explicit operator authorization before any MT5 source change. |
| GFS-2 | SPC evaluation does NOT authorize runtime consumption. No evaluated policy may be read by the decision pipeline. |
| GFS-3 | PLAYBOOK_VALID in any SPC analysis is an evidence label only — does not authorize execution. |
| GFS-4 | PLAYBOOK_CONTRADICTED in any SPC analysis is an evidence label only — does not block execution. |
| GFS-5 | FAILURE_MODE_PACKET does not mean veto. An accepted failure mode packet from SPC evaluation is a research finding only. |
| GFS-6 | SPC starvation risk CRITICAL means the policy must never be proposed as a mandatory gate without architectural resolution. |
| GFS-7 | SPC verdict CANDIDATE_FOR_DESIGN_REVIEW means the operator may choose to initiate a separate design review — it does not initiate one automatically. |

---

## 12. Standard Output Artifacts

Every lab run must produce a consistent set of artifacts to ensure reproducibility and traceability.

### 12.1 Required Artifacts Per Strategy Certification

| Artifact | Format | Location | Required? |
|---|---|---|---|
| run_manifest.json | JSON | `system_lab/manifests/` | YES |
| metrics.json | JSON | `outputs/strategy_cert/` | YES |
| trades.csv | CSV | `outputs/strategy_cert/` | YES |
| packet_classification.json | JSON | `outputs/strategy_cert/` | YES |
| system_compatibility.json | JSON | `outputs/system_compat/` | YES |
| certification_report.md | MD | `certifications/` | YES |
| playbook_compatibility.json | JSON | `outputs/playbook_cert/` | YES if playbook role assigned |
| evidence_limitations.md | MD | `certifications/` | YES if proxy gaps exist |

### 12.2 Required Artifacts Per Playbook Certification

| Artifact | Format | Location | Required? |
|---|---|---|---|
| run_manifest.json | JSON | `system_lab/manifests/` | YES |
| playbook metrics.json | JSON | `outputs/playbook_cert/` | YES |
| co_presence_analysis.json | JSON | `outputs/playbook_cert/` | YES |
| chain_state.json | JSON | `outputs/playbook_cert/` | YES |
| trades.csv | CSV | `outputs/playbook_cert/` | YES |
| certification_playbook.md | MD | `certifications/` | YES |

### 12.3 Required Artifacts Per Shadow Policy Evaluation

| Artifact | Format | Location | Required? |
|---|---|---|---|
| run_manifest.json | JSON | `system_lab/manifests/` | YES |
| shadow_policy_results.json | JSON | `outputs/shadow_policy/` | YES |
| counterfactual_comparison.csv | CSV | `outputs/shadow_policy/` | YES |
| certification_shadow_policy.md | MD | `certifications/` | YES |

### 12.4 Naming Convention

**Strategy certification scripts:**
```
cert_<strategy_id>_<symbol>_<version>.py
```
Example: `cert_sweep_reversal_xauusd_v1.py`

**Strategy certification metrics output:**
```
<strategy_id>_<symbol>_<version>_metrics.json
<strategy_id>_<symbol>_<version>_trades.csv
<strategy_id>_<symbol>_<version>_packet_classification.json
```

**Strategy certification report:**
```
certification_<strategy_id>_<symbol>_<version>.md
```

**Playbook certification:**
```
cert_playbook_<playbook_id>_<version>.py
playbook_<playbook_id>_<version>_metrics.json
certification_playbook_<playbook_id>_<version>.md
```
Example: `cert_playbook_rbsr_v2.py`, `certification_playbook_rbsr_v2.md`

**Shadow policy evaluation:**
```
cert_shadow_policy_<policy_id>_<version>.py
shadow_policy_<policy_id>_<version>_results.json
certification_shadow_policy_<policy_id>_<version>.md
```
Example: `cert_shadow_policy_spc006_v1.py`, `certification_shadow_policy_spc006_v1.md`

**Run manifest:**
```
manifest_<task_id>_<YYYYMMDD_HHMMSS>.json
```

### 12.5 Run Manifest Schema

Every lab run begins with creating a manifest before any script is run.

```json
{
  "manifest_id": "string",
  "task_id": "string",
  "task_type": "STRATEGY_CERT | PLAYBOOK_CERT | SHADOW_POLICY | SYSTEM_COMPAT | REGRESSION",
  "strategy_id": "string or null",
  "playbook_id": "string or null",
  "policy_id": "string or null",
  "run_date": "YYYY-MM-DD",
  "run_timestamp": "YYYY-MM-DD HH:MM:SS",
  "data_file_m1": "filename",
  "data_file_m5": "filename or null",
  "data_range_start": "YYYY-MM-DD",
  "data_range_end": "YYYY-MM-DD",
  "cost_model_spread_pt": 10,
  "cost_model_slippage_pt": 2,
  "atr_period": 14,
  "atr_multiplier": 1.20,
  "rr": 1.50,
  "replication_class": "SOURCE_FAITHFUL | PARTIAL_REPLICATION | BEHAVIORAL_PROXY | NOT_REPLICABLE",
  "proxy_gaps": [],
  "piml_version_ref": "YYYY-MM-DD snapshot",
  "registry_version_ref": "YYYY-MM-DD snapshot",
  "scripts_run": [],
  "outputs_produced": [],
  "certifications_produced": [],
  "authority_reminder": "EVIDENCE_ONLY — no runtime authority transferred by this run",
  "system_status": "DEVELOPING"
}
```

---

## 13. Evidence Classification Rules

All findings from lab runs must be assigned one of these classifications. The classification determines how findings can be cited in PIML, registry, and design documents.

| Classification | When Applied | Citation Rule |
|---|---|---|
| **Verified** | Finding confirmed from direct source read or multiple independent test runs producing consistent results | May be cited as established fact; source must be referenced |
| **Strongly supported** | Finding consistent across multiple variants or confirmed by Nautilus + live runtime agreement | May be cited with "strongly supported" qualifier; confidence is high but not absolute |
| **Plausible but unverified** | Finding is mechanically consistent with expected behavior but has not been tested directly | May be cited only as hypothesis; must not be used as basis for gate/weight/source change |
| **Suspicious / needs investigation** | Finding contradicts expectations without explanation; may be sampling artifact or proxy gap | Must not be cited until investigation is complete; flag in cert report |
| **Contradicted / unstable** | Finding is inconsistent across variants, walk-forward splits, or live vs Nautilus agreement | Must be cited as CONTRADICTED; use contradicted findings to rule out hypotheses, not to confirm |
| **Data insufficient** | N < 30 in the relevant subset, or simulation window < 14 calendar days | Must not be used for any edge or packet decision; cite only as DATA_INSUFFICIENT |
| **Proxy-only** | Finding relies entirely on GC=F or other proxy data with documented divergence from live broker XAUUSD | Must be cited with PARTIAL_REPLICATION caveat; cannot be used as sole basis for source change authorization |
| **Not runtime transferable** | Finding exists in Nautilus but cannot be observed by MT5 before decision (post-decision timing, unavailable data, wrong layer) | Must be classified NOT_RUNTIME_TRANSFERABLE; cannot be used in any runtime gate or score design |

---

## 14. Acceptance and Rejection Rules

These rules govern packet certification decisions. Rules are derived from PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md §3 and are reproduced here for lab use. The registry governs in case of conflict.

### 14.1 Alpha Trigger Packet

- **Accept if:** WR ≥ 40% OR E[R] > 0 with N ≥ ADEQUATE (50); improvement demonstrable over naive baseline; direction × regime mechanically plausible (not geometric artifact)
- **Reject if:** E[R] negative in all tested conditions with adequate N; OR geometric constraint prevents the direction from firing in the tested regime (sampling artifact)
- **Research-only if:** Positive E[R] or WR ≥ 40% in at least one condition but formal thresholds not fully met

### 14.2 Confirmation Packet

- **Accept if:** Co-presence WR lift ≥ +2pp AND E[R] lift ≥ +0.04R vs standalone baseline; co-presence rate < 80% (non-ubiquitous); both thresholds required simultaneously
- **Reject if:** Co-presence WR lift < +2pp OR E[R] lift < +0.04R; OR co-presence rate > 80% (ubiquitous = non-discriminating); OR co-presence degrades outcomes

### 14.3 Failure Mode Packet

- **Accept if:** E[R] degradation ≥ −0.06R OR WR degradation ≥ −3pp when the failure mode is active vs baseline; N ≥ ADEQUATE in failure-mode-active subset
- **Reject if:** Degradation below both thresholds in adequately sized sample

### 14.4 Location Packet

- **Accept if:** Gated WR lift ≥ +2pp OR gated E[R] lift ≥ +0.04R vs ungated baseline
- **Reject if:** Gating degrades outcomes vs ungated baseline (i.e., the location filter hurts)

### 14.5 Timing Packet

- **Accept if:** Target period WR ≥ 40% AND E[R] ≥ 0 with N ≥ 50; pattern persists across ≥2 sub-windows
- **Reject if:** Target period is worse than baseline; or improvement is within-sample noise (N < 30)

### 14.6 Regime Packet

- **Accept if:** Regime WR ≥ 40%, E[R] ≥ 0, N ≥ 50; regime isolation mechanically plausible; not a geometric artifact
- **Reject if:** Regime result is a structural sampling artifact (the direction × regime combination is physically constrained); N < 50

### 14.7 Direction Packet

- **Accept if:** Direction WR lift ≥ +2pp AND E[R] positive vs overall baseline; N ≥ 50 in the direction subset
- **Reject if:** Both directions below breakeven with adequate N; asymmetry below threshold

### 14.8 Shadow Policy (Evaluation Verdicts)

| Verdict | Criteria |
|---|---|
| REJECT | Policy would have fired incorrectly more often than correctly; starvation rate >25% with no material WR improvement; OR policy fires in only one regime and that regime has <30 records |
| CONTINUE_RESEARCH | Policy shows directional signal but sample inadequacy prevents verdict; re-evaluate after accumulation |
| CANDIDATE_FOR_DESIGN_REVIEW | Policy WR delta ≥ +3pp OR E[R] delta ≥ +0.04R in triggered subset vs non-triggered; starvation rate <10%; N ≥ ADEQUATE in both groups; findings reproducible across data halves |

### 14.9 System Compatibility Assessment

| Verdict | Criteria |
|---|---|
| SYSTEM_COMPATIBLE | MT5 can observe evidence before decision; starvation risk LOW; no authority leakage path; EOC fit; layer ownership clear |
| SYSTEM_COMPATIBLE_WITH_CAVEATS | Observable but sparse; or requires new ledger fields; or starvation risk MEDIUM |
| SYSTEM_INCOMPATIBLE | Cannot be observed by MT5 before decision; OR creates starvation risk CRITICAL if implemented; OR requires authority boundary violation |

---

## 15. Runtime Transferability Assessment

For every lab finding, the following 10 questions must be answered before the finding can be proposed for any runtime influence.

| Question | Assessment | Flag |
|---|---|---|
| 1. Can MT5 observe this evidence? | Can the trigger condition be evaluated from data available to EA within OnTick()? | NOT_OBSERVABLE if no |
| 2. Can MT5 observe it BEFORE the final_decision? | Is the evidence available before council_aggregator runs? | LATE_EVIDENCE if no |
| 3. Does it require unavailable timestamps? | If it requires sub-second ordering not available at Stage 18.5 → LATE_EVIDENCE | EOC_VIOLATION if yes |
| 4. Does it require unavailable market structure? | Tick-level data not available in OHLCV-only system | NOT_OBSERVABLE if yes |
| 5. Is the trigger sparse? | If co-presence <10% in any mandatory role → starvation risk | STARVATION_RISK if yes |
| 6. Does it create starvation risk? | If implemented as mandatory gate and fires rarely → CRITICAL starvation | STARVATION_CRITICAL |
| 7. Does it belong to which layer? | Alpha / Risk / Execution / Attribution / Environment / Evidence | STATE_LAYER |
| 8. Would it require source changes? | If yes → requires bounded Codex task + operator authorization | REQUIRES_CODEX |
| 9. Would it risk score/gate leakage? | If fed to council_quality or filter → authority boundary violation | AUTHORITY_RISK |
| 10. Is the proxy gap too large? | If GC=F finding relies on proxy that diverges materially from live XAUUSD → caveat | PROXY_CAVEAT |

**Runtime Transferability Classification:**

| Class | All 10 questions satisfied? | Citation rule |
|---|---|---|
| FULLY_TRANSFERABLE | Yes | May be proposed for runtime without caveats beyond standard governance |
| TRANSFERABLE_WITH_CAVEATS | Most, with documented exceptions | Must state caveats in every proposal |
| NOT_TRANSFERABLE | Critical failures in Q1, Q2, Q3, or Q5+Q6 CRITICAL | Cannot be proposed for runtime until condition is resolved |

---

## 16. Integration With PCEA V1C Ledger

The V1C Opportunity Ledger (`ai_opportunity_ledger.jsonl`) is the runtime observation layer. Nautilus certification feeds the design of what this ledger should observe and how its fields should be interpreted.

### 16.1 Nautilus → PCEA V1C Field Mapping

| Nautilus Finding | PCEA V1C Field | Relationship |
|---|---|---|
| Playbook assigned from cert | `playbook_id` | Cert defines the registry; runtime reads registry |
| Playbook state from co-presence | `playbook_state` | Nautilus defines what FORMING/VALID/CONTRADICTED means; MT5 emits the actual state per bar |
| Packet status from cert | `packet_registry_status` | Static registry lookup in `OL_PacketRegistryStatusForStrategy()` |
| Completed causal chain links | `completed_links_json` | Cert defines what "complete" means; runtime checks presence of each link |
| Missing causal chain links | `missing_links_json` | Cert defines what constitutes a missing link; runtime detects absence |
| Contradicted links | `contradicted_links_json` | Cert defines which combinations are contradictory; runtime detects those combinations |
| Failure mode co-presence | `failure_mode_present`, `failure_mode_type` | Cert accepts the failure mode; runtime checks presence |
| Event ordering | `event_order_valid`, `pre_decision_available`, `late_evidence` | Cert cannot validate live timing; only runtime can verify EOC compliance |
| Trade outcome | `outcome` | Runtime writes; Nautilus cannot observe live execution outcomes |
| Final decision | `final_decision` | Runtime writes; Nautilus simulates decisions under Nautilus cost model (not live spread) |

### 16.2 What Nautilus Can and Cannot Simulate

**Nautilus CAN simulate:**
- Strategy trigger detection (source-faithful or proxy)
- Historical trade outcomes under the Nautilus cost model
- Regime × direction × period segmentation
- Co-presence rates between strategies
- Packet classification (acceptance/rejection rule application)
- Playbook chain state (FORMING / VALID / NOT_PRESENT / CONTRADICTED)
- Shadow policy counterfactual outcomes
- Standalone WR, E[R], PF

**Only MT5 runtime CAN validate:**
- File I/O reliability of the opportunity ledger
- Live spread and slippage (GC=F proxy does not match exactly)
- EA governance chain execution (DSN/CRR/pre-AI filter behavior)
- Terminal reload behavior and session continuity
- Live co-presence between triggered strategies in real XAUUSD conditions
- Decision invariance of shadow fields (runtime_authority_status = NONE)
- Actual trade execution timing and outcome (broker-side execution)

### 16.3 Schema Version Alignment

| Schema Version | Status | Nautilus Coverage |
|---|---|---|
| OL_V1B_CROSS_FAMILY | SUPERSEDED by V1C | Partial — cross-family evidence only |
| OL_V1C_PLAYBOOK_SHADOW | CURRENT (as of 2026-05-09 cleanup) | Playbook states, packet registry status, event order trace |
| OL_V1D (future) | NOT_IMPLEMENTED | Pre-decision timestamps; room/stop geometry; zone_label per record |

All current Nautilus certifications feed the V1C schema. V1D schema extensions (zone_label, pre_decision_available from actual timestamps) will require a new set of cert-to-runtime mappings when implemented.

---

## 17. Current Lab Baseline From Existing Evidence

### 17.1 Phase 3 Certification Status (2026-05-09)

| Cert Status | Count | Strategies |
|---|---|---|
| Formally edge-classified | 8 | sweep_reversal, bollinger_reclaim, trend_momentum, trend_pullback_cont_v1, breakdown_momentum_v1, lower_high_rejection_v1, micro_structure_reentry_v1, range_edge_fade |
| Cert run — DATA_INSUFFICIENT | 1 | mfi_reversal_assist (cert file exists; 0 live entries at time of cert) |
| FROZEN — no cert needed | 1 | momentum_breakout_cont_v1 (EDGE_REJECTED, vote_weight=0.00) |
| PENDING_CERTIFICATION | 7 | mean_reversion_bounce, fake_break_reversal, range_compression_breakout, volatility_squeeze_release, volatility_breakout, expansion_continuation, micro_range_expansion |
| **Total** | **17** | All council strategies accounted for |

### 17.2 Accepted Packet Inventory (System Total)

| Status | Count | Detail |
|---|---|---|
| Formally ACCEPTED | 1 | micro_structure_reentry_v1: FAILURE_MODE_PACKET for LHR E[R] degradation (−0.068R; N=4,268 SUFFICIENT) |
| Research designation | 1 | trend_pullback_cont_v1: CONFIRM_PACKET_SPARSE (EDGE_SUPPORTED standalone; 1.4% TM co-presence — structural sparsity) |
| RESEARCH_ONLY (per cert) | Multiple | sweep_reversal counter-trend; LHR TC SELL proxy; MSR SELL×TREND_UP; others — all below formal thresholds |
| Formally REJECTED | Many | BR/REF CONFIRMATION (zone proxy degrades; ubiquitous co-presence); BDM all packets; VWAP candidate rejected |
| DATA_INSUFFICIENT | 9 | All PENDING_CERTIFICATION strategies + mfi_reversal_assist |

**Key gap:** Zero formally accepted CONFIRMATION_PACKET in any playbook. This is why all three playbooks remain below PLAYBOOK_VALID.

### 17.3 Playbook States

| Playbook | State | Reason for Current State | Primary Missing Evidence |
|---|---|---|---|
| RBSR | PLAYBOOK_FORMING | No accepted CONFIRMATION_PACKET; SR/BR co-presence ubiquitous (88–94%); sweep_reversal below ALPHA formal threshold | Cross-family CONFIRM with WR lift ≥ +2pp; OR sweep_reversal counter-trend E[R] to reach +0.04R |
| TPC | PLAYBOOK_FORMING | TPC co-presence structural (1.4%); all TC-CONFIRM certs complete with no accepted CONFIRMATION_PACKET | Phase 4A architecture decision; non-starvation CONFIRM path |
| VCR | PLAYBOOK_NOT_PRESENT | Zero evidence at any level | range_compression_breakout Phase 3 cert as minimum first step |

### 17.4 Additional Lab Artifacts (Beyond Core Certs)

| Artifact | Type | Significance |
|---|---|---|
| certification_composite_rbsr_v1.md | Playbook pilot | RBSR chain co-presence test; first playbook-level cert |
| certification_vwap_regime_reclaim_xauusd_v1.md | Rejected candidate | VWAP strategy screened and rejected before admission |
| certification_tsmom_proxy_benchmark_v1.md | Baseline | TSMOM naive baseline for comparing strategy alpha |
| certification_ref_sell_trend_down_isolation_v1.md | Subset cert | REF SELL×TREND_DOWN isolation — RESEARCH_ONLY direction finding |
| mfi_reversal_assist_veto_overlay_v1.json | Overlay | MFI veto simulation output — informative for SPC-005/006 |
| micro_structure_reentry_v1_packet_classification_v1.json | Packet | Accepted FAILURE_MODE_PACKET data |
| trend_pullback_cont_v1_overlap_trend_momentum.csv | Co-presence | TPC-TM 1.4% co-presence evidence file |

### 17.5 Data Inventory

| File | Records | Date Range | Status |
|---|---|---|---|
| `XAUUSD_M1_20251107_20260507.csv` | SOURCE_READ_REQUIRED | 2025-11-07 to 2026-05-07 | CURRENT |
| `XAUUSD_M5_20251107_20260507.csv` | SOURCE_READ_REQUIRED | 2025-11-07 to 2026-05-07 | CURRENT |

**Data extension required:** Re-export from MetaEditor64 when data is >30 days stale from last certification run date.

---

## 18. Lab Use Cases

| # | Use Case | Trigger | Deliverable | Phase Dependency |
|---|---|---|---|---|
| 1 | New strategy admission test | Any new strategy proposed for MT5 cohort | Full admission protocol (§8) — standalone cert + packet + playbook + system compat | None — can run any time |
| 2 | Existing strategy reclassification | Live WR diverges from cert WR by >5pp sustained; or registry gap found | Targeted subset re-cert; packet status update | After ≥30 live closed trades with divergence |
| 3 | Packet role validation | Registry packet status RESEARCH_ONLY and accumulation threshold reached | Co-presence analysis; confirmation or rejection of packet hypothesis | After minimum N reached per §14 |
| 4 | Playbook certification | Playbook has FORMING state; evidence gap identified in chain | Composite playbook replay; chain state analysis | After anchor strategy certified + ≥1 confirm candidate certified |
| 5 | Shadow policy evaluation | SPC minimum sample threshold met (per §11.3) | Shadow policy results JSON + cert MD | After post-cleanup V1C accumulation |
| 6 | Phase blocker investigation | Phase 4A/4B/4C blocker condition; lab can generate supporting evidence | Targeted test for the specific blocker | As specific blocker specifies |
| 7 | Production-readiness evidence support | System moves toward PRE_PRODUCTION_CANDIDATE status criteria | Comprehensive multi-strategy evidence package; regime stability; direction balance | After Phase 3 substantially complete (≥12/17) + Phase 4 live |
| 8 | Regression after source change | Any bounded Codex task applies a trigger change to council_strategies.mqh | Cert re-run with new trigger logic vs prior cert baseline | Immediately after compile-clean source change |
| 9 | Broker / cost sensitivity check | Cost model assumptions questioned; new broker under consideration | D-variant (stress) + cost sensitivity sweep | Any time |
| 10 | Data period robustness check | >6 months since last cert run; market regime may have shifted | Variant A re-run on extended data; compare to prior cert | When data file extended by ≥3 months |

---

## 19. Lab Limitations

These limitations are permanent and structural. No version of this lab removes them.

### 19.1 What Nautilus Cannot Prove

| Cannot Prove | Reason | Implication |
|---|---|---|
| MT5 runtime stability | Nautilus runs offline Python — no EA file I/O, no terminal events | Live runtime validation remains mandatory after any source change |
| File I/O reliability | Nautilus does not test jsonl write/read cycle, file lock, or session continuity | ai_opportunity_ledger.jsonl write behavior only validated via live runtime |
| Broker execution quality | GC=F proxy does not match XAUUSD broker spread exactly | All Nautilus WR/E[R] figures carry PARTIAL_REPLICATION caveat |
| Terminal reload behavior | EA init/deinit lifecycle not simulated | Reload effects (ledger reset, counter state) only validated live |
| Live spread/slippage exactly | Cost model (10pt + 2pt) is approximation | Actual cost sensitivity requires live trade sample analysis |
| Governance chain execution | DSN/CRR/pre-AI filter chain runs in MQL5 — not simulated in Nautilus | Gate behavior only validated via MT5 runtime |
| Production readiness | Nautilus evidence is a necessary condition, not sufficient; live capital risk requires MT5 runtime + extended trade sample | DEVELOPING status cannot be changed by lab results alone |
| Decision invariance of shadow fields | runtime_authority_status=NONE cannot be verified by Nautilus — only by reading live JSONL records | V1C decision invariance confirmed by runtime audit |

### 19.2 What Nautilus Accelerates

| Accelerates | How |
|---|---|
| Evidence generation | Hundreds of backtested trades per strategy in minutes, vs weeks of live accumulation |
| Historical replay | Any market period, any regime composition, can be analyzed deterministically |
| Policy falsification | Shadow policy hypotheses can be rapidly rejected if data does not support them |
| Packet / playbook classification | Co-presence analysis runs in seconds on 7,000+ bar datasets |
| Strategy admission screening | New candidates screened before source changes — prevents harmful strategies from entering MT5 |
| Regime segmentation | Full regime×direction breakdown produced per run — live runtime cannot produce this rapidly |
| Starvation detection | Co-presence rates are directly observable in Nautilus before any gate is proposed |

---

## 20. Recommended First Lab Build Package

### IRREW_NAUTILUS_LAB_BOOTSTRAP_PACKAGE_V1

**Recommended execution date:** After this document is approved; market-closed period acceptable
**Purpose:** Formalize the lab infrastructure to support all future certification work at the quality level defined in this document

**Deliverables:**

| Deliverable | Description | Files Created |
|---|---|---|
| system_lab/ folder structure | Create `system_lab/manifests/`, `system_lab/templates/`, `system_lab/registry_snapshots/`, `system_lab/compatibility_reports/`, `system_lab/run_logs/` | Folders only — no file content yet |
| run_manifest schema | Standardized JSON schema for lab run manifests (per §12.5) | `system_lab/templates/run_manifest_schema.json` |
| certification_report template | Standardized MD template for all future strategy cert reports | `system_lab/templates/certification_report_template.md` |
| metrics schema | Shared JSON schema for metrics output (per §7.3 metrics table) | `system_lab/templates/metrics_schema.json` |
| packet_classification schema | JSON schema for packet classification output | `system_lab/templates/packet_classification_schema.json` |
| system_compatibility schema | JSON schema for system compatibility output | `system_lab/templates/system_compatibility_schema.json` |
| playbook_compatibility schema | JSON schema for playbook compatibility output | `system_lab/templates/playbook_compatibility_schema.json` |
| shadow_policy_results schema | JSON schema for SPC evaluation output | `system_lab/templates/shadow_policy_results_schema.json` |
| PCEA V1C replay skeleton | Python script skeleton for reading V1C JSONL and preparing SPC evaluation | `scripts/shadow_policy/pcea_v1c_ledger_replay_skeleton.py` |
| Registry snapshot (current) | Snapshot of PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md at Bootstrap date | `system_lab/registry_snapshots/registry_snapshot_<YYYYMMDD>.md` |

**Scope restrictions:**

| Restriction | Reason |
|---|---|
| Do NOT run new strategy certifications in Bootstrap package | Bootstrap is infrastructure only; cert runs happen in subsequent packages |
| Do NOT retest existing certified strategies | Existing cert output is valid; re-cert only when a defined trigger fires (§9.2) |
| Do NOT create new Python scripts with live strategy logic | Only schema/template/skeleton work; no new cert runs |
| Do NOT move or rename existing lab files | Existing scripts/outputs/certifications stay where they are |
| Do NOT propose MT5 source changes | Bootstrap is lab infrastructure — no runtime impact |

**Next package after Bootstrap:**

After Bootstrap is complete, the recommended first certification work packages are:

1. **MEAN_REVERSION_BOUNCE_CERT_PACKAGE_V1** — certify mean_reversion_bounce (RBSR chain CONFIRM gap; closest to completing RBSR causal chain)
2. **FAKE_BREAK_REVERSAL_CERT_PACKAGE_V1** — certify fake_break_reversal (RBSR SCOUT secondary; required for SPC-003 evaluation)
3. **SPC_EVALUATION_PACKAGE_V1** — run SPC-006 and SPC-005 evaluations once mfi_reversal_assist accumulates ≥5 live entries

Do not attempt VCR family certifications until COMPRESSION zone activity is confirmed live in the V1C ledger.

---

## 21. Completion Checklist

| Item | Status |
|---|---|
| PIML reviewed (authority, governance, phase status, forbidden changes) | REVIEWED |
| PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md reviewed (17 strategies, 3 playbooks, 13 packet types, GF-1 through GF-12) | REVIEWED |
| ARCHITECTURE_BUILD_PACKAGE_V1.md reviewed (4-layer model, Event Order Contract, Package A-E, phase gate status) | REVIEWED |
| IMPLEMENTATION_SPEC_PACKAGE_V1.md reviewed (5 Codex candidates, GFW-1 through GFW-14, struct specs) | REVIEWED |
| SHADOW_POLICY_CANDIDATE_DESIGN_PACKAGE_V1.md reviewed (SPC-001 through SPC-010, 8 SPC types, GFS-1 through GFS-10) | REVIEWED |
| Existing Nautilus lab inventory confirmed (folder structure, cert files, script files, output files, data files) | REVIEWED |
| Lab identity defined (official name, short name, path, engine, data, cost model) | COMPLETE |
| All four certification levels defined (strategy, packet/playbook, system compat, shadow policy) | COMPLETE |
| Standard 8-step certification workflow defined | COMPLETE |
| New strategy admission protocol defined (11 steps, admission rules, fast-track criteria) | COMPLETE |
| Existing strategy re-certification mode defined (17 strategies, re-cert triggers, no micro-test swamp rule) | COMPLETE |
| Playbook certification mode defined (RBSR / TPC / VCR current state, what Nautilus can and cannot do) | COMPLETE |
| Shadow policy evaluation mode defined (SPC-001 through SPC-010, sample requirements, governance firewall) | COMPLETE |
| Standard output artifacts defined (naming convention, schemas, required files per run type) | COMPLETE |
| Evidence classification rules defined (8 classes, citation rules) | COMPLETE |
| Acceptance and rejection rules defined (per packet type, per shadow policy verdict) | COMPLETE |
| Runtime transferability assessment defined (10 questions, 3 transferability classes) | COMPLETE |
| PCEA V1C ledger integration defined (Nautilus → V1C field mapping, what Nautilus can/cannot simulate) | COMPLETE |
| Current lab baseline documented (cert inventory, packet inventory, playbook states, data inventory) | COMPLETE |
| 10 lab use cases defined | COMPLETE |
| Lab limitations defined (what Nautilus cannot prove, what it accelerates) | COMPLETE |
| First lab build package recommended (IRREW_NAUTILUS_LAB_BOOTSTRAP_PACKAGE_V1) | COMPLETE |
| Governance firewall stated clearly (Nautilus = evidence only; MT5 = runtime authority) | COMPLETE |
| No MT5 source files modified | CONFIRMED |
| No runtime JSON/JSONL files modified | CONFIRMED |
| No PIML update | CONFIRMED |
| No compile run | CONFIRMED |
| No MT5 reload | CONFIRMED |
| System status DEVELOPING unchanged | CONFIRMED |

---

## Governance Firewall Summary

The following constraints apply permanently to every output of this lab, every document that cites this lab, and every downstream decision that references any lab finding.

| Rule | Constraint |
|---|---|
| GFW-LAB-1 | Nautilus is evidence lab only. MT5 remains runtime authority. Permanently. |
| GFW-LAB-2 | Nautilus findings do not authorize MT5 source changes. Authorization requires operator review → bounded Codex task → compile-clean → static validation. |
| GFW-LAB-3 | Nautilus findings do not authorize gates, scores, weights, roles, CRR/DSN changes, HIGH_CONVICTION changes, execution changes, or risk changes. |
| GFW-LAB-4 | Strategy certification does not equal strategy admission. |
| GFW-LAB-5 | Packet acceptance does not equal runtime authority. |
| GFW-LAB-6 | Playbook PLAYBOOK_VALID state does not equal trade permission. |
| GFW-LAB-7 | Shadow policy success does not equal implementation approval. |
| GFW-LAB-8 | Any MT5 implementation requires a separate bounded Codex task with separate operator authorization and adversarial review. |
| GFW-LAB-9 | PIML governs in any conflict between this document and PIML. |
| GFW-LAB-10 | DATA_INSUFFICIENT means the question was not answered. It implies neither positive nor negative edge. |

---

## Footer

```
LAB_ID:                      IRREW_NAUTILUS_EVIDENCE_CERTIFICATION_LAB_V1
SHORT_NAME:                  INEC_LAB_V1
VERSION:                     V1
DATE_ESTABLISHED:            2026-05-09
SUPERSEDES:                  NAUTILUS_PCEA_OFFLINE_VALIDATION_LAB_V1 (informal; no formal document existed)
LAB_PATH:                    C:\Users\INFINTY GROUP\Documents\nautilus_lab\
ENGINE:                      NautilusTrader
PYTHON:                      3.14.3
DATA_SYMBOL:                 XAUUSD (GC=F proxy — PARTIAL_REPLICATION)
DATA_RANGE:                  2025-11-07 to 2026-05-07 (current)
STRATEGIES_CERTIFIED:        8 formally edge-classified; 1 DATA_INSUFFICIENT cert; 1 FROZEN; 7 PENDING
PLAYBOOKS_REGISTERED:        3 (RBSR=FORMING; TPC=FORMING; VCR=NOT_PRESENT)
ACCEPTED_PACKETS:            1 formal (MSR FAILURE_MODE for LHR); 1 research (TPC CONFIRM_SPARSE)
SOURCE_CHANGED:              NO
COMPILE_RUN:                 NO
RUNTIME_FILES_MODIFIED:      NO
PIML_UPDATE:                 NO
MT5_RELOAD:                  NO
SYSTEM_STATUS:               DEVELOPING
PRODUCTION_READY_CLAIMED:    NO
RUNTIME_AUTHORITY:           MT5 EA (V1) — permanent; not transferred to this lab
NEXT_RECOMMENDED_PACKAGE:   IRREW_NAUTILUS_LAB_BOOTSTRAP_PACKAGE_V1
```
