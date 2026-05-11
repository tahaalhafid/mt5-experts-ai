# IMBALANCE_FILL_REVERSAL_PLAYBOOK_DESIGN_PACKAGE_V1

**Package type:** PLAYBOOK_DESIGN — Architecture definition and evidence mapping
**Date:** 2026-05-09
**Motivated by:** FVG_TPB_MT5_ADMISSION_DESIGN_PACKAGE_V1 (complete)
**Authority:** EVIDENCE_ONLY — No MT5 source change. No runtime change. No compile. No reload.
**Governed by:** PROJECT_INTELLIGENCE_MEMORY_LAYER.md (PIML) — sole authoritative project memory
**Evidence source:** INEC_LAB_V1 (IRREW_NAUTILUS_EVIDENCE_CERTIFICATION_LAB_V1)
**System status:** DEVELOPING — unchanged
**Runtime authority:** V1 (MT5 EA) — permanent; not transferred to any document, playbook definition, or design package

---

## GOVERNANCE FIREWALL

This package does NOT authorize:

- MT5 source changes of any kind
- FVG_TPB implementation in MT5
- Strategy admission or injection
- factory_admission_lock lift
- Weight changes (vote_weight, effective_weight, role multiplier)
- Role changes (SCOUT, CONFIRM, TREND_JUDGE, EXHAUSTION_JUDGE, GUARD)
- Gate changes (CRR, DSN, DOMINANT_SIDE)
- Score changes (council_quality, consensus thresholds, conflict thresholds)
- council_quality changes
- HIGH_CONVICTION condition changes
- CRR / DSN / DOMINANT_SIDE logic changes
- Risk, execution, stop/target geometry changes
- V1 permission logic changes
- Production readiness claims
- Playbook runtime authority of any kind

**Playbook design is not implementation.**
**INEC certification is not runtime authority.**
**ALPHA_TRIGGER_PACKET acceptance is not strategy admission.**
**IFR_VALID does not mean trade. IFR_CONTRADICTED does not mean block.**
**Playbook state is evidence-layer attribution unless explicitly authorized otherwise by operator.**
**MT5 remains the sole runtime authority.**
**V1 remains the sole permission authority.**
**Execution geometry remains the sole survivability authority.**

---

## 1. Executive Summary

This package defines the **IMBALANCE_FILL_REVERSAL (IFR)** playbook as a new design candidate within the IRREW/PCEA architecture.

IFR is proposed as a distinct playbook lane, separate from RBSR and TPC, motivated by a specific empirical finding: FVG_TPB's counter-trend edge inversion (BUY_TREND_DOWN = EDGE_SUPPORTED at WR=47.76%; SELL_TREND_DOWN = EDGE_NOT_CONFIRMED at E[R]=−0.041R). This inversion is mechanically interpretable and structurally incompatible with both the sweep/liquidity mechanism that anchors RBSR and the trend-continuation mechanism that anchors TPC.

**Five core facts entering this design:**

1. FVG_TPB is the strongest certified external candidate in INEC_LAB_V1: N=2,442 SUFFICIENT, WR=43.41%, E[R]=+0.085R, ALPHA_TRIGGER_PACKET FORMALLY_ACCEPTABLE, 5/5 months positive, 1.7pp walk-forward stability gap.
2. FVG_TPB's best edge is counter-trend: BUY in TREND_DOWN and SELL in RANGE_NEUTRAL — both EDGE_SUPPORTED subsets, both exceeding LOCATION_PACKET thresholds.
3. FVG_TPB's worst edge is exactly the TPC core use case: SELL in TREND_DOWN is EDGE_NOT_CONFIRMED (E[R]=−0.041R). TPC lane is rejected by direct counter-evidence.
4. RBSR (sweep/liquidity mechanism) is a distinct structural precondition from IFR (imbalance gap fill). Provisional RBSR placement is workable but creates scope dilution risk.
5. IFR is a **DESIGN_CANDIDATE_ONLY** — no implementation is authorized, no MT5 change is made, and no factory lock is lifted by this package.

**Current IFR state: IFR_FORMING** — one ALPHA_TRIGGER certified; no confirmed CONFIRMATION_PACKET; no live entries.

**System status: DEVELOPING — unchanged.**

---

## 2. Evidence Basis

### 2.1 FVG_TPB Certification Metrics

| Metric | Value | Classification |
|---|---|---|
| M1 bar count | 100,466 | Verified |
| M5 bar count | 34,652 | Verified |
| Total FVG events | 6,675 (3,613 BUY; 3,062 SELL) | Verified |
| FVG-to-trigger ratio | 36.6% | Verified |
| Variant A N | 2,442 | SUFFICIENT |
| Variant A WR | 43.41% | +3.41pp above breakeven |
| Variant A E[R] | +0.0852R | Positive |
| Variant A PF | 1.1505 | Positive |
| Max consecutive losses | 12 | Verified |
| Avg MAE | 0.9564R | Favorable (< MFE) |
| Avg MFE | 1.1108R | Verified |
| Avg bars held | 7.7 | Verified |
| Trigger rate | 2.43% of M1 bars | ADEQUATE_DENSITY |
| Walk-forward gap (early/late) | 1.7pp (late outperforms) | STABLE |
| All months positive E[R] | YES (5/5) | STABLE |
| Monthly WR range | 42.2% – 44.6% | 2.4pp |
| Slippage stress +10pt WR | 42.11% | ROBUST — above breakeven |
| Slippage stress +10pt E[R] | +0.0528R | ROBUST — positive |
| Outlier sensitivity | ±0.02pp WR on ±3 trade exclusion | NEGLIGIBLE |

### 2.2 Best Subsets (EDGE_SUPPORTED)

| Subset | N | WR | E[R] | PF | WR lift | E[R] lift | Label |
|---|---|---|---|---|---|---|---|
| BUY_TREND_DOWN | 335 | 47.76% | +0.1940R | 1.3714 | +4.35pp | +0.109R | EDGE_SUPPORTED |
| SELL_RANGE_NEUTRAL | 425 | 47.06% | +0.1765R | 1.3333 | +3.65pp | +0.091R | EDGE_SUPPORTED |

Both subsets exceed LOCATION_PACKET dual thresholds: WR lift ≥ +2pp AND E[R] lift ≥ +0.04R.

### 2.3 Hostile Subset

| Subset | N | WR | E[R] | PF | Label |
|---|---|---|---|---|---|
| SELL_TREND_DOWN | 417 | 38.37% | −0.0408R | 0.9339 | EDGE_NOT_CONFIRMED |

WR=38.37% is above 35% formal rejection threshold. SELL_TREND_DOWN is hostile but not formally rejected. E[R]=−0.041R is negative, confirming hostile status.

### 2.4 Data Provenance

| Field | Value |
|---|---|
| M1 data identity | XAUUSD_BROKER_DATA (MetaQuotes terminal export) |
| M5 data identity | XAUUSD_BROKER_DATA |
| M1 simulation range | 2026-01-23 to 2026-05-07 |
| M5 warm-up start | 2025-11-07 (ATR14 initialization) |
| Replication class | PARTIAL_REPLICATION |

**Important:** FVG_TPB was certified using XAUUSD broker data directly — not GC=F futures proxy used in earlier INEC_LAB_V1 certifications (bollinger_reclaim, etc.). This is a superior data provenance for FVG_TPB vs. those earlier certs.

### 2.5 External Source Caveat

**Source classification: UNVERIFIED_EXTERNAL_SOURCE.** The FVG mechanism is derived from publicly documented ICT/SMC methodology (knowledge cutoff August 2025). The concept origin is not attributed to a specific live trading system. The certification trigger logic is OHLCV-deterministic and fully replicable — the "external" classification refers to concept origin, not to data quality or replication validity.

### 2.6 Admission Design Decision

Per FVG_TPB_MT5_ADMISSION_DESIGN_PACKAGE_V1: **ADMISSION_DESIGN_APPROVED_PENDING_OPERATOR_AUTHORIZATION.**

Three remaining blockers:
1. Playbook lane selection (this package resolves the design side)
2. factory_admission_lock lift (operator decision)
3. Operator authorization for implementation (operator decision)

### 2.7 Why TPC Was Rejected

**Classification: STRONGLY_SUPPORTED**

SELL_TREND_DOWN (E[R]=−0.041R, WR=38.37%) is the exact core TPC SELL use case. TPC requires direction-aligned signals in TREND zones. FVG_TPB's worst-performing subset is precisely where TPC needs confirmation most. The counter-evidence is direct, verified, and mechanically interpretable.

Additionally: BUY_TREND_DOWN (the best FVG_TPB subset) is counter-trend to TC zone logic. A strategy whose best edge is counter-trend to the anchor's direction cannot serve as a TPC CONFIRM without contradicting TPC's causal hypothesis.

TPC lane: **TPC_PLACEMENT_REJECTED.**

### 2.8 Why RBSR Is Only Fallback

**Classification: STRONGLY_SUPPORTED**

RBSR is anchored on sweep-and-reclaim: price sweeps a liquidity level (beyond a swing high/low), then reverses. The causal object is a swept liquidity pool. sweep_reversal's trigger is a bearish/bullish rejection candle at a sweep extreme.

FVG_TPB is anchored on imbalance-fill mitigation: price creates a 3-candle gap (rapid impulsive move), then retraces into the unfilled gap zone. The causal object is a price imbalance region.

These are structurally orthogonal preconditions. A sweep does not always create a FVG; a FVG does not always follow a sweep. Co-presence data does not exist. Placing FVG_TPB in RBSR makes the playbook's causal chain ambiguous: RBSR can no longer claim "reversal from swept liquidity" as its exclusive mechanism when FVG_TPB fires on imbalance fills without any sweep.

Furthermore, RBSR has 0 required-link packets satisfied. sweep_reversal holds RESEARCH_ONLY (E[R]=−0.011R unrestricted). Adding FVG_TPB as an RBSR ALPHA does not advance the RBSR causal chain — it adds a second independent alpha with a different mechanism, diluting chain clarity without confirming the sweep-reversal hypothesis.

RBSR provisional placement remains workable if the operator needs to admit FVG_TPB before IFR playbook design is formalized, but it is explicitly the inferior architectural choice.

RBSR lane: **RBSR_PROVISIONAL_FALLBACK_ONLY.**

### 2.9 Evidence Classification Summary

| Claim | Classification |
|---|---|
| FVG_TPB Variant A WR=43.41%, E[R]=+0.085R, N=2,442 | Verified |
| BUY_TREND_DOWN WR=47.76%, E[R]=+0.194R — EDGE_SUPPORTED | Verified |
| SELL_RANGE_NEUTRAL WR=47.06%, E[R]=+0.176R — EDGE_SUPPORTED | Verified |
| SELL_TREND_DOWN E[R]=−0.041R — hostile | Verified |
| Temporal stability (1.7pp walk-forward gap; 5/5 months positive) | Verified |
| Slippage robustness (WR=42.11% at +10pt) | Verified |
| IFR playbook concept — mechanically distinct from RBSR/TPC | Strongly supported |
| mean_reversion_bounce as IFR CONFIRM candidate | Plausible but unverified |
| sweep_reversal co-presence with FVG_TPB | Insufficient — no data |
| mfi_reversal_assist as IFR failure-mode guard | Plausible but unverified |
| fake_break_reversal co-presence relevance | Insufficient — N=19 |
| IFR causal chain completion timeline | Plausible but unverified |
| Live XAUUSD trigger rate matching INEC 2.43% | Insufficient — 0 live entries |

---

## 3. Playbook Identity

### 3.1 Identity Fields

| Field | Value |
|---|---|
| playbook_id | IMBALANCE_FILL_REVERSAL |
| Short code | IFR |
| Version | V1 (design candidate) |
| Design status | DESIGN_CANDIDATE_ONLY |
| Runtime authority status | NONE |
| Factory lock status | N/A — playbook design requires no factory lock; lock applies to strategy admission |
| Current playbook state | IFR_FORMING (ALPHA_TRIGGER certified; no CONFIRMATION_PACKET; no live entries) |

### 3.2 Family Domain

| Field | Value |
|---|---|
| Primary family | IMBALANCE_REVERSAL |
| Secondary family | LIQUIDITY_EXHAUSTION |
| Tertiary family | RECLAIM (range-mean reversion sub-type) |
| Family distinction from RBSR | RBSR family = LIQUIDITY_REVERSAL (sweep/reclaim); IFR family = IMBALANCE_REVERSAL (gap fill/exhaustion) |
| Family distinction from TPC | TPC family = TREND_CONTINUATION; IFR family = counter-trend or range reclaim from imbalance zone |

### 3.3 Primary Thesis

An impulsive price move (bullish or bearish) creates a Fair Value Gap (FVG) — a 3-candle imbalance where price skipped over a region, leaving an unfilled zone. When price retraces into this gap zone (mitigation), one of two things occurs:

1. **Displacement exhaustion (BUY_TREND_DOWN pattern):** The bullish FVG was created by a bearish impulse. Price returning to the gap zone marks exhaustion of the downside move — the gap is the last location where bearish momentum existed, and mitigation signals that momentum has stalled. BUY entry into the gap targets the reversal upward.

2. **Range mean-reclaim (SELL_RANGE_NEUTRAL pattern):** The bearish FVG was created by a bearish extension in a range context. Price returning to the gap zone marks mean-reversion from the over-extended state. SELL entry into the gap targets continuation of the reclaim toward the range mean.

In both cases, the **causal object is the imbalance zone itself**, not a swept liquidity level (RBSR) or a trend-direction alignment (TPC). The trade hypothesis is that imbalance zones act as institutional demand/supply regions — price gravitates toward them for equilibration, and the equilibration process defines the direction.

### 3.4 IFR vs. Related Hypotheses

| Distinction | IFR | RBSR | TPC |
|---|---|---|---|
| What triggers a signal? | FVG (3-candle price gap) | Sweep of swing high/low | EMA momentum alignment |
| What is the causal object? | Imbalance zone | Swept liquidity pool | Trend direction |
| What market state is required? | Any regime with displacement | REV/RMR zone with swept level | TC/BREAKOUT zone with trend |
| What does "reversal" mean? | Mitigation from imbalance = exhaustion/fill | Rejection from swept level = fake breakout | Not applicable — continuation |
| Primary edge direction | Counter-trend (BUY_TD) + range-reclaim (SELL_RN) | Counter-sweep direction | Trend-aligned |

---

## 4. Why Not TPC

### 4.1 Direct Counter-Evidence

The TPC causal chain requires:
1. TC zone confirms established trend
2. trend_momentum fires direction-aligned signal (ALPHA LEAD)
3. trend_pullback_cont_v1 detects trend-aligned pullback (CONFIRM)
4. Supporting CONFIRM strategies add confirmation (same direction as trend)

FVG_TPB's performance is exactly inverted relative to this requirement:

| Configuration | E[R] | Status |
|---|---|---|
| SELL_TREND_DOWN (TPC core SELL case) | −0.041R | EDGE_NOT_CONFIRMED — hostile |
| BUY_TREND_DOWN (counter-trend to TC logic) | +0.194R | EDGE_SUPPORTED — strongest subset |

**The strategy's best edge is where TPC would say "do not trade."**
**The strategy's worst edge is where TPC would say "trade here."**

This is not a marginal mismatch. It is a structural contradiction between FVG_TPB's evidence and TPC's causal hypothesis.

### 4.2 TPC Architecture Mismatch

TPC already has an architectural sparsity problem: trend_pullback_cont_v1 fires in only 1.4% of trend_momentum trigger bars (confirmed live — TPC trigger_seen=0 in first V1C window). Phase 4A (cross-family CRR) is BLOCKED. Adding FVG_TPB to TPC as an additional ALPHA would create:
- A second alpha with no TPC confirmer (CRR still fails for FVG_TPB)
- A signal that fires in hostile SELL_TREND_DOWN context 17% of the time (417/2,442 triggers)
- Architectural confusion between the "trend continuation" causal chain and FVG's "imbalance fill/reversal" mechanism

### 4.3 TPC Placement Verdict

**TPC_PLACEMENT_REJECTED**

Rationale:
- Direct counter-evidence in core TPC SELL use case (SELL_TREND_DOWN E[R]=−0.041R)
- Counter-trend dominance (BUY_TREND_DOWN > BUY_TREND_UP) contradicts TPC's direction-alignment requirement
- TPC architectural problems (sparsity, Phase 4A blockage) must not be addressed by importing a mechanically incompatible strategy
- TPC lane is explicitly prohibited for any future FVG_TPB implementation

---

## 5. Why Not Pure RBSR

### 5.1 Mechanism Distinction

| Mechanism Attribute | sweep_reversal (RBSR anchor) | FVG_TPB (IFR candidate) |
|---|---|---|
| Trigger event | Bearish/bullish rejection at swing extreme | M1 close enters FVG gap zone |
| Causal object | Swept liquidity pool (stops above swing high/below swing low) | Price imbalance region (3-candle gap) |
| Structural precondition | A prior swing high/low must exist and be swept | A 3-candle impulse gap must form |
| Entry mechanism | Rejection candle pattern at sweep | Close within gap bounds |
| Dependency | Requires M5 range bounds (iHighest/iLowest) | Requires only M5 OHLCV gap arithmetic |
| Regime specificity | REV/RMR zone contexts | Cross-regime (all three M5 regimes fire) |
| Best performance | Counter-trend sweeps (E[R]=+0.012R — RESEARCH_ONLY) | Counter-trend BUY in TREND_DOWN (E[R]=+0.194R — EDGE_SUPPORTED) |

The mechanisms may fire simultaneously in some market conditions (a sweep followed by a FVG, or a FVG at a sweep level), but they are not definitionally linked. Co-presence data does not exist. RBSR placement would claim a causal connection that has not been tested.

### 5.2 RBSR Chain Impact

RBSR currently has:
- sweep_reversal: RESEARCH_ONLY, E[R]=−0.011R unrestricted (0 formal packets)
- bollinger_reclaim: REJECTED as CONFIRM (E[R]=−0.018R in RANGE era; gate degrades outcomes)
- mfi_reversal_assist: DATA_INSUFFICIENT (2 entries; below minimum threshold)
- mean_reversion_bounce: ACCEPTED_ALPHA_TRIGGER per 2026-05-09 cert (WR=42.68%, N=656) — supports RMR zones independently
- range_edge_fade: 0 formal packets; E[R]=−0.038R unrestricted
- fake_break_reversal: DATA_INSUFFICIENT (N=19)

**RBSR has 0 required-link packets satisfied.** Adding FVG_TPB as a second RBSR ALPHA with a different mechanism does not satisfy any of RBSR's required links. The required links are:
1. sweep_reversal_anchor_certified (anchor must achieve ALPHA_TRIGGER formal status)
2. bollinger_reclaim_confirmation_certified (CONFIRM packet required)
3. mfi_reversal_failure_mode_certified (FAILURE_MODE packet required)

FVG_TPB satisfies none of these. It would add evidence richness to RBSR without advancing the specific chain proofs RBSR requires. This is scope dilution — evidence that improves the overall RBSR-zone picture but does not validate the RBSR causal hypothesis.

### 5.3 RBSR Verdict

**RBSR_PROVISIONAL_FALLBACK_ONLY**

If the operator decides to admit FVG_TPB before IFR design is completed, RBSR placement is workable. The strategy would fire as an independent ALPHA alongside sweep_reversal, contributing to consensus without contaminating the chain analysis. This is a pragmatic option, not the architecturally correct one.

IFR is the preferred lane because:
1. It creates a clean, non-overlapping causal definition for FVG-specific imbalance evidence
2. It prevents future confusion between sweep-anchored RBSR evidence and gap-anchored IFR evidence
3. It allows a separate confirmation chain design that does not assume sweep_reversal co-presence

---

## 6. IFR Causal Chain

The IFR causal chain consists of 7 links. Links 1–5 are the core execution path; Link 6 is the hostile filter; Link 7 is the geometry anchor. For playbook VALID status, links 1–5 must be certified; links 6 and 7 are prerequisites for production deployment.

---

### Link 1 — Context Recognition

| Field | Value |
|---|---|
| link_id | IFR-L1 |
| Purpose | Identify regime/zone context where imbalance-fill reversal is plausible |
| Evidence source | FVG_TPB Variant C direction × regime breakdown (INEC certification) |
| Present condition | M5 regime is TREND_DOWN (BUY entries) or RANGE_NEUTRAL (SELL entries) — highest-edge contexts |
| Supporting condition | M5 regime is TREND_UP (BUY entries — EDGE_WEAK_BUT_RECOVERABLE, not edge-supported) |
| Hostile condition | M5 regime is TREND_DOWN + direction = SELL — hostile subset |
| V1C field needed | fvg_regime_context, fvg_subset_classification |
| Packet type | LOCATION_PACKET (regime context gating) |
| Status | APPLICABLE_CANDIDATE CONFIRMED (BUY_TD and SRN both exceed +2pp WR + +0.04R E[R] thresholds) |
| Evidence classification | Verified |
| Required / Supporting / Optional | REQUIRED for LOCATION_PACKET; SUPPORTING for ALPHA_TRIGGER |

---

### Link 2 — Displacement / Imbalance Creation

| Field | Value |
|---|---|
| link_id | IFR-L2 |
| Purpose | A 3-candle price gap (FVG) forms above minimum size threshold, creating the imbalance zone |
| Evidence source | FVG detection logic; 6,675 total events across 100,466 M1 bars; 36.6% result in triggers |
| Present condition | M5 bar[j]: `low[j] > high[j-2]` (bullish) or `high[j] < low[j-2]` (bearish); gap_size >= ATR14_M5 × 0.05 |
| Missing condition | No FVG formed; or FVG too small (gap_size < 0.05 × ATR) |
| Contradicted condition | Not applicable — mechanical definition, cannot be contradicted |
| V1C field needed | fvg_gap_low, fvg_gap_high, fvg_size_atr, fvg_direction |
| Packet type | ALPHA_TRIGGER_PACKET (FVG creation is the trigger precondition) |
| Status | VERIFIED — deterministic from OHLCV; core certified rule |
| Evidence classification | Verified |
| Required / Supporting / Optional | REQUIRED — no FVG = no IFR trigger |

---

### Link 3 — Gap Persistence

| Field | Value |
|---|---|
| link_id | IFR-L3 |
| Purpose | FVG remains active (not expired, not invalidated by price closing through far side) |
| Evidence source | Expiry: 4-hour window (48 M5 bars); invalidation: M1 close through gap boundary. 36.6% FVG-to-trigger ratio implies 63.4% expire/invalidate/occupied. |
| Present condition | FVG age < 4 hours (expiry); no M1 close through fvg_lo (BUY) or fvg_hi (SELL) |
| Missing condition | FVG has expired before price returns; FVG invalidated (price closed through far side) |
| Contradicted condition | FVG invalidated = price already rejected the imbalance zone from the far side; causal hypothesis weakened |
| V1C field needed | fvg_age_bars, fvg_expired, fvg_invalidated, fvg_active_zone_count |
| Packet type | TIMING_PACKET (age at trigger may correlate with edge quality) |
| Status | CERTIFIED for expiry/invalidation rules; UNTESTED for age-vs-performance correlation |
| Evidence classification | Verified (rules); Plausible but unverified (age timing analysis) |
| Required / Supporting / Optional | REQUIRED — no active FVG = no trigger; TIMING analysis optional future work |

---

### Link 4 — Mitigation / Fill Entry

| Field | Value |
|---|---|
| link_id | IFR-L4 |
| Purpose | Price retraces into the gap zone; entry taken at first M1 close within [fvg_lo, fvg_hi] |
| Evidence source | run_simulation() in cert script; N=2,442 trades from entry rule |
| Present condition | M1 close in [fvg_lo, fvg_hi] for first active non-expired, non-invalidated FVG |
| Missing condition | No M1 bar enters the gap zone before expiry |
| Contradicted condition | Not applicable — entry rule is mechanical |
| V1C field needed | fvg_mitigation_pct (how deep into gap the entry was), fvg_entry_reason |
| Packet type | ALPHA_TRIGGER_PACKET (entry event) |
| Status | CERTIFIED — exact rule produces N=2,442 |
| Evidence classification | Verified |
| Required / Supporting / Optional | REQUIRED — this is the core trigger event |

---

### Link 5 — Reversal Acceptance (Execution)

| Field | Value |
|---|---|
| link_id | IFR-L5 |
| Purpose | Trade is executed in FVG direction; price must reach TP before SL |
| Evidence source | Trade outcomes: WR=43.41% baseline; BUY_TD=47.76%; SRN=47.06% |
| Present condition | WR > 40% (above breakeven); E[R] > 0 |
| Missing condition | WR ≤ 40% (no positive expectancy) |
| Contradicted condition | WR < 35% (REJECTION threshold) — not currently met in any tested subset except not-tested extreme hostiles |
| V1C field needed | (standard result/r_multiple from existing V1C) |
| Packet type | ALPHA_TRIGGER_PACKET (outcome metric) |
| Status | CERTIFIED — Variant A WR=43.41% > 40%; E[R]=+0.085R > 0 |
| Evidence classification | Verified |
| Required / Supporting / Optional | REQUIRED — primary acceptance criterion |

---

### Link 6 — Hostile Context Filter

| Field | Value |
|---|---|
| link_id | IFR-L6 |
| Purpose | Explicitly suppress SELL_TREND_DOWN signals; protect against the primary hostile subset |
| Evidence source | SELL_TREND_DOWN: N=417, WR=38.37%, E[R]=−0.041R (INEC certification Variant C) |
| Present condition | SELL entry AND regime = TREND_DOWN → suppressed |
| Missing condition | Gate not implemented → SELL_TREND_DOWN trades execute at E[R]=−0.041R |
| Contradicted condition | Not applicable — hostile subset is empirically verified |
| V1C field needed | fvg_hostile_gate_fired (bool) |
| Packet type | FAILURE_MODE_PACKET (candidate — hostile combination, E[R] negative) |
| Status | FAILURE_MODE_CANDIDATE — E[R]=−0.041R < 0 meets negative criterion, WR=38.37% above 35% threshold so not formally REJECTED; gate is design-intent, not formalized FAILURE_MODE_PACKET (requires: WR degradation ≥ −3pp OR E[R] ≥ −0.06R vs baseline) |
| Evidence classification | Verified (the hostile result itself); Plausible but unverified (whether gate improves live performance) |
| Required / Supporting / Optional | REQUIRED at implementation (hostile gate mandatory) |
| Misuse risk | Treating SELL_TREND_DOWN as globally rejected (WR=38.37% > 35% threshold — hostile not rejected) |

**FAILURE_MODE_PACKET formal assessment for SELL_TREND_DOWN:**
- E[R] degradation: −0.041R vs baseline −0.085R = −0.041R − (−0.085R) ... wait, E[R] is the absolute value for the subset.
- Required: E[R] ≤ −0.06R OR WR degradation ≥ −3pp vs baseline
- Actual: E[R] = −0.041R (negative, below 0, but above −0.06R threshold)
- WR degradation: 38.37% vs 43.41% baseline = −5.04pp degradation ≥ −3pp threshold — **MEETS WR DEGRADATION CRITERION**
- **Re-assessment: SELL_TREND_DOWN may qualify as FAILURE_MODE_PACKET** under WR degradation ≥ −3pp criterion (−5.04pp). This requires formal packet testing against baseline, not standalone E[R] alone. Upgraded status: FAILURE_MODE_PACKET CANDIDATE STRONG.

---

### Link 7 — Execution Geometry

| Field | Value |
|---|---|
| link_id | IFR-L7 |
| Purpose | Stop distance and target model are structurally survivable at verified cost model |
| Evidence source | Cost model: spread=10pt, slippage=2pt, stop=ATR14(M1)×1.20, RR=1.50, breakeven WR=40.0% |
| Present condition | Actual WR ≥ 40% (verified); slippage stress WR ≥ 40% (verified: 42.11% under +10pt) |
| Missing condition | If live broker spread regularly exceeds ~22pt total friction, E[R] would approach zero |
| Contradicted condition | If live avg stop < ATR×1.20 (premature stop-outs inflate apparent losses) |
| V1C field needed | (standard stop/entry/exit fields from existing V1C) |
| Packet type | ALPHA_TRIGGER_PACKET (geometry component) |
| Status | CERTIFIED — survivable at base and +10pt stress |
| Evidence classification | Verified |
| Required / Supporting / Optional | REQUIRED — geometry must be preserved in implementation |

---

## 7. IFR Evidence Packet Map

### A. ALPHA_TRIGGER_PACKET

| Field | Value |
|---|---|
| Strategy | FVG_TPB |
| Role in IFR | PRIMARY ALPHA TRIGGER — playbook anchor |
| Current evidence | WR=43.41%, E[R]=+0.085R, N=2,442 SUFFICIENT |
| Acceptance rule | WR ≥ 40% OR E[R] > 0 with N ≥ 50; no geometric artifact |
| Rejection rule | E[R] negative in all tested conditions with adequate N |
| Current verdict | FORMALLY_ACCEPTABLE — first external candidate to achieve this in INEC_LAB_V1 |
| Starvation risk | LOW — trigger rate 2.43%; ~23 triggers per active trading day estimated |
| Misuse risk | HIGH — must not be used as TPC ALPHA; must not be used as CRR CONFIRM gate |
| Implementation path | FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 (not yet authorized) |

---

### B. LOCATION_PACKET

| Field | Value |
|---|---|
| Strategy | FVG_TPB — regime subset classification |
| Role in IFR | LOCATION MODIFIER — identifies premium and hostile contexts |
| Subsets | BUY_TREND_DOWN: +4.35pp WR, +0.109R E[R] above baseline; SELL_RANGE_NEUTRAL: +3.65pp WR, +0.091R E[R] |
| Acceptance rule | Gated WR lift ≥ +2pp OR gated E[R] lift ≥ +0.04R vs baseline |
| Rejection rule | Gating degrades vs baseline; or co-presence rate > 80% (ubiquitous) |
| Current verdict | APPLICABLE_CANDIDATE CONFIRMED — both premium subsets meet dual thresholds |
| Starvation risk | LOW for gated-only (BUY_TD + SRN = N=760, trigger rate ~0.75%) |
| Misuse risk | Using LOCATION as a mandatory gate would miss 68% of positive-E[R] trades (BUY_TU, SRN, BUY_RN all positive E[R]) |

---

### C. FAILURE_MODE_PACKET

| Field | Value |
|---|---|
| Strategy | FVG_TPB — SELL_TREND_DOWN hostile context |
| Role in IFR | FAILURE MODE IDENTIFIER — hostile subset marker |
| Evidence | SELL_TREND_DOWN: WR=38.37% (−5.04pp vs 43.41% baseline); E[R]=−0.041R; N=417 SUFFICIENT |
| Acceptance rule | WR degradation ≥ −3pp OR E[R] degradation ≥ −0.06R vs baseline; N sufficient |
| Current status | CANDIDATE STRONG — WR degradation = −5.04pp ≥ −3pp criterion MET; E[R]=−0.041R (negative but > −0.06R) |
| Why not formally accepted yet | Formal FAILURE_MODE_PACKET requires comparison against baseline E[R] in the same context; dedicated test not run |
| Current verdict | FAILURE_MODE_CANDIDATE_STRONG — pending formal co-baseline test |
| Starvation risk | N/A — failure mode is a filter, not a trigger |
| Misuse risk | Treating SELL_TREND_DOWN as globally rejected (WR=38.37% > 35%; not REJECTED status; it is EDGE_NOT_CONFIRMED) |

---

### D. CONFIRMATION_PACKET

| Field | Value |
|---|---|
| Role in IFR | CONFIRMATION — secondary signal that co-fires with FVG_TPB and lifts outcomes |
| Current status | NOT_TESTABLE — FVG_TPB has no MT5 entries; co-presence analysis cannot be run |
| Acceptance rule | Co-presence WR lift ≥ +2pp AND E[R] lift ≥ +0.04R; co-presence rate < 80% |
| Rejection rule | Co-presence ubiquitous (>80%); co-presence degrades outcomes; no lift |
| Possible future candidates | — |

| Candidate Strategy | Rationale | Status | Test Required |
|---|---|---|---|
| mean_reversion_bounce | ACCEPTED_ALPHA_TRIGGER (WR=42.68%, N=656, RMR zone); SELL outperforms (WR=43.8%); zone overlap with IFR SELL_RANGE_NEUTRAL plausible | PLAUSIBLE — evidence exists; co-presence unknown | CO_PRESENCE_TEST after FVG_TPB admission |
| sweep_reversal | Sweeps may precede FVG formation; orthogonal mechanisms could co-fire; RBSR-IFR overlap zone | PLAUSIBLE — co-presence unknown; E[R]=−0.011R unrestricted limits its value as confirmer | CO_PRESENCE_TEST after FVG_TPB admission |
| fake_break_reversal | LIQUIDITY_REVERSAL family; DATA_INSUFFICIENT (N=19); RMR zone | PENDING_CERTIFICATION — too sparse for co-presence test | FBR expansion cert needed first |
| bollinger_reclaim | MEAN_RECLAIM family; E[R]=−0.018R unrestricted; REJECTED as RBSR CONFIRM | CONTRADICTED — E[R] negative unrestricted; cannot be a credible IFR CONFIRM without regime restriction evidence | Regime-restricted cert needed |
| range_edge_fade | MEAN_RECLAIM family; WR=38.5%, E[R]=−0.038R unrestricted | UNLIKELY — negative unrestricted E[R] cannot be IFR CONFIRM | Regime-conditional subset cert needed |
| mfi_reversal_assist | EXHAUSTION_JUDGE; first entries observed (2 entries); Phase 4B partially unblocked | PENDING_DATA — 2 entries < 5 minimum threshold | Live accumulation needed |

**Starvation risk if CONFIRMATION required gate:** HIGH — any mandatory CONFIRM requirement before IFR trades execute would starve the playbook since no confirmer has been tested or accepted.

**Current verdict: NOT_TESTABLE — no live co-presence data. No CONFIRMATION_PACKET designatable yet.**

---

### E. TIMING_PACKET

| Field | Value |
|---|---|
| Role in IFR | TIMING — session/time/age context correlation with IFR performance |
| Possible dimensions | FVG age at trigger (bars active before entry); time-of-day; session (London/NY); mitigation depth (% of gap filled) |
| Current status | UNTESTED — no temporal breakdown below monthly resolution in current cert |
| Acceptance rule | Target period WR ≥ 40% AND E[R] ≥ 0 with N ≥ 50; pattern persists across ≥ 2 sub-windows |
| Current verdict | DATA_INSUFFICIENT_PACKET — tests not run; no session or age-breakdown analysis |
| Future tests | INEC test: session filter (London/NY vs. off-session FVG performance); FVG age sensitivity (early vs. late-life triggers) |

---

### F. ATTRIBUTION_PACKET (informational)

| Field | Value |
|---|---|
| Role in IFR | POST-TRADE ATTRIBUTION — explains which FVG characteristics correlate with outcome |
| Relevant fields | fvg_size_atr, fvg_age_bars, fvg_mitigation_pct, fvg_active_zone_count |
| Current status | ATTRIBUTION_ONLY — no packet claim; fields needed for future analysis |
| Acceptance rule | N/A — attribution is observational, not a formal packet type |
| Current verdict | NOT_A_PACKET — informational only |

---

### G. RESEARCH_ONLY and REJECTED Packets

| Packet Type | Verdict |
|---|---|
| RESEARCH_ONLY_PACKET | SUPERSEDED — FVG_TPB achieved ALPHA_TRIGGER formal acceptance; RESEARCH_ONLY is not needed |
| REJECTED_PACKET (TPC confirmers for IFR) | NOT_APPLICABLE — TPC CONFIRM strategies (BDM, LHR, MSR, TPC) have no evidence basis for IFR participation; they target TREND_CONTINUATION context |
| ATTRIBUTION_PACKET | NOT_APPLICABLE as formal packet — see Section F above |

---

## 8. IFR Playbook State Definitions

Categorical states for IFR follow the PCEA V1 pattern. These are evidence-layer classifications only. **No state permits or blocks execution.** Playbook state is observation/attribution unless explicitly authorized otherwise.

---

### IFR_NOT_PRESENT

**Definition:** No IFR anchor strategy has been certified. No evidence base exists for the playbook.

**Required evidence:** None — this is the default state before any certification.

**Forbidden interpretation:** "IFR_NOT_PRESENT means FVG_TPB has no edge." (Evidence can exist; playbook state refers to chain completeness, not strategy quality.)

**FVG_TPB context:** N/A — this was the state before FVG_TPB certification. FVG_TPB has now been certified; state has advanced.

---

### IFR_FORMING

**Definition:** The playbook has a certified ALPHA_TRIGGER (anchor strategy with positive unrestricted E[R] and WR ≥ 40%), but no CONFIRMATION_PACKET has been formally accepted. The causal chain is incomplete.

**Required evidence:**
- At least one strategy with ALPHA_TRIGGER_PACKET FORMALLY_ACCEPTABLE in IFR context
- Positive E[R] unrestricted (≥ 0)
- No contradicting evidence in dominant test conditions

**Current state: IFR is in IFR_FORMING.**

- FVG_TPB: ALPHA_TRIGGER_PACKET FORMALLY_ACCEPTABLE ✓
- CONFIRMATION_PACKET: not tested ✗
- FAILURE_MODE_PACKET: CANDIDATE_STRONG (SELL_TREND_DOWN −5.04pp WR degradation)

**Forbidden interpretation:**
- "IFR_FORMING means we can execute IFR trades." (No — FORMING means chain is incomplete)
- "IFR_FORMING means FVG_TPB can fire without CONFIRM." (FVG_TPB as standalone ALPHA can fire independently under V1 rules — this is unrelated to playbook state; playbook state is attribution only)

---

### IFR_VALID

**Definition:** The playbook has a certified ALPHA_TRIGGER AND at least one formally accepted CONFIRMATION_PACKET (co-presence WR lift ≥ +2pp AND E[R] lift ≥ +0.04R with co-presence rate < 80%) AND at least one acknowledged FAILURE_MODE indicator.

**Required evidence:**
- ALPHA_TRIGGER_PACKET: formally accepted (met — FVG_TPB)
- CONFIRMATION_PACKET: formally accepted from a non-anchor strategy (NOT MET — no co-presence data)
- At least one FAILURE_MODE metric documented (CANDIDATE_STRONG for SELL_TD — partially met)

**Current state:** IFR_VALID is not achievable yet. At minimum: FVG_TPB must be admitted to MT5, V1C records must accumulate, co-presence analysis must be run against a potential CONFIRM candidate.

**Forbidden interpretation:**
- "IFR_VALID means trades from IFR context are authorized." (State is observation-only; no execution permission)
- "IFR_VALID supersedes V1 runtime authority." (V1 is sole runtime authority)

---

### IFR_CONTRADICTED

**Definition:** Evidence actively contradicts the IFR causal hypothesis. Either the ALPHA_TRIGGER's edge has collapsed across the majority of tested conditions, or a CONFIRMATION attempt has shown co-presence degrades outcomes.

**Example:** If FVG_TPB live WR < 35% for 30+ trades across all contexts → ALPHA_TRIGGER retracted → IFR_CONTRADICTED.

**FVG_TPB context:** Not applicable yet — 0 live entries. IFR_CONTRADICTED would require live evidence that the INEC edge does not transfer to MT5 execution.

**Forbidden interpretation:**
- "IFR_CONTRADICTED blocks RBSR or TPC execution." (IFR state is independent of other playbooks)

---

### IFR_LATE

**Definition:** IFR was in VALID or FORMING state; subsequent evidence shows temporal instability (significant late-period WR decay) or regime regime shift has made historical IFR evidence unreliable.

**Example:** If FVG_TPB early/late walk-forward gap grows to > 15pp over an extended data window → IFR_LATE.

**Current FVG_TPB context:** 1.7pp gap — not relevant. IFR_LATE is a future monitoring condition.

---

### IFR_INVALID

**Definition:** IFR evidence is structurally invalid — either due to simulation error, lookahead bias discovered post-deployment, or evidence of geometric sampling artifact.

**Example:** Discovery that the FVG detection logic used bar[0] (forming bar) data instead of bar[1] data → all N=2,442 results are invalid → IFR_INVALID.

**Current context:** Not applicable — EOC compliance verified in design; no lookahead bias identified.

---

### State Summary

| State | Current Applicability | Evidence Gate |
|---|---|---|
| IFR_NOT_PRESENT | Past state (before FVG_TPB cert) | No anchor |
| **IFR_FORMING** | **CURRENT STATE** | Anchor certified; no CONFIRM |
| IFR_VALID | Future (post-CONFIRM packet, post-admission, post-co-presence) | Anchor + CONFIRM + FAILURE_MODE |
| IFR_CONTRADICTED | Future monitoring condition | Evidence contradicts chain |
| IFR_LATE | Future monitoring condition | Temporal decay |
| IFR_INVALID | Future monitoring condition | Structural simulation error |

---

## 9. IFR Event Order Contract

### 9.1 Required Sequence

| Step | Description | Pre-Decision? | MT5 State Tracking Needed? | Stage 18.5 Status |
|---|---|---|---|---|
| 1 | Context known: M5 regime computed (EMA20/50/ATR14) | YES — M5 bars close before council evaluation | YES — M5 EMA/ATR persisted across bars | COMPLIANT |
| 2 | FVG created: M5 bar[j] closes; 3-candle test applied | YES — bar[j] close = activation-1 event | YES — SFVGZone added to active list after bar[j] close | COMPLIANT |
| 3 | FVG persisted / active: activation_time = bar[j] close; time check | YES — deterministic timestamp | YES — zone list persisted; on-init replay for cold start | COMPLIANT |
| 4 | Mitigation occurs: M1 close enters [fvg_lo, fvg_hi] | YES — M1 close is completed bar data (shift=1) | NO new tracking — already in simulation as M1 OHLCV check | COMPLIANT |
| 5 | Trigger accepted: entry decision (direction, stop, target) | YES — ATR14(M1) from completed bar | NO new tracking — ATR from shift=1 bars | COMPLIANT |
| 6 | Hostile subset checked: SELL_TREND_DOWN gate | YES — regime known pre-decision | NO new tracking — regime from Link 1 | COMPLIANT |
| 7 | Stop/target geometry known: ATR×1.20, RR=1.50 | YES — ATR from closed bar | NO new tracking | COMPLIANT |
| 8 | Playbook state emitted to V1C ledger | POST-DECISION — written after trade decision; attribution only | NO — write-only path, no feedback to decision | COMPLIANT |
| 9 | V1 decision remains separate: execution by core_trade_engine | V1 authority is unchanged | NO — IFR does not interact with execution engine | COMPLIANT |

### 9.2 What Can Be Known Pre-Decision

All steps 1–7 are deterministic from completed-bar OHLCV data. FVG_TPB trigger is fully observable before the council decision:
- M5 regime: known from previous M5 bars
- FVG zone boundaries: fixed at M5 bar[j] close time
- M1 entry: checked against closed M1 bar
- ATR stop: computed from closed M1 bars

**No lookahead bias exists in the certified design.**

### 9.3 New MT5 State Tracking Required

The only new state tracking required is **FVG zone persistence** across bars within a session:
- SFVGZone array: maintained per-bar (add on M5 close; expire/invalidate/check on M1 close)
- On-init replay: 48 M5 bars replayed on EA startup to rebuild active zones
- This is the only structural complexity beyond existing pattern

### 9.4 Stage 18.5 Assessment

Stage 18.5 (pre-decision observation point) cannot validate:
- Whether the FVG zone state correctly matches the INEC simulation's zone state at each bar
- Whether on-init replay produces identical zone lists to a continuously-running simulation
- Whether zone invalidation timing in MT5 matches the Python simulation's bar-close timing

These gaps are **not blocking** for initial implementation but must be verified by comparing V1C fvg_ field values against expected INEC outputs on a per-trade basis after deployment.

### 9.5 Pre-Decision Instrumentation Future Requirements

If IFR_VALID state is sought, the following pre-decision instrumentation would be required:
- FVG zone count and active zone list logged at council evaluation time (already handled by fvg_active_zone_count in V1C)
- Regime at trigger time vs. regime at FVG creation time (does regime change between detection and entry?)
- M5 bar timestamp alignment confirmation (broker server time UTC offset validation)

---

## 10. IFR V1C Observability Requirements

Schema designation: **OL_V1D_FVG_TPB_EXTENSION** (extends OL_V1C_PLAYBOOK_SHADOW; not yet authorized)

### 10.1 Blocking Fields — Required Before Admission

These fields are mandatory. Without them, live FVG_TPB performance cannot be attributed, diagnosed, or compared to INEC evidence.

| Field | Type | Purpose | IFR Link |
|---|---|---|---|
| fvg_direction | string ("BUY"/"SELL") | Direction of triggering FVG zone | L2, L5 |
| fvg_gap_low | double | Lower boundary of FVG zone at trigger | L2, L4 |
| fvg_gap_high | double | Upper boundary of FVG zone at trigger | L2, L4 |
| fvg_regime_context | string | M5 regime at trigger time | L1 |
| fvg_subset_classification | string | e.g., BUY_TREND_DOWN, SELL_RANGE_NEUTRAL | L1, L6 |
| fvg_hostile_gate_fired | bool | Whether SELL_TREND_DOWN gate suppressed trigger | L6 |

**Classification: REQUIRED BEFORE ADMISSION**

---

### 10.2 Recommended Attribution Fields

These fields are not blocking but are highly valuable for diagnosing IFR performance and building the causal chain picture.

| Field | Type | Purpose | IFR Link |
|---|---|---|---|
| fvg_size_atr | double | Gap size / ATR14_M5 at detection | L2 |
| fvg_age_bars | int | M1 bars elapsed since activation | L3 |
| fvg_invalidated | bool | Whether this zone was invalidated | L3 |
| fvg_expired | bool | Whether this zone expired before triggering | L3 |
| fvg_active_zone_count | int | Number of active FVGs at trigger time | L3, L4 |
| fvg_mitigation_pct | double | Depth into gap (0=gap edge, 1.0=far side) | L4 |

**Classification: USEFUL FOR ATTRIBUTION — recommended at initial implementation**

---

### 10.3 IFR-Specific Playbook State Fields

These fields support IFR playbook shadow state observation once FVG_TPB is admitted and V1C records accumulate.

| Field | Type | Purpose | Classification |
|---|---|---|---|
| ifr_playbook_state | string | IFR_NOT_PRESENT / IFR_FORMING / IFR_VALID / etc. | USEFUL — playbook state shadow |
| ifr_completed_links | string[] | Which IFR causal links were present at trigger | USEFUL — chain completeness |
| ifr_missing_links | string[] | Which IFR causal links were absent | USEFUL — chain diagnosis |
| ifr_contradicted_links | string[] | Which links contradicted the hypothesis | USEFUL — contradiction tracking |
| ifr_failure_mode_present | bool | Whether SELL_TD hostile context is active | USEFUL — failure mode tracking |
| ifr_failure_mode_type | string | "SELL_TREND_DOWN_HOSTILE" or other | OPTIONAL — future failure mode types |

**Classification: USEFUL FOR IFR STATE SHADOW — not blocking; do not implement before FVG_TPB admitted**

---

### 10.4 Forbidden as Score/Gate

These hypothetical uses are explicitly prohibited:

| Field or Use | Forbidden Reason |
|---|---|
| Any fvg_ field feeding council_quality computation | Must not affect decision layer; observation-only |
| ifr_playbook_state feeding HIGH_CONVICTION | Playbook state must not qualify or disqualify consensus type |
| fvg_subset_classification as CRR gate condition | Must not add new gate conditions; existing gate logic unchanged |
| fvg_hostile_gate_fired as DSN input | DSN conditions unchanged; hostile gate is a strategy-level filter, not a pre_ai_filter condition |
| ifr_completed_links as vote_weight modifier | Weight changes require operator authorization; no automatic adjustment |

---

## 11. IFR Relationship to Existing Playbooks

### 11.1 Comparison Table

| Attribute | RBSR | TPC | VCR | IFR |
|---|---|---|---|---|
| Trigger type | Bearish/bullish rejection at swept liquidity level | EMA momentum alignment in trend direction | ATR compression breakout | 3-candle FVG mitigation (M1 close within gap zone) |
| Primary causal object | Swept liquidity pool (stop cluster at swing extreme) | Trend direction (EMA stack alignment) | Volatility contraction / expansion | Price imbalance region (gap created by impulse) |
| Best market context | REV/RMR zone; range boundary established | TC/BREAKOUT zone; clear trend momentum | COMPRESSION zone; ATR contracting | RANGE_NEUTRAL (SELL) or TREND_DOWN (BUY) |
| Failure mode | False reversal: price sweeps again, doesn't reverse | Exhaustion: trend is ending while continuation trade fires | False breakout: ATR expands then contracts again | SELL_TREND_DOWN: continuation gap; price extends through FVG |
| Current anchor evidence | sweep_reversal RESEARCH_ONLY (E[R]=−0.011R) | trend_momentum RESEARCH_ONLY (RANGE_NEUTRAL×SELL best) | None (VCR PLAYBOOK_NOT_PRESENT) | FVG_TPB ALPHA_TRIGGER FORMALLY_ACCEPTABLE (E[R]=+0.085R) |
| Current confirm evidence | 0 accepted CONFIRM packets | 0 accepted CONFIRM packets | 0 evidence | 0 co-presence data (NOT_TESTABLE) |
| Current playbook state | PLAYBOOK_FORMING | PLAYBOOK_FORMING | PLAYBOOK_NOT_PRESENT | IFR_FORMING (proposed) |
| Implementation complexity | MODERATE — uses existing strategies | MODERATE — Phase 4A BLOCKED | HIGH — all 5 strategies DATA_INSUFFICIENT | MODERATE — new FVG zone state machine |
| Overlap risk with IFR | POSSIBLE — both target reversal contexts; co-presence unknown | NONE — counter-directional profiles | NONE | — |
| Evidence level | 9 strategies have certs | 5 strategies have certs | 0 certifications | 1 certification (FVG_TPB) |

### 11.2 Positioning Statements

**IFR should not replace RBSR.** RBSR targets swept liquidity levels — a mechanically distinct precondition with a well-defined causal hypothesis (stops above/below range = predictable reversal location). RBSR's weakness is lack of accepted confirmation packets, not a wrong mechanism. IFR and RBSR could co-exist as parallel reversal playbooks targeting different structural triggers.

**IFR should not patch TPC.** TPC's problem is architectural sparsity (TPC never fires alongside trend_momentum) and Phase 4A blockage. Importing FVG_TPB into TPC to compensate for TPC's sparse confirmation chain would create hostile trades (SELL_TREND_DOWN) and misclassify FVG_TPB's mechanism. TPC must be addressed on its own terms.

**IFR may eventually stand beside RBSR as a second reversal playbook.** Both target reversal/reclaim scenarios from structural zones. IFR's structural trigger (imbalance gap) is orthogonal to RBSR's structural trigger (swept liquidity). They represent two different ways price creates opportunity for reversal. A future system could have RBSR handling sweep-initiated reversals and IFR handling imbalance-fill reversals, with mfi_reversal_assist potentially serving as a shared failure-mode guard across both.

**VCR remains entirely separate.** VCR (COMPRESSION zone, ATR-based) targets breakout mechanics that have no overlap with FVG imbalance structure. IFR has no VCR interaction.

---

## 12. IFR Relationship to Existing Strategies

### FVG_TPB (external_fvg_tpb)

| Field | Assessment |
|---|---|
| Potential role | PLAYBOOK_ANCHOR — primary ALPHA_TRIGGER |
| Evidence status | ALPHA_TRIGGER_PACKET FORMALLY_ACCEPTABLE (N=2,442, WR=43.41%, E[R]=+0.085R) |
| IFR compatible | YES — this is the IFR-motivating strategy |
| IFR redundant | NO — it is the anchor |
| IFR hostile | NO — it is the evidence source |
| Future test needed | CO_PRESENCE with RBSR strategies; HOSTILE_GATE formalization; SESSION_FILTER test |

---

### sweep_reversal

| Field | Assessment |
|---|---|
| Potential role | Possible IFR CONFIRMATION candidate (co-presence test needed) |
| Evidence status | RESEARCH_ONLY (E[R]=−0.011R unrestricted); counter-trend subset E[R]=+0.012R |
| IFR compatible | PLAUSIBLE — sweeps may precede FVG formation; if co-presence rate is non-ubiquitous and WR lift ≥ +2pp, CONFIRMATION_PACKET possible |
| IFR redundant | POSSIBLE — if co-presence is ubiquitous (>80%), it cannot serve as discriminating CONFIRM |
| IFR hostile | NO — independent mechanism; not hostile to IFR |
| Future test needed | CO_PRESENCE_TEST after FVG_TPB admitted; compare WR of FVG_TPB trades with vs without sweep_reversal co-fire |

---

### bollinger_reclaim

| Field | Assessment |
|---|---|
| Potential role | Theoretically possible IFR CONFIRMATION (MEAN_RECLAIM family aligns with IFR range-reclaim scenario) |
| Evidence status | REJECTED as RBSR CONFIRM; E[R]=−0.018R unrestricted; WR=38.5% (W/L basis) |
| IFR compatible | UNLIKELY — negative unrestricted E[R] does not support CONFIRM role; RANGE-era performance is EDGE_NOT_CONFIRMED (E[R]=−0.052R per RBSR registry) |
| IFR redundant | NO — different family (MEAN_RECLAIM vs IMBALANCE_REVERSAL) |
| IFR hostile | POSSIBLE in RANGE context — E[R] negative in the context most relevant to IFR SELL_RANGE_NEUTRAL |
| Future test needed | Regime-conditional cert needed before any IFR CONFIRM consideration |

---

### mfi_reversal_assist

| Field | Assessment |
|---|---|
| Potential role | IFR FAILURE_MODE_GUARD (exhaustion signal could correlate with FVG_TPB hostile subsets) |
| Evidence status | DATA_INSUFFICIENT — 2 live entries (Phase 4B partially unblocked; minimum 5 entries for threshold calibration) |
| IFR compatible | PLAUSIBLE — exhaustion signals during SELL_TREND_DOWN context may predict hostile IFR outcomes |
| IFR redundant | NO — different role (EXHAUSTION_JUDGE vs IMBALANCE_REVERSAL trigger) |
| IFR hostile | NO |
| Future test needed | Accumulate ≥ 5 MFI live entries; assess correlation with FVG_TPB trigger timing |

---

### mean_reversion_bounce

| Field | Assessment |
|---|---|
| Potential role | STRONGEST IFR CONFIRMATION candidate — highest evidence quality of any RBSR CONFIRM strategy |
| Evidence status | ACCEPTED_ALPHA_TRIGGER per 2026-05-09 cert: WR=42.68%, N=656, E[R]=+0.067R; SELL outperforms (WR=43.8%, E[R]=+0.096R); fires in RANGE_NEUTRAL regime exclusively |
| IFR compatible | STRONGLY PLAUSIBLE — SELL_RANGE_NEUTRAL (IFR best SELL subset) and mean_reversion_bounce SELL (range-reclaim) target the same regime context. Both use RANGE_NEUTRAL regime. Both favor SELL direction in range. Co-presence test is the highest-priority CONFIRMATION_PACKET candidate for IFR. |
| IFR redundant | POSSIBLE — if co-presence rate > 80%, CONFIRM packet cannot be confirmed (ubiquitous = non-discriminating); if FVG_TPB SELL_RN and MRB SELL fire simultaneously on most triggers, no useful discrimination exists |
| IFR hostile | NO — positive-E[R] strategy in IFR-relevant context |
| Future test needed | CO_PRESENCE_TEST: of all FVG_TPB SELL_RANGE_NEUTRAL triggers, what % are co-present with MRB SELL trigger? Does MRB co-presence lift WR ≥ +2pp? |

---

### fake_break_reversal

| Field | Assessment |
|---|---|
| Potential role | TIMING_PACKET candidate — FBR and FVG may co-occur at range fake breakouts |
| Evidence status | DATA_INSUFFICIENT — N=19, 47.7pp early/late WR gap; RESEARCH_ONLY_PACKET |
| IFR compatible | PLAUSIBLE but cannot be tested yet |
| IFR redundant | NO — different trigger (wick-pattern rejection vs 3-candle gap) |
| IFR hostile | NO |
| Future test needed | Expand FBR sample; co-presence test with FVG_TPB when both have adequate N |

---

### range_edge_fade

| Field | Assessment |
|---|---|
| Potential role | Possible IFR CONFIRMATION secondary (RMR zone, MEAN_RECLAIM family) |
| Evidence status | WR=38.5%, E[R]=−0.038R unrestricted; EDGE_WEAK_BUT_RECOVERABLE; best in TREND_DOWN regime (unexpectedly) |
| IFR compatible | UNLIKELY as primary CONFIRM — negative unrestricted E[R]; but possible in conditional subset |
| IFR redundant | NO — different mechanism |
| IFR hostile | IN RMR CONTEXT — E[R] negative suggests it would not confirm IFR without restriction |
| Future test needed | Regime-conditional co-presence test if MRB test is insufficient |

---

### trend_momentum

| Field | Assessment |
|---|---|
| Potential role | INCOMPATIBLE with IFR |
| Evidence status | TPC anchor; RANGE_NEUTRAL×SELL = EDGE_SUPPORTED; TC zone focus |
| IFR compatible | NO — TPC mechanism; SELL_TREND_DOWN alignment would make it hostile in IFR context |
| IFR hostile | YES in TC zone — trend_momentum fires SELL in TREND_DOWN = IFR hostile subset |
| Future test needed | None required for IFR; TPC relationship only |

---

### TPC Strategies (BDM, LHR, MSR, TPC)

| Strategy | IFR Role | Reason |
|---|---|---|
| trend_pullback_cont_v1 | INCOMPATIBLE — TPC CONFIRM | TC archetype; 0 entries; not relevant to IFR |
| breakdown_momentum_v1 | INCOMPATIBLE — hostile TC performance | EDGE_REJECTED in TC proxy; SELL-only; TPC context |
| lower_high_rejection_v1 | INCOMPATIBLE — TC SELL context | Near-breakeven; TC zone focus; not IFR relevant |
| micro_structure_reentry_v1 | INCOMPATIBLE — FAILURE_MODE for LHR | TC context only |

All TPC strategies: **NOT_APPLICABLE to IFR.** Their performance was certified in TC/BREAKOUT zones. IFR operates in REV/RMR/RANGE contexts. No cross-context evidence exists or is needed.

---

## 13. IFR Admission Criteria

All of the following must be true before IFR can become an official registry playbook (i.e., registered in PIML and playbook registry):

| Criterion | Required State | Current State |
|---|---|---|
| Playbook design complete | YES — this document | MET (this package) |
| FVG_TPB admitted or shadow-tracked in MT5 | YES — V1C records required for chain analysis | NOT MET — factory_admission_lock ACTIVE |
| V1C observability fields specified | YES — Section 10 defines all required and recommended fields | MET (design) |
| Event Order Contract assessed | YES — Section 9 confirms compliance | MET (design) |
| factory_admission_lock lifted for FVG_TPB | YES — operator decision | NOT MET |
| FVG_TPB implementation Codex task authorized | YES — operator authorization required | NOT MET |
| Rejection rules defined | YES — Section 14 | MET (design) |
| Rollback plan defined | YES — admission design package defines rollback | MET (design) |
| No score/gate leakage confirmed | YES — code review at implementation time | PENDING IMPLEMENTATION |
| Operator authorization for IFR registry entry | YES — PIML update requires operator authorization | NOT MET |
| CONFIRMATION_PACKET test run | Recommended before IFR_VALID — not required for IFR registration | NOT MET — cannot run without live FVG_TPB data |

**Minimum admission path:** factory_admission_lock lift → FVG_TPB admitted → V1C records accumulate → IFR registered in PIML as PLAYBOOK_FORMING → co-presence analysis run → CONFIRMATION_PACKET candidate evaluated.

---

## 14. IFR Rejection Rules

IFR design should be frozen, suspended, or abandoned if any of the following occur:

| Condition | Trigger | Action |
|---|---|---|
| FVG trigger divergence | Live FVG_TPB trigger rate < 0.5% or > 8% of M1 bars (far outside INEC 2.43%) after 72h active market | Halt; investigate zone state machine for bugs; review INEC simulation accuracy |
| SELL_TREND_DOWN dominance | >40% of all live FVG_TPB SELL trades are in TREND_DOWN regime despite hostile gate | Halt; verify gate implementation; consider full SELL suspension |
| WR collapse | Live WR < 35% after 50 closed W/L trades (any combination of subsets) | Suspend IFR; retrace to INEC data; check broker spread vs 12pt assumed |
| E[R] severe degradation | Live E[R] < −0.08R after 50 closed W/L trades | Suspend; investigate cost model divergence |
| Event order violation | Discovery that FVG zone state machine used forming-bar data (bar[0]) | IFR_INVALID; full re-certification required |
| Zone state instability | EA crashes or zone array grows unboundedly across sessions | Rollback implementation; redesign zone lifecycle |
| Playbook duplicates RBSR without distinction | After 100+ co-presence records: FVG_TPB co-presence with sweep_reversal > 90%; WR without SR = WR with SR (no discrimination) | Reclassify as RBSR supplementary alpha; IFR design candidate abandoned |
| No confirmation candidate after 200 co-presence records | No strategy achieves co-presence lift ≥ +2pp AND ≥ +0.04R after 200 FVG_TPB live records tested | Re-evaluate playbook viability; consider IFR_RESEARCH_ONLY status |
| Decision leakage appears | Any fvg_ or ifr_ V1C field is discovered to be read by decision pipeline (aggregator/filter/governor) | Halt immediately; rollback to pre-FVG V1C schema; fix isolation before re-deployment |
| Implementation complexity cost too high | FVG zone state machine creates systematic live WR degradation relative to INEC that cannot be explained by cost model | Rollback; redesign zone tracking |

---

## 15. Future INEC Tests Required

These are targeted future tests for IFR evidence progression. Each is bounded and specific — not broad retesting.

### Test 1 — FVG_TPB Co-Presence with RBSR Anchors

**Purpose:** Determine whether FVG_TPB and sweep_reversal fire together or independently.
**Method:** After FVG_TPB admission, compare V1C records: for all sweep_reversal trigger-present bars, what % are also FVG_TPB trigger-present?
**Required N:** 50+ sweep_reversal triggers AND 50+ FVG_TPB triggers from overlapping time windows.
**Acceptance criteria:** Co-presence rate < 80% (below ubiquitous threshold). WR comparison between co-present and solo FVG_TPB trades.
**Classification if accepted:** CONFIRMATION_PACKET (if WR lift ≥ +2pp AND E[R] lift ≥ +0.04R).

---

### Test 2 — FVG_TPB Subset Stability Under Extended Data

**Purpose:** Confirm BUY_TREND_DOWN and SELL_RANGE_NEUTRAL edge stability beyond the 2026-01 to 2026-05 certification window.
**Method:** Extend M1/M5 data to include 2025-11-07 (M5 start) through M1 start; certify Variant C on extended sample.
**Required N:** BUY_TD N ≥ 200; SELL_RN N ≥ 200 in extended sample.
**Acceptance criteria:** WR and E[R] within 3pp/0.05R of INEC values.
**Classification if accepted:** EDGE_SUPPORTED confirmation at SUFFICIENT N.

---

### Test 3 — SELL_TREND_DOWN Hostile Failure-Mode Formalization

**Purpose:** Formally test whether SELL_TREND_DOWN meets FAILURE_MODE_PACKET acceptance rule.
**Method:** Run dedicated test comparing SELL_TREND_DOWN performance against full SELL baseline. Measure WR degradation and E[R] degradation vs. the SELL-only unrestricted baseline.
**Required N:** N ≥ 50 in SELL_TREND_DOWN (already N=417 in INEC; re-test for formalization).
**Acceptance criteria for FAILURE_MODE:** WR degradation ≥ −3pp OR E[R] degradation ≥ −0.06R vs baseline.
**Current status:** WR degradation from 43.41% baseline = −5.04pp — likely meets criterion. Formal test needed to confirm against SELL-only baseline.

---

### Test 4 — FVG Mitigation-Depth Timing Test

**Purpose:** Determine whether early-mitigation (close near fvg_lo/fvg_hi edge) vs. late-mitigation (close near center/far side) correlates with outcome quality.
**Method:** From existing trades CSV, compute mitigation_pct for each trade; split by quartile; compare WR and E[R] per quartile.
**Required N:** Per-quartile N ≥ 50 (current total N=2,442 supports this).
**Acceptance criteria for TIMING_PACKET:** Target quartile WR ≥ 40% AND E[R] ≥ 0 with N ≥ 50; pattern distinguishes from other quartiles by ≥ +2pp.

---

### Test 5 — FVG Age / Expiry Sensitivity Test

**Purpose:** Determine whether FVG triggers near the beginning of the 4-hour active window vs. near expiry show different edge quality.
**Method:** From existing trades CSV, compute fvg_age_bars at entry; split early/late (e.g., bars 1-12 vs bars 13-48); compare WR and E[R].
**Required N:** Per-half N ≥ 100.
**Acceptance criteria for TIMING_PACKET:** Age quartile outperforms baseline by ≥ +2pp WR AND +0.04R.

---

### Test 6 — FVG_TPB vs. mean_reversion_bounce Overlap Test

**Purpose:** Determine whether mean_reversion_bounce (the strongest IFR CONFIRMATION candidate) co-fires with FVG_TPB SELL_RANGE_NEUTRAL triggers.
**Method:** After both strategies are producing live V1C records, compute: for each FVG_TPB SELL_RANGE_NEUTRAL trigger, was MRB also trigger_present=true on the same bar?
**Required N:** 30+ FVG_TPB SELL_RN triggers with MRB co-present; 30+ without.
**Acceptance criteria for CONFIRMATION_PACKET:** Co-presence rate < 80%; WR lift ≥ +2pp AND E[R] lift ≥ +0.04R vs FVG_TPB SELL_RN solo.

---

### Test 7 — FVG_TPB vs. sweep_reversal Temporal Overlap Test

**Purpose:** Determine whether sweeps precede FVG formation systematically.
**Method:** From INEC M5 data, run sweep_reversal detection alongside FVG detection; for each FVG trigger, check if sweep_reversal also fired within the same or previous 3 M5 bars.
**Required N:** N ≥ 100 overlap analysis.
**Acceptance criteria:** > 30% of FVG_TPB triggers preceded by sweep_reversal trigger = structural link. < 10% = independent mechanisms confirmed.

---

### Test 8 — IFR Confirmation Packet Search

**Purpose:** Systematically identify the strongest IFR CONFIRMATION candidate.
**Method:** After FVG_TPB is live with 100+ V1C records, run co-presence matrix analysis against: mean_reversion_bounce, sweep_reversal, fake_break_reversal (when N is sufficient), bollinger_reclaim (with restrictions). Rank by WR lift AND co-presence rate.
**Required N:** 100 FVG_TPB records; 30+ co-presence observations per candidate.
**Acceptance criteria:** Best candidate with WR lift ≥ +2pp AND E[R] lift ≥ +0.04R AND co-presence rate < 80%.

---

## 16. Future Codex Implementation Implications

**DESIGN_ONLY — no code, no authorization, no Codex task initiated.**

### 16.1 Future Package: FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1

This package would be the first MT5-touching deliverable in the IFR lane. It implements FVG_TPB into council_strategies.mqh and adds V1C observability fields.

**Allowed files:**
- `council_mode_types.mqh` — SFVGZone struct; new V1C fvg_ fields
- `council_strategies.mqh` — BuildCouncilStrategy_FVG_TPB() + helpers
- `council_mode_runtime.mqh` — integration call in RunCouncilStrategySet()
- Potentially a registry MD file (documentation update only)

**Forbidden files:**
- `core_trade_engine.mqh` — execution geometry unchanged
- `council_pre_ai_filter.mqh` — no gate changes
- `council_aggregator.mqh` — no aggregation logic changes
- `council_ai_governor.mqh` — no governor changes
- All risk/execution files
- All existing strategy functions (no modification)

**Required for IFR compliance:**
- V1 authority preserved: FVG_TPB contributes vote; cannot override or bypass council decision
- No score/gate leakage: fvg_ V1C fields write-only; zero read-back to decision pipeline
- FVG zone state tracking: SFVGZone array with on-init replay (48 M5 bars)
- V1C fields: all 6 required fields from Section 10.1 + all 6 recommended fields from Section 10.2
- SELL_TREND_DOWN hostile gate: mandatory; not optional
- EOC compliance: zero bar[0] usage in zone detection or entry check
- Compile 0 errors / 0 warnings
- Timestamped backups before all file changes
- Rollback instructions included in task specification
- Adversarial review before Codex execution
- Runtime validation checklist (72h trigger observation; V1C field completeness; gate firing verification)

**Key complexity note:** FVG zone state machine is the primary implementation risk. The state machine (activate → expire/invalidate/check/FIFO-select) must precisely replicate the INEC Python simulation's logic. Bar-by-bar state equivalence is the key validation criterion.

---

## 17. Phase Impact

**IFR design does not unlock any phase by itself. FVG_TPB evidence creates a future admission path, not production readiness.**

| Phase | Current State | IFR Impact |
|---|---|---|
| Phase 3 (Nautilus certs) | 8 strategies formally classified; 9 uncertified; FVG_TPB is an external candidate | IFR design does not count toward the 17 internal strategies' Phase 3 completeness. FVG_TPB is the 9th Nautilus-run strategy (if counted as Phase 3 equivalent), but it is external. 10 internal strategies remain uncertified. |
| Phase 4A (Cross-family CRR) | BLOCKED — TPC sparsity architectural; option F selected diagnostically | NONE — FVG_TPB admission does not change TPC fire rate or Phase 4A architectural decision. IFR is independent of TC zone. |
| Phase 4B (Exhaustion veto) | PARTIALLY_UNBLOCKED — mfi_reversal_assist 2 entries (min 5) | NONE — mfi_reversal_assist's IFR role (potential FAILURE_MODE_GUARD) is a post-admission design candidate, not a Phase 4B input. Phase 4B requires 5+ MFI entries for veto threshold calibration. |
| Phase 4C (Quality soft gate) | BLOCKED — Opportunity Ledger below 200 records | MARGINAL ACCELERATION — FVG_TPB admission would generate ~23 V1C records per active trading day; this would help reach the 200-record threshold faster. BUT: Phase 4C requires 200 records from the existing system, not from an external candidate. This is a side effect, not authorization. |
| Phase 5 (Strategy restriction patches) | Phase 5A applied (bollinger_reclaim SELL_TREND_UP gate); runtime validation pending | FVG_TPB admission = a Phase 5-equivalent action: new strategy + hostile gate (SELL_TREND_DOWN). It would be a separate bounded Codex task, analogous to Phase 5 in scope. |
| Phase 6 (EEWP) | DESIGN_ONLY — blocked on Phase 2 + Phase 3 (≥8 certs) + Phase 4 runtime | NONE — FVG_TPB does not have a vote_weight yet; EEWP does not apply to unadmitted strategies. |
| Production Candidate | System DEVELOPING | NONE — IFR design does not change system status. Production readiness requires all Phase 3 certifications, Phase 4 live, and 200+ trades under IRREW. None of these are changed by IFR design. |

---

## 18. Recommended Decision

### IFR_DESIGN_APPROVED_AS_PLAYBOOK_CANDIDATE

**Justification:**

1. **Evidence quality is sufficient for playbook design.** FVG_TPB's certification (N=2,442, WR=43.41%, ALPHA_TRIGGER FORMALLY_ACCEPTABLE, temporal stability confirmed) provides the evidence foundation required to define a playbook lane. The anchor strategy's evidence exceeds the ALPHA_TRIGGER acceptance threshold.

2. **Mechanical distinctiveness from RBSR and TPC is demonstrated.** The counter-trend edge inversion (BUY_TREND_DOWN > BUY_TREND_UP) is a statistically verified finding with mechanical interpretation. This is not ambiguous overlap with RBSR or TPC — it is a structurally distinct causal pattern.

3. **Causal chain is designable.** Links 1-7 are all mechanically defined with certified rules (Links 2, 4, 5, 7) and evidence-supported context definitions (Links 1, 3, 6). The chain is not hypothetical — it is grounded in 2,442 certified transactions.

4. **Rejection rules and failure modes are identified.** SELL_TREND_DOWN hostility (WR degradation −5.04pp; E[R]=−0.041R) provides a failure-mode candidate. The playbook has observable risk conditions.

5. **IFR design is documentation-only, consistent with current system philosophy.** No source changes, no compilation, no runtime impact. Design cost is zero. Benefit is a clean architectural lane for FVG_TPB admission when authorized.

**What this decision does NOT authorize:**
- MT5 implementation of any kind
- Strategy admission
- factory_admission_lock lift
- Playbook registry update in PIML
- Any runtime behavior change

---

## 19. What Must Not Be Concluded

The following conclusions are **explicitly prohibited** from this design package or any document citing it:

1. **No MT5 implementation authorized.** FVG_TPB code must not be written until FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 is separately authorized by the operator.
2. **No FVG_TPB admission.** strategy_id "external_fvg_tpb" is not registered in any council file.
3. **No factory_admission_lock lift.** factory_admission_lock = ACTIVE throughout this document.
4. **No playbook runtime authority.** IFR playbook state (IFR_FORMING, IFR_VALID, etc.) is evidence-layer attribution only. No execution permission follows from any playbook state.
5. **No gate/score modification.** Zero changes to CRR, DSN, council_quality, HIGH_CONVICTION, or any filter condition.
6. **No phase unlock.** IFR design does not unblock Phase 4A, 4B, 4C, or Phase 6.
7. **No production readiness.** System status = DEVELOPING. IFR design does not change this.
8. **No replacement of RBSR.** RBSR remains a distinct playbook targeting swept liquidity. IFR does not replace, supersede, or absorb RBSR.
9. **No patching of TPC.** TPC's sparsity and Phase 4A problems must be addressed on their own terms. FVG_TPB must not be routed to TPC under any circumstances.
10. **No live policy activation.** The SELL_TREND_DOWN hostile gate design is design-intent only; no runtime gate has been added.
11. **ALPHA_TRIGGER acceptance is not admission.** IFR_FORMING status means the anchor is certified, not that the strategy is admitted.
12. **IFR design does not accelerate Phase 4C.** The 200-record threshold requirement applies to existing system records, not to planned FVG_TPB future records.
13. **mean_reversion_bounce is not confirmed as IFR CONFIRM.** It is the highest-priority candidate; it is not accepted. The co-presence test has not been run.
14. **IFR_VALID state does not mean trade.** Even when achieved, VALID is observation-only.

---

## 20. Recommended Next Large Package

### FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1

**Recommended as the next large package — requires explicit operator authorization and factory_admission_lock lift before execution.**

**Justification:**

With IFR playbook design complete (this package), the architectural lane is defined. The admission criteria in Section 13 now have one remaining design-side gap addressed (playbook design). The remaining blockers are governance decisions:
- factory_admission_lock lift for FVG_TPB
- Operator authorization for implementation

Given that:
1. Admission design is complete (FVG_TPB_MT5_ADMISSION_DESIGN_PACKAGE_V1)
2. Playbook design is complete (this package)
3. Implementation boundary is specified (Section 16)
4. V1C fields are specified (Section 10)
5. EOC compliance is confirmed (Section 9)
6. Hostile gate is designed (SELL_TREND_DOWN)
7. Rollback procedure is defined
8. Adversarial review requirement is stated

The evidence-side and design-side work is done. The remaining work is execution — and for that, the operator must authorize the implementation Codex task. Once authorized, FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 can be executed as a bounded task.

**Alternative packages not selected:**

| Alternative | Reason Not Selected |
|---|---|
| IFR_REGISTRY_INTEGRATION_DESIGN_PACKAGE_V1 (Option B) | This package is effectively IFR registry design. A separate registry package would duplicate the work done here. Registry integration follows implementation; designing the registry further before implementation would be over-engineering. |
| POST_CLEANUP_RUNTIME_VALIDATION_AND_ACCUMULATION_PACKAGE_V1 (Option C) | Valid parallel work; should continue in background. But it is not the "next large package" — runtime accumulation is ongoing continuous work, not a discrete deliverable that advances the FVG_TPB/IFR path. |
| ADDITIONAL_INEC_REPLICATION_PACKAGE_V1 (Option D) | Not needed. N=2,442 is SUFFICIENT. Temporal stability is confirmed. Slippage is robust. Additional INEC runs would not materially change the evidence baseline for admission design purposes. Additional testing (Tests 1-8 in Section 15) requires live V1C data, not more offline cert runs. |

**Parallel work:** Runtime accumulation (Option C) should continue. Evidence continues to accumulate whether or not FVG_TPB is being implemented. These are not mutually exclusive.

---

## 21. Completion Checklist

| Item | Status |
|---|---|
| Reference 1: FVG_TPB_MT5_ADMISSION_DESIGN_PACKAGE_V1.md | REVIEWED — full package; all 18 sections |
| Reference 2: certification_external_fvg_tpb_xauusd_v1.md | REVIEWED — 16 sections; all variant results |
| Reference 3: external_fvg_candidate_discovery_xauusd_v1.md | REVIEWED — 12 sections; selection rationale |
| Reference 4: FVG_TPB JSON artifacts (metrics, packet, playbook, system) | REVIEWED — all 4 files |
| Reference 5: IRREW_NAUTILUS_EVIDENCE_CERTIFICATION_LAB_V1.md | REVIEWED — §1-3; lab identity, scope, authority |
| Reference 6: nautilus_lab/system_lab/README.md | SOURCE_READ_REQUIRED — file not directly read; lab structure known from related docs |
| Reference 7: registry_snapshot_V1.json | REVIEWED — all 17 strategies + 3 playbooks |
| Reference 8: PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md | REVIEWED — full; all packet taxonomy, 3 playbook states, master strategy table |
| Reference 9: ARCHITECTURE_BUILD_PACKAGE_V1.md | REVIEWED — evidence inventory, packet inventory, 5 packages |
| Reference 10: IMPLEMENTATION_SPEC_PACKAGE_V1.md | REVIEWED — V1C schema OL_V1C_PLAYBOOK_SHADOW confirmed; 5 spec candidates |
| Reference 11: SHADOW_POLICY_CANDIDATE_DESIGN_PACKAGE_V1.md | REVIEWED — V1C live; K1/K2/K3 status; mfi_reversal_assist 2 entries; Phase gates |
| Reference 12: V1C_CLEANUP_PACKAGE_V1_REPORT.md | ARTIFACT_FOUND — content referenced via SHADOW doc |
| Reference 13: RBSR certifications (all 6) | REVIEWED — registry entries + master table; mean_reversion_bounce cert directly read |
| Reference 14: TPC certifications (all 5) | REVIEWED — registry entries + master table; TPC sparsity confirmed live |
| Evidence basis summarized | YES — Section 2 with classification |
| IFR identity defined | YES — Section 3 |
| TPC rejection explained | YES — Section 4 |
| RBSR fallback explained | YES — Section 5 |
| Causal chain defined | YES — Section 6 (7 links) |
| Packet map defined | YES — Section 7 (A-G) |
| Playbook state definitions | YES — Section 8 (6 states) |
| EOC assessed | YES — Section 9 |
| V1C requirements defined | YES — Section 10 (required + recommended + forbidden) |
| IFR vs RBSR/TPC/VCR assessed | YES — Section 11 |
| Strategy relationships assessed | YES — Section 12 (9 strategies) |
| Admission criteria defined | YES — Section 13 |
| Rejection rules defined | YES — Section 14 |
| Future INEC tests defined | YES — Section 15 (8 targeted tests) |
| Codex implementation implications | YES — Section 16 |
| Phase impact assessed | YES — Section 17 |
| Recommended decision issued | YES — Section 18: IFR_DESIGN_APPROVED_AS_PLAYBOOK_CANDIDATE |
| Forbidden conclusions listed | YES — Section 19 (14 items) |
| Next large package recommended | YES — Section 20: FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 |
| No MT5 source modified | CONFIRMED |
| No runtime file modified | CONFIRMED |
| No compile | CONFIRMED |
| No reload | CONFIRMED |
| No PIML update | CONFIRMED |
| factory_admission_lock status | ACTIVE — unchanged |
| System status | DEVELOPING — unchanged |
| Package complete | YES |

---

## Package Footer

```
PACKAGE_ID:               IMBALANCE_FILL_REVERSAL_PLAYBOOK_DESIGN_PACKAGE_V1
DATE:                     2026-05-09
MOTIVATED_BY:             FVG_TPB_MT5_ADMISSION_DESIGN_PACKAGE_V1
PLAYBOOK_ID:              IMBALANCE_FILL_REVERSAL
SHORT_CODE:               IFR
DESIGN_STATUS:            DESIGN_CANDIDATE_ONLY
CURRENT_PLAYBOOK_STATE:   IFR_FORMING
ALPHA_TRIGGER:            FVG_TPB (external_fvg_tpb) — FORMALLY_ACCEPTABLE
CONFIRMATION_PACKET:      NOT_TESTABLE (no live co-presence data)
FAILURE_MODE_CANDIDATE:   SELL_TREND_DOWN — CANDIDATE_STRONG (WR degradation −5.04pp)
TPC_LANE:                 EXPLICITLY_REJECTED
RBSR_LANE:                PROVISIONAL_FALLBACK_ONLY
RECOMMENDED_DECISION:     IFR_DESIGN_APPROVED_AS_PLAYBOOK_CANDIDATE
NEXT_LARGE_PACKAGE:       FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 (requires operator auth + factory lock lift)
MT5_MODIFIED:             NO
RUNTIME_MODIFIED:         NO
PIML_MODIFIED:            NO
COMPILE_RUN:              NO
RELOAD_RUN:               NO
FACTORY_ADMISSION_LOCK:   ACTIVE — unchanged
RUNTIME_AUTHORITY:        NONE
SYSTEM_STATUS:            DEVELOPING — unchanged
GOVERNANCE_COMPLIANT:     YES
```
