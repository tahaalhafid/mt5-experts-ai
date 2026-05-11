# CLAUDE_EXTERNAL_STRATEGY_SELECTION_AND_INEC_PLAN_V1

**Date:** 2026-05-11
**Author:** Claude (decision authority — independent evaluation of Gemini research)
**Input:** GEMINI_EXTERNAL_XAUUSD_STRATEGY_CANDIDATE_RESEARCH_V1.md
**Scope:** Independent candidate evaluation, selection, and INEC certification plan design.
**Authority:** MT5 = runtime authority. This document = research/planning only. `runtime_authority_status: "NONE"`
**Status:** STRATEGY_SELECTED_AWAITING_INEC_APPROVAL (APPROVAL_GATE_1 required before INEC execution)

---

## A. Claude's Independent Evaluation Framework

Claude does not accept Gemini's ranking without independent review. This section applies the 10-question evaluation framework to each top-3 candidate.

---

## B. Candidate Evaluations

### B1. Candidate A — NR7 Narrow Range Compression Breakout

| Question | Answer |
|---|---|
| Does it fill a real current gap? | YES — VCR ALPHA_TRIGGER (Gap #2 = HIGH severity, currently PLAYBOOK_NOT_PRESENT). Secondary: LOCATION_PACKET context (Gap #3). |
| Materially different from existing 17? | YES — no compression detection exists in any of the 17 strategies. |
| Improves quality or adds complexity only? | Improves — adds a new regime (VCR) with zero current coverage, no starvation competition with existing MEAN_RECLAIM/TC signals. |
| Representable categorically without score authority? | YES — NR7_CONDITION is a single binary: `(High[0]-Low[0]) < min(High[i]-Low[i] for i=1..6)`. Clean categorical gate. |
| Compatible with V1/IRREW/PCEA? | YES — pure OHLCV, no authority boundary overlap. |
| Packet role? | ALPHA_TRIGGER_PACKET (primary). LOCATION_PACKET (secondary — NR7_CONDITION as pre-decision state). |
| Data required — available today? | OHLCV only. YES — available from current nautilus_lab export (2025-11-07 to 2026-05-07). |
| INEC evidence that would PROVE it? | WR ≥40%, E[R] > 0.0R on N ≥ 50 NR7 signals on XAUUSD M15, surviving Variant D (+10pt spread). |
| INEC evidence that would REJECT it? | WR < 35%, E[R] < −0.05R across all filter variants with N ≥ 30. |
| Minimum implementation footprint if approved? | Single function `DetectNR7CompressionTrigger()` (~30–40 lines MQL5), council role SCOUT or TREND_JUDGE for VCR zone. |
| Starvation risk? | LOW — NR7 fires only in compression conditions; does not compete for bar-space with TC/RMR signals. |

**Claude Classification: ACCEPT_FOR_INEC_CANDIDATE**

**Strengths:**
- Crabel futures origin (commodity futures = closest empirical analogue to XAUUSD)
- Lowest parameter count of any candidate (lookback=7, single value, Crabel's original)
- Cleanest INEC test: binary condition → INEC variants are structurally unambiguous
- Never been optimized for XAUUSD → zero XAUUSD-specific overfitting

**Concerns:**
- Bulkowski's 13,391-trade evidence is daily timeframe, not M15 intraday. The statistical tendency may or may not transfer to 15-minute bars on a single instrument.
- The OCO structure (buy stop above + sell stop below) captures false breakouts as losses — requires INEC to verify which direction has edge, or whether direction is random.
- No built-in direction filter: INEC must test direction quality separately from trigger quality.

---

### B2. Candidate B — TTM Squeeze (BB-Keltner) Volatility Compression Release

| Question | Answer |
|---|---|
| Does it fill a real current gap? | YES — VCR ALPHA_TRIGGER (Gap #2). LOCATION_PACKET (Gap #3) via SQUEEZE_ON state (more architecturally complete than NR7's secondary LOCATION role). |
| Materially different from existing 17? | YES — no BB/KC compression state machine exists. |
| Improves quality or adds complexity only? | Improves — the SQUEEZE_ON state solving event_order_valid=false is the most architecturally valuable element found in this research. |
| Representable categorically without score authority? | YES — three clean states: COMPRESSED/FIRED/RESET, each a binary condition. |
| Compatible with V1/IRREW/PCEA? | YES. |
| Packet role? | ALPHA_TRIGGER_PACKET (SQUEEZE_FIRE) + LOCATION_PACKET (SQUEEZE_ON state as context anchor). Dual role confirmed. |
| Data required — available today? | OHLCV only. YES. |
| INEC evidence that would PROVE it? | WR ≥40% on SQUEEZE_FIRE + momentum direction signals, N ≥ 50 on XAUUSD M5, surviving Variant D. LOCATION test: SQUEEZE_ON preceding a signal must improve WR by ≥+3pp vs signals without prior SQUEEZE_ON state. |
| INEC evidence that would REJECT it? | WR < 35% with N ≥ 30 across all filter variants AND SQUEEZE_ON LOCATION test fails to lift WR. |
| Minimum implementation footprint if approved? | BB + KC calculation + 3-state machine + LinReg histogram. Approximately 80–100 lines MQL5. Council role: SCOUT or TREND_JUDGE for VCR zone. |
| Starvation risk? | LOW-MEDIUM — SQUEEZE_ON state may occur frequently in range-bound XAUUSD (Asian session), creating false state activations. Co-presence rate must be tested in INEC. |

**Claude Classification: ACCEPT_FOR_INEC_CANDIDATE**

**Strengths:**
- Dual role: ALPHA_TRIGGER + LOCATION_PACKET — most architecturally valuable candidate found
- SQUEEZE_ON state maps precisely to the pre-decision context anchor the system needs for event_order_valid=true
- The SQUEEZE_ON → SQUEEZE_FIRE sequential chain matches the council's event-ordering requirement: context/location → trigger → confirm
- Built-in directional signal (momentum histogram) allows INEC to test direction quality independently
- Carter's published framework widely implemented on commodity futures/ETFs

**Concerns:**
- Gold-specific false-breakout documented: [FACT from volatilitybox.com] "Gold often breaks one direction after the squeeze before making the true move in the opposite direction." This is XAUUSD-specific, not a generic squeeze limitation.
- Two adjustable parameters (BB SD + KC ATR multiplier) vs NR7's one — slightly larger overfitting surface
- Minimum squeeze duration filter (≥6 bars) is an INTERPRETATION not in primary source — must be tested in INEC not assumed

---

### B3. Candidate C — RSI Divergence + Candlestick Composite

| Question | Answer |
|---|---|
| Does it fill a real current gap? | YES — FAILURE_MODE (Gap #5: mfi_reversal_assist only 2 entries, insufficient for veto calibration). CONFIRMATION_PACKET potential (Gap #1) in REVERSAL_EXHAUSTION zone. |
| Materially different from existing 17? | YES — mfi_reversal_assist uses MFI (volume-weighted); RSI divergence is pure price momentum. Independent dimensions. |
| Improves quality or adds complexity only? | Improves — parallel FAILURE_MODE signal diversification without duplicating MFI. |
| Representable categorically without score authority? | YES — composite AND gate: both RSI divergence AND candlestick conditions simultaneously. |
| Compatible with V1/IRREW/PCEA? | YES. |
| Packet role? | FAILURE_MODE_PACKET (primary — TC/BREAKOUT exhaustion veto diversification). CONFIRMATION_PACKET (secondary — co-presence lift test in REVERSAL_EXHAUSTION zone). |
| Data required — available today? | OHLCV only. YES. |
| INEC evidence that would PROVE it? | For FAILURE_MODE: E[R] degradation ≥ −0.06R OR WR degradation ≥ −3pp when co-present with TC signals. For CONFIRMATION: WR lift ≥ +2pp AND E[R] lift ≥ +0.04R when co-present with sweep_reversal in REVERSAL zone. |
| INEC evidence that would REJECT it? | FAILURE_MODE test: no statistically meaningful degradation signal (P < 0.10 not achievable). CONFIRMATION test: co-presence rate > 80% (starvation risk) or WR lift < +2pp. |
| Minimum implementation footprint if approved? | RSI + divergence scan (bar loop) + candlestick check. ~60–80 lines MQL5. |
| Starvation risk? | LOW for FAILURE_MODE (fires at extremes). MEDIUM for CONFIRMATION (co-presence rate with sweep_reversal unknown). |

**Claude Classification: ACCEPT_FOR_INEC_CANDIDATE (TERTIARY — different gap from A and B)**

**Strengths:**
- Fills a different and important gap from A and B (FAILURE_MODE, not VCR)
- Code-level definitions verified from MQL5 source — lowest implementation ambiguity of any candidate
- Aligns with documented XAUUSD liquidity sweep behavior
- Diversifies FAILURE_MODE signal beyond mfi_reversal_assist

**Concerns:**
- Source quality is ALGO_COMMUNITY only — no academic or VERIFIED_PRACTITIONER validation on XAUUSD M5 performance
- Strong trends = repeated false signals without mandatory regime gating
- Phase 4B (exhaustion veto) is specifically about mfi_reversal_assist calibration — adding RSI divergence does not unblock Phase 4B. These are separate architectural tracks.
- The CONFIRMATION_PACKET role (Gap #1) requires testing cross-family co-presence lift with existing signals — this needs more OL records than currently exist (53 total) to be meaningful.

---

## C. Claude's Independent Ranking

| Rank | Candidate | Classification | Gap Priority | Architectural Value |
|---|---|---|---|---|
| **1** | **TTM Squeeze (B)** | ACCEPT_FOR_INEC_CANDIDATE | VCR ALPHA (#2) + LOCATION (#3) | **HIGHEST** — dual role solves two gaps simultaneously; SQUEEZE_ON state uniquely resolves event_order_valid=false |
| **2** | NR7 (A) | ACCEPT_FOR_INEC_CANDIDATE | VCR ALPHA (#2) | HIGH — cleanest parameter surface, strongest evidence base, conservative fallback if TTM Squeeze fails |
| **3** | RSI Divergence+Pattern (C) | ACCEPT_FOR_INEC_CANDIDATE | FAILURE_MODE (#5) | MEDIUM — valid gap fill but different track from A/B; best pursued after VCR gap is addressed |

**Claude Re-rank Rationale vs Gemini Rank:**

Gemini ranked NR7 #1 primarily on evidence quality and parameter simplicity. Claude re-ranks TTM Squeeze to #1 for the following architectural reason:

**The SQUEEZE_ON state as a pre-decision LOCATION_PACKET is the single most valuable architectural contribution found in this research.**

All 53 opportunity ledger records have `event_order_valid=false`. The root cause is `POST_DECISION_SHADOW_ASSEMBLY` — the pre-decision context chain (context → location → trigger → confirm) is never fully established before the decision fires. This blocks `playbook_thesis_complete=true` across all three active playbooks.

TTM Squeeze provides a natural solution:
- `SQUEEZE_ON` state = pre-decision LOCATION anchor (compression context is identified before the trigger fires)
- `SQUEEZE_FIRE` = ALPHA_TRIGGER
- An existing confirmation packet = CONFIRM

This sequential chain (SQUEEZE_ON → SQUEEZE_FIRE → confirm) maps directly to the required pre-decision event ordering. NR7's OCO trigger fires at the entry bar and does not provide a distinct pre-trigger state.

If TTM Squeeze passes INEC for both ALPHA_TRIGGER (SQUEEZE_FIRE WR ≥40%) and LOCATION (SQUEEZE_ON preceding a signal lifts WR ≥+3pp), it simultaneously unlocks:
1. VCR ALPHA_TRIGGER_PACKET (Gap #2)
2. LOCATION_PACKET (Gap #3)
3. event_order_valid pathway toward playbook_thesis_complete=true

NR7 is classified as the fallback candidate if TTM Squeeze INEC results are insufficient.

---

## D. Selected INEC Candidate

```
SELECTED_CANDIDATE:         TTM_SQUEEZE_VCR_INEC_V1
STRATEGY_NAME:              TTM Squeeze (BB-Keltner Volatility Compression Release)
GAP_TARGETED:               VCR ALPHA_TRIGGER (Gap #2, HIGH) + LOCATION_PACKET (Gap #3, HIGH)
PACKET_ROLES_TESTED:        ALPHA_TRIGGER_PACKET (primary), LOCATION_PACKET (secondary)
FALLBACK_CANDIDATE:         NR7_COMPRESSION_VCR_INEC_V1 (if TTM Squeeze INEC fails)
TERTIARY_CANDIDATE:         RSI_DIVERGENCE_FAILURE_MODE_INEC_V1 (separate track, pursue after VCR gap addressed)
```

---

## E. INEC Certification Plan — TTM_SQUEEZE_VCR_INEC_V1

### E1. Hypothesis

**Primary hypothesis (ALPHA_TRIGGER_PACKET):**
> "TTM Squeeze FIRE signals on XAUUSD M5, filtered by minimum squeeze duration ≥6 bars and momentum histogram direction, achieve WR ≥40% and E[R] > 0.0R on N ≥ 50 signals, surviving +10pt spread stress."

**Secondary hypothesis (LOCATION_PACKET):**
> "The presence of an active SQUEEZE_ON state in the bar(s) preceding an existing council signal improves that signal's WR by ≥+3pp vs signals that occurred without prior SQUEEZE_ON state."

### E2. Replication Plan

| Component | Implementation |
|---|---|
| Symbol | XAUUSD (primary). GC=F (CME Gold Futures) as proxy if XAUUSD unavailable → PARTIAL_REPLICATION |
| Timeframes | M5 (primary ALPHA_TRIGGER test), M15 (secondary validation) |
| Data | Existing nautilus_lab export: 2025-11-07 to 2026-05-07. Re-export if >30 days stale. |
| BB calculation | `pandas_ta.bbands(close, length=20, std=2.0)` — SOURCE_FAITHFUL |
| KC calculation | Keltner Channel: `EMA(close, 20) ± 1.5 × ATR(close, high, low, 20)` — SOURCE_FAITHFUL |
| SQUEEZE_ON | `Upper_BB < Upper_KC AND Lower_BB > Lower_KC` — SOURCE_FAITHFUL |
| SQUEEZE_FIRE | Previous bar SQUEEZE_ON=True, current bar SQUEEZE_ON=False (BB expanded outside KC) — SOURCE_FAITHFUL |
| Momentum histogram | `LinReg(close - MA(close,20), 20)` — SOURCE_FAITHFUL |
| Direction | LONG if histogram > 0 and rising (histogram[0] > histogram[1]); SHORT if < 0 and falling — SOURCE_FAITHFUL |
| Replication class | SOURCE_FAITHFUL (all components computable from OHLCV without external data) |

### E3. Cost Model (Fixed — Per INEC Lab Standard)

| Parameter | Value |
|---|---|
| Spread | 10 points |
| Slippage | 2 points |
| Stop | ATR(M1,14) × 1.20 |
| Risk-Reward | 1.50 |
| Breakeven WR | 40% |

### E4. Certification Variants

| Variant | Filter Applied | Purpose |
|---|---|---|
| **A — Unrestricted** | Raw SQUEEZE_FIRE with momentum direction only | Baseline WR and E[R]; full sample |
| **B — Duration filter** | A + minimum squeeze duration ≥6 bars before fire | Tests whether longer squeezes produce better edge (XAUUSD false-breakout mitigation) |
| **C — Session filter** | B + London/NY overlap only (07:00–17:00 GMT) | Tests whether session timing improves edge in gold's high-liquidity window |
| **D — Stress** | B + spread = 20pt (base 10pt + 10pt stress) | Validates edge survives cost increase |
| **E — Walk-forward** | B split 60/40 chronologically (train/validate) | Tests against in-sample overfitting if N ≥ 30 |

### E5. LOCATION_PACKET Test (Secondary — Variant F)

| Test | Method |
|---|---|
| **Variant F — LOCATION co-presence** | From all existing council signals in nautilus_lab OL records (53 current), separate into two groups: (1) signals where SQUEEZE_ON=True on the same bar or within the prior 3 bars; (2) all other signals. Compare WR between groups. |
| Acceptance threshold | WR lift ≥ +3pp for group 1 vs group 2 with N ≥ 30 in both groups |
| Rejection | WR lift < +2pp, or N < 15 in either group |

**Note on N:** With only 53 OL records currently, the LOCATION test is expected to be DATA_INSUFFICIENT at this stage. The ALPHA_TRIGGER test (Variants A–E) is primary; LOCATION is secondary and may require more data.

### E6. Segmentation Required

| Segmentation | Method |
|---|---|
| Regime breakdown | Separate results per regime label: COMPRESSION, RANGE_BALANCED, RANGE_DIRTY, TREND_UP, TREND_DOWN, REVERSAL_RISK, RANGE_MEAN_RECLAIM, TREND_CONTINUATION, BREAKOUT_EXPANSION |
| Direction breakdown | BUY vs SELL signals separately; confirm whether direction accuracy differs by session |
| Session breakdown | Asian (00:00–07:00 GMT), London (07:00–12:00), NY overlap (12:00–17:00), NY close (17:00–21:00) |
| Squeeze duration bands | <6 bars, 6–10 bars, 11–15 bars, >15 bars — WR by band |
| Outlier sensitivity | Remove best 3 and worst 3 trades; verify WR and E[R] hold |

### E7. Acceptance Thresholds

**For ALPHA_TRIGGER_PACKET (Primary):**

| Condition | Classification |
|---|---|
| WR ≥ 40% AND E[R] > 0.0R, N ≥ 50, Variant D survives | CERTIFIED_ALPHA_TRIGGER |
| WR 38–40% AND E[R] > −0.02R, N ≥ 30, Variant D borderline | RESEARCH_ONLY_PACKET — monitor 30 more signals |
| WR 35–38% OR E[R] < −0.02R | NOT_CERTIFIED — review session/regime filter improvement |
| WR < 35% across all variants with N ≥ 30 | REJECTED_PACKET |

**For LOCATION_PACKET (Secondary):**

| Condition | Classification |
|---|---|
| WR lift ≥ +3pp with SQUEEZE_ON prior presence, N ≥ 30 | CERTIFIED_LOCATION_PACKET |
| WR lift +2pp to +3pp | RESEARCH_ONLY_LOCATION |
| WR lift < +2pp | NOT_CERTIFIED_LOCATION |
| N < 15 in either group | DATA_INSUFFICIENT — repeat after OL accumulates ≥200 records |

### E8. Rejection Thresholds

| Condition | Outcome |
|---|---|
| WR < 35% across all variants with N ≥ 30 | REJECTED_PACKET — proceed to NR7 fallback INEC |
| E[R] < −0.05R across all regime splits | REJECTED_PACKET |
| False-breakout rate > 60% (signal reverses within 3 bars of fire) | REJECTED_PACKET |
| Squeeze duration analysis shows no benefit from ≥6 bar filter AND Variant A fails | REJECTED_PACKET |
| Replication classification forced to BEHAVIORAL_PROXY due to BB/KC proxy issues | DOWNGRADE to RESEARCH_ONLY; re-test with alternative KC method |

### E9. Required Python Implementation Artifacts

1. `nautilus_lab/strategies/ttm_squeeze_vcr.py` — Source-faithful trigger implementation
   - Functions: `calc_bb_bands()`, `calc_keltner_channels()`, `calc_momentum_histogram()`, `detect_squeeze_state()`, `detect_squeeze_fire()`
   - State machine: `COMPRESSED`, `FIRED`, `RESET` — per-bar state tracking
   - Replication class documented as SOURCE_FAITHFUL in module docstring

2. `nautilus_lab/outputs/ttm_squeeze_vcr_variant_a.csv` through `_variant_e.csv` — raw results

3. `nautilus_lab/outputs/ttm_squeeze_vcr_regime_breakdown.csv` — regime-split results

4. `nautilus_lab/outputs/ttm_squeeze_vcr_direction_breakdown.csv`

5. `nautilus_lab/outputs/ttm_squeeze_vcr_squeeze_duration_bands.csv`

6. `nautilus_lab/outputs/ttm_squeeze_vcr_location_test.csv` — Variant F co-presence results

7. `nautilus_lab/certifications/ttm_squeeze_vcr_certification_v1.md` — Final certification report with:
   - Replication classification
   - All variant results
   - Packet classification verdict (ALPHA_TRIGGER + LOCATION)
   - Evidence labels [FACT]/[INTERPRETATION]/[HYPOTHESIS] per claim
   - `runtime_authority_status: "NONE"` header

### E10. What This INEC Run Cannot Authorize

- No source (.mqh) changes from INEC results alone
- No strategy added to the operating cohort
- No weight assignment
- No production-ready claim
- Operator must explicitly authorize APPROVAL_GATE_2 before any implementation design begins

---

## F. If TTM Squeeze INEC Is Rejected — Fallback Plan

If TTM Squeeze fails INEC (WR < 35% across all variants, N ≥ 30):

**Immediate next step:** Run NR7 INEC (Candidate A) as the alternative VCR ALPHA_TRIGGER candidate.

NR7 INEC plan (abridged):
- N ≥ 200 NR7 signals on XAUUSD M15
- Variants: raw NR7 / + ATR regime filter / + session filter / + both filters
- Stress: +10pt spread
- Acceptance: WR ≥40%, E[R] > 0.0R, N ≥50
- Python: `detect_nr7_condition()` — rolling minimum range over 7 bars (one function, ~20 lines)

---

## G. Approval Gate Status

| Gate | Status | Condition |
|---|---|---|
| APPROVAL_GATE_0 | **AUTHORIZED** | Operator approved plan on 2026-05-11 |
| **APPROVAL_GATE_1** | **PENDING** | Operator must explicitly confirm: "Approve TTM Squeeze (TTM_SQUEEZE_VCR_INEC_V1) as the INEC candidate — authorize execution of INEC certification plan E1–E10 in nautilus_lab." |
| APPROVAL_GATE_2 | Blocked by Gate 1 | After INEC complete and verdict returned |
| APPROVAL_GATE_3 | Blocked by Gate 2 | Outside scope of this mission |

**No INEC Python code will be written. No nautilus_lab files will be created. No PIML will be updated until Gate 1 is explicitly confirmed.**

---

## H. Final Recommendation

```
INEC_CANDIDATE:             TTM_SQUEEZE_VCR_INEC_V1
PACKET_ROLES_TESTED:        ALPHA_TRIGGER_PACKET (primary) + LOCATION_PACKET (secondary)
GAPS_TARGETED:              VCR ALPHA (#2 HIGH) + LOCATION packet (#3 HIGH)
ARCHITECTURAL_VALUE:        HIGHEST of 3 candidates — dual role; SQUEEZE_ON resolves event_order_valid=false
EVIDENCE_BASE:              VERIFIED_PRACTITIONER (Carter published; CQG professional; StockCharts formal)
INEC_FEASIBILITY:           HIGH — SOURCE_FAITHFUL replication, all OHLCV-derivable, standard Python libraries
REJECTION_FALLBACK:         NR7_COMPRESSION_VCR_INEC_V1
TERTIARY_TRACK:             RSI_DIVERGENCE_FAILURE_MODE_INEC_V1 (separate authorization required)
NEXT_GATE_REQUIRED:         APPROVAL_GATE_1
SYSTEM_STATUS:              DEVELOPING
PRODUCTION_READY:           FALSE
```

---

```
DOC_ID:                     CLAUDE_EXTERNAL_STRATEGY_SELECTION_AND_INEC_PLAN_V1
DATE:                       2026-05-11
APPROVAL_GATE_0:            AUTHORIZED
APPROVAL_GATE_1:            PENDING — explicit operator confirmation required
SOURCE_CHANGED:             NO
COMPILE_RUN:                NO
MT5_RELOAD:                 NO
RUNTIME_FILES_MODIFIED:     NO
CODEX_INVOLVED:             NO
PRODUCTION_READY_CLAIMED:   NO
PIML_UPDATED:               NO — awaiting Gate 1
```
