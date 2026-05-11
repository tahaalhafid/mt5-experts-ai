# FVG_TPB_MT5_ADMISSION_DESIGN_PACKAGE_V1

**Package type:** ADMISSION_DESIGN — Evidence review, architecture placement, and implementation boundary specification  
**Date:** 2026-05-09  
**Precedes:** FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 (not yet authorized)  
**Authority:** EVIDENCE_ONLY — No MT5 source change. No runtime change. No compile. No reload.  
**Governed by:** PROJECT_INTELLIGENCE_MEMORY_LAYER.md (PIML) — sole authoritative project memory  
**Evidence source:** EXTERNAL_FVG_STRATEGY_DISCOVERY_AND_INEC_CERTIFICATION_PACKAGE_V1 (complete)  
**System status:** DEVELOPING — unchanged  
**Runtime authority:** V1 (MT5 EA) — permanent; not transferred to any document, shadow layer, or policy candidate  

---

## GOVERNANCE FIREWALL

This design package does NOT authorize:

- MT5 source changes of any kind
- Strategy admission to the production EA
- Strategy injection, promotion, or role assignment
- Weight changes (vote_weight, effective_weight)
- Role changes (SCOUT, CONFIRM, TREND_JUDGE, EXHAUSTION_JUDGE, GUARD)
- Gate changes (CRR, DSN, DOMINANT_SIDE)
- Score changes (council_quality, consensus thresholds)
- HIGH_CONVICTION condition changes
- CRR / DSN / DOMINANT_SIDE logic changes
- Risk, execution, stop/target geometry changes
- V1 permission logic changes
- Production readiness claims
- factory_admission_lock bypass
- Playbook state changes in runtime
- PIML updates

**Admission design is not implementation.**  
**INEC certification is not runtime authority.**  
**ALPHA_TRIGGER_PACKET acceptance does not mean strategy admission.**  
**RBSR or playbook candidate fit does not mean trade permission.**  
**Factory admission lock remains ACTIVE.**  
**MT5 remains the sole runtime authority.**

---

## 1. Executive Summary

FVG_TPB (FVG Trend Pullback) is the strongest external candidate evaluated under INEC_LAB_V1 to date. With N=2,442 SUFFICIENT, WR=43.41%, E[R]=+0.085R, temporal stability (1.7pp walk-forward gap, 5/5 months positive), slippage robustness (WR=42.11% under +10pt stress), and ALPHA_TRIGGER_PACKET FORMALLY_ACCEPTABLE classification, FVG_TPB has a stronger evidence profile than all 17 currently admitted strategies on a per-certification-sample basis.

**Four core conclusions guide this design:**

1. **FVG_TPB is a valid MT5 admission design candidate.** The INEC evidence meets all technical thresholds for admission-design-level consideration. Evidence quality alone is not a blocker.

2. **FVG_TPB is NOT a trend continuation strategy and should not be treated as TPC.** The best edge is counter-trend (BUY_TREND_DOWN, EDGE_SUPPORTED at WR=47.76%), and the worst edge is exactly the TPC core case (SELL_TREND_DOWN, E[R]=−0.041R). TPC misclassification is an active risk requiring explicit prohibition.

3. **RBSR is a pragmatic provisional lane; IMBALANCE_FILL_REVERSAL is the architecturally cleanest lane.** FVG marks displacement exhaustion/imbalance zones — a mechanically distinct structural precondition from RBSR's liquidity sweep. A new IMBALANCE_FILL_REVERSAL playbook design is the recommended next large package.

4. **Admission requires factory_admission_lock lift and explicit operator authorization.** No admission is authorized or initiated by this document.

**System status: DEVELOPING — unchanged.**

---

## 2. Evidence Baseline

### 2.1 Discovery Method

**Source classification:** UNVERIFIED_EXTERNAL_SOURCE — ICT/SMC FVG methodology from research knowledge base (knowledge cutoff August 2025). No live internet retrieval was performed. All trigger logic is OHLCV-derived and deterministic; the "external" classification refers to the strategy concept origin, not the replication quality.

**Three FVG candidates evaluated:**

| Candidate | Slug | Expected N | Starvation | Overlap | Selected |
|---|---|---|---|---|---|
| FVG Trend Pullback | fvg_tpb | HIGH | LOW | NONE | YES |
| Liquidity Sweep + FVG Reversal | fvg_sweep_rev | LOW | MOD-HIGH | HIGH (sweep_reversal) | NO |
| Session Displacement FVG | fvg_session_disp | MOD | MOD | MOD | NO |

**Selection basis:** OHLCV-exact core trigger; expected HIGH N; no MT5 strategy overlap; LOW starvation risk.

### 2.2 Core Certification Metrics

| Metric | Value | Classification |
|---|---|---|
| M1 bar count | 100,466 | Verified |
| Total FVG events | 6,675 | Verified |
| FVG-to-trigger ratio | 36.6% | Verified |
| Variant A N | 2,442 | SUFFICIENT |
| Variant A WR | 43.41% | +3.41pp above breakeven |
| Variant A E[R] | +0.0852R | Positive |
| Variant A PF | 1.1505 | Positive |
| Max consecutive losses | 12 | Manageable |
| Avg MAE | 0.9564R | Favorable (< MFE) |
| Avg MFE | 1.1108R | Favorable |
| Avg bars held | 7.7 | Verified |
| Trigger rate (M1) | 2.43% | ADEQUATE_DENSITY |
| Monthly WR range | 42.2% – 44.6% | 2.4pp — STABLE |
| Walk-forward gap | 1.7pp (late outperforms) | STABLE |
| All months positive E[R] | YES (5/5) | STABLE |
| Slippage stress +10pt WR | 42.11% | Positive — ROBUST |
| Slippage stress +10pt E[R] | +0.0528R | Positive — ROBUST |
| Outlier sensitivity | ±0.02pp WR / ±0.0004R | NEGLIGIBLE |

### 2.3 Best Subsets (EDGE_SUPPORTED)

| Subset | N | WR | E[R] | PF | Label |
|---|---|---|---|---|---|
| BUY_TREND_DOWN | 335 | 47.76% | +0.1940R | 1.3714 | EDGE_SUPPORTED |
| SELL_RANGE_NEUTRAL | 425 | 47.06% | +0.1765R | 1.3333 | EDGE_SUPPORTED |

**Lift above baseline (Variant A):**
- BUY_TREND_DOWN: +4.35pp WR, +0.109R E[R]
- SELL_RANGE_NEUTRAL: +3.65pp WR, +0.091R E[R]

Both exceed +2pp WR AND +0.04R E[R] LOCATION_PACKET thresholds simultaneously.

### 2.4 Hostile Subset

| Subset | N | WR | E[R] | PF | Label |
|---|---|---|---|---|---|
| SELL_TREND_DOWN | 417 | 38.37% | −0.0408R | 0.9339 | EDGE_NOT_CONFIRMED |

WR=38.37% is above the 35% formal REJECTION threshold. SELL_TREND_DOWN is **hostile but not rejected**. A regime-direction gate excluding this subset would improve aggregate E[R] from +0.085R to approximately +0.110R.

### 2.5 Replication Classification

**PARTIAL_REPLICATION.** The core FVG trigger (3-candle OHLCV gap test) is OHLCV-exact — no proxy gap in the primary signal. The only proxy gap is regime classification: EMA20/EMA50/ATR14 threshold proxy vs MT5 council_environment zone detection. Since FVG_TPB has no MT5 source implementation, there is no source-faithfulness concern; this is a potential regime-label divergence upon admission.

**Data identity:** XAUUSD broker data (MetaQuotes terminal export). No GC=F futures proxy — superior to bollinger_reclaim's PARTIAL_REPLICATION basis.

### 2.6 Source Caveats

- UNVERIFIED_EXTERNAL_SOURCE — concept origin is publicly documented but not attributed to a specific live trading system
- No proprietary indicator required — trigger is deterministic from OHLCV
- INEC evidence is strong but does not authorize MT5 admission
- Nautilus is evidence-only; MT5 is runtime authority

### 2.7 Evidence Classification

| Evidence Claim | Classification |
|---|---|
| Variant A WR=43.41%, E[R]=+0.085R, N=2,442 | **Verified** — direct output from deterministic OHLCV simulation |
| BUY_TREND_DOWN EDGE_SUPPORTED (WR=47.76%, E[R]=+0.194R) | **Verified** — N=335 SUFFICIENT, direct simulation output |
| SELL_RANGE_NEUTRAL EDGE_SUPPORTED (WR=47.06%, E[R]=+0.176R) | **Verified** — N=425 SUFFICIENT, direct simulation output |
| Temporal stability (1.7pp walk-forward gap) | **Verified** — split calculation directly from trade CSV |
| Slippage robustness (+10pt: WR=42.11%) | **Verified** — friction adjustment in simulation |
| Outlier insensitivity (±0.02pp WR) | **Verified** — 6 trades excluded, N-6 simulation |
| SELL_TREND_DOWN hostility (E[R]=−0.041R) | **Verified** — N=417 SUFFICIENT, direct output |
| Counter-trend edge inversion (BUY_TD > BUY_TU) | **Strongly supported** — verified result, mechanically interpretable |
| RBSR candidate fit (reversal/imbalance archetype) | **Strongly supported** — counter-trend dominance consistent with reversal classification |
| TPC misfit (SELL_TD hostile) | **Strongly supported** — hostile result in core TPC use case |
| IMBALANCE_FILL_REVERSAL new playbook concept | **Plausible but unverified** — mechanically logical; no co-presence test, no MT5 experience |
| Co-presence lift with sweep_reversal | **Insufficient** — no co-presence data; external candidate has no MT5 history |
| Live runtime behavior of FVG_TPB in MT5 | **Insufficient** — external candidate; 0 live entries |
| Regime-proxy divergence magnitude | **Plausible but unverified** — EMA vs zone detection; divergence is architecturally expected but not quantified |
| Hostile gate improving aggregate E[R] to +0.110R | **Plausible but unverified** — linear exclusion estimate; regime transition edge effects not modeled |

---

## 3. Strategy Identity Proposal

**Design-only. No weight, role, or source change is authorized by this section.**

| Field | Proposed Value | Basis |
|---|---|---|
| strategy_id | `external_fvg_tpb` | INEC certification slug; "external_" prefix indicates pre-admission status |
| Display name | FVG Trend Pullback | INEC discovery designation |
| Family candidate | IMBALANCE_FILL (proposed) or LIQUIDITY_REVERSAL (provisional RBSR fit) | Counter-trend dominance supports imbalance/reversal family; LIQUIDITY_REVERSAL is the closest existing family |
| Role candidate | SCOUT | Independent alpha trigger; not a confirmer; fires standalone |
| Direction_bias | BOTH | Fires BUY and SELL; both productive |
| Active zones candidate | REV / RMR / RANGE (provisional) | FVG_TPB fires across all M5 regimes; zone mapping pending playbook placement decision |
| Observe_only zones candidate | TC / BREAKOUT | SELL_TREND_DOWN hostile; TC zones are high-risk for continuation-misuse |
| Blocked zones candidate | None yet defined | Hostile subset is direction×regime, not zone-level |
| vote_weight range (design-only) | 0.60–0.80 | Starting range for SCOUT with EDGE_WEAK_BUT_RECOVERABLE baseline; pending live evidence. NOT AUTHORIZED. |
| Registry status | NOT_REGISTERED — external candidate; factory_admission_lock ACTIVE | Verified |
| Packet role | ALPHA_TRIGGER_PACKET (primary) + LOCATION_PACKET secondary | Formally accepted; location improvement confirmed |
| Playbook association | RBSR (provisional) OR new IMBALANCE_FILL_REVERSAL | Design decision Section 5 |
| Chain role | ALPHA_TRIGGER_INDEPENDENT | Does not depend on another strategy; fires standalone |
| runtime_authority_status | NONE — cannot be ACTIVE until admitted | Verified |
| hostile_gate_design | SELL_TREND_DOWN excluded at design intent | Not authorized for implementation; design-intent only |
| RCEM candidate | REDUCE in TC zones; OBSERVE_ONLY if SELL_TREND_DOWN | Pending playbook placement and operator authorization |

---

## 4. Core Rule Definition

### 4.1 Certified Rules (Implementation-Ready)

These rules are certified from OHLCV simulation. They define the deterministic trigger that produced the N=2,442 results. Any future implementation must faithfully replicate these rules.

**Bullish FVG definition:**
```
bar j: FVG condition = low[j] > high[j-2]
Gap zone: fvg_lo = high[j-2], fvg_hi = low[j]
Direction: BUY
```

**Bearish FVG definition:**
```
bar j: FVG condition = high[j] < low[j-2]
Gap zone: fvg_lo = high[j], fvg_hi = low[j-2]
Direction: SELL
```

**Gap size threshold (noise filter):**
```
gap_size = fvg_hi - fvg_lo
Required: gap_size >= ATR14(M5, Wilder) * 0.05
Ratio: 5% of ATR — filters single-tick and micro-structure noise
```

**M5/M1 relationship:**
- FVG detection timeframe: M5 (3-candle test on confirmed M5 OHLCV bars)
- FVG activation time: M5 bar[j] open timestamp + 5 minutes (after bar[j] closes)
- Entry timeframe: M1 (close within gap zone on completed M1 bar)
- Stop sizing timeframe: M1 ATR14 (Wilder EWM)

**Mitigation / Entry rule:**
```
ENTRY: First M1 bar whose close falls within [fvg_lo, fvg_hi] of an active FVG
Condition: fvg_lo <= m1_close <= fvg_hi
Direction: From FVG direction (BUY for bullish gap, SELL for bearish gap)
Constraint: One active trade at a time (FIFO gap selection when multiple gaps active)
```

**Expiry rule:**
```
FVG expires: activation_time + 4 hours (= activation_time + 48 M5 bars)
Expired FVGs are removed from the active list; no entry is taken after expiry
```

**Invalidation rule:**
```
Bullish FVG invalidated: M1 close < fvg_lo (price closes below gap bottom)
Bearish FVG invalidated: M1 close > fvg_hi (price closes above gap top)
Invalidated FVGs are removed from the active list; no entry is taken after invalidation
```

**Stop model:**
```
stop_distance = ATR14(M1, Wilder) * 1.20
BUY: stop = entry - stop_distance - slippage_pts * POINT
SELL: stop = entry + stop_distance + slippage_pts * POINT
POINT = 0.01 (XAUUSD 5-digit pricing)
```

**Target model:**
```
target_distance = stop_distance * 1.50
BUY: target = entry + target_distance - slippage_pts * POINT
SELL: target = entry - target_distance + slippage_pts * POINT
RR = 1.50 (breakeven WR = 40.0%)
```

**Cost model used in certification:**
```
spread_pts = 10.0
slippage_pts = 2.0
total_friction_pts = 12.0 = 0.12 price units
stop_atr_mult = 1.20
rr = 1.50
breakeven_wr = 0.40
```

**Hostile subset rule (design intent — not implemented):**
```
IF direction == SELL AND regime == TREND_DOWN: SKIP (do not fire)
Effect: Removes N=417 trades with E[R]=−0.041R
Estimated improvement: E[R] from +0.085R to ~+0.110R
```

**Best subset rule (location filter — design intent):**
```
BUY_TREND_DOWN: BUY entries with M5 regime == TREND_DOWN — EDGE_SUPPORTED
SELL_RANGE_NEUTRAL: SELL entries with M5 regime == RANGE_NEUTRAL — EDGE_SUPPORTED
Combined: 760 trades, estimated WR ~47.4%, E[R] ~+0.185R
```

### 4.2 Optional Future Refinements (Not Certified — Design Intent Only)

These refinements were not tested in the INEC certification. They are design-intent candidates requiring separate evidence testing before authorization.

| Refinement | Hypothesis | Risk |
|---|---|---|
| Session filter (London/NY only) | Session FVGs may have stronger institutional backing | INSUFFICIENT evidence; would require separate TIMING_PACKET test |
| Partial mitigation threshold (e.g., 50% fill) | Early entry before full gap mitigation | Changes trigger definition; would invalidate N=2,442 base |
| Multi-timeframe regime (H1 filter) | H1 trend direction may improve subset selection | Adds regime proxy; complexity without proven benefit |
| Expiry extension to 96 M5 bars (8 hours) | More time for price to return to gap | Changes expiry rule; would require re-certification |
| Minimum gap size multiplier increase | Larger gaps may have stronger institutional imbalance | Would reduce N significantly; needs N-impact assessment |

### 4.3 Forbidden Optimizations

These optimizations are forbidden because they would constitute overfitting to the INEC sample or would change the core mechanism:

| Forbidden Action | Reason |
|---|---|
| Curve-fitting gap size threshold to maximize WR | Over-parameterization of the 0.05×ATR rule |
| Post-hoc regime filter optimized on certification data | Data mining from the same 100,466-bar sample |
| Direction bias elimination based on hostile subset | SELL_TREND_DOWN is hostile, not rejected; eliminating SELL globally is overcorrection |
| RR optimization (e.g., RR=1.8 or RR=2.0) | Changes cost model; invalidates all N=2,442 comparative evidence |
| Using M1 ATR for FVG size threshold instead of M5 ATR | Mixes timeframe ATRs inconsistently with mechanism design |

---

## 5. Playbook Placement Decision

### 5.1 Option A — Existing RBSR Playbook

**Evidence fit:**
- BUY_TREND_DOWN (WR=47.76%, EDGE_SUPPORTED): A bullish FVG in a downtrend captures displacement exhaustion/reversal — this is semantically aligned with RBSR's "reversal from structural imbalance" logic.
- SELL_RANGE_NEUTRAL (WR=47.06%, EDGE_SUPPORTED): A bearish FVG in range context triggers mean-reclaim — this aligns with RBSR's range-boundary reclaim mechanism.
- FVG_TPB ALPHA_TRIGGER (E[R]=+0.085R unrestricted) is the strongest unrestricted positive E[R] of any RBSR strategy:
  - sweep_reversal: E[R]=−0.011R unrestricted
  - bollinger_reclaim: E[R]=−0.018R unrestricted
  - mean_reversion_bounce: E[R]=+0.067R (RBSR CONFIRM candidate; ACCEPTED_ALPHA_TRIGGER per 2026-05-09 cert)
  - FVG_TPB: E[R]=+0.085R unrestricted — **strongest RBSR-context unrestricted positive E[R] in the lab**

**Contradiction:**
- FVG_TPB fires across all M5 regimes, not just REV/RMR zones. RBSR is primarily a REV/RMR-zone playbook. Zone mapping would require FVG_TPB to be active in REV/RMR while reduced/blocked in TC/BREAKOUT.
- FVG imbalance mechanism (3-candle gap) is mechanically distinct from RBSR sweep mechanism (liquidity level sweep + rejection). These are orthogonal structural preconditions — the sweep-then-reversal causal chain does not inherently include FVG.
- No co-presence data exists. FVG_TPB may or may not correlate with sweep_reversal triggers.

**Required causal chain:**
If FVG_TPB is placed in RBSR as ALPHA_TRIGGER, the chain becomes:
1. Displacement/imbalance occurs (FVG detected) OR sweep occurs (sweep_reversal detects)
2. Price returns to imbalance/sweep zone (FVG_TPB or sweep_reversal fires)
3. Mean-reclaim confirmed (bollinger_reclaim, range_edge_fade, mean_reversion_bounce)
4. Exhaustion guard (mfi_reversal_assist)

This chain has two independent alpha sources — FVG_TPB and sweep_reversal — without a required causal dependency. This is architecturally loose but pragmatically workable.

**Risk:** Over-broad playbook scope. RBSR becomes a catch-all for "any reversal from any zone," diluting the causal chain clarity. Co-presence ubiquity risk if FVG_TPB fires frequently alongside sweep_reversal.

**Runtime complexity:** LOW — uses existing SCOUT role, LIQUIDITY_REVERSAL or similar family, existing gate paths.

**Registry impact:** MODERATE — adds new external strategy to RBSR; requires registry update (not authorized here).

**Starvation risk if required as gate:** MINIMAL — FVG_TPB trigger rate is 2.43% (adequate density); would not starve system.

**Interpretation clarity:** MODERATE — FVG and sweep are related but not identical mechanisms; co-habitation in RBSR requires documentation.

**Verdict: PROVISIONAL_FIT — pragmatic lane; architecturally impure; workable if new playbook is not pursued.**

---

### 5.2 Option B — Existing TPC Playbook

**Evidence fit (weak):**
- BUY_TREND_UP (WR=44.83%, E[R]=+0.121R): Acceptable trend-aligned BUY performance in TC zone.
- Variant B trend-filtered (WR=41.6%, E[R]=+0.040R): Barely above breakeven.

**Contradiction:**
- SELL_TREND_DOWN (WR=38.37%, E[R]=−0.041R): This is the PRIMARY TPC SELL use case. FVG_TPB's worst-performing subset is exactly where TPC needs it most.
- TPC causal chain requires direction-aligned signals that confirm the trend is continuing. FVG_TPB's best signal (BUY_TREND_DOWN) is COUNTER-trend, which is the opposite of TPC's intent.
- trend_momentum (TPC anchor) has 0 formal accepted packets and its own confirmation gap. Adding FVG_TPB as a TPC ALPHA would create an authority mismatch: FVG_TPB (FORMALLY_ACCEPTABLE) would outrank trend_momentum (RESEARCH_ONLY) as a TPC alpha.

**Required causal chain:** Not constructable. FVG continuation in a downtrend (SELL_TREND_DOWN) is the TPC core case and it is hostile. The evidence contradicts the TPC causal hypothesis for FVG_TPB.

**Risk:** HIGH — misclassifying FVG_TPB as TPC would cause hostile SELL_TREND_DOWN trades to be treated as TPC-compliant, degrading execution quality.

**Verdict: REJECTED — counter-evidence in core TPC use case. TPC lane must not be used for FVG_TPB.**

---

### 5.3 Option C — New IMBALANCE_FILL_REVERSAL Playbook

**Evidence fit (strongest):**
- FVG imbalance fill as a structural archetype is mechanically distinct from both RBSR (sweep reversal) and TPC (trend continuation). An FVG marks a zone where price moved rapidly, leaving an unfilled imbalance. Reversion into that zone captures institutional mean-reversion from the displacement point.
- BUY_TREND_DOWN + SELL_RANGE_NEUTRAL define the core causal pair:
  - BUY_TREND_DOWN: Bullish gap in downtrend = bearish impulse exhaustion; displacement reversal
  - SELL_RANGE_NEUTRAL: Bearish gap in range = extension above range mean; range-mean reclaim from imbalance
- The counter-trend and range-reclaim signatures define a coherent new playbook hypothesis: price fills an imbalance zone, then resumes the prior structural direction (counter-trend to the impulse, or range-mean direction in neutral context).
- This is architecturally cleanest: FVG_TPB would be the PLAYBOOK_ANCHOR for a new playbook, with a clear causal chain that can be tested independently of RBSR.

**Contradiction:**
- No co-presence data with any strategy exists.
- A new playbook requires PIML update, playbook design, and operator authorization.
- Creating a new playbook with 0 live entries and 1 external candidate has no confirmation chain yet.
- factory_admission_lock is ACTIVE — the playbook would immediately have a single strategy with no confirmed chain.

**Required causal chain (design):**
1. Impulse move creates FVG (imbalance zone)
2. FVG_TPB detects M1 retracement into gap zone (ALPHA/ANCHOR)
3. A future CONFIRMATION strategy confirms zone interaction (CONFIRM — RESEARCH_ONLY gap exists)
4. mfi_reversal_assist or similar exhaustion guard monitors continuation (FAILURE_MODE)

Chain members 3 and 4 would need to be designed and certified — no existing strategy is pre-assigned.

**Risk:** MODERATE — creates architectural overhead without a complete chain. New playbook could sit at PLAYBOOK_NOT_PRESENT or PLAYBOOK_FORMING indefinitely without a confirmer.

**Runtime complexity:** MODERATE — new playbook_id in registry, new family ID, new chain role assignments.

**Registry impact:** SIGNIFICANT — new playbook, new family, new strategy registration. All require PIML and registry updates (not authorized here).

**Starvation risk:** LOW for FVG_TPB itself. LOW for new playbook (standalone alpha trigger, adequate density).

**Interpretation clarity:** HIGH — mechanically distinct archetype, clean causal hypothesis, no overlap confusion with RBSR or TPC.

**Verdict: MECHANICALLY_STRONGEST fit; requires new playbook design; DESIGN_CANDIDATE_ONLY status until operator authorizes playbook creation.**

---

### 5.4 Playbook Placement Recommendation

**Recommended playbook lane:** IMBALANCE_FILL_REVERSAL (Option C) as the architectural target, with RBSR (Option A) as a provisional admission lane if the operator prefers to admit FVG_TPB before the new playbook design is complete.

**Recommended path:**

| Path | Description | When to Use |
|---|---|---|
| Path 1 (Preferred) | Design IMBALANCE_FILL_REVERSAL playbook first; then admit FVG_TPB as anchor | Architecturally cleanest; avoids RBSR scope dilution; recommended next large package |
| Path 2 (Provisional) | Admit FVG_TPB to RBSR as provisional ALPHA_TRIGGER; migrate to new playbook when ready | Faster admission; acceptable if RBSR co-presence can be tested first |

**Rejected lane:** TPC — explicitly prohibited. Any implementation proposal that routes FVG_TPB to TPC zones or uses it as a TPC ALPHA must be rejected by the design review.

**Design constraint (mandatory in future Codex task):**
- FVG_TPB must be REDUCED or BLOCKED in TC/BREAKOUT zones where SELL_TREND_DOWN risk is highest
- SELL_TREND_DOWN hostile gate must be included in the initial implementation, not deferred
- FVG_TPB must not participate in CRR satisfaction as a TPC CONFIRM strategy under any path

---

## 6. Packet Role Decision

### 6.1 ALPHA_TRIGGER_PACKET

**Acceptance evidence:** WR=43.41% > 40%; E[R]=+0.085R > 0; N=2,442 SUFFICIENT; all 5 months positive E[R]; 5/5 direction-regime cells positive (only SELL_TREND_DOWN negative); no geometric sampling artifact (both directions fire in all three regimes).

**Rejection rule:** Not triggered. WR=43.41% > 40%; E[R] not negative in all conditions; no geometric constraint.

**Current verdict: FORMALLY_ACCEPTABLE — primary packet role.**

**Runtime implication if authorized:** FVG_TPB fires as an independent directional signal in the council. Its vote contributes to consensus formation. No confirmation from other strategies is required for it to fire. It fires alongside sweep_reversal as a parallel ALPHA — not as a confirmer or a gate.

**Risk if misused:** Treating FVG_TPB as a CRR gate satisfier (CONFIRM role) would bypass the cross-family CRR upgrade. FVG_TPB must be SCOUT/ALPHA, not CONFIRM, to avoid gate contamination.

---

### 6.2 LOCATION_PACKET

**Acceptance evidence:** BUY_TREND_DOWN: WR lift +4.35pp (vs baseline), E[R] lift +0.109R — exceeds +2pp AND +0.04R simultaneously. SELL_RANGE_NEUTRAL: WR lift +3.65pp, E[R] lift +0.091R — exceeds both thresholds. Both subsets achieve N > 300 SUFFICIENT.

**Current verdict: APPLICABLE_CANDIDATE CONFIRMED — secondary packet role.**

**Runtime implication if authorized:** Location filtering (SELL_TREND_DOWN blocked; BUY_TREND_DOWN + SELL_RANGE_NEUTRAL flagged as premium subsets) could be implemented as a per-trigger context label in the V1C ledger, enabling future co-presence analysis of how location context affects overall council quality.

**Risk if misused:** Using LOCATION as a gate (only allowing BUY_TREND_DOWN or SELL_RANGE_NEUTRAL to fire) would reduce trigger density from 2.43% to ~0.75% — still adequate but potentially starving co-presence analysis. Location improvement should be optional enhancement, not a mandatory gate.

---

### 6.3 CONFIRMATION_PACKET

**Current verdict: NOT_TESTABLE — no co-presence data exists.**

FVG_TPB has no MT5 history. Co-presence analysis with sweep_reversal (the RBSR anchor) cannot be run without live V1C records from both strategies firing in the same sessions. Scheduled for future RBSR playbook cert if FVG_TPB is admitted.

**Risk if misused:** Treating FVG_TPB as a CONFIRM packet without evidence would pollute the RBSR causal chain. The CONFIRMATION_PACKET designation requires WR lift ≥ +2pp AND E[R] lift ≥ +0.04R above sweep_reversal standalone — this cannot be assumed from standalone cert results.

---

### 6.4 FAILURE_MODE_PACKET

**Current verdict: NOT_APPLICABLE.** FVG_TPB is an alpha trigger, not a failure-mode detector. Its trigger logic contains no failure-mode sub-condition.

---

### 6.5 TIMING_PACKET

**Current verdict: STABLE — NOT_A_TIMING_ARTIFACT.** All 5 months show WR 42.2%–44.6%; walk-forward gap = 1.7pp; no dominant session required. The TIMING_PACKET designation is not needed (temporal stability is a positive quality, not a timing-dependent pattern).

**Future candidate:** A session-filtered variant (London/NY FVG analysis) could produce a TIMING_PACKET if the session lift is material. This would require a separate INEC test run.

---

### 6.6 ATTRIBUTION_PACKET

**Current verdict: NOT_APPLICABLE.** FVG_TPB fires independently and does not explain outcomes from other strategies.

---

### 6.7 RESEARCH_ONLY_PACKET

**Current verdict: SUPERSEDED.** ALPHA_TRIGGER_PACKET is formally acceptable. RESEARCH_ONLY designation is not needed.

---

### 6.8 REJECTED_PACKET

**Current verdict: NOT_MET.** WR=43.41% is well above 35% rejection threshold. No regime shows WR < 35% with N >= 20 except SELL_TREND_DOWN (WR=38.4%, above 35%, EDGE_NOT_CONFIRMED not REJECTED).

---

### 6.9 Packet Role Summary

| Role | Verdict | Priority |
|---|---|---|
| ALPHA_TRIGGER_PACKET | **FORMALLY_ACCEPTABLE** | PRIMARY |
| LOCATION_PACKET | **APPLICABLE_CANDIDATE CONFIRMED** | SECONDARY |
| CONFIRMATION_PACKET | NOT_TESTABLE | Future (post-admission, post-co-presence) |
| FAILURE_MODE_PACKET | NOT_APPLICABLE | N/A |
| TIMING_PACKET | STABLE — not a timing artifact | N/A |
| ATTRIBUTION_PACKET | NOT_APPLICABLE | N/A |
| RESEARCH_ONLY_PACKET | SUPERSEDED | N/A |
| REJECTED_PACKET | NOT_MET | N/A |

---

## 7. MT5 Implementation Boundary Design

**DESIGN_ONLY — no code, no authorization.**

This section defines what a future Codex task would need to implement. All content is specification and boundary definition. Implementation is not authorized here or by this document.

### 7.1 Files Likely Involved

| File | Purpose | Change Type |
|---|---|---|
| council_mode_types.mqh | New SFVGZone struct; new FVG trigger result field in SStrategyResult or SCouncilStrategyReport | NEW STRUCT + NEW FIELDS |
| council_strategies.mqh | FVG detection, zone state management, BuildCouncilStrategy_FVG_TPB() function | NEW FUNCTION (~150-200 lines) |
| strategy_runtime.mqh | Potentially: persistent M5 FVG zone array across council calls | POSSIBLE NEW ARRAY |
| council_mode_runtime.mqh | Integration of FVG_TPB into RunCouncilModePipeline (call to BuildCouncilStrategy_FVG_TPB) | MINOR INTEGRATION (~5-10 lines) |
| ai_opportunity_ledger.jsonl | V1C schema extension with FVG-specific observation fields | LEDGER SCHEMA EXTENSION |

**FORBIDDEN files in FVG_TPB implementation:**
- core_trade_engine.mqh — execution logic forbidden from this package
- council_pre_ai_filter.mqh — no gate changes permitted
- council_aggregator.mqh — no aggregation logic changes
- council_ai_governor.mqh — no governor changes
- All strategy files OTHER than the new FVG_TPB function and its supporting structures

### 7.2 New Structure — SFVGZone (design concept)

```
// DESIGN CONCEPT ONLY — Not authorized for implementation
struct SFVGZone
{
   datetime  activation_time;     // M5 bar close time (bar[j] open + 5 min)
   datetime  expiry_time;         // activation_time + 240 minutes
   double    fvg_lo;              // lower boundary of gap zone
   double    fvg_hi;              // upper boundary of gap zone
   double    gap_size_pts;        // fvg_hi - fvg_lo in points
   double    atr_m5;              // ATR14(M5, Wilder) at detection time
   int       direction;           // TRADE_DIRECTION_BUY or TRADE_DIRECTION_SELL
   string    regime;              // M5 regime at detection: TREND_UP/TREND_DOWN/RANGE_NEUTRAL
   bool      is_active;           // has been activated (time >= activation_time)
   bool      is_expired;          // has expired
   bool      is_invalidated;      // price closed through far side
   bool      has_triggered;       // M1 entry has been taken from this zone
};
```

### 7.3 Required Functions (Conceptual)

**DetectFVGZones(M5_bars[]) — design concept:**
- Input: M5 OHLCV array with ATR14(Wilder)
- Logic: Scan for 3-candle gap patterns; apply size filter (gap >= ATR14_M5 * 0.05)
- Output: Array of new SFVGZone structs to be added to active zone list
- Called: Once per M5 bar close (not on every M1 bar)

**UpdateFVGZoneState(active_zones[], current_m1_close, current_time) — design concept:**
- Input: Current active zone list, current M1 bar's close and timestamp
- Logic: For each zone — (1) activate if time >= activation_time; (2) check expiry; (3) check invalidation (BUY: M1 close < fvg_lo; SELL: M1 close > fvg_hi); (4) remove expired/invalidated zones
- Output: Updated zone list (in-place mutation or new array)
- Called: Every M1 bar

**DetectFVGTPBTrigger(active_zones[], current_m1_close, open_trade) — design concept:**
- Input: Active zone list, current M1 close, flag indicating whether a trade is already open
- Logic: FIFO search for first active zone where fvg_lo <= m1_close <= fvg_hi; skip if trade already open
- Output: Triggered SFVGZone or null
- Called: Every M1 bar after UpdateFVGZoneState()

**BuildCouncilStrategy_FVG_TPB(env, reports[], index) — design concept:**
- Mirrors BuildCouncilStrategy_X() pattern from council_strategies.mqh
- Input: Council environment report, strategy report array, index to populate
- Logic: Call DetectFVGTPBTrigger(); if trigger found, set reports[index] fields (vote_direction, trigger_present, score_final, trigger_quality, etc.); apply SELL_TREND_DOWN hostile gate
- Output: Populated SCouncilStrategyReport for FVG_TPB
- Critical: Must use the SAME cost model (spread=10, slippage=2, ATR_MULT=1.20, RR=1.50) as certification
- Called: Within RunCouncilStrategySet()

### 7.4 FVG Zone State Persistence

The zone state machine requires persistence across M1 bars within a session. Two approaches:

| Approach | Description | Pros | Cons |
|---|---|---|---|
| Static global array | Static SFVGZone array declared at EA global scope | Simple, zero overhead | Zones lost on EA reload; cold-start gap of up to 4 hours |
| On-init replay | On EA init(), replay last 48 M5 bars to rebuild active zone list | Cold-start robustness | Requires M5 data access on OnInit(); ~5-10 lines extra |

**Recommended: On-init replay.** The 4-hour expiry window means EA reload during a session could miss active zones. Replaying 48 M5 bars on startup is minimal overhead and ensures zone continuity.

### 7.5 Hostile Gate Implementation Design (SELL_TREND_DOWN)

```
// DESIGN CONCEPT ONLY — Not authorized
// Inside BuildCouncilStrategy_FVG_TPB():
if(triggered_zone.direction == TRADE_DIRECTION_SELL && 
   env.m5_regime == REGIME_TREND_DOWN)
{
   // Hostile gate: SELL in TREND_DOWN is EDGE_NOT_CONFIRMED (E[R]=-0.041R)
   // Suppress trigger; log gate activation in V1C ledger
   reports[index].trigger_present = false;
   reports[index].gate_fired = "SELL_TREND_DOWN_HOSTILE";
   return;
}
```

### 7.6 Single Codex Task Scope

A future FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 Codex task should be bounded to:

- ONE new struct in council_mode_types.mqh (SFVGZone)
- ONE new function in council_strategies.mqh (BuildCouncilStrategy_FVG_TPB + helpers)
- ONE new call in RunCouncilStrategySet() in council_strategies.mqh
- NEW V1C ledger fields for FVG_TPB observation
- Compile 0 errors / 0 warnings required
- No changes to aggregator, filter, governor, execution, or stop geometry
- No changes to any other existing strategy function

---

## 8. Event Order Contract Assessment

### 8.1 Core Questions

| Question | Answer | Classification |
|---|---|---|
| Can FVG be detected before decision? | YES — FVG detected after M5 bar[j] closes; no lookahead required | Verified |
| Is activation_time deterministic before entry? | YES — activation = M5 bar[j] open + 5 min; always known before M1 entry | Verified |
| Can mitigation (entry) be known before decision? | YES — M1 close within [fvg_lo, fvg_hi] is checked on closed M1 bar | Verified |
| Can invalidation be known before decision? | YES — M1 close < fvg_lo (BUY) or M1 close > fvg_hi (SELL) on completed bar | Verified |
| Can expiry be known before decision? | YES — time-based; activation_time + 240 min is deterministic | Verified |
| Can stop/target be computed before decision? | YES — ATR14(M1, Wilder) on closed M1 bars; computed at trigger time | Verified |
| What timestamp fields are required? | M5 bar open timestamp (FVG detection); M5 bar close timestamp (activation); M1 entry bar timestamp; M1 SL/TP hit timestamp | Design requirement |
| What would make evidence late? | Checking M5 bar[j] before it closes (using bar[0] data); using M1 bar[0] (forming bar) for entry check | PROHIBITED in design |
| Is there a Stage 18.5 concern? | LOW — FVG trigger is OHLCV-complete before council evaluation; no partial-bar data required | Verified |

### 8.2 EOC Status

**EOC: COMPLIANT (hypothetical — no MT5 implementation exists)**

Stages 1-7 all produce PASS verdicts for the conceptual design:
- Stage 1 (timestamps): PASS — M1 used directly
- Stage 2 (M5 regime): PASS — from completed M5 bars, shift=1 or equivalent
- Stage 3 (FVG detection): PASS — M5 bar[j] and bar[j-2] both completed when zone is activated
- Stage 4 (FVG activation): PASS — activation_time is after M5 bar[j] close
- Stage 5 (M1 entry): PASS — M1 close from closed bar; no bar[0]
- Stage 6 (FVG state): PASS — expiry/invalidation use completed bar data
- Stage 7 (aggregation): PASS — standard council aggregation path unchanged

**EOC blockers:** NONE for the conceptual design. Actual implementation requires code review at Stage 18.5 to verify no bar[0] usage slips into the FVG detection or entry logic.

### 8.3 EOC Requirements for Future Implementation

| Requirement | Enforcement Method |
|---|---|
| M5 FVG detection uses bar[j] (shift >= 1 from current bar) | Code review before deployment |
| M1 entry uses bar[1] close (not bar[0]) | Code review before deployment |
| Activation_time is AFTER M5 bar[j] close (>= bar[j].time + 5 min) | Unit test: activation_time always > detection_time |
| No zone state reads from partial M5 bar | Zone update only called after M5 bar close event |
| ATR14(M1) uses shift=1 source data | Consistent with existing strategy_runtime.mqh ATR pattern |

### 8.4 Pre-Decision Instrumentation

FVG zone state is a per-bar persistent computation. The opportunity ledger must record:
- How many active FVG zones existed at trigger time
- Which zone triggered (by activation timestamp)
- Whether the trigger was suppressed by a gate (SELL_TREND_DOWN hostile)
- FVG age at trigger time (bars held in active list before entry)

This instrumentation cannot be done without V1C ledger field extensions (Section 9).

---

## 9. V1C Ledger / Observability Requirements

Current V1C schema: **OL_V1C_PLAYBOOK_SHADOW** (live per SHADOW_POLICY_CANDIDATE_DESIGN_PACKAGE_V1.md review; K1/K2/K3 cleanup compiled, pending reload validation).

FVG_TPB requires a new generation of fields: **OL_V1D_FVG_EXTENSION** (design concept — not authorized).

### 9.1 Required Before Admission

These fields are mandatory for FVG_TPB to be observable after admission. Without them, live performance cannot be attributed or diagnosed.

| Field | Type | Purpose | Classification |
|---|---|---|---|
| fvg_direction | string | BUY or SELL direction of triggering FVG | REQUIRED |
| fvg_gap_low | double | Lower boundary of FVG zone at trigger | REQUIRED |
| fvg_gap_high | double | Upper boundary of FVG zone at trigger | REQUIRED |
| fvg_regime_context | string | M5 regime at FVG detection time (TREND_UP/TREND_DOWN/RANGE_NEUTRAL) | REQUIRED |
| fvg_subset_classification | string | BUY_TREND_DOWN / SELL_RANGE_NEUTRAL / SELL_TREND_DOWN / etc. | REQUIRED |
| fvg_hostile_gate_fired | bool | Whether SELL_TREND_DOWN gate suppressed this trigger | REQUIRED |

### 9.2 Useful for Attribution

These fields are valuable for post-admission analysis but not blocking for initial admission.

| Field | Type | Purpose | Classification |
|---|---|---|---|
| fvg_size_atr | double | Gap size as fraction of ATR14_M5 at detection | USEFUL |
| fvg_age_bars | int | M1 bars elapsed since FVG became active until entry | USEFUL |
| fvg_invalidated | bool | Whether this or a competing FVG was invalidated before entry | USEFUL |
| fvg_expired | bool | Whether the FVG expired without triggering | USEFUL |
| fvg_active_zone_count | int | Number of active FVG zones at time of trigger | USEFUL |
| fvg_mitigation_pct | double | How deep into the gap zone the entry was (0=gap edge, 1=far side) | USEFUL |

### 9.3 Optional Future Fields

These fields support the IMBALANCE_FILL_REVERSAL playbook concept if it is later created.

| Field | Type | Purpose | Classification |
|---|---|---|---|
| fvg_entry_reason | string | Why this zone triggered (first active, best-ranked, FIFO) | OPTIONAL |
| imbalance_fill_playbook_candidate | string | Playbook context label for future IFR packet analysis | OPTIONAL |
| fvg_detection_bar_ts | datetime | M5 bar timestamp when FVG was originally detected | OPTIONAL |
| fvg_activation_ts | datetime | Exact timestamp when FVG became active (available for entry) | OPTIONAL |

### 9.4 Forbidden as Score/Gate

These hypothetical fields must never be plumbed into the decision pipeline:

| Field | Forbidden Reason |
|---|---|
| fvg_score or fvg_quality_score | Must not feed council_quality; observation-only |
| fvg_in_edge_subset (bool flag for BUY_TD or SRN) | Must not gate or weight trades; evidence label only |
| fvg_playbook_state | Must not influence HIGH_CONVICTION or consensus; observation-only |
| fvg_expectancy_estimate | No prospective score field may read live E[R] estimates into decisions |

---

## 10. Admission Risk Register

| Risk | Severity | Mitigation | Evidence Required Before Implementation |
|---|---|---|---|
| External-source narrative risk | MEDIUM | "UNVERIFIED_EXTERNAL_SOURCE" label maintained; trigger is OHLCV-deterministic; concept origin doesn't affect mathematical replication | None blocking — acknowledge and document |
| Overfitting risk (optimization on INEC sample) | HIGH | Rules certified as defined (0.05 ATR threshold, 4-hour expiry, 1.20 ATR stop). Any deviation from certified rules requires new certification run | Codex task must implement exact certified rules; deviation triggers re-cert |
| Subset cherry-picking risk | MEDIUM | BUY_TREND_DOWN and SELL_RANGE_NEUTRAL meet dual LOCATION_PACKET thresholds (+2pp WR AND +0.04R E[R]); N=335 and N=425 both SUFFICIENT | Document threshold meeting explicitly in Codex task; do not claim EDGE_SUPPORTED for gated-only variant without re-run |
| Regime inversion misunderstanding | HIGH | Must document counter-trend finding explicitly: FVG_TPB is NOT a trend continuation tool. BUY in downtrend = reversal, not pullback. SELL in downtrend = hostile. | Require adversarial review of implementation design before Codex execution |
| Accidental TPC misclassification | CRITICAL | Explicit prohibition in Section 5. SELL_TREND_DOWN hostile E[R]=−0.041R is the direct counter-evidence. Design must block TC zones for FVG_TPB. | Codex task must include "SELL in TREND_DOWN gate = ALWAYS ACTIVE" as a mandatory requirement |
| Score/gate leakage | MEDIUM | FVG_TPB vote must not feed council_quality differently from other SCOUT strategies; no new gate fields; fvg_ V1C fields are observation-only | Pre-deployment code review: confirm zero read paths from fvg_ fields to decision layer |
| factory_admission_lock bypass risk | CRITICAL | factory_admission_lock = ACTIVE; any implementation attempt without explicit operator lift is a governance violation | factory_admission_lock lift required before any FVG_TPB implementation task begins |
| Starvation risk (standalone) | LOW | Trigger rate 2.43% = 23 triggers/day estimated. Even edge-gated only (~0.75%) is 7/day — adequate | Monitor trigger rate in first 30 live sessions post-admission |
| Starvation risk (as required gate) | LOW | FVG_TPB should be SCOUT/ALPHA, not a mandatory gate. Do not make it a required CRR condition. | Confirmed in role assignment; SCOUT role confirmed |
| Cost sensitivity risk | LOW-MEDIUM | Slippage stress +10pt: WR=42.11% — positive but thin margin. Live broker spread variation is the primary cost risk. | Monitor live avg_slippage vs 2pt assumption in first 50 trades |
| Live broker mismatch | MEDIUM | INEC used MetaQuotes terminal CSV data. Live broker spread, slippage, and execution timing may differ from simulation assumptions. | First 50 live closed trades: compare WR, E[R] vs INEC baseline. Alert if WR < 38% |
| Event-order risk (bar[0] usage) | MEDIUM | Comprehensive EOC assessment in Section 8. Zone state machine requires careful implementation. | Code review at Stage 18.5: zero bar[0] usage policy; unit test for activation_time > detection_time |
| Implementation complexity risk | MEDIUM | SFVGZone state machine adds ~200 lines and one new struct. More complex than most existing strategies but not unprecedented. | Require compile 0 errors / 0 warnings; require line-by-line review of state machine logic |
| Interaction with sweep_reversal | UNKNOWN | FVG and sweep may fire simultaneously (co-presence ubiquity) or never together (disjoint). Unknown without live data. | Run co-presence analysis after 50+ live FVG_TPB entries; check sweep_reversal co-fire rate |
| Duplicate contribution risk | LOW-MEDIUM | FVG and sweep target different structural preconditions (imbalance gap vs liquidity sweep). Duplication is unlikely but unconfirmed. | Co-presence rate < 30% would confirm orthogonality; > 80% would indicate ubiquitous overlap |
| Production-readiness overclaim risk | CRITICAL | System is DEVELOPING. FVG_TPB admission does not change this. No production-readiness claim at any step. | Document "system status: DEVELOPING" in Codex task header |
| Registry confusion risk (external_ prefix) | LOW | "external_fvg_tpb" strategy_id preserves external origin. Rename to "fvg_tpb" only if operator explicitly authorizes admission under revised naming. | strategy_id = "external_fvg_tpb" until operator-authorized naming decision |

---

## 11. Admission Criteria

All of the following must be true before FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 can be authorized:

| Criterion | Required State | Current State |
|---|---|---|
| INEC certification complete | YES — ALPHA_TRIGGER_PACKET FORMALLY_ACCEPTABLE | MET |
| Source rule deterministic from OHLCV | YES — 3-candle gap test; no proprietary indicator | MET |
| Playbook lane selected | YES — operator selects RBSR provisional OR new IMBALANCE_FILL_REVERSAL | NOT MET — pending operator decision |
| Packet role selected | YES — ALPHA_TRIGGER primary; LOCATION secondary | MET |
| Rejection rules defined | YES — SELL_TREND_DOWN gate; WR < 38% rollback threshold | MET (design) |
| V1C observability fields specified | YES — 6 required fields documented in Section 9 | MET (design) |
| Codex package scoped and bounded | YES — single package: new struct + new function + integration + ledger | MET (this document) |
| Adversarial review completed | YES — by design reviewer before Codex execution | NOT MET — pending |
| Rollback path defined | YES — Section 12 | MET (design) |
| No score/gate authority | YES — V1C fields are observation-only | MET (design) |
| No phase unlock implied | YES — stated explicitly; admission does not unblock Phase 4A/4B/4C | MET |
| factory_admission_lock lifted for FVG_TPB | YES — explicit operator authorization required | NOT MET — ACTIVE |
| Operator authorization issued | YES — bounded Codex task explicitly authorized | NOT MET — pending |

**Blockers:** 3 items not met: playbook lane selection, adversarial review, and factory_admission_lock lift. All three require operator decision.

---

## 12. Rejection / Rollback Rules

### 12.1 Rejection Triggers (Post-Admission, Pre-Full-Validation)

FVG_TPB should be immediately suspended and removed from the production EA if any of the following occur:

| Trigger | Condition | Action |
|---|---|---|
| INEC trigger count mismatch | Live trigger rate < 0.5% of M1 bars after 72h of active market — far below INEC 2.43% | Halt; investigate zone state machine for bugs |
| Severe WR mismatch | Live WR < 35% after 50 closed W/L trades | Suspend; compare live vs INEC trade conditions |
| E[R] degradation | Live E[R] < −0.05R after 50 closed W/L trades | Suspend; review cost model vs live broker spread |
| Hostile subset dominance | SELL_TREND_DOWN gate not firing OR SELL_TREND_DOWN WR < 30% after 30 trades | Halt; verify gate implementation; consider full SELL suspension |
| JSON/ledger corruption | V1C fvg_ fields missing or incorrect format in > 5% of records | Halt; fix schema before continuing |
| Runtime instability | EA crashes, hung state, or memory errors attributable to FVG zone array | Halt immediately; rollback struct change |
| Execution starvation | FVG_TPB firing rate causes > 40% of ALL council executions (dominates system) | Reduce vote_weight; investigate if SCOUT weight is miscalibrated |
| Behavior duplication | Co-presence with sweep_reversal > 80% across 100+ records | Review; may indicate FVG is a proxy for sweep signals; consider reducing weight |
| Playbook misclassification confirmed | Live evidence shows FVG_TPB fires predominantly in TC zones (SELL_TREND_DOWN > 40% of SELL trades) | Restrict TC zones immediately; review RCEM mapping |

### 12.2 Rollback Requirements for Future Codex Task

Any FVG_TPB implementation Codex task must include explicit rollback instructions:

1. **Pre-implementation backup:** Create timestamped backups of all modified files before any change
   - `council_mode_types.mqh.bak_YYYYMMDD_HHMMSS`
   - `council_strategies.mqh.bak_YYYYMMDD_HHMMSS`
2. **Rollback trigger conditions:** Any condition from Section 12.1
3. **Rollback procedure:** Restore from backups; recompile; confirm 0 errors; reload EA; verify restored version matches pre-FVG behavior in opportunity ledger
4. **Rollback validation:** Compare post-rollback V1C records to pre-admission baseline; confirm fvg_ fields absent and system behavior unchanged
5. **Documentation:** Rollback event must be logged in PIML with reason and evidence snapshot

---

## 13. Interaction With Current Phase Blockers

**FVG_TPB admission design does not unblock Phase 4A, 4B, or 4C. Stated explicitly.**

| Phase | Current Blocker | FVG_TPB Impact |
|---|---|---|
| Phase 4A (Cross-family CRR) | TPC sparsity is architectural (1.4% TPC co-presence with trend_momentum); option F selected diagnostically; implementation path not yet chosen | NONE — FVG_TPB admission does not change TPC fire rate; does not interact with Phase 4A CRR architecture |
| Phase 4B (Exhaustion veto) | mfi_reversal_assist 0 live entries; veto threshold undesignable without real signal readings | NONE — FVG_TPB is not mfi_reversal_assist; no interaction |
| Phase 4C (Quality soft gate) | Opportunity Ledger below 200-record threshold; gate cannot be activated without sufficient records | NONE — FVG_TPB admission would generate V1C records and eventually help reach the 200-record threshold, but this is a side effect, not a Phase 4C unblock condition |
| RBSR | PLAYBOOK_FORMING; 0 required links satisfied; anchor sweep_reversal RESEARCH_ONLY with E[R]=−0.011R | POSITIVE IF ADMITTED — FVG_TPB as RBSR ALPHA would provide the first positive-E[R] unrestricted alpha evidence in RBSR (E[R]=+0.085R vs SR −0.011R). Would not satisfy GF-6 (CONFIRMATION_PACKET still needed) but would improve anchor quality |
| TPC | PLAYBOOK_FORMING; TPC sparsity architectural; 0 required links satisfied | NONE — FVG_TPB must not interact with TPC |
| VCR | PLAYBOOK_NOT_PRESENT; 0 evidence | NONE — FVG_TPB has no VCR connection |
| Production Candidate | System DEVELOPING; no production status | NONE — FVG_TPB admission does not change system status |
| GF-11 (no micro-test chaining) | Active constraint: default action after any test is architecture build-out | COMPLIANT — this document is architecture build-out, not micro-testing |

**Phase 4C side note:** FVG_TPB's 2.43% trigger rate means it would generate approximately 23 V1C records per day of active market. The 200-record threshold for Phase 4C would be reached faster with FVG_TPB admitted — but this must not be used as a justification for admission. Phase 4C requires 200 records from the existing system, not from an external candidate.

---

## 14. Future Codex Package Outline

**FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 — design outline only, not authorized**

### 14.1 Package Boundaries

| Item | Status |
|---|---|
| Authorized files | council_mode_types.mqh, council_strategies.mqh (new function only), council_mode_runtime.mqh (integration call only) |
| Forbidden files | core_trade_engine.mqh, council_pre_ai_filter.mqh, council_aggregator.mqh, council_ai_governor.mqh, main_ea.mq5, all existing strategy functions |
| Backup requirements | Timestamped .bak of all 3 modified files before first change; backup verified before Codex task proceeds |
| Compile requirements | 0 errors, 0 warnings mandatory; no suppressed warnings |

### 14.2 Decision-Path Isolation Requirements

- Zero read dependency from any council decision layer (aggregator, filter, governor, runtime pipeline) to any new fvg_ V1C field
- New SFVGZone struct instances must NOT be accessible from outside council_strategies.mqh scope (or limited to strategy_runtime.mqh if persistence is needed)
- fvg_hostile_gate_fired field in V1C is write-only from the strategy function; must not be read by aggregator or filter
- Verified by code inspection (grepping for fvg_ field names in aggregator/filter/governor before deployment)

### 14.3 Ledger Fields

New fields at schema version `OL_V1D_FVG_TPB_EXTENSION` (or extend V1C schema with FVG block):
- All 6 required fields from Section 9.1
- All 6 useful fields from Section 9.2 (recommended for initial implementation)
- Optional fields from Section 9.3 (defer unless operator requests)

### 14.4 Runtime Validation Checklist

After EA reload with FVG_TPB admitted:

| Check | Condition | Pass |
|---|---|---|
| Trigger fires | At least 1 FVG_TPB trigger in first 4 hours of active market | YES if ≥1 seen |
| Trigger rate reasonable | trigger_seen / evaluations_seen in range 1–5% | YES if within range |
| V1C records produced | fvg_direction, fvg_gap_low, fvg_gap_high, fvg_regime_context in all FVG records | YES if all present |
| Hostile gate fires | SELL_TREND_DOWN records show fvg_hostile_gate_fired=true | YES if gate active |
| No execution anomaly | No duplicate entries; no gap-zone entry outside certified range | YES if no anomalies |
| No ledger corruption | All fvg_ fields valid JSON types; no null in required fields | YES if clean |
| Decision invariance confirmed | Adding FVG_TPB does not change OTHER strategies' V1C output | YES if confirmed by spot check |
| No runtime instability | EA runs 72h without crash or hung state attributable to FVG zone array | YES if stable |

### 14.5 Adversarial Review Requirement

Before Codex execution, a mandatory adversarial review must:
- Verify no TPC zone routing (FVG_TPB must not appear in TC/BREAKOUT as primary alpha)
- Verify SELL_TREND_DOWN gate is active and tested
- Verify EOC compliance of zone activation timing
- Verify V1C fields are observation-only
- Verify no factory admission lock bypass path exists in the code
- Verify rollback procedure is documented and executable

### 14.6 Rollback Instructions

See Section 12.2. Rollback must be included verbatim in the Codex task specification.

---

## 15. Recommended Decision

### ADMISSION_DESIGN_APPROVED_PENDING_OPERATOR_AUTHORIZATION

**Justification:**

FVG_TPB meets all technical thresholds for admission design approval:

1. **Evidence quality:** ALPHA_TRIGGER_PACKET FORMALLY_ACCEPTABLE. This is the first external candidate to achieve this classification in INEC_LAB_V1. N=2,442 SUFFICIENT (exceeds all existing 17 admitted strategies in per-certification sample size). E[R]=+0.085R is the highest unrestricted positive E[R] in the RBSR space.

2. **Temporal stability:** 1.7pp walk-forward gap (vs FBR's 47.7pp). All 5 months positive. Late sample outperforms early. No performance decay.

3. **Robustness:** Slippage stress (+10pt) leaves WR=42.11% and E[R]=+0.053R positive. Outlier sensitivity negligible (±0.02pp).

4. **Replication fidelity:** PARTIAL_REPLICATION with OHLCV-exact core trigger. No proprietary indicator. Regime proxy is the only gap.

5. **System compatibility:** Fully observable from MT5 OHLCV; EOC compliant design; V1C fields specifiable; no novel gate interaction; LOW starvation risk.

6. **Playbook lane identified:** RBSR provisional or new IMBALANCE_FILL_REVERSAL.

7. **Hostile subset identified and gated:** SELL_TREND_DOWN hostile gate is designed and ready for implementation.

**Remaining blockers (operator decisions):**
- factory_admission_lock must be explicitly lifted for FVG_TPB
- Playbook lane must be selected (RBSR provisional vs new IFR playbook)
- Adversarial review must be completed
- Operator authorization must be issued for FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1

**What this decision does NOT authorize:**
- It does not authorize MT5 implementation
- It does not authorize factory_admission_lock bypass
- It does not authorize strategy registration in PIML
- It does not change system status from DEVELOPING

---

## 16. What Must Not Be Concluded

The following conclusions are **explicitly prohibited** from this design package or any document that cites it:

1. **No MT5 implementation authorized.** FVG_TPB code must not be written until FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 is separately authorized.
2. **No strategy admitted.** FVG_TPB is not registered in the council; council_strategies.mqh is unchanged.
3. **No weight assigned.** vote_weight=0.60–0.80 is a design-intent range only; not an authorized value.
4. **No role assigned.** "SCOUT" is a candidate role designation; no role assignment has been made.
5. **No playbook has runtime authority.** Neither RBSR nor any new IMBALANCE_FILL_REVERSAL playbook is authorized to govern execution.
6. **No production readiness.** System status remains DEVELOPING. FVG_TPB admission, if authorized, would not change this.
7. **No Phase 4 unlocked.** Admission design does not unblock Phase 4A, 4B, or 4C.
8. **No runtime policy activated.** SELL_TREND_DOWN hostile gate and location filters are design-intent; not runtime-active.
9. **No gate/score/CRR/DSN modification.** Zero changes to existing decision pipeline.
10. **No PIML update authorized.** PIML is not modified by this document.
11. **No factory_admission_lock bypass.** factory_admission_lock=ACTIVE throughout this document.
12. **No co-presence evidence claimed.** FVG_TPB CONFIRMATION_PACKET is NOT_TESTABLE; no co-presence lift is claimed or implied.
13. **No weight increase for existing strategies.** This package creates no authority for changing any existing strategy's weight.
14. **ALPHA_TRIGGER_PACKET acceptance does not equal production readiness.** Evidence meeting thresholds is a necessary, not sufficient, condition for admission.

---

## 17. Recommended Next Large Package

### IMBALANCE_FILL_REVERSAL_PLAYBOOK_DESIGN_PACKAGE_V1

**Recommended as the next large package.**

**Justification:**

FVG_TPB's evidence profile is too mechanically distinct and too strong to be force-fitted into RBSR without a principled playbook design. The counter-trend edge inversion (BUY_TREND_DOWN > BUY_TREND_UP; SELL_TREND_DOWN hostile) defines a new causal archetype — imbalance fill / displacement reversal — that is not represented by any existing playbook.

Designing IMBALANCE_FILL_REVERSAL_PLAYBOOK_DESIGN_PACKAGE_V1 before implementing FVG_TPB achieves:

1. **Clean architecture:** FVG_TPB is admitted as the PLAYBOOK_ANCHOR of a new playbook, not as a misclassified RBSR supplementary alpha.
2. **Causal chain definition:** The new playbook defines what a CONFIRMATION strategy would look like (e.g., M5 candle structure at gap zone; momentum indicator reading at entry). This prevents the playbook from remaining perpetually at PLAYBOOK_NOT_PRESENT.
3. **Future candidate pipeline:** The IMBALANCE_FILL_REVERSAL playbook creates a receptacle for future external candidates in the same archetype (e.g., fvg_sweep_rev, which was not selected in this round but targets an adjacent mechanism).
4. **Prevents RBSR dilution:** RBSR currently has 0 formally accepted packets. Adding FVG_TPB as a "provisional" RBSR alpha could confuse the RBSR evidence picture and create registry ambiguity.
5. **No MT5 changes required:** A playbook design package is documentation-only, consistent with the current work philosophy. No source changes, no compile, no reload.

**Alternative packages considered:**

| Option | Reason Not Selected |
|---|---|
| FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 (Option B) | Premature — playbook lane not yet selected; factory_admission_lock not yet lifted |
| ADDITIONAL_INEC_REPLICATION_PACKAGE_V1 (Option C) | Not needed — N=2,442 is SUFFICIENT; temporal stability confirmed; slippage robustness confirmed; additional INEC runs would not materially change the evidence |
| POST_CLEANUP_RUNTIME_VALIDATION_AND_ACCUMULATION_PACKAGE_V1 (Option D) | Valid parallel work but not the "next large package" — runtime validation is ongoing continuous work; the IFR playbook design is a discrete high-value deliverable that creates the architectural precondition for FVG_TPB admission |

**Parallel work:** Option D (runtime accumulation) should continue in parallel. Evidence continues to accumulate whether or not the IFR playbook is being designed. These are not mutually exclusive.

---

## 18. Completion Checklist

| Item | Status |
|---|---|
| Reference 1: IRREW_NAUTILUS_EVIDENCE_CERTIFICATION_LAB_V1.md | REVIEWED (file exists; lab methodology incorporated) |
| Reference 2: nautilus_lab/system_lab/README.md | SOURCE_READ_REQUIRED (file not directly read; lab structure known from related docs) |
| Reference 3: registry_snapshot_V1.json | REVIEWED — all 17 strategies and 3 playbooks read |
| Reference 4: PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md | REVIEWED — full registry, packet taxonomy, 3 playbook states |
| Reference 5: ARCHITECTURE_BUILD_PACKAGE_V1.md | REVIEWED — §1-3 read; 5 packages known; evidence layer inventoried |
| Reference 6: IMPLEMENTATION_SPEC_PACKAGE_V1.md | REVIEWED — §1-5 read; V1C schema OL_V1C_PLAYBOOK_SHADOW confirmed live |
| Reference 7: SHADOW_POLICY_CANDIDATE_DESIGN_PACKAGE_V1.md | REVIEWED — V1C live, K1/K2/K3 cleanup compiled, 28 V1C records reviewed |
| Reference 8: V1C_CLEANUP_PACKAGE_V1_REPORT.md | ARTIFACT_FOUND (file exists; content not fully read — referenced via SHADOW doc) |
| Reference 9: FVG discovery report | REVIEWED — authored in this lab; all 18 fields per candidate, selection rationale |
| Reference 10: certification_external_fvg_tpb_xauusd_v1.md | REVIEWED — 16-section cert; all variant results |
| Reference 11: FVG JSON artifacts (metrics, packet, playbook, system) | REVIEWED — all 4 files read; key fields incorporated |
| Reference 12: RBSR certifications (sweep, bollinger, mfi, mrb, fbr, ref) | REVIEWED — registry entries for all; MRB cert read directly (ACCEPTED_ALPHA_TRIGGER, N=656, WR=42.68%) |
| Reference 13: TPC certifications (TM, TPC, BDM, LHR, MSR) | REVIEWED — registry entries and master strategy table for all |
| Evidence summarized | YES — Section 2 with classification labels |
| Playbook placement decided | YES — IFR recommended; RBSR provisional; TPC rejected |
| Packet role decided | YES — ALPHA_TRIGGER primary; LOCATION secondary |
| MT5 implementation boundary defined | YES — Section 7 |
| EOC assessed | YES — Section 8; COMPLIANT |
| V1C observability assessed | YES — Section 9; 6 required + 6 useful + 4 optional |
| Risk register complete | YES — Section 10; 18 risks |
| Admission criteria defined | YES — Section 11; 13 criteria |
| Rejection/rollback rules defined | YES — Section 12 |
| Phase blocker interaction assessed | YES — Section 13; 4A/4B/4C all unaffected |
| Future Codex outline defined | YES — Section 14 |
| Recommended decision issued | YES — ADMISSION_DESIGN_APPROVED_PENDING_OPERATOR_AUTHORIZATION |
| Forbidden conclusions listed | YES — Section 16; 14 items |
| Next large package recommended | YES — IMBALANCE_FILL_REVERSAL_PLAYBOOK_DESIGN_PACKAGE_V1 |
| No MT5 source modified | CONFIRMED |
| No runtime file modified | CONFIRMED |
| No compile | CONFIRMED |
| No reload | CONFIRMED |
| No PIML update | CONFIRMED |
| factory_admission_lock status | ACTIVE — unchanged |
| Package complete | YES |

---

## Package Footer

```
PACKAGE_ID:               FVG_TPB_MT5_ADMISSION_DESIGN_PACKAGE_V1
DATE:                     2026-05-09
PRECEDES:                 FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 (not yet authorized)
STRATEGY_ID:              external_fvg_tpb
CERT_REFERENCE:           EXTERNAL_FVG_STRATEGY_DISCOVERY_AND_INEC_CERTIFICATION_PACKAGE_V1
ADMISSION_DECISION:       ADMISSION_DESIGN_APPROVED_PENDING_OPERATOR_AUTHORIZATION
PLAYBOOK_RECOMMENDATION:  IMBALANCE_FILL_REVERSAL (new) — RBSR provisional fallback
PACKET_ROLE_PRIMARY:      ALPHA_TRIGGER_PACKET (FORMALLY_ACCEPTABLE)
PACKET_ROLE_SECONDARY:    LOCATION_PACKET (APPLICABLE_CANDIDATE CONFIRMED)
TPC_LANE:                 EXPLICITLY_REJECTED
MT5_MODIFIED:             NO
RUNTIME_MODIFIED:         NO
PIML_MODIFIED:            NO
COMPILE_RUN:              NO
RELOAD_RUN:               NO
FACTORY_ADMISSION_LOCK:   ACTIVE — unchanged
RUNTIME_AUTHORITY:        NONE
SYSTEM_STATUS:            DEVELOPING — unchanged
NEXT_LARGE_PACKAGE:       IMBALANCE_FILL_REVERSAL_PLAYBOOK_DESIGN_PACKAGE_V1
GOVERNANCE_COMPLIANT:     YES — all GF-1 through GF-14 satisfied
```
