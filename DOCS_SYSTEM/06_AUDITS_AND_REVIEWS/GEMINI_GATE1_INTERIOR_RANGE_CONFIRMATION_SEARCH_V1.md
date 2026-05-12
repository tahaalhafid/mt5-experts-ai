# GEMINI_GATE1_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1

```
REPORT_ID:      GEMINI_GATE1_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1
DATE:           2026-05-12
PACKAGE:        GEMINI_GATE1_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1
VERDICT:        CONFIRMATION_GAP_REMAINS_OPEN_AFTER_GATE1
AUTHORITY:      EVIDENCE_ONLY — MT5 runtime authority unchanged
SOURCE_CHANGED: NO
COMPILE_RUN:    NO
MT5_RELOAD:     NO
BUILD_FREEZE:   ACTIVE
PRODUCTION_READY: NO
```

---

## A. Mission and Authority

**Objective:** Find and INEC-screen interior-range confirmation mechanism candidates that can serve as `COUNCIL_ROLE_CONFIRM` sources in the RMR zone when price is NOT at BB band, range edge, or range bound.

**Authority baseline:** SIMPLE_CONFIRMATION_MECHANISM_V1 (Option B — keep existing `confirm_role_present` path; find better sources through existing mechanism). No new runtime fields. No gate rewrites. No Codex. No MT5 source changes.

**Critical gap context:** Three primary RMR CONFIRM strategies (`bollinger_reclaim`, `mean_reversion_bounce`, `range_edge_fade`) all require price at structural extremes. In interior-range sessions they do not fire → `confirm_role_present=false` → structural gate rejects every decision → `actual_trade=0`.

**Mandatory corrections applied:**
- Acceptance requires lift in RMR interior subset, not global SR/TM lift
- H1DA is not automatically interior — must prove lift in interior subset
- Acceptance: WR lift ≥+2pp OR E[R] lift ≥+0.03R (with other metric not materially worse) AND N_pres ≥ 50 AND co-presence ≥ 20% AND interior subset confirms
- H1DA no-lookahead: `h1_floor = ts.floor('H')` → `asof(h1_floor - 1min)` for prior closed H1 bar

---

## B. Prior Screen Summary (V1–V3)

Nine candidates screened across three iterations. All rejected.

| Screen | Candidates | Verdict | Root Cause |
|---|---|---|---|
| V1 | BCLC, PBHB, MRR | ARTIFACT | Trigger-bar quality correlation |
| V2 | PTBM, PTAI | TOO WEAK | ≤+1.3pp lift, no starvation issue but insufficient |
| V2 | TWOBAR | ARTIFACT | Includes trigger bar direction (same-bar) |
| V2 | M5BC_RAW | LOOK-AHEAD | Used unclosed M5 bar (+46pp was artifact) |
| V3 | TBB | TRIGGER_SUB_FILTER | Same bar as alpha trigger — not independent |
| V3 | M5BC_CORR | RESEARCH_ONLY | +3pp SR at 93% starvation — disqualifying |

**Root cause confirmed:** All prior candidates used bar-shape properties of the trigger bar or the single prior bar. Gate 1 targets multi-bar lookback (bars 2–6), higher-timeframe (H1), and structural mechanisms that can fire in interior range.

---

## C. Candidate Research — Full 12-Candidate List

All 12 candidates enumerated from plan research:

| ID | Name | Definition | Interior? | Independence |
|---|---|---|---|---|
| C1 | H1DA | Prior closed H1 bar: body ≥ 30% of H1 range AND directional | NOT AUTOMATICALLY — must prove | FULL (different TF + prior bar) |
| C2 | RMDM | Of bars[2]–[6], ≥ 4/5 are directional (close > open for BUY) | YES | FULL (bars 2–6, pre-trigger) |
| C3 | BBMP | bars[2] AND [3] both above BB 20-SMA (BUY) | YES — midline ≠ band extreme | FULL (different condition from trigger) |
| C4 | IRDF | bar[2] NOT within 15% of M5 range bounds AND directional | EXPLICIT interior | FULL |
| C5 | FCM | bar[2] had counter-directional body ≥ 0.3×ATR, closed back toward trade direction | YES | FULL |
| C6 | HLMA | bars[2,3,4] form progressively higher lows (BUY) | YES | FULL |
| C7 | CBAR | bars[2,3,4] ALL directional (3-bar run) | YES | FULL |
| C8 | MIRA | Last 2 prior M5 bars: directional AND not within 15% of M5 range extremes | YES (explicit) | FULL |
| C9 | VBODY | Sum of body sizes bars[2]+[3]+[4] ≥ 1.5 × ATR(M1,14) | YES | FULL |
| C10 | PRDAY | Price in correct half of prior day's range | YES | FULL (daily) |
| C11 | HLLH | bar[2] has wick ≥ 40% of range on same side as trade direction | YES | FULL |
| C12 | M5CRUN | Last 2 prior closed M5 bars both directional | YES for TM | FULL |

---

## D. Top-3 Selection Rationale

| Rank | Candidate | Rationale |
|---|---|---|
| 1 | **H1DA** (C1) | Highest expected co-presence (30–50%); genuinely independent (different timeframe); avoids starvation; must prove lift in interior subset per Correction 2 |
| 2 | **BBMP** (C3) | Captures "bars[2]+[3] above BB midline before trigger" — fires in interior; independent (bars 2–3 vs midline ≠ bar[1] vs band); potentially identifies interior sessions where price was holding above midline |
| 3 | **RMDM** (C2) | Multi-bar majority (4/5 of bars 2–6); fires anywhere; genuinely different from PTBM (5 bars, higher bar count, majority threshold) |

**Eliminated candidates (Gate 1):**
- C4, C6, C8, C9, C11: Low expected co-presence / hard to implement cleanly / M5 variant of M5BC_CORR
- C5, C7: Low co-presence; similar to what was already tested
- C10 (PRDAY): ROOM signal, not CONFIRM
- C12 (M5CRUN): M5 variant — likely starvation for SR similar to M5BC_CORR

---

## E. RMR Interior Subset — Definition and Filter Methodology

**Filter objective:** Proxy for sessions where `bollinger_reclaim`, `mean_reversion_bounce`, `range_edge_fade` would NOT fire — i.e., trigger bar (bar[1]) is neither near BB band nor near M5 range extreme.

**Implementation:**
- Load M1 BB (20-SMA ± 2×std) — compute `bb_upper`, `bb_lower`, `bb_mid`
- Load M5 rolling 20-bar range — compute `m5_range_high`, `m5_range_low`
- At trigger_time, look up M1 bar[1] close and BB; look up M5 range
- **BB proximity**: exclude if close ≤ `bb_lower + 0.10 × (bb_upper - bb_lower)` OR close ≥ `bb_upper - 0.10 × (bb_upper - bb_lower)` (within 10% of BB range from nearest band)
- **M5 range proximity**: exclude if close ≤ `m5_range_low + 0.15 × (m5_range_high - m5_range_low)` OR close ≥ `m5_range_high - 0.15 × (m5_range_high - m5_range_low)` (within 15% of M5 range from extreme)
- **Interior = NOT at_bb_band AND NOT at_m5_extreme**
- NaN → treated as at-band/at-extreme (conservative exclusion)

**Interior subset composition:**

| Primary | Total | Interior N | Interior % | Excl (BB band) | Excl (M5 extreme) |
|---|---|---|---|---|---|
| sweep_reversal (SR) | 6,589 | 2,924 | 44.4% | 2,778 (42.2%) | 2,032 (30.8%) |
| trend_momentum (TM) | 8,445 | 6,774 | 80.2% | 128 (1.5%) | 1,563 (18.5%) |
| bollinger_reclaim (BR) | 8,350 | 3,894 | 46.6% | 3,309 (39.6%) | 2,554 (30.6%) |

**SR interior note:** SR fires when M1 low ≤ BB_lower AND close > BB_lower. The 44.4% interior SR trades are those where the close recovered significantly above the lower band (> 10% of BB range above BB_lower). These represent strong-recovery bounces that ended in the interior. They show higher WR globally (52.4% interior vs 39.6% global) — this is a TRIGGER_QUALITY finding, documented separately.

**BR interior note:** BR also fires at BB band → expected low interior fraction (actual 46.6% — same effect as SR: strong BB reclaims that carry well into interior).

**TM interior note:** TM fires on momentum continuation away from extremes → 80.2% interior is expected.

---

## F. H1DA Results — H1 Directional Alignment

**Signal definition:** Prior closed H1 bar is directional. No-lookahead: `h1_open = ts.floor('H')`, then `asof(h1_open - 1min)` for prior H1 bar. Body filter: `|close - open| / (high - low) ≥ 0.30`.

**H1 source:** M1 resampled to H1 (1,680 bars).

**Global co-presence:**
- SR: 2,078/6,589 = 31.5%; TM: 3,815/8,445 = 45.2%; BR: 2,602/8,350 = 31.2%

### Global results

| Primary | N_pres | Rate | WR_all | WR_pres | WR_abs | liftWR | liftER | Classification |
|---|---|---|---|---|---|---|---|---|
| sweep_reversal | 2,078 | 32% | 0.396 | 0.369 | 0.408 | −0.0390 | −0.0975 | REJECT_HARMFUL |
| trend_momentum | 3,815 | 45% | 0.391 | 0.385 | 0.397 | −0.0120 | −0.0301 | REJECT_HARMFUL |
| bollinger_reclaim | 2,602 | 31% | 0.393 | 0.373 | 0.402 | −0.0283 | −0.0709 | REJECT_HARMFUL |

H1DA is globally harmful across all three primaries. Trades where the prior H1 bar was directionally aligned perform WORSE than the baseline.

### Interior subset results (Correction 1 primary criterion)

| Primary | N_int | N_pres | Rate | WR_int_all | WR_pres | WR_abs | liftWR | liftER | Classification |
|---|---|---|---|---|---|---|---|---|---|
| sweep_reversal | 2,924 | 1,043 | 36% | 0.524 | 0.491 | 0.543 | −0.0519 | −0.1298 | REJECT_HARMFUL |
| trend_momentum | 6,774 | 2,724 | 40% | 0.405 | 0.407 | 0.403 | +0.0039 | +0.0098 | REJECT_WEAK_OR_NOISY |
| bollinger_reclaim | 3,894 | 1,376 | 35% | 0.516 | 0.495 | 0.528 | −0.0333 | −0.0832 | REJECT_HARMFUL |

**Correction 2 confirmed:** H1DA does NOT prove lift in the RMR interior subset. SR and BR are REJECT_HARMFUL. TM interior is near-zero (+0.4pp WR, +1pp ER) — below both thresholds.

### Direction breakdown (interior)

- TM [BUY] interior: N=1,203, liftWR=−0.0144 → REJECT_HARMFUL
- TM [SELL] interior: N=1,521, liftWR=+0.0182, liftER=+0.046 → ACCEPT_COUNCIL_ROLE_CONFIRM_CANDIDATE (classification only; see monthly)

**Monthly stability (TM + H1DA interior):**

| Month | N_all | N_pres | Rate | WR_pres | liftWR | Class |
|---|---|---|---|---|---|---|
| 2026-01 | 520 | 210 | 40% | 0.438 | −0.010 | REJECT_HARMFUL |
| 2026-02 | 1,843 | 740 | 40% | 0.404 | +0.021 | STRONG_ACCEPT |
| 2026-03 | 2,090 | 841 | 40% | 0.406 | −0.003 | REJECT_WEAK |
| 2026-04 | 1,952 | 762 | 39% | 0.394 | −0.010 | REJECT_WEAK |
| 2026-05 | 369 | 171 | 46% | 0.450 | +0.041 | STRONG_ACCEPT |

Monthly inconsistency: 2/5 months positive, 3/5 months negative or flat. The positive months (Feb, May) are insufficient to certify a stable signal. The SELL direction ACCEPT finding (aggregate) is driven by Feb 2026 and May 2026 specifically; BUY direction is harmful.

**H1DA verdict: REJECT. H1DA does not solve the interior-range confirmation gap.**

---

## G. BBMP Results — BB Midline Position

**Signal definition:** bars[2] AND [3] closes both above BB 20-SMA (BUY) or below (SELL).
- bar[2] = `asof(trigger_time - 1min)` on M1
- bar[3] = `asof(trigger_time - 2min)` on M1
- BB midline = 20-period SMA at each respective bar's time

**Independence from trigger:** Trigger bar[1] for SR fires when low ≤ BB_lower AND close > BB_lower. BBMP checks bars[2]+[3] vs BB *midline* — different bars, different BB level → genuinely independent.

**Global co-presence:**
- SR: 16/6,589 = 0.2%; TM: 5,241/8,445 = 62.1%; BR: 17/8,350 = 0.2%

**SR/BR structural note:** SR and BR trigger at BB band touch. For bar[1] to be near the lower band while bars[2]+[3] are above the BB midline, price must have dropped from well above midline to the band in exactly 1 bar. This is rare → 0.2% co-presence is expected. SR/BR are DATA_INSUFFICIENT for BBMP.

### Global results

| Primary | N_pres | Rate | WR_all | WR_pres | WR_abs | liftWR | liftER | Classification |
|---|---|---|---|---|---|---|---|---|
| sweep_reversal | 16 | 0% | 0.396 | 0.250 | 0.396 | −0.146 | −0.365 | REJECT_HARMFUL |
| trend_momentum | 5,241 | 62% | 0.391 | 0.391 | 0.391 | +0.0005 | +0.001 | REJECT_WEAK |
| bollinger_reclaim | 17 | 0% | 0.393 | 0.294 | 0.393 | −0.099 | −0.247 | REJECT_HARMFUL |

### Interior subset results

| Primary | N_int | N_pres | Rate | WR_int_all | WR_pres | WR_abs | liftWR | liftER | Classification |
|---|---|---|---|---|---|---|---|---|---|
| sweep_reversal | 2,924 | 8 | 0% | 0.524 | 0.125 | 0.525 | −0.400 | −1.001 | REJECT_HARMFUL |
| trend_momentum | 6,774 | 3,966 | 59% | 0.405 | 0.409 | 0.399 | +0.0095 | +0.024 | RESEARCH_ONLY |
| bollinger_reclaim | 3,894 | 8 | 0% | 0.516 | 0.125 | 0.517 | −0.392 | −0.981 | REJECT_HARMFUL |

**Aggregate interior verdict:** RESEARCH_ONLY for TM; SR/BR DATA_INSUFFICIENT.

### Direction breakdown — critical finding (TM interior)

| Direction | N_pres | Rate | WR_pres | WR_abs | liftWR | liftER | Classification |
|---|---|---|---|---|---|---|---|
| BUY | 1,752 | 56% | 0.406 | 0.384 | +0.0220 | +0.055 | **STRONG_ACCEPT_CANDIDATE** |
| SELL | 2,214 | 60% | 0.411 | 0.414 | −0.003 | −0.007 | REJECT_WEAK |

BBMP for TM BUY interior shows STRONG_ACCEPT (+2.2pp WR, +5.5pp ER). However:

**Monthly stability (TM + BBMP interior aggregate):**

| Month | N_all | N_pres | Rate | WR_pres | liftWR | Class |
|---|---|---|---|---|---|---|
| 2026-01 | 520 | 317 | 61% | 0.445 | +0.002 | REJECT_WEAK |
| 2026-02 | 1,843 | 1,101 | 60% | 0.390 | −0.005 | REJECT_WEAK |
| 2026-03 | 2,090 | 1,217 | 58% | 0.405 | −0.005 | REJECT_WEAK |
| 2026-04 | 1,952 | 1,123 | 58% | 0.418 | +0.045 | STRONG_ACCEPT |
| 2026-05 | 369 | 208 | 56% | 0.423 | −0.012 | REJECT_HARMFUL |

Monthly inconsistency is pronounced. 4/5 months are flat or harmful; April 2026 alone drives the aggregate. The BUY direction STRONG_ACCEPT is concentrated in a single-month regime effect.

**Sensitivity check:** WR_trimmed = 0.408 (drop top 3 wins from present group) vs WR_present = 0.409 — robust due to large N. The sensitivity is not a concern; the monthly instability is.

**BBMP verdict:** RESEARCH_ONLY for TM interior aggregate. The BUY direction STRONG_ACCEPT is NOT certifiable due to directional asymmetry (SELL is flat) and monthly instability (single month driving the lift). BBMP is the strongest lead from Gate 1. Warrants follow-up in Gate 2 with regime-stratified analysis. BBMP cannot currently be admitted as COUNCIL_ROLE_CONFIRM_CANDIDATE.

---

## H. RMDM Results — Rolling M1 Directional Majority

**Signal definition:** Of bars[2]–[6] before trigger, ≥ 4 of 5 are directional (close > open for BUY; close < open for SELL).
- bar[k] = `asof(trigger_time - (k-1) min)` for k ∈ [2,3,4,5,6]

**Global co-presence:**
- SR: 89/6,589 = 1.4%; TM: 1,975/8,445 = 23.4%; BR: 97/8,350 = 1.2%

SR and BR have severe starvation (1–2%). The 4/5 requirement is too strict for strategies that trigger near BB extremes — the approach leading to a band touch naturally mixes directional and indecisive bars. RMDM is DATA_INSUFFICIENT for SR and BR as CONFIRM candidates.

### Global results

| Primary | N_pres | Rate | WR_all | WR_pres | WR_abs | liftWR | liftER | Classification |
|---|---|---|---|---|---|---|---|---|
| sweep_reversal | 89 | 1% | 0.396 | 0.438 | 0.395 | +0.043 | +0.107 | RESEARCH_ONLY |
| trend_momentum | 1,975 | 23% | 0.391 | 0.386 | 0.393 | −0.006 | −0.016 | REJECT_WEAK |
| bollinger_reclaim | 97 | 1% | 0.393 | 0.433 | 0.392 | +0.041 | +0.102 | RESEARCH_ONLY |

RMDM shows apparent positive global lift for SR and BR (~+4pp), but these are small-N subsets with high noise.

### Interior subset results (Correction 1 primary criterion)

| Primary | N_int | N_pres | Rate | WR_int_all | WR_pres | WR_abs | liftWR | liftER | Classification |
|---|---|---|---|---|---|---|---|---|---|
| sweep_reversal | 2,924 | 50 | 2% | 0.524 | 0.480 | 0.525 | −0.045 | −0.113 | REJECT_HARMFUL |
| trend_momentum | 6,774 | 1,513 | 22% | 0.405 | 0.402 | 0.406 | −0.004 | −0.010 | REJECT_WEAK |
| bollinger_reclaim | 3,894 | 55 | 1% | 0.516 | 0.455 | 0.517 | −0.063 | −0.157 | REJECT_HARMFUL |

All three primaries fail in the interior subset. The apparent global lift for SR and BR reversed to harmful in the interior — the global lift was driven by the non-interior (BB band / range extreme) subset where RMDM happened to fire during strong directional moves.

**Monthly stability (TM + RMDM interior):**
- 2026-01: +4.3pp (STRONG_ACCEPT) — isolated month
- 2026-02 to 2026-05: flat or harmful
- Overall: REJECT_WEAK_OR_NOISY

**Sensitivity (SR + RMDM interior):** WR_trimmed = 0.447 (from 0.480) — meaningful drop for small N=50, confirming fragility.

**RMDM verdict: REJECT. Starvation for SR/BR (1–2%). Zero lift in TM interior. Global apparent lift is non-interior effect.**

---

## I. Gemini Fallback — Triggered

**Trigger condition met:** Top 3 candidates (H1DA, BBMP, RMDM) produced no ACCEPT_COUNCIL_ROLE_CONFIRM_CANDIDATE for the interior subset. BBMP yields RESEARCH_ONLY aggregate with a BUY-only STRONG_ACCEPT that is monthly inconsistent — insufficient for certification.

**Claude performed equivalent bounded research as package owner (no external Gemini delegation in this session).** The following 8 candidates were generated from first-principles research targeting interior-range confirmation mechanisms not previously tested in V1–V4.

### Fallback Candidate List (8 candidates)

| ID | Name | Definition | Interior? | Co-presence Est. | Independence |
|---|---|---|---|---|---|
| F1 | BBMP3 | bars[2]+[3]+[4] all above BB midline (BUY) — 3-bar version of BBMP | YES | 35–50% TM | FULL (bars 2–4 vs midline) |
| F2 | M5MP — M5 Midpoint Position | Last closed M5 bar close > M5 10-bar rolling midpoint ((rolling_max_high + rolling_min_low)/2) | YES — midpoint ≠ band extreme | 40–55% TM; 20–35% SR | FULL (M5 level, different condition) |
| F3 | M52MP — M5 2-Bar Midpoint | Last 2 prior closed M5 bars both close > M5 10-bar rolling midpoint | YES | 25–40% TM | FULL |
| F4 | RMDM3 — RMDM 3/5 | Of bars[2]–[6], ≥ 3/5 directional (lower threshold than RMDM's 4/5) | YES | 35–45% TM; 5–8% SR | FULL |
| F5 | PRWK — Prior-bar Wick Rejection | bar[2] has wick on counter-side ≥ 40% of bar range (lower wick for BUY) — shows rejection absorbed in prior bar | YES | 20–30% | FULL (prior bar structure) |
| F6 | HLGAP — Higher Low Gap | bar[2].low > bar[4].low for BUY (progressive higher lows, 3-step) — ascending micro-structure | YES | 35–50% TM | FULL (sequential bars 2 and 4) |
| F7 | BVOL — Below-Average Volatility | ATR of bars[2]–[5] < 0.7 × ATR(14) at trigger — low pre-trigger volatility = compression before direction | YES — compression can occur anywhere | 20–35% | FULL (volatility state, not price level) |
| F8 | MIDRC — Midrange Reclaim | bar[2].close > mean((max_high + min_low)/2 of bars[3]–[7]) — price reclaimed the 5-bar prior midrange in bar[2] | YES | 15–25% | FULL (structural reclaim, prior bars) |

### Fallback Candidate Evaluation

| ID | Accept for Screen? | Rationale |
|---|---|---|
| F1 (BBMP3) | **YES** | Builds on BBMP's strongest V4 lead (TM BUY +2.2pp). If 3 bars above midline is more selective, may reduce noise and improve monthly stability. Co-presence sufficient for TM (35–50%). |
| F2 (M5MP) | **YES** | Genuinely novel — tests M5-level midpoint position, not directional bar body. M5 midpoint approach is fundamentally different from M5BC_CORR (body direction). May show stable lift for both TM and SR. |
| F3 (M52MP) | **YES** | 2-bar M5 midpoint — balances signal strength with co-presence (vs M5MP 1-bar). Complementary to F2. |
| F4 (RMDM3) | **REJECTED** | Lower threshold (3/5) than RMDM (4/5). Would simply extend RMDM's noisy result to more trades with diluted signal. RMDM already showed flat TM interior at 4/5 — reducing threshold unlikely to create meaningful lift. |
| F5 (PRWK) | **REJECTED** | Single prior bar wick analysis. Similar mechanism to PTBM/PTAI (V2) which showed ≤+1.3pp lift. Expected to be equally weak. |
| F6 (HLGAP) | **REJECTED** | Multi-bar higher low structure (bars 2 and 4). Conceptually sound but requires price to advance twice in 2 bars before trigger — similar co-presence and mechanism to RMDM3. Not sufficiently differentiated from tested candidates. |
| F7 (BVOL) | **REJECTED** | Below-average ATR pre-trigger. This captures compression before direction — may be correlated with SR trigger mechanism (BB squeeze before sweep). Risk of being a regime filter rather than a CONFIRM signal. Keep for separate regime analysis research. |
| F8 (MIDRC) | **REJECTED** | Midrange reclaim — bar[2] reclaimed the 5-bar prior midrange. Interesting but similar mechanism to BBMP (above midline). BBMP3 already tests bar[2]+[3]+[4] above midline which captures the same "sustained above mid" condition more directly. |

**Selected for Gate 2 INEC screen:** F1 (BBMP3), F2 (M5MP), F3 (M52MP)

**Selection rationale:**
1. BBMP3 follows the strongest V4 lead (BBMP BUY +2.2pp) with more stringent bar requirement — tests whether the monthly inconsistency was noise or signal
2. M5MP is fundamentally different from all tested candidates — M5-level midpoint position tests whether price is "floating in the interior" at the M5 level, not just the M1 level
3. M52MP complements M5MP — 2-bar confirmation reduces single-bar noise while maintaining reasonable co-presence

---

## J. Classification Table

### Interior subset (primary criterion) and global (supporting reference)

| Primary | Candidate | Subset | N_pres | Rate | WR_all | WR_pres | WR_abs | liftWR | liftER | Classification |
|---|---|---|---|---|---|---|---|---|---|---|
| sweep_reversal | H1DA | global | 2,078 | 32% | 0.396 | 0.369 | 0.408 | −0.039 | −0.098 | REJECT_HARMFUL |
| sweep_reversal | H1DA | interior_rmr | 1,043 | 36% | 0.524 | 0.491 | 0.543 | −0.052 | −0.130 | **REJECT_HARMFUL** |
| trend_momentum | H1DA | global | 3,815 | 45% | 0.391 | 0.385 | 0.397 | −0.012 | −0.030 | REJECT_HARMFUL |
| trend_momentum | H1DA | interior_rmr | 2,724 | 40% | 0.405 | 0.407 | 0.403 | +0.004 | +0.010 | **REJECT_WEAK_OR_NOISY** |
| bollinger_reclaim | H1DA | global | 2,602 | 31% | 0.393 | 0.373 | 0.402 | −0.028 | −0.071 | REJECT_HARMFUL |
| bollinger_reclaim | H1DA | interior_rmr | 1,376 | 35% | 0.516 | 0.495 | 0.528 | −0.033 | −0.083 | **REJECT_HARMFUL** |
| sweep_reversal | BBMP | global | 16 | 0% | 0.396 | 0.250 | 0.396 | −0.146 | −0.365 | DATA_INSUFFICIENT |
| sweep_reversal | BBMP | interior_rmr | 8 | 0% | 0.524 | 0.125 | 0.525 | −0.400 | −1.001 | **DATA_INSUFFICIENT** |
| trend_momentum | BBMP | global | 5,241 | 62% | 0.391 | 0.391 | 0.391 | +0.001 | +0.001 | REJECT_WEAK |
| trend_momentum | BBMP | interior_rmr | 3,966 | 59% | 0.405 | 0.409 | 0.399 | +0.010 | +0.024 | **RESEARCH_ONLY** |
| trend_momentum | BBMP | interior BUY | 1,752 | 56% | 0.396 | 0.406 | 0.384 | +0.022 | +0.055 | STRONG_ACCEPT* |
| trend_momentum | BBMP | interior SELL | 2,214 | 60% | 0.412 | 0.411 | 0.414 | −0.003 | −0.007 | REJECT_WEAK |
| bollinger_reclaim | BBMP | global | 17 | 0% | 0.393 | 0.294 | 0.393 | −0.099 | −0.247 | DATA_INSUFFICIENT |
| bollinger_reclaim | BBMP | interior_rmr | 8 | 0% | 0.516 | 0.125 | 0.517 | −0.392 | −0.981 | **DATA_INSUFFICIENT** |
| sweep_reversal | RMDM | global | 89 | 1% | 0.396 | 0.438 | 0.395 | +0.043 | +0.107 | RESEARCH_ONLY |
| sweep_reversal | RMDM | interior_rmr | 50 | 2% | 0.524 | 0.480 | 0.525 | −0.045 | −0.113 | **REJECT_HARMFUL** |
| trend_momentum | RMDM | global | 1,975 | 23% | 0.391 | 0.386 | 0.393 | −0.006 | −0.016 | REJECT_WEAK |
| trend_momentum | RMDM | interior_rmr | 1,513 | 22% | 0.405 | 0.402 | 0.406 | −0.004 | −0.010 | **REJECT_WEAK_OR_NOISY** |
| bollinger_reclaim | RMDM | global | 97 | 1% | 0.393 | 0.433 | 0.392 | +0.041 | +0.102 | RESEARCH_ONLY |
| bollinger_reclaim | RMDM | interior_rmr | 55 | 1% | 0.516 | 0.455 | 0.517 | −0.063 | −0.157 | **REJECT_HARMFUL** |

`*` = STRONG_ACCEPT classification (statistically) but NOT certifiable due to directional asymmetry + monthly inconsistency. Interior primary criterion not met at aggregate level.

---

## K. Confirmation Gap Status

**Verdict: `CONFIRMATION_GAP_REMAINS_OPEN_AFTER_GATE1`**

No candidate from Gate 1 (H1DA, BBMP, RMDM) met the full acceptance criteria for the interior subset. All three failed on at least one of:
- Interior lift threshold (all primaries): H1DA harmful; RMDM harmful/flat
- Starvation: RMDM for SR/BR (1–2%); BBMP for SR/BR (0.2%)
- Monthly stability: BBMP TM interior aggregate inconsistent (driven by single month)
- Directional asymmetry: BBMP TM BUY strong, SELL flat — not usable as universal CONFIRM

**Most promising lead:** BBMP BUY direction for TM interior (+2.2pp aggregate) — monthly regime-dependent, warrants follow-up.

**New byproduct finding (interior composition):** Interior SR trades (44.4% of all SR) show substantially higher WR than global SR (52.4% vs 39.6%). This suggests the interior/non-interior distinction is a meaningful TRIGGER_QUALITY discriminator for SR. This is a TRIGGER_REFINEMENT observation, not a CONFIRMATION finding.

**Residual open question:** The interior TM confirmation gap is primarily testable through M5-level structural signals (M5MP, M52MP) which have not been screened. Gate 1 was limited to M1-level multi-bar lookback and H1 alignment.

---

## L. Next Single-Package Recommendation

**Recommended next package: `GEMINI_GATE2_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1`**

**Scope:** Bounded INEC screen for three fallback candidates: BBMP3 (3-bar BBMP extension), M5MP (M5 midpoint position), M52MP (2-bar M5 midpoint).

**Primary focus:** Interior subset lift (same methodology as Gate 1 V4 script — reuse interior flag from V4 enriched CSVs).

**Additional analysis for BBMP3:**
- Regime-stratified monthly breakdown (to investigate April 2026 concentration in BBMP)
- BUY vs SELL split to understand directional asymmetry

**Script:** `cert_confirmation_packet_candidates_v5.py` — builds on V4 enriched CSVs (interior flag already computed).

**Data required for M5MP/M52MP:**
- M5 rolling 10-bar midpoint = `(m5_rolling_10_high + m5_rolling_10_low) / 2`
- Lookup via `asof(trigger_time - 5min)` on M5 for last closed M5 bar

**Acceptance standard:** Same as V4 (Correction 3: OR logic, interior subset required). Co-presence ≥ 20% in interior subset required for non-starvation.

**Authorization requirements:**
- No MT5 source changes
- No Codex / compile / reload
- No gate changes
- No TBB reconciliation in this package
- BUILD_FREEZE active

---

## M. Governance Verification

```
mt5_source_modified:     FALSE
runtime_files_modified:  FALSE
compile_run:             FALSE
mt5_reload:              FALSE
runtime_authority_status: NONE
production_ready:        FALSE
build_freeze:            ACTIVE
```

Scripts executed (read-only, evidence-only):
- `nautilus_lab/scripts/cert_confirmation_packet_candidates_v4.py`
- `nautilus_lab/outputs/confirmation_packet_screen/confirmation_packet_screen_v4_results.json`
- `nautilus_lab/outputs/confirmation_packet_screen/sweep_reversal_trades_v4.csv`
- `nautilus_lab/outputs/confirmation_packet_screen/trend_momentum_trades_v4.csv`
- `nautilus_lab/outputs/confirmation_packet_screen/bollinger_reclaim_trades_v4.csv`

---

## N. Required Matrices

### PIML Update Required
Add anchor: `GEMINI_GATE1_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1 — CONFIRMATION_GAP_REMAINS_OPEN_AFTER_GATE1 (2026-05-12)`

### DOCS_SYSTEM_INDEX Update Required
- 06_AUDITS_AND_REVIEWS: 9 → 10 files
- Total docs: 53 → 54
- Add row for this report

### Next Action
`GEMINI_GATE2_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1` — operator authorization required before execution

```
REPORT_COMPLETE:    YES
FALLBACK_USED:      YES (Claude performed equivalent research as package owner)
GAP_STATUS:         OPEN
LEAD_CANDIDATE:     BBMP BUY direction TM interior (+2.2pp) — monthly inconsistent
GATE2_CANDIDATES:   BBMP3, M5MP, M52MP
NEXT_PACKAGE:       GEMINI_GATE2_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1
```
