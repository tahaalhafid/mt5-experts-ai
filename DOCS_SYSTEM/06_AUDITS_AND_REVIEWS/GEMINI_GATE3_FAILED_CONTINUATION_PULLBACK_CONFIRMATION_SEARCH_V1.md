# GEMINI_GATE3_FAILED_CONTINUATION_PULLBACK_CONFIRMATION_SEARCH_V1

**Date:** 2026-05-12
**Authority:** EVIDENCE_ONLY — MT5 runtime authority unchanged
**Script:** `nautilus_lab/scripts/cert_confirmation_packet_candidates_v6.py`
**Output:** `outputs/confirmation_packet_screen/confirmation_packet_screen_v6_results.json`
**Branch:** docs/blocker-closure-roadmap-state-v1

---

## A. Mission and Authority

Gate 3 interior-range confirmation candidate INEC screen. Continuation of Gate 2 after all Gate 2 primary candidates (BBMP3, M5MP, M52MP) failed interior certification, with M5MP/M52MP producing a systematic directional asymmetry finding.

**Scope:** Research + Python scripting only. No MT5 source changes. No Codex. No compile. No reload.
**MT5 status:** Runtime authority unchanged. All governance flags false.

Gate 3 tests five failed-continuation and pullback-sequence candidates (FCM, HLMA, CBAR, FCPB, PBR) using bars[2]–[4] only — no trigger bar, no look-ahead — against the RMR interior subset of three primary alpha strategies (SR, TM, BR).

**Acceptance target:** CONFIRM gap in RMR interior-range sessions. All existing CONFIRM sources (bollinger_reclaim, mean_reversion_bounce, range_edge_fade) require price at structural extremes → interior sessions produce `confirm_role_present=false` → actual_trade=0.

**Baseline:** SIMPLE_CONFIRMATION_MECHANISM_V1 (Option B — keep existing confirm_role_present path; solve gap by ADD_AS_COUNCIL_ROLE_CONFIRM). No gate rewrites authorized.

**New classification allowed (Gate 3):** BUY_ONLY or SELL_ONLY acceptance where one direction clears threshold, opposite is not harmful, and architectural limitation is explicitly noted.

---

## B. Prior INEC Screens Summary (V1–V3 and Gates 1–2)

| Version | Candidates | Verdict |
|---|---|---|
| V1 (BCLC, PBHB, MRR) | Bar-close and partial-body proximity | All artifacts (trigger-bar correlation) — REJECTED |
| V2 (PTBM, PTAI, TWOBAR, M5BC_RAW) | Prior-bar and M5-bar direction | PTBM/PTAI genuine but weak (≤+1.3pp); TWOBAR/M5BC artifact/look-ahead — REJECTED |
| V3 (TBB, M5BC_CORR) | Trigger-bar direction; corrected M5 bar | TBB = TRIGGER_SUB_FILTER (same bar); M5BC_CORR +3pp but 93% starvation — REJECTED |
| V4 Gate 1 (H1DA, BBMP, RMDM) | H1 alignment; BB midline 2-bar; multi-bar majority | H1DA harmful; BBMP TM interior RESEARCH_ONLY but April-driven; RMDM starvation — ALL FAILED |
| V5 Gate 2 (BBMP3, M5MP, M52MP; M15MP, H1MP diag.) | BB midline 3-bar; M5/M52/M15/H1 midpoint | BBMP3 April-driven; M5MP directional asymmetry artifact; M52MP research only; M15MP/H1MP harmful — ALL FAILED |

**Cumulative prior total:** 14 unique mechanisms tested across V1–V5 / Gates 1–2. Zero certifiable interior CONFIRM source found.

**Gate 2 structural finding carried into Gate 3:** M5 midpoint signals for reversal strategies (SR/BR) are directional selectivity effects, not true CONFIRM signals. Present-for-BUY selects atypical approach to band (price rising before hitting lower band) → lower WR. Present-for-SELL at upper band is typical subset → higher WR. This is the same structural root cause relevant to any pullback/reclaim signal applied to SR/BR BUY.

---

## C. Gate 3 Candidate Selection Rationale

Gate 3 candidates target failed-continuation and pullback-sequence mechanics — mechanisms that capture whether price demonstrated a failed attempt before the trigger or confirmed directional momentum via bar structure in bars[2]–[4]. All candidates use only M1 OHLCV from bars[2]–[4] before trigger_time.

**Five candidates selected:**

| ID | Name | Definition | Interior Range? | Independence |
|---|---|---|---|---|
| FCM | Failed Counter-Move | At least one of bars[2]–[4] has bearish push (for BUY) but closes high (≥60% of bar range) | YES — applies anywhere in range | FULL — no trigger bar used |
| HLMA | Higher-Low Micro Acceptance | bars[2,3,4] form consecutive HL (low[2]≥low[3]≥low[4] for BUY) | YES | FULL |
| CBAR | Consecutive Bar Acceptance Run | ≥2 of bars[2,3,4] are directional AND net movement directional | YES | FULL |
| FCPB | Failed Continuation Pullback Break | bars[3,4] had bearish attempt AND bar[2] close above their 2-bar range midpoint | YES | FULL |
| PBR | Pullback Reclaim/Rejection | bar[2] close above bars[3,4] 2-bar range midpoint (no attempt precondition) | YES | FULL |

**Elimination rationale (candidates not chosen):**
- C4 (IRDF), C9 (VBODY), C10 (PRDAY), C11 (HLLH): tested after observing similar structure in prior screens; deferred to Gate 4 if Gate 3 finds leads.
- C8 (MIRA): M5 variant — expected same starvation as M5BC_CORR for SR; deferred.
- C12 (M5CRUN): similar to M5BC starvation pattern for SR.

**FCPB vs PBR relationship:** FCPB adds a "bearish/bullish attempt" precondition to PBR. FCPB is a strict subset of PBR. For SR/BR interior BUY, the precondition is largely satisfied (SR fires after sustained decline), making FCPB ≈ PBR in coverage. For TM, PBR captures ~1556 additional trades not requiring the attempt condition.

---

## D. RMR Interior Subset Filter Definition

RMR interior proxy = trades where, at trigger_time, price is NOT near a BB band extreme AND NOT near a M5 range extreme.

```
Interior = NOT at_bb_band AND NOT at_m5_range_extreme

at_bb_band:
  bb_range = bb_upper - bb_lower  (BB 20-SMA ± 2×std, M1)
  near_lower = close ≤ bb_lower + 0.10 × bb_range
  near_upper = close ≥ bb_upper - 0.10 × bb_range
  at_bb_band = near_lower OR near_upper

at_m5_range_extreme:
  m5_range = m5_high20 - m5_low20  (M5 20-bar rolling high/low)
  m5_near_low = close ≤ m5_low20 + 0.15 × m5_range
  m5_near_high = close ≥ m5_high20 - 0.15 × m5_range
  at_m5_range_extreme = m5_near_low OR m5_near_high
```

Interior flag was pre-computed and persisted in V5 enriched CSVs. Gate 3 loads V5 enriched CSVs directly — no recomputation of BB or M5 range signals.

**Caveat for SR interior BUY:** SR alpha trigger fires by definition at or near the lower BB band (sweep below BB lower → reversal). This geometric constraint means the SR BUY interior subset will contain trades where price is NOT near the lower band at trigger_time — an atypical SR entry. The SR interior BUY subset is therefore inherently unusual; pullback signals that are present for this subset may be anti-predictive (they select atypical approaches to the band).

---

## E. No-Lookahead Verification

All five Gate 3 candidates use only bars[2]–[4] before trigger_time:
- bar[2] = `asof(trigger_time - 1min)` → guaranteed last closed M1 bar 2+ minutes prior
- bar[3] = `asof(trigger_time - 2min)`
- bar[4] = `asof(trigger_time - 3min)`

The `merge_asof_lookup()` function uses `pd.merge_asof(..., direction="backward")` ensuring only bars with index ≤ lookup timestamp are matched. No current-bar or partial-bar data is used. No H1 or M5 data is used in Gate 3 (no resampling required). All signals are bar-sequence properties of M1 data only.

---

## F. FCM — Failed Counter-Move Results

**Definition:** For BUY — at least one of bars[2,3,4] has a bearish push (downward move) but closes in the upper 60% of the bar's range, demonstrating rejection of bearish pressure. Bearish push = (close < open) OR ((open − low)/range ≥ 0.30). Closes high = (close − low)/range ≥ 0.60.

**Parameters:** FCM_UPPER_CLOSE_MIN=0.60, FCM_LOWER_CLOSE_MAX=0.40, FCM_LOWER_PUSH_FRAC=0.30, FCM_UPPER_PUSH_FRAC=0.30.

### F.1 SR Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 2924 | 1730 | 1194 | — | — |
| Co-presence | — | 59.2% | — | — | — |
| WR | 52.43% | 50.81% | 54.77% | **−3.96pp** | **REJECT_HARMFUL** |
| E[R] | +0.311R | +0.270R | +0.369R | −0.099R | REJECT_HARMFUL |

SR interior BUY direction: N_pres=1012/1707 (59%), WR lift=−3.80pp → REJECT_HARMFUL
SR interior SELL direction: N_pres=718/1217 (59%), WR lift=−4.18pp → REJECT_HARMFUL

**Note:** FCM present for SR interior BUY means bar[2]–[4] showed bearish push + high close before price reached the lower BB band. This selects atypical SR approaches (price already rejected bearish pressure before the band → "hesitation" before trigger) → structurally lower WR. Consistent with Gate 2 M5MP anti-prediction pattern.

### F.2 TM Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 6774 | 3366 | 3408 | — | — |
| Co-presence | — | 49.7% | — | — | — |
| WR | 40.48% | 40.97% | 39.99% | **+0.98pp** | **RESEARCH_ONLY** |
| E[R] | +0.012R | +0.024R | −0.000R | +0.024R | RESEARCH_ONLY |

TM interior BUY: N_pres=1574/3107 (51%), WR lift=+0.04pp → REJECT_WEAK (essentially flat)
TM interior SELL: N_pres=1792/3667 (49%), WR lift=**+1.81pp**, ER lift=**+0.0453R** → **ACCEPT_COUNCIL_ROLE_CONFIRM_CANDIDATE**

Directional asymmetry: FCM adds value in SELL direction (momentum-aligned — FCM fires when bar shows failed counter-rally before SELL trigger). BUY direction is flat — symmetric failed counter-move is less meaningful for upside momentum.

### F.3 BR Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 3894 | 1965 | 1929 | — | — |
| Co-presence | — | 50.5% | — | — | — |
| WR | 51.64% | 50.79% | 52.51% | **−1.72pp** | **REJECT_HARMFUL** |
| E[R] | +0.291R | +0.270R | +0.313R | −0.043R | REJECT_HARMFUL |

### F.4 TM Monthly Stability (Interior, Aggregate)

| Month | N (pres/all) | Co-pres | WR lift | Classification |
|---|---|---|---|---|
| 2026-01 | 241/520 | 46.4% | −3.92pp | REJECT_HARMFUL |
| 2026-02 | 950/1843 | 51.6% | **+2.79pp** | STRONG_ACCEPT |
| 2026-03 | 1045/2090 | 50.0% | **+2.78pp** | STRONG_ACCEPT |
| 2026-04 | 969/1952 | 49.6% | −1.68pp | REJECT_HARMFUL ◀ APRIL |
| 2026-05 | 161/369 | 43.6% | **+4.47pp** | STRONG_ACCEPT |
| **Ex-April** | **2397/4822** | **49.7%** | **+2.05pp** | **STRONG_ACCEPT** |

Ex-April TM interior: N=2397, WR lift=+2.05pp, E[R] lift=+0.0512R → STRONG_ACCEPT

**Monthly assessment:** 3/5 positive months (Feb, Mar, May strong; Jan and April harmful). April 2026 is the anomalous regime. Ex-April performance is STRONG_ACCEPT on both metrics, but April presence is harmful. Pattern is 3 strong / 2 harmful — not certifiable without April regime explanation.

### F.5 FCM Classification

**Final classification: REJECT for SR and BR. TM SELL direction: RESEARCH_ONLY (strategy-specific lead only).**

Cannot be certified as general interior CONFIRM source because:
1. SR interior: REJECT_HARMFUL (structural anti-prediction)
2. BR interior: REJECT_HARMFUL
3. TM BUY: flat — no signal in BUY direction
4. TM SELL aggregate passes ACCEPT threshold but monthly stability fails (Jan+Apr harmful)
5. Strategy-specific gating (TM-SELL-only) not currently authorized

---

## G. HLMA — Higher-Low Micro Acceptance Results

**Definition:** BUY = bars[2,3,4] form consecutive higher lows: low[2] ≥ low[3] ≥ low[4]. SELL = bars[2,3,4] form consecutive lower highs: high[2] ≤ high[3] ≤ high[4].

### G.1 Geometric Incompatibility with SR Interior BUY

SR alpha trigger fires by definition after a sustained price decline to or through the lower BB band. The pre-trigger M1 bars are structurally expected to have declining lows (downward momentum before the reversal trigger fires). Consecutive higher lows across bars[2]–[4] — a sustained micro-uptrend — is geometrically incompatible with the SR BUY trigger pattern.

**SR interior BUY: N_present = 0. Co-presence = 0.0%.** Geometric incompatibility confirmed. HLMA cannot function as an SR BUY interior CONFIRM source.

### G.2 SR Interior Results

| Metric | SR global | SR interior (all) | Interior present | Co-pres |
|---|---|---|---|---|
| N present | 3 | 0 | 0 | 0.0% |
| Classification | DATA_INSUFFICIENT | **DATA_INSUFFICIENT** | — | — |

SR interior SELL: N_pres=0/1217 (0%) — same incompatibility (declining prior structure before SELL trigger at upper band is opposite direction).

### G.3 TM Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 6774 | 2285 | 4489 | — | — |
| Co-presence | — | 33.7% | — | — | — |
| WR | 40.48% | 39.08% | 41.19% | **−2.11pp** | **REJECT_HARMFUL** |
| E[R] | +0.012R | −0.023R | +0.030R | −0.053R | REJECT_HARMFUL |

TM interior BUY: N_pres=984/3107 (32%), WR lift=−3.54pp → REJECT_HARMFUL
TM interior SELL: N_pres=1301/3667 (35%), WR lift=−1.08pp → REJECT_HARMFUL

**Explanation:** HLMA for TM interior BUY selects trades where bars[2]–[4] were already trending up before the trigger. For a momentum-break entry (TM), a sustained prior micro-uptrend may indicate the initial momentum pulse already fired — the trigger fires into an extended move rather than the start of momentum. This reduces WR.

### G.4 BR Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 3894 | 77 | 3817 | — | — |
| Co-presence | — | 2.0% | — | — | — |
| WR | 51.64% | 49.35% | 51.69% | **−2.34pp** | **REJECT_HARMFUL** |

Co-presence 2.0% — starvation. BR interior HLMA is geometrically incompatible (BR fires at lower band similar to SR). N=77 — DATA_INSUFFICIENT.

### G.5 HLMA Classification

**Final classification: REJECT_HARMFUL across all primaries and directions.**

Key findings:
1. SR interior BUY: N=0 — geometric incompatibility (consecutive HL impossible before SR BUY trigger in declining structure)
2. TM: REJECT_HARMFUL on both BUY and SELL directions
3. BR: DATA_INSUFFICIENT (2% coverage) + harmful lift
4. Structural root cause: consecutive higher lows selects trades where M1 already trended in trigger direction before the signal fired — often means entry into extended momentum, not beginning of move

---

## H. CBAR — Consecutive Bar Acceptance Run Results

**Definition:** BUY = at least 2 of bars[2,3,4] have close > open (directional) AND net movement is positive (close[2] > close[4]).

### H.1 SR Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 2924 | 244 | 2680 | — | — |
| Co-presence | — | 8.3% | — | — | — |
| WR | 52.43% | 45.90% | 53.02% | **−7.12pp** | **REJECT_HARMFUL** |
| E[R] | +0.311R | +0.148R | +0.326R | −0.178R | REJECT_HARMFUL |

SR interior BUY: WR lift=−8.75pp. SR interior SELL: WR lift=−4.64pp. Both strongly harmful.

### H.2 TM Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 6774 | 2781 | 3993 | — | — |
| Co-presence | — | 41.1% | — | — | — |
| WR | 40.48% | 40.67% | 40.35% | **+0.32pp** | **REJECT_WEAK** |
| E[R] | +0.012R | +0.017R | +0.009R | +0.008R | REJECT_WEAK |

TM interior BUY: N_pres=1217/3107 (39%), WR lift=+0.65pp → REJECT_WEAK
TM interior SELL: N_pres=1564/3667 (43%), WR lift=−0.05pp → REJECT_WEAK

No meaningful signal in either direction for TM.

### H.3 BR Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 3894 | 322 | 3572 | — | — |
| Co-presence | — | 8.3% | — | — | — |
| WR | 51.64% | 42.86% | 52.44% | **−9.58pp** | **REJECT_HARMFUL** |
| E[R] | +0.291R | +0.071R | +0.311R | −0.240R | REJECT_HARMFUL |

### H.4 CBAR Classification

**Final classification: REJECT.**

CBAR present for SR/BR interior means 2+ of the 3 prior M1 bars were directional in the trigger direction — price was already moving strongly in that direction before the reversal trigger fired. For reversal strategies (SR/BR), this "too much prior momentum" effect selects the worst entries. For TM, the effect is near-zero. No path forward.

---

## I. FCPB — Failed Continuation Pullback Break Results

**Definition:** BUY = bars[3,4] included at least one bearish candle (close < open) OR bearish-range push ((open − low)/range ≥ 0.30), AND bar[2] close is above the 2-bar range midpoint of bars[3,4]. Interpretation: there was a bearish attempt in bars[3,4], and bar[2] reclaimed above that range's midpoint.

**Relationship to PBR:** FCPB is a strict subset of PBR. FCPB adds the bearish-attempt precondition. For SR/BR BUY, this precondition is nearly always satisfied (there was a downward move before the lower-band reversal trigger). For TM, FCPB excludes ~1556 additional trades from PBR.

### I.1 SR Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 2924 | 583 | 2341 | — | — |
| Co-presence | — | 19.9% | — | — | — |
| WR | 52.43% | 45.97% | 54.04% | **−8.07pp** | **REJECT_HARMFUL** |
| E[R] | +0.311R | +0.149R | +0.351R | −0.202R | REJECT_HARMFUL |

SR interior BUY: N_pres=360/1707 (21%), WR lift=−11.13pp → STRONGLY HARMFUL
SR interior SELL: N_pres=223/1217 (18%), WR lift=−3.15pp → REJECT_HARMFUL

**Root cause:** FCPB present for SR interior BUY = bars[3,4] had bearish attempt AND bar[2] closed above range midpoint = price fell then rose before hitting the lower BB band. The "absent" group (price declined cleanly into the band) = typical SR BUY setup → much higher WR (54.04% vs 45.97%). Same structural anti-prediction as Gate 2 M5MP BUY and PBR BUY below.

### I.2 TM Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 6774 | 2185 | 4589 | — | — |
| Co-presence | — | 32.3% | — | — | — |
| WR | 40.48% | 40.27% | 40.58% | **−0.31pp** | **REJECT_WEAK** |
| E[R] | +0.012R | +0.007R | +0.014R | −0.008R | REJECT_WEAK |

TM interior BUY: N_pres=1005/3107 (32%), WR lift=+1.45pp, ER lift=+0.0361R → ACCEPT (ER criterion passes; WR below +2pp threshold; marginal)
TM interior SELL: N_pres=1180/3667 (32%), WR lift=−1.78pp → REJECT_HARMFUL

**BUY direction caveat:** FCPB TM BUY is dominated by PBR TM BUY (which is a superset with STRONG_ACCEPT at +2.05pp/+0.0512R). FCPB adds a bearish-attempt restriction that reduces N by ~40% relative to PBR while providing weaker lift (+1.45pp vs +2.05pp). FCPB TM BUY is strictly dominated and offers no independent value.

### I.3 BR Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 3894 | 1196 | 2698 | — | — |
| Co-presence | — | 30.7% | — | — | — |
| WR | 51.64% | 46.15% | 54.08% | **−7.93pp** | **REJECT_HARMFUL** |
| E[R] | +0.291R | +0.154R | +0.352R | −0.198R | REJECT_HARMFUL |

### I.4 FCPB Classification

**Final classification: REJECT.**

FCPB is architecturally dominated by PBR in the TM BUY direction (the only positive signal) and REJECT_HARMFUL for SR/BR. The bearish-attempt precondition provides no independent value over PBR's simpler midpoint condition. The aggregate TM interior is REJECT_WEAK (−0.31pp) due to SELL direction harm canceling BUY direction signal.

---

## J. PBR — Pullback Reclaim/Rejection Results

**Definition:** BUY = bar[2] close is above the 2-bar range midpoint of bars[3,4]: range_mid = (max(high[3], high[4]) + min(low[3], low[4])) / 2; pbr_buy = close[2] > range_mid. No bearish-attempt precondition.

### J.1 SR Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 2924 | 609 | 2315 | — | — |
| Co-presence | — | 20.8% | — | — | — |
| WR | 52.43% | 45.81% | 54.17% | **−8.36pp** | **REJECT_HARMFUL** |
| E[R] | +0.311R | +0.145R | +0.354R | −0.209R | REJECT_HARMFUL |

SR interior BUY: N_pres=379/1707 (22%), WR lift=−10.68pp → STRONGLY HARMFUL
SR interior SELL: N_pres=230/1217 (19%), WR lift=−4.53pp → REJECT_HARMFUL

**Root cause (structural, confirmed):** PBR present for SR interior BUY = bar[2] closed above bars[3,4] midpoint = price rose above prior range midpoint before hitting the lower BB band. The "absent" group (bar[2] closed below midpoint, price still trending down cleanly) = WR=54.17% vs PBR present WR=45.81%. This is the pullback anti-prediction pattern for reversal strategies: a clean approach to the band is the better reversal setup; a prior bounce (above midpoint) = hesitation that weakens the reversal.

### J.2 TM Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 6774 | 3741 | 3033 | — | — |
| Co-presence | — | 55.2% | — | — | — |
| WR | 40.48% | 41.09% | 39.73% | **+1.36pp** | **ACCEPT** |
| E[R] | +0.012R | +0.027R | −0.007R | +0.034R | ACCEPT |

TM interior BUY: N_pres=1684/3107 (54%), WR lift=**+2.05pp**, ER lift=**+0.0512R** → **STRONG_ACCEPT_CANDIDATE**
TM interior SELL: N_pres=2057/3667 (56%), WR lift=+0.71pp → REJECT_WEAK

**Directional profile:** PBR is BUY-driven for TM. The BUY direction shows STRONG_ACCEPT on both WR and E[R]. SELL direction is flat/weak. Aggregate is ACCEPT_COUNCIL_ROLE_CONFIRM_CANDIDATE driven by BUY direction strength.

### J.3 BR Interior Results

| Metric | All | Present | Absent | Lift | Classification |
|---|---|---|---|---|---|
| N | 3894 | 1214 | 2680 | — | — |
| Co-presence | — | 31.2% | — | — | — |
| WR | 51.64% | 45.88% | 54.25% | **−8.37pp** | **REJECT_HARMFUL** |
| E[R] | +0.291R | +0.147R | +0.356R | −0.209R | REJECT_HARMFUL |

Same anti-prediction as SR: BR fires at BB band (lower band for BUY) → prior pullback-above-midpoint is atypical approach → lower WR.

### J.4 TM Monthly Stability (Interior, Aggregate)

| Month | N (pres/all) | Co-pres | WR lift | Classification |
|---|---|---|---|---|
| 2026-01 | 286/520 | 55.0% | **+5.40pp** | STRONG_ACCEPT |
| 2026-02 | 1029/1843 | 55.8% | +0.19pp | REJECT_WEAK |
| 2026-03 | 1194/2090 | 57.1% | **+4.46pp** | STRONG_ACCEPT |
| 2026-04 | 1051/1952 | 53.8% | −1.43pp | REJECT_HARMFUL ◀ APRIL |
| 2026-05 | 181/369 | 49.1% | −0.55pp | REJECT_WEAK |
| **Ex-April** | **2690/4822** | **55.8%** | **+2.47pp** | **STRONG_ACCEPT** |

Monthly positive: 3/5 (Jan strong +5.40pp, Mar strong +4.46pp, Ex-Apr strong +2.47pp)
Monthly negative: 2/5 (Apr −1.43pp harmful; May −0.55pp weak)
February: flat (+0.19pp, REJECT_WEAK)

**Ex-April aggregate:** N=2690/4822 (56%), WR lift=+2.47pp, E[R] lift=+0.062R → STRONG_ACCEPT_CANDIDATE on both metrics.

**April 2026 anomaly:** April systematically appears as the negative regime across Gates 1, 2, and 3. Any candidate requiring April exclusion to pass is regime-specific. PBR requires April exclusion to clear STRONG_ACCEPT; inclusive April the aggregate is ACCEPT (not STRONG_ACCEPT). The April regime is not explained and cannot be excluded in production.

### J.5 PBR Classification

**Aggregate TM interior:** ACCEPT_COUNCIL_ROLE_CONFIRM_CANDIDATE
**TM BUY direction:** STRONG_ACCEPT_CANDIDATE (passes both thresholds)
**Final gate classification: TM BUY_ONLY RESEARCH_ONLY**

**Reasons for RESEARCH_ONLY (not ACCEPT):**
1. REJECT_HARMFUL for SR and BR interior — cannot be general CONFIRM source
2. TM SELL direction: flat (+0.71pp) — candidate is directionally asymmetric
3. Monthly instability: April harmful; February flat; May flat → 3/5 positive with two-month negative clusters
4. Strategy-specific CONFIRM gating (TM-only) is not currently authorized in council architecture
5. Architectural caveat: implementing PBR as CONFIRM source would require strategy-specific signal routing not present in current SIMPLE_CONFIRMATION_MECHANISM_V1

**Research lead value:** PBR TM BUY is the strongest positive signal found across all 19 mechanisms tested. Ex-April STRONG_ACCEPT with 56% co-presence. This is worth Gate 4 investigation if operator authorizes strategy-specific CONFIRM path.

---

## K. Global Context Results (Supporting Only)

Global SR lift is positive for PBR (WR lift=+1.98pp at 14.6% co-presence) and FCPB (WR lift=+1.71pp at 13.9% co-presence) but this is misleading. These are driven by the global (non-interior) subset where PBR fires at band extremes or range boundaries. Global lift does NOT override interior subset results per Gate 1 Correction 1.

---

## L. Structural Finding: Pullback Anti-Prediction for Reversal Strategies

This is the central structural finding of Gate 3, extending the Gate 2 M5MP directional asymmetry insight.

**Pattern (confirmed for FCPB and PBR across SR and BR interior):**

For reversal alpha triggers (SR fires at lower BB band; BR fires at lower BB band) interior BUY trades:
- When FCPB/PBR is **present**: bar[2] closed above bars[3,4] midpoint → price rose before hitting the lower band → atypical "hesitating" approach → WR ≈ 46%
- When FCPB/PBR is **absent**: bar[2] closed below midpoint → price declined cleanly into the band → typical, clean reversal setup → WR ≈ 54%

The **absent group** is the better reversal group. The signal inverts.

**Root cause:** Reversal strategies require a clean sustained decline (BUY) or sustained rise (SELL) to build sufficient momentum for the reversal. A prior pullback (bar[2] above midpoint) introduces hesitation in the approach → the trigger fires at a structurally weaker reversal point.

**Implication:** Any pullback-reclaim signal used as CONFIRM for SR/BR BUY will be anti-predictive in the interior subset. The mechanism class (pullback → reclaim) is structurally incompatible with reversal strategy CONFIRM role in interior range. This eliminates the entire pullback-reclaim family for SR/BR interior CONFIRM use.

**Exception for TM:** TM is a momentum/trend continuation strategy, not a reversal. For TM BUY interior, price is trending up in the interior range. PBR present (bar[2] already above prior range midpoint before trigger) = the uptrend context is established → confirms the trigger direction → higher WR. The signal works because TM and pullback-reclaim are architecturally compatible (momentum, not reversal).

---

## M. Classification Table — All Gate 3 Candidates

| Candidate | SR interior WR lift | TM interior WR lift | BR interior WR lift | Best TM direction | Final |
|---|---|---|---|---|---|
| FCM | −3.96pp HARMFUL | +0.98pp RESEARCH_ONLY | −1.72pp HARMFUL | SELL +1.81pp ACCEPT | REJECT (SR/BR harmful) |
| HLMA | N=0 GEOMETRIC | −2.11pp HARMFUL | −2.34pp HARMFUL | — | REJECT_HARMFUL |
| CBAR | −7.12pp HARMFUL | +0.32pp WEAK | −9.58pp HARMFUL | — | REJECT |
| FCPB | −8.07pp HARMFUL | −0.31pp WEAK | −7.93pp HARMFUL | BUY +1.45pp marginal | REJECT (dominated by PBR) |
| PBR | −8.36pp HARMFUL | +1.36pp ACCEPT | −8.37pp HARMFUL | BUY +2.05pp STRONG | TM BUY_ONLY RESEARCH_ONLY |

---

## N. Cumulative Mechanism Summary — All Gates

| Gate | Candidates | Best result | Status |
|---|---|---|---|
| V1–V3 (9 total) | BCLC, PBHB, MRR, PTBM, PTAI, TWOBAR, M5BC_RAW, TBB, M5BC_CORR | M5BC_CORR +3pp SR (93% starvation) | All REJECTED |
| Gate 1 (3) | H1DA, BBMP, RMDM | BBMP TM BUY interior STRONG_ACCEPT statistically but April-driven | All FAILED |
| Gate 2 (5) | BBMP3, M5MP, M52MP, M15MP, H1MP | M5MP SELL SR/BR (directional selectivity artifact) | All FAILED |
| **Gate 3 (5)** | FCM, HLMA, CBAR, FCPB, PBR | **PBR TM BUY +2.05pp/+0.0512R STRONG_ACCEPT (TM only)** | **RESEARCH_ONLY** |

**Total mechanisms tested: 22 across V1–V3 plus Gates 1–3 (noting some overlap in methodology families).**
**Unique mechanisms: 19 distinct signal definitions.**
**Zero certifiable general interior CONFIRM source found.**
**One TM-specific research lead identified: PBR TM BUY (strategy-specific, monthly instability, not authorized for implementation).**
**One TM SELL research lead: FCM TM SELL (less stable, Jan+Apr harmful).**

---

## O. Confirmation Gap Status

**Gap definition:** `confirm_role_present=false` in interior-range sessions → structural gate rejects all decisions → actual_trade=0.

**Current status after Gate 3:** `CONFIRMATION_GAP_REMAINS_OPEN_AFTER_GATE3`

**Gap analysis:**
- No mechanism from Gates 1–3 is certifiable as a general CONFIRM source covering SR, TM, and BR interior trades
- The pullback anti-prediction finding (Section L) eliminates the entire pullback-reclaim signal family for SR/BR reversal interior CONFIRM
- Consecutive-bar structure (HLMA, CBAR) is either geometrically incompatible (SR) or actively harmful
- The gap for SR and BR interior is increasingly deep: no class of M1 bar-sequence signal appears to provide positive lift for these reversal strategies in their interior subsets

**Two narrow research leads (TM-specific, not general):**
- PBR TM BUY: STRONG_ACCEPT direction ex-April; 56% co-presence; monthly instability (2/5 flat/harmful)
- FCM TM SELL: ACCEPT_COUNCIL; 49% co-presence; Jan+Apr harmful

Both leads are TM-specific. Implementing either would require strategy-specific CONFIRM gating architecture not currently present or authorized.

---

## P. Final Decision and Next Package Recommendation

**Verdict: `CONFIRMATION_GAP_REMAINS_OPEN_AFTER_GATE3`**
**Production Ready: FALSE**
**Build freeze: ACTIVE**

### P.1 What Was Learned

Gate 3 established a structural constraint: pullback-reclaim signals are anti-predictive for reversal-strategy (SR/BR) interior CONFIRM use. The anti-prediction is structural (reversal requires clean decline; prior bounce = atypical, weaker setup). This eliminates a broad mechanism class. The HLMA geometric incompatibility establishes that consecutive HL structure cannot serve SR BUY interior CONFIRM.

For TM (momentum-continuation strategy), the structural constraint is absent. PBR and FCM both show positive TM interior lift. This suggests that CONFIRM signal classes need to be strategy-type-specific. Reversal strategies may require a different class of CONFIRM signal than momentum strategies.

### P.2 Three Paths for Operator Selection

**Path A — TM-Specific CONFIRM (PBR or FCM) — Narrow Gap Closure**
Authorize Gate 4 to investigate PBR TM BUY as TM-specific CONFIRM source. Requires:
- Architectural review of strategy-specific CONFIRM routing (council_pre_ai_filter.mqh + council_strategies.mqh)
- Monthly stability improvement plan (explain April 2026 regime)
- Directional asymmetry handling (BUY-only vs bidirectional)
- Does not close SR/BR interior gap

**Path B — Gate Architecture Review — Investigate Non-CONFIRM Paths**
Before further signal search, investigate whether there is an architectural alternative to CONFIRM for interior-range sessions. Could include:
- Conditional zone reclassification (interior-range as BREAKOUT_EXPANSION when no CONFIRM available)
- CONFIRM role bypass under specific interior conditions (requires design review)
- Changes to council_pre_ai_filter.mqh gate logic for interior sessions
Requires operator authorization for design review (no source changes).

**Path C — New Signal Class Search — Anti-Continuation Family**
Gates 1–3 tested midline-position, higher-timeframe alignment, multi-bar directional, and pullback-reclaim families. Untested families that could serve both reversal and momentum interior CONFIRM:
- Volume-based signals (requires volume data — not currently available)
- Volatility compression signals (NR7 on M1 bars[2]–[4])
- Failed breakout signals (price attempted beyond bar range boundary then retracted)
- Wick-ratio signals (C11/HLLH from original 12-candidate list — not yet tested)
- Range position signals (price relative to daily or weekly range, not M5 range)
Requires Gate 4 mission brief.

**Operator must select one path.** No parallel packages. No source changes in any path without separate authorization.

### P.3 Governance Verification

```
mt5_source_modified:    false
runtime_files_modified: false
compile_run:            false
mt5_reload:             false
runtime_authority_status: NONE
production_ready:       false
build_freeze:           ACTIVE
```

---

## Appendix — V6 Script Summary

**Script:** `cert_confirmation_packet_candidates_v6.py`
**Data:** SR, TM, BR trade files (V5 enriched with interior_rmr flag). M1 OHLCV for bars[2]–[4] lookup.
**Core utility:** `merge_asof_lookup()` — vectorized asof join via `pd.merge_asof(..., direction="backward")`.
**Bar fetch:** `fetch_bar(trades, m1, offset_min)` where offset_min ∈ {1, 2, 3} → bars[2, 3, 4].
**No-lookahead:** All lookups use `trigger_time - N_minutes` with backward asof — guaranteed prior closed bars only.
**Output:** V6 enriched CSVs + `confirmation_packet_screen_v6_results.json`.

```
PLAN_ID:         GEMINI_GATE3_FAILED_CONTINUATION_PULLBACK_CONFIRMATION_SEARCH_V1
DATE:            2026-05-12
SOURCE_CHANGED:  NO
COMPILE_RUN:     NO
MT5_RELOAD:      NO
PRODUCTION_READY: NO
BUILD_FREEZE:    ACTIVE
```
