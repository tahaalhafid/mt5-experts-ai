# GEMINI_GATE2_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1

**Date:** 2026-05-12
**Authority:** EVIDENCE_ONLY — MT5 runtime authority unchanged
**Script:** `nautilus_lab/scripts/cert_confirmation_packet_candidates_v5.py`
**Output:** `outputs/confirmation_packet_screen/confirmation_packet_screen_v5_results.json`
**Branch:** docs/blocker-closure-roadmap-state-v1

---

## A. Mission and Authority

Gate 2 interior-range confirmation candidate INEC screen. Continuation of Gate 1 after all three Gate 1 primary candidates (H1DA, BBMP, RMDM) failed interior certification.

**Scope:** Research + Python scripting only. No MT5 source changes. No Codex. No compile. No reload.
**MT5 status:** Runtime authority unchanged. All governance flags false.

Gate 2 tests three primary candidates (BBMP3, M5MP, M52MP) and two diagnostic candidates (M15MP, H1MP) against the RMR interior subset of three primary alpha strategies (SR, TM, BR).

**Acceptance target:** CONFIRM gap in RMR interior-range sessions. All existing CONFIRM sources (bollinger_reclaim, mean_reversion_bounce, range_edge_fade) require price at structural extremes → interior sessions produce `confirm_role_present=false` → actual_trade=0.

**Baseline:** SIMPLE_CONFIRMATION_MECHANISM_V1 (Option B — keep existing confirm_role_present path; solve gap by ADD_AS_COUNCIL_ROLE_CONFIRM). No gate rewrites authorized.

---

## B. Prior INEC Screens Summary (V1–V3, Gate 1 V4)

| Version | Candidates | Verdict |
|---|---|---|
| V1 (BCLC, PBHB, MRR) | Bar-close and partial-body proximity | All artifacts (trigger-bar correlation) — REJECTED |
| V2 (PTBM, PTAI, TWOBAR, M5BC_RAW) | Prior-bar and M5-bar direction | PTBM/PTAI genuine but too weak (≤+1.3pp); TWOBAR/M5BC artifact/look-ahead — REJECTED |
| V3 (TBB, M5BC_CORR) | Trigger-bar direction; corrected M5 bar | TBB = TRIGGER_SUB_FILTER (same bar); M5BC_CORR +3pp but 93% starvation — REJECTED |
| V4 Gate 1 (H1DA, BBMP, RMDM) | H1 alignment; BB midline 2-bar; multi-bar majority | H1DA harmful; BBMP TM interior RESEARCH_ONLY but April-driven; RMDM starvation — ALL FAILED |

**Gate 1 Verdict:** CONFIRMATION_GAP_REMAINS_OPEN_AFTER_GATE1. Gemini fallback triggered. Three fallback candidates (F1=BBMP3, F2=M5MP, F3=M52MP) selected for Gate 2.

---

## C. Gate 1 Key Findings (Carried into Gate 2)

1. **BBMP (2-bar) TM interior:** RESEARCH_ONLY aggregate (+0.95pp WR lift). Monthly stability failed — April 2026 alone contributed +4.5pp; ex-April: near-zero.
2. **SR/BR interior subsets:** Geometrically small for BB-midline signals. SR fires at BB band by design → prior bars above midline = rare for BUY.
3. **TBB SR interior trigger bifurcation:** Trigger-bar direction reveals SR WR=57.3% (directional TBB) vs 21.2% (non-directional). Classified as TRIGGER_QUALITY finding, not CONFIRM.
4. **April 2026 pattern:** April appears anomalous across multiple candidates. Gate 2 must explicitly test April exclusion.

---

## D. Gate 2 Candidate Selection Rationale

Gate 2 candidates were selected as Gemini fallback F1–F3 after Gate 1 exhausted prior approaches.

**BBMP3 (F1 — BBMP extended):**
- Extension of BBMP: require bar[2], bar[3], AND bar[4] all above BB midline (BUY).
- Hypothesis: 3-bar consecutive midline position = stronger interior lean than 2-bar.
- bar[4] = `asof(trigger_time - 3min)` — no look-ahead.
- Independence: same as BBMP; BB midline on prior bars, independent from trigger band condition.

**M5MP (F2 — M5 Midpoint Position):**
- Prior closed M5 bar close above/below 10-bar M5 rolling range midpoint.
- No-lookahead: `m5_floor = ts.floor("5min")` → `asof(m5_floor - 1min)`.
- Hypothesis: If M5 price is in the correct structural half of the recent 50-minute range, the alpha trigger is more likely to complete. Fires anywhere — not tied to BB band or range extreme.
- Independence: M5 timeframe; 10-bar rolling range midpoint; different mechanism from all prior candidates.

**M52MP (F3 — M5 Two-Bar Midpoint):**
- Both prior closed M5 bars above/below midpoint.
- bar1 = `asof(m5_floor - 1min)`, bar2 = `asof(m5_floor - 6min)`.
- Hypothesis: 10-minute sustained structural lean is a stronger confirmation than a single bar.

**M15MP (diagnostic — M15 Midpoint Position):**
- Same midpoint concept applied to M15 (15-minute) bars.
- Purpose: timeframe compatibility diagnostic — does M15 add information over M5?

**H1MP (diagnostic — H1 Midpoint Position):**
- Same midpoint concept applied to H1 (hourly) bars.
- Purpose: whether H1-level structural position provides independent confirmation.
- Caveat carried from Gate 1: SR interior BUY subset expected near-empty (SR fires at BB lower band; H1 position at trigger likely near lower half).

---

## E. RMR Interior Subset Definition

Interior = NOT near BB band AND NOT near M5 rolling range extreme (same as Gate 1 V4).

**BB proximity exclusion:** close within 10% of BB(20) range from nearest band.
**M5 range extreme exclusion:** close within 15% of M5(20-bar high/low) from either extreme.

Interior subset sizes:
- SR: 2924/6589 = 44.4%
- TM: 6774/8445 = 80.2%
- BR: 3894/8350 = 46.6%

**Note:** SR and BR trigger at BB band by definition → SR/BR interior subsets are structurally expected to be smaller and to behave differently from TM. This caveat applies to all analysis below.

---

## F. BBMP3 Results

**Co-presence rates:**
- SR global: 13/6589 = 0.2% — near-zero (geometric: 3 consecutive bars above BB midline while triggering at lower BB band is extremely rare)
- TM global: 4971/8445 = 58.9%
- BR global: 14/8350 = 0.2%

**Interior co-presence rates:**
- SR interior: 7/2924 = 0.2%
- TM interior: 3767/6774 = 55.6%
- BR interior: 7/3894 = 0.2%

**SR/BR: DATA_INSUFFICIENT / REJECT_HARMFUL (N<10 in interior) — no certification possible.**

**TM global:** N=4971 (59%), liftWR=+0.0063, liftER=+0.0156 → REJECT_WEAK_OR_NOISY

**TM interior aggregate:** N=3767 (56%), WR_all=0.405, WR_pres=0.411, WR_abs=0.396, liftWR=+0.0151, liftER=+0.0377 → **ACCEPT_COUNCIL_ROLE_CONFIRM_CANDIDATE** (passes OR threshold: ER lift ≥+0.03R; WR lift not materially worse at +1.51pp)

**TM interior directional split:**
- TM BUY interior: N=1668 (54%), WR_pres=0.409, liftWR=+0.0274, liftER=+0.0684 → **STRONG_ACCEPT_CANDIDATE**
- TM SELL interior: N=2099 (57%), WR_pres=0.413, liftWR=+0.0034, liftER=+0.0086 → REJECT_WEAK_OR_NOISY

**Directional asymmetry:** BBMP3 benefits TM BUY strongly (+2.74pp) but not TM SELL (+0.34pp). Directional-asymmetric confirmation has limited utility as a general CONFIRM source.

**Monthly stability (TM interior, 5 months):**

| Month | N_pres/N_all | Rate | WR_pres | liftWR | liftER | Class |
|---|---|---|---|---|---|---|
| 2026-01 | 301/520 | 58% | 0.449 | +0.0101 | +0.0254 | RESEARCH_ONLY |
| 2026-02 | 1045/1843 | 57% | 0.395 | +0.0080 | +0.0200 | RESEARCH_ONLY |
| 2026-03 | 1154/2090 | 55% | 0.406 | −0.0037 | −0.0091 | REJECT_WEAK |
| **2026-04** | 1069/1952 | 55% | 0.418 | **+0.0410** | **+0.1026** | **STRONG_ACCEPT ◀ APRIL** |
| 2026-05 | 198/369 | 54% | 0.439 | +0.0242 | +0.0605 | STRONG_ACCEPT |

**Ex-April aggregate:** N=2698 (56%), liftWR=+0.0044, liftER=+0.0110 → **REJECT_WEAK_OR_NOISY**

**Verdict:** REJECT — April 2026 accounts for the aggregate pass. Ex-April lift collapses to +0.44pp. Same April-concentration failure as Gate 1 BBMP. BBMP3 is not certifiable.

---

## G. M5MP Results

**Co-presence rates:**
- SR interior: 899/2924 = 30.7%
- TM interior: 5441/6774 = 80.3%
- BR interior: 1111/3894 = 28.5%

All interior co-presence rates above 20% starvation threshold.

**SR interior aggregate:** N=899 (31%), liftWR=−0.0021, liftER=−0.0053 → REJECT_WEAK_OR_NOISY

**SR interior directional split:**
- SR BUY interior: N=528 (31%), WR_pres=0.502, WR_abs=0.526, liftWR=**−0.0240**, liftER=−0.0600 → **REJECT_HARMFUL**
- SR SELL interior: N=371 (30%), WR_pres=0.553, WR_abs=0.524, liftWR=**+0.0290**, liftER=+0.0723 → **STRONG_ACCEPT**

**TM interior aggregate:** N=5441 (80%), liftWR=+0.0089, liftER=+0.0224 → RESEARCH_ONLY

**TM interior directional split:**
- TM BUY interior: N=2560 (82%), WR_pres=0.400, WR_abs=0.378, liftWR=**+0.0216**, liftER=+0.0539 → **STRONG_ACCEPT**
- TM SELL interior: N=2881 (79%), WR_pres=0.412, WR_abs=0.411, liftWR=+0.0015, liftER=+0.0035 → REJECT_WEAK

**BR interior aggregate:** N=1111 (29%), liftWR=−0.0085, liftER=−0.0213 → REJECT_WEAK

**BR interior directional split:**
- BR BUY interior: N=671 (29%), liftWR=**−0.0341**, liftER=−0.0853 → **REJECT_HARMFUL**
- BR SELL interior: N=440 (28%), liftWR=**+0.0301**, liftER=+0.0755 → **STRONG_ACCEPT**

**Directional asymmetry finding — structural explanation:**
M5MP shows a systematic split: SELL direction passes STRONG_ACCEPT for SR/BR; BUY direction is REJECT_HARMFUL for SR/BR. This is a geometric consequence of the reversal trigger condition:

- SR/BR BUY fires when price touches the lower BB band (after a decline). At trigger time, the prior M5 bar is typically below the 50-minute midpoint (price has been falling). M5MP present for BUY selects the **atypical** subset — trades where price touched the lower band AFTER coming from the upper half of the range. This is a lower-probability configuration for a clean reversal. Hence present WR < absent WR → HARMFUL.
- SR/BR SELL fires at the upper BB band. Prior M5 bar above midpoint = typical for a SELL trigger → present is the typical subset → higher WR. The "confirmation" is actually a structural selectivity artifact: absent = atypical approach from below midpoint → worse outcome.

This is NOT a true confirmation signal for the interior gap. For BUY triggers, M5MP is anti-aligned. A signal that is helpful for SELL only would be directionally limited as a general CONFIRM source.

**TM BUY:** M5MP genuinely aligns with BUY momentum (price in upper structural half = upward trend support). But this only works for BUY, and monthly stability is problematic.

**Monthly stability (TM interior):**

| Month | N_pres/N_all | liftWR | liftER | Class |
|---|---|---|---|---|
| 2026-01 | 421/520 | **−0.0501** | −0.1254 | REJECT_HARMFUL |
| 2026-02 | 1453/1843 | +0.0351 | +0.0876 | STRONG_ACCEPT |
| 2026-03 | 1661/2090 | +0.0108 | +0.0270 | RESEARCH_ONLY |
| 2026-04 | 1601/1952 | +0.0147 | +0.0369 | ACCEPT ◀ APRIL |
| 2026-05 | 305/369 | **−0.1058** | −0.2645 | REJECT_HARMFUL |

**Ex-April TM:** N=3840 (80%), liftWR=+0.0071 → **REJECT_WEAK**

Monthly: 3/5 positive. Jan 2026 REJECT_HARMFUL (−5pp); May 2026 REJECT_HARMFUL (−10.6pp). Monthly instability is severe.

**Monthly SR (interior):** Ex-April: +0.69pp → REJECT_WEAK. April itself REJECT_HARMFUL.

**Verdict:** REJECT — directional asymmetry makes M5MP unsuitable as a general CONFIRM source. For reversal strategies, BUY direction is actively harmful. Monthly instability fails the stability requirement.

---

## H. M52MP Results

**Co-presence rates (interior):**
- SR: 834/2924 = 28.5%
- TM: 4607/6774 = 68.0%
- BR: 1026/3894 = 26.3%

**SR interior aggregate:** N=834 (29%), liftWR=−0.0054 → REJECT_WEAK

**SR interior directional split:**
- SR BUY: liftWR=**−0.0288** → REJECT_HARMFUL (same asymmetry as M5MP)
- SR SELL: liftWR=**+0.0284**, liftER=+0.0711 → STRONG_ACCEPT (same asymmetry)

**TM interior aggregate:** N=4607 (68%), liftWR=+0.0110, liftER=+0.0274 → RESEARCH_ONLY

**TM interior directional split:**
- TM BUY: N=2199 (71%), liftWR=+0.0167, liftER=+0.0418 → ACCEPT_COUNCIL_ROLE_CONFIRM_CANDIDATE
- TM SELL: N=2408 (66%), liftWR=+0.0082, liftER=+0.0205 → RESEARCH_ONLY

**BR interior:**
- BUY: liftWR=**−0.0351** → REJECT_HARMFUL
- SELL: liftWR=**+0.0303**, liftER=+0.0758 → STRONG_ACCEPT

**Monthly stability (TM interior):**

| Month | N_pres/N_all | liftWR | liftER | Class |
|---|---|---|---|---|
| 2026-01 | 354/520 | **+0.0597** | +0.1492 | STRONG_ACCEPT |
| 2026-02 | 1228/1843 | **+0.0511** | +0.1277 | STRONG_ACCEPT |
| 2026-03 | 1401/2090 | +0.0034 | +0.0084 | REJECT_WEAK |
| 2026-04 | 1366/1952 | −0.0167 | −0.0417 | REJECT_HARMFUL ◀ APRIL |
| 2026-05 | 258/369 | **−0.0834** | −0.2084 | REJECT_HARMFUL |

**Ex-April TM:** N=3241 (67%), liftWR=**+0.0219**, liftER=**+0.0548** → **STRONG_ACCEPT_CANDIDATE**

Ex-April aggregate is STRONG_ACCEPT — both WR lift ≥+2pp AND E[R] lift ≥+0.03R pass. However this is driven by 2 months (Jan/Feb 2026). March is flat. May 2026 is REJECT_HARMFUL (−8.34pp).

**Temporal concentration analysis:**
- Jan–Feb 2026 combined: STRONG_ACCEPT driven
- Mar–May 2026 combined: mostly negative
- 3/5 months positive, 2/5 REJECT_HARMFUL
- The ex-April "pass" masks a clear temporal degradation pattern: signal was strong Jan–Feb, decayed to flat in March, and became harmful in May

**Verdict:** RESEARCH_ONLY — temporal concentration disqualifies STRONG_ACCEPT label. Signal appears to have been active in Jan–Feb 2026 environment and degraded substantially. Not certifiable as stable CONFIRM source. Same directional asymmetry as M5MP (same underlying signal, extended by one bar).

---

## I. M15MP Results (Diagnostic)

**M15MP is uniformly REJECT_HARMFUL across all three primaries and both directions in interior subset.**

| Primary | Interior aggregate | liftWR | liftER | Class |
|---|---|---|---|---|
| SR | N=1548 (53%) | −0.0324 | −0.0810 | REJECT_HARMFUL |
| TM | N=4889 (72%) | −0.0228 | −0.0570 | REJECT_HARMFUL |
| BR | N=1990 (51%) | −0.0295 | −0.0738 | REJECT_HARMFUL |

Co-presence is high (51–72%) — abundant data. The signal is clearly harmful, not merely noisy.

**Monthly for TM:** Only 2026-04 shows positive lift (+2.05pp). All other 4 months: REJECT_HARMFUL. The single positive month is April 2026 again. Ex-April: **−4.09pp** — strongly harmful.

**Timeframe diagnostic conclusion:** M15MP is the worst performing timeframe. Imposing a 15-minute requirement actively hurts performance by selecting trades where the 15-minute trend is aligned — but this appears to be a "too late" signal that identifies exhausted moves rather than confirming fresh continuation.

---

## J. H1MP Results (Diagnostic)

**H1MP is uniformly REJECT_WEAK to REJECT_HARMFUL in interior subset.**

| Primary | Interior aggregate | liftWR | liftER | Class |
|---|---|---|---|---|
| SR | N=1530 (52%) | −0.0098 | −0.0245 | REJECT_WEAK |
| TM | N=3551 (52%) | −0.0067 | −0.0169 | REJECT_WEAK |
| BR | N=2059 (53%) | −0.0086 | −0.0215 | REJECT_WEAK |

Monthly: SR Jan 2026 shows anomalous +17.03pp (1 month); all other months negative. TM Jan 2026 +3.92pp; otherwise −1.75pp to −4.68pp. H1MP suffers from the same single-month January 2026 outlier pattern in SR.

**Ex-April TM:** −0.87pp → REJECT_WEAK. H1MP provides no interior-range confirmation value.

---

## K. Timeframe Compatibility Diagnostic

| Primary | M5MP liftWR | M15MP liftWR | H1MP liftWR | M5MP∩M15MP WR | M5MP∩M15MP∩H1MP WR |
|---|---|---|---|---|---|
| SR interior | −0.21pp | **−3.24pp** | −0.98pp | 0.531 | 0.519 |
| TM interior | +0.89pp | **−2.28pp** | −0.67pp | 0.402 | 0.400 |
| BR interior | −0.85pp | **−2.95pp** | −0.86pp | 0.520 | 0.505 |

**M5 is the best-performing timeframe** but still fails interior certification in aggregate. M15 and H1 are strictly worse. Adding all three timeframes conjunctly (M5MP∩M15MP∩H1MP) yields near-zero ER for TM interior (ER≈0.000) — no stacking benefit.

**Diagnostic conclusion:** The midpoint mechanism does not improve by using higher timeframes. In fact, M15 is actively harmful. The M5 level is the natural granularity for these strategies but is insufficient on its own to solve the CONFIRM gap.

---

## L. Classification Table — All Gate 2 Candidates

### Interior Subset (Primary Acceptance Criterion)

| Primary | Candidate | N_pres | Rate | WR_all | WR_pres | WR_abs | liftWR | liftER | Class |
|---|---|---|---|---|---|---|---|---|---|
| sweep_reversal | BBMP3 | 7 | 0% | 0.524 | 0.000 | 0.525 | −0.5255 | −1.3138 | REJECT_HARMFUL |
| trend_momentum | BBMP3 | 3767 | 56% | 0.405 | 0.411 | 0.396 | +0.0151 | +0.0377 | ACCEPT* |
| bollinger_reclaim | BBMP3 | 7 | 0% | 0.516 | 0.000 | 0.517 | −0.5174 | −1.2934 | REJECT_HARMFUL |
| sweep_reversal | M5MP | 899 | 31% | 0.524 | 0.523 | 0.525 | −0.0021 | −0.0053 | REJECT_WEAK |
| trend_momentum | M5MP | 5441 | 80% | 0.405 | 0.406 | 0.398 | +0.0089 | +0.0224 | RESEARCH_ONLY |
| bollinger_reclaim | M5MP | 1111 | 29% | 0.516 | 0.510 | 0.519 | −0.0085 | −0.0213 | REJECT_WEAK |
| sweep_reversal | M52MP | 834 | 29% | 0.524 | 0.520 | 0.526 | −0.0054 | −0.0136 | REJECT_WEAK |
| trend_momentum | M52MP | 4607 | 68% | 0.405 | 0.408 | 0.397 | +0.0110 | +0.0274 | RESEARCH_ONLY |
| bollinger_reclaim | M52MP | 1026 | 26% | 0.516 | 0.510 | 0.519 | −0.0091 | −0.0227 | REJECT_WEAK |
| sweep_reversal | M15MP | 1548 | 53% | 0.524 | 0.509 | 0.541 | −0.0324 | −0.0810 | REJECT_HARMFUL |
| trend_motivation | M15MP | 4889 | 72% | 0.405 | 0.398 | 0.421 | −0.0228 | −0.0570 | REJECT_HARMFUL |
| bollinger_reclaim | M15MP | 1990 | 51% | 0.516 | 0.502 | 0.531 | −0.0295 | −0.0738 | REJECT_HARMFUL |
| sweep_reversal | H1MP | 1530 | 52% | 0.524 | 0.520 | 0.529 | −0.0098 | −0.0245 | REJECT_WEAK |
| trend_momentum | H1MP | 3551 | 52% | 0.405 | 0.402 | 0.408 | −0.0067 | −0.0169 | REJECT_WEAK |
| bollinger_reclaim | H1MP | 2059 | 53% | 0.516 | 0.512 | 0.521 | −0.0086 | −0.0215 | REJECT_WEAK |

*BBMP3 TM interior ACCEPT aggregate fails April exclusion — see Section F.

### Final Classifications

| Candidate | Type | Final Verdict | Reason |
|---|---|---|---|
| BBMP3 | Primary | **REJECT** | April 2026 driven (ex-Apr +0.44pp); SR/BR 0.2% coverage |
| M5MP | Primary | **REJECT** | Directional asymmetry (BUY harmful for SR/BR); monthly unstable |
| M52MP | Primary | **RESEARCH_ONLY** | Ex-Apr STRONG_ACCEPT but Jan/Feb concentrated; May HARMFUL |
| M15MP | Diagnostic | **REJECT_HARMFUL** | Uniformly harmful; only April positive |
| H1MP | Diagnostic | **REJECT** | Near-zero across all primaries; single-month outlier only |

---

## M. April 2026 Anomaly Pattern

April 2026 consistently appears as an outlier across Gate 1 and Gate 2 screens:

- Gate 1 BBMP TM interior: April +4.5pp (single month that drove aggregate RESEARCH_ONLY)
- Gate 2 BBMP3 TM interior: April +4.10pp (STRONG_ACCEPT in April alone; ex-April +0.44pp)
- Gate 2 M52MP TM interior: April REJECT_HARMFUL (−1.67pp) — notably M52MP reverses in April vs Jan/Feb pattern
- Gate 2 M15MP TM interior: April is the ONLY positive month (+2.05pp); all others harmful

April 2026 appears to be a regime month in XAUUSD that was atypical relative to the overall dataset window (January 2026 – May 2026 partial). Any candidate that requires April 2026 to pass must be treated as regime-specific and uncertifiable as a general CONFIRM source.

**Note:** The dataset begins January 23, 2026 (M1 start) which is only 3.5 months. April 2026 is a large fraction of available data. Monthly stability analysis with 5 months is at the lower bound of statistical reliability.

---

## N. Directional Asymmetry Analysis — Structural Finding

**Key structural finding from Gate 2:** M5-level midpoint signals (M5MP, M52MP) exhibit systematic directional asymmetry that explains why they cannot serve as general CONFIRM sources for reversal strategies:

**For reversal BUY (SR, BR):**
- SR/BR BUY fires at lower BB band — price has been falling
- Prior M5 bar is typically BELOW the 50-minute rolling midpoint at trigger time
- M5MP present (close > midpoint) for BUY selects the ATYPICAL subset: trades where price declined to the lower band despite being in the upper half of the recent range — a weaker reversal setup
- Result: REJECT_HARMFUL for SR BUY (−2.40pp), BR BUY (−3.41pp)

**For reversal SELL (SR, BR):**
- SR/BR SELL fires at upper BB band — price has been rising
- Prior M5 bar is typically ABOVE midpoint → M5MP present is the TYPICAL subset
- Result: STRONG_ACCEPT for SR SELL (+2.90pp), BR SELL (+3.01pp)

**For trend BUY (TM):**
- TM BUY momentum fires in uptrend → M5MP present (above midpoint) aligns with trend
- Result: STRONG_ACCEPT for TM BUY (+2.16pp) but monthly instability

**Implication:** The "confirmation" value of M5MP is not additive information — it is a structural selectivity effect identifying which subset of reversal triggers is "typical vs atypical." This is more accurately classified as a trigger quality indicator (similar to TBB in Gate 1), not a CONFIRM-role signal. Adding it as COUNCIL_ROLE_CONFIRM would create a directional gate that helps SELL but hurts BUY for reversal strategies, which is unacceptable.

---

## O. Confirmation Gap Status

**Verdict: CONFIRMATION_GAP_REMAINS_OPEN_AFTER_GATE2**

Two gates, eleven candidates tested across V1–V5 screens (9 in V1–V3, 3 in V4 Gate 1, 5 in V5 Gate 2 = 14 total unique mechanisms tested including prior bar shape, multi-bar majority, H1 alignment, BB midline, M5 midpoint). None have produced a certifiable, direction-symmetric, monthly-stable, interior-capable CONFIRM signal.

**Pattern of failures:**
- Bar-shape / body signals (V1, V2): trigger-bar artifacts or too weak
- Multi-bar directional majority (V3, RMDM Gate 1): starvation for reversal strategies
- Higher timeframe alignment (H1DA Gate 1, H1MP Gate 2): harmful or near-zero
- BB midline position (BBMP Gate 1, BBMP3 Gate 2): April-driven; SR/BR geometric exclusion
- M5 midpoint (M5MP, M52MP Gate 2): directional asymmetry; monthly instability

**What has NOT been tested:**
- Failed-continuation detection (counter-move after trigger bar followed by resumption)
- Volume/tick-based signals (requires data not currently available)
- Session/time-of-day filtering as CONFIRM source
- Pattern-based (e.g., inside bar, engulfing) on prior bars
- Explicitly asymmetric CONFIRM (different sources for BUY vs SELL)

---

## P. Next Recommendation, Governance, and Required Matrices

### P1. Next Single-Package Recommendation

Three paths are available. Only one should be initiated:

**Option 1 (RESEARCH_ONLY — Gate 3):** Test failed-continuation / pullback-completion mechanisms that explicitly avoid the midpoint-vs-direction coupling problem. Specific candidates: FCM (failed continuation marker — counter-bar then resumption), HLMA (progressive higher lows for BUY), CBAR (3-bar run). These are listed as C5, C6, C7 in the 12-candidate Gate 1 list and were deferred. They test bar-sequence patterns rather than price-position relative to a structural reference.

**Option 2 (Gate architecture review):** Investigate whether interior-range `confirm_role_present=false` is the actual bottleneck for actual_trade=0 or whether there are other gate conditions (consensus, zone, or event_order_valid) that also need to be met. If interior-range trades are blocked by multiple conditions simultaneously, solving only CONFIRM may not unlock them.

**Option 3 (Asymmetric CONFIRM):** Accept that BUY and SELL require different CONFIRM sources. M5MP is STRONG_ACCEPT for SELL direction in reversal strategies (SR/BR). If a direction-specific CONFIRM source is acceptable by architecture, this could be added for SELL only. Requires architectural review of whether COUNCIL_ROLE_CONFIRM can be directionally gated.

**Operator must select one path before proceeding.** No further automated search should begin without explicit mission authorization.

### P2. Governance Verification

```
mt5_source_modified:   FALSE
runtime_files_modified: FALSE
compile_run:           FALSE
mt5_reload:            FALSE
runtime_authority:     NONE (MT5 runtime unchanged)
```

No MT5 source was read, modified, or compiled in this package. All work is Python evidence-only.

### P3. Required Matrices

**PIML UPDATE:**
New anchor bullet under CURRENT STATE ANCHOR:
```
[2026-05-12] GATE2: CONFIRMATION_GAP_REMAINS_OPEN_AFTER_GATE2 — V5 screen: BBMP3/M5MP/M52MP/M15MP/H1MP all failed interior certification; BBMP3 April-driven; M5MP/M52MP directional asymmetry (SELL-only for reversal); M15MP uniformly harmful; 14 total mechanisms tested across V1–V5; no certifiable interior CONFIRM source found; 3 paths recommended (Gate 3 FCM/HLMA/CBAR, Gate architecture review, asymmetric CONFIRM); operator must select
```

**DOCS_SYSTEM_INDEX UPDATE:**
- 06_AUDITS_AND_REVIEWS: 10 → 11 files
- Total documents: 54 → 55

```
DOC_ID:             GEMINI_GATE2_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1
DATE:               2026-05-12
SCRIPT:             cert_confirmation_packet_candidates_v5.py
CANDIDATES_TESTED:  5 (BBMP3, M5MP, M52MP primary; M15MP, H1MP diagnostic)
PRIMARIES_SCREENED: sweep_reversal, trend_momentum, bollinger_reclaim
INTERIOR_SUBSETS:   SR=44.4%, TM=80.2%, BR=46.6%
VERDICT:            CONFIRMATION_GAP_REMAINS_OPEN_AFTER_GATE2
SOURCE_CHANGED:     NO
COMPILE_RUN:        NO
MT5_RELOAD:         NO
PRODUCTION_READY:   NO
BUILD_FREEZE:       ACTIVE
```
