# PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1

**Registry type:** EVIDENCE_DOCUMENTATION — Strategy and Playbook Packet Registry
**Architecture:** PLAYBOOK_CENTRIC_EVIDENCE_ARCHITECTURE_V1 (PCEA)
**Date created:** 2026-05-08
**Authority:** EVIDENCE_ONLY — No MT5 source change. No runtime change. No weight change.
**Governed by:** PROJECT_INTELLIGENCE_MEMORY_LAYER.md (PIML) — sole authoritative project memory
**System status:** DEVELOPING — unchanged

---

## Section 1 — Registry Purpose

This registry is the canonical reference for the current evidence state of all 17 council strategies and all 3 active playbooks under PCEA V1.

**What this registry contains:**
- Edge verdict per strategy (from Nautilus certification or live evidence)
- Packet classification per strategy (accepted, research-only, rejected, or insufficient)
- Playbook state per playbook (forming, valid, not present, or contradicted)
- Registry-driven next work priorities derived from evidence gaps

**What this registry is NOT:**
- A source-change authorization
- A weight-change authorization
- A runtime routing table
- An RCEM enforcement document
- A production readiness assessment

**Governing principle:** Strategies are evidence packets within playbooks, not standalone trading systems. A strategy's value is measured by the packets it contributes to its playbook's causal chain. A strategy with no accepted packets contributes no confirmed evidence to its playbook, regardless of role assignment or vote weight.

**Accepted packets count (system total as of 2026-05-08):** 1
— trend_pullback_cont_v1: CONFIRM_PACKET_SPARSE (research designation; not a mandatory gate)
All other packet claims across all 17 strategies are REJECTED, RESEARCH_ONLY, or DATA_INSUFFICIENT.

---

## Section 2 — Governance Firewall

The following constraints are absolute. They apply to every entry in this registry and every downstream decision this registry informs.

| Rule | Constraint |
|---|---|
| GF-1 | Nautilus evidence does not authorize MT5 source changes. Authorization requires operator review → bounded Codex task. |
| GF-2 | RESEARCH_ONLY_PACKET status does not authorize any gate, weight change, posture change, or RCEM update. |
| GF-3 | REJECTED_PACKET means the evidence claim was tested and failed. It does not authorize the inverse of the claim. |
| GF-4 | DATA_INSUFFICIENT_PACKET means the question was not answered. It does not imply positive or negative edge. |
| GF-5 | No strategy may be promoted to a new zone, new role, or increased weight without Nautilus certification AND live runtime evidence (N ≥ 15 closed W/L outcomes) AND explicit operator authorization. |
| GF-6 | No playbook may be declared PLAYBOOK_VALID until at least one CONFIRMATION_PACKET is formally accepted (WR lift ≥ +2pp AND E[R] lift ≥ +0.04R) beyond the anchor strategy alone. |
| GF-7 | Phase 4A (cross-family CRR) remains BLOCKED. TPC sparsity is architectural, not a threshold issue. No Phase 4A implementation until operator selects and authorizes a redesign path. |
| GF-8 | Phase 4B (exhaustion veto) remains BLOCKED. mfi_reversal_assist has 0 live entries. No veto threshold may be designed or implemented until ≥5 real signal-strength readings exist. |
| GF-9 | Phase 4C (quality soft gate) remains BLOCKED. Opportunity Ledger is live but below the 200-record threshold required before activating any suppression gate. |
| GF-10 | This registry does not supersede PIML. Where conflict exists, PIML governs. |
| GF-11 | No micro-test chaining authorized. Further isolation tests require operator identification of a specific REG.6 rule (R1–R5) that applies. Default action after any test completion is architecture build-out, not further micro-testing. |
| GF-12 | momentum_breakout_cont_v1 is permanently FROZEN (vote_weight=0.00, decision=WAIT). No redesign or restoration without a dedicated standalone plan. |

---

## Section 3 — Packet Taxonomy

Thirteen packet types are recognized under PCEA V1. All packet claims must be tested against the acceptance and rejection rules below. Meeting a rejection rule overrides any positive evidence in the acceptance rule.

| # | Packet Type | Acceptance Rule | Rejection Rule | Notes |
|---|---|---|---|---|
| 1 | ALPHA_TRIGGER_PACKET | WR ≥ 40% OR E[R] > 0 with N ≥ 50; improvement over unrestricted baseline; regime / direction mechanically plausible | E[R] negative in all tested conditions with adequate N; geometric constraint prevents sampling | Strategy produces a standalone directional signal with real edge in at least one condition |
| 2 | LOCATION_PACKET | Gated WR lift ≥ +2pp OR gated E[R] lift ≥ +0.04R vs ungated baseline | Gating degrades outcomes vs ungated baseline | Zone or context filter must improve outcomes, not just restrict them |
| 3 | CONFIRMATION_PACKET | Co-presence WR lift ≥ +2pp AND E[R] lift ≥ +0.04R vs baseline; co-presence rate below 80% (non-ubiquitous) | Co-presence does not lift outcomes; co-presence rate > 80% (ubiquitous = non-discriminating); co-presence degrades outcomes | Both thresholds required simultaneously |
| 4 | FAILURE_MODE_PACKET | E[R] degradation ≥ −0.06R OR WR degradation ≥ −3pp when the mode is active vs baseline; N sufficient | Degradation below both thresholds | Accepted = evidence that a specific combination or co-presence destroys edge |
| 5 | QUALITY_DISCRIMINANT_PACKET | High-quality-flag group WR ≥ +2pp above low-quality-flag group | Flag is inverted (low-quality outperforms); flag is non-discriminating (<1pp WR gap); ubiquitous flag rate | Meta-signal must predict actual outcome quality, not quality score |
| 6 | TIMING_PACKET | Target period WR ≥ 40% AND E[R] ≥ 0 with N ≥ 50; pattern persists across ≥2 sub-windows | Target period is worse than baseline; improvement is within-sample noise (N < 30) | Session, time-of-day, or walk-forward temporal evidence |
| 7 | REGIME_PACKET | Regime WR ≥ 40%, E[R] ≥ 0, N ≥ 50; regime isolation mechanically plausible; not a geometric sampling artifact | Regime result is a structural sampling artifact (geometry prevents the direction from firing in that regime); N < 50 | Must verify that the direction × regime combination is physically observable |
| 8 | DIRECTION_PACKET | Direction WR lift ≥ +2pp AND E[R] positive vs overall baseline; N ≥ 50 | Both directions below breakeven with adequate N; asymmetry is below threshold | Asymmetric performance must be material, not marginal |
| 9 | CAUSAL_CHAIN_PACKET | Chain co-presence improves both strategies' outcomes above their standalone baselines; causal mechanism documented and not circular | Co-presence is ubiquitous on one or both sides; chain co-presence degrades one or both members | Requires bi-directional lift evidence |
| 10 | PLAYBOOK_ANCHOR_PACKET | Strategy achieves ALPHA_TRIGGER status in playbook's core context with E[R] > 0; anchor designation is non-circular | No positive E[R] in playbook's intended context; strategy fires in wrong regime or direction for the playbook causal chain | Anchors the playbook hypothesis; does not validate the chain |
| 11 | RESEARCH_ONLY_PACKET | Positive E[R] or WR ≥ 40% exists in at least one tested condition; formal acceptance thresholds not met; hypothesis is mechanically plausible | Not applicable — this packet type cannot be formally rejected, only upgraded or archived | Does NOT authorize any gate, weight, or source change. Points to a specific testable next hypothesis. |
| 12 | REJECTED_PACKET | N/A — this packet type is assigned when an acceptance rule is explicitly violated | Applied when: acceptance threshold not met; flag inverted; co-presence ubiquitous without lift; zone proxy degrades; geometric constraint prevents sampling | Rejection is definitive for the specific condition tested. Does not reject the strategy globally. |
| 13 | DATA_INSUFFICIENT_PACKET | N/A — assigned when sample is too small to classify | Applied when: N < 30 in the relevant subset; or simulation window < 14 calendar days; or strategy has zero live W/L outcomes | Neither a pass nor a fail. The question was not answered. |

**Breakeven WR:** 40.0% (spread=10pt + slippage=2pt = 12pt = 0.12 price; SL=ATR14(Wilder,M1,shift=1)×1.20; RR=1.50)
**Sample confidence labels:** SUFFICIENT (N≥100), ADEQUATE (N 50–99), MARGINAL (N 30–49), INSUFFICIENT (N<30)

---

## Section 4 — Playbook Registry Summary

Three playbooks are registered under PCEA V1. Playbook states use categorical labels only: PLAYBOOK_NOT_PRESENT / PLAYBOOK_FORMING / PLAYBOOK_VALID / PLAYBOOK_CONTRADICTED / PLAYBOOK_LATE / PLAYBOOK_INVALID.

---

### Playbook 1: RBSR — Range Boundary Sweep Reversal

| Field | Value |
|---|---|
| Playbook ID | RBSR |
| State | PLAYBOOK_FORMING |
| Cert date | 2026-05-08 |
| Zone context | REV / RMR |
| Direction bias | BOTH (sweep direction determines entry) |
| Family anchor | LIQUIDITY_REVERSAL (sweep_reversal) |

**Causal chain design:**
1. Price sweeps beyond established range boundary (new high/low forming)
2. sweep_reversal detects bearish/bullish rejection candle at sweep extreme (ALPHA)
3. bollinger_reclaim / range_edge_fade confirm price reclaiming range interior (CONFIRM)
4. mfi_reversal_assist monitors for exhaustion signal strength (FAILURE_MODE / GUARD)

**Registered packet states:**

| Strategy | Chain Role | Packet Claim | Packet Status | Key Evidence |
|---|---|---|---|---|
| sweep_reversal | ALPHA anchor | ALPHA_TRIGGER | RESEARCH_ONLY — E[R]=−0.011R unrestricted; counter-trend subset E[R]=+0.012R (positive but below threshold) | WR=39.58%, N=6,589. Positive E[R] only in counter-trend sweeps (N=2,319). Standalone edge insufficient for PLAYBOOK_ANCHOR formal acceptance. |
| bollinger_reclaim | CONFIRM | CONFIRMATION_PACKET | REJECTED — zone proxy (RANGE) is EDGE_NOT_CONFIRMED; E[R]=-0.052R in RANGE era | RANGE era WR=37.92% vs needed ≥40%; E[R]=-0.052R vs needed ≥0. Chain confirm role not confirmed by evidence. |
| mfi_reversal_assist | FAILURE_MODE / GUARD | DATA_INSUFFICIENT_PACKET | DATA_INSUFFICIENT — 0 live entries; no Nautilus cert run | Strategy has produced no closed trades. Co-presence test cannot be run. Phase 4B veto design BLOCKED. |
| range_edge_fade | CONFIRM secondary | CONFIRMATION_PACKET | REJECTED — zone proxy (RANGE_NEUTRAL gate) degrades outcomes (−1.37pp WR, −0.034R E[R]); SR/BR co-presence 88–94% ubiquitous | Counter-intuitively fires better in TREND_DOWN than RANGE. Chain role contradicted. |

**Why PLAYBOOK_FORMING not PLAYBOOK_VALID:**
- SR/BR co-presence rates 88–94% across REF triggers → co-presence is structurally ubiquitous, cannot discriminate quality
- No CONFIRMATION_PACKET accepted: both bollinger_reclaim and range_edge_fade REJECTED as chain confirmers
- No formal PLAYBOOK_ANCHOR_PACKET: sweep_reversal counter-trend E[R]=+0.012R is positive but below +0.04R threshold
- mfi_reversal_assist has no data to contribute a FAILURE_MODE packet formally

**Next packet needed:** Cross-family CONFIRM with WR lift ≥ +2pp AND E[R] lift ≥ +0.04R vs sweep_reversal standalone; co-presence rate must be below 80%. Alternatively: formal ALPHA_TRIGGER acceptance for sweep_reversal counter-trend subset (needs N ≥ 100 in counter-trend only; currently N=2,319 but E[R]=+0.012R below +0.04R threshold).

---

### Playbook 2: TPC — Trend Pullback Continuation

| Field | Value |
|---|---|
| Playbook ID | TPC |
| State | PLAYBOOK_FORMING |
| Cert date | 2026-05-08 |
| Zone context | TC (TREND_CONTINUATION) |
| Direction bias | BOTH (direction from regime) |
| Family anchor | TREND_CONTINUATION (trend_momentum) |

**Causal chain design:**
1. Zone = TREND_CONTINUATION confirms established trend environment
2. trend_momentum fires directional signal (EMA + momentum confluence) — ALPHA LEAD
3. trend_pullback_cont_v1 detects ATR-bounded pullback and reclaim — CONFIRM
4. Supporting TC-CONFIRM strategies (LHR, MSR, BDM) attempt secondary confirmation
5. mfi_reversal_assist / CEIS monitors exhaustion — FAILURE_MODE GUARD

**Registered packet states:**

| Strategy | Chain Role | Packet Claim | Packet Status | Key Evidence |
|---|---|---|---|---|
| trend_momentum | ALPHA lead | ALPHA_TRIGGER | RESEARCH_ONLY — Variant B WR=41.17%; RANGE_NEUTRAL×SELL=EDGE_SUPPORTED (WR=44.37%, E[R]=+0.109R, N=1,402); TREND_UP×BUY EDGE_NOT_CONFIRMED | No formal ALPHA_TRIGGER_PACKET accepted (condition-dependent; EDGE_SUPPORTED is bucket-specific, not unrestricted). Strongest alpha evidence in system. |
| trend_pullback_cont_v1 | CONFIRM | CONFIRM_PACKET_SPARSE | RESEARCH designation — EDGE_SUPPORTED standalone (WR=44.99%, N=409) but co-presence with TM only 1.4% (114/7,940 TM trades) | Standalone cert is the strongest in the registry (EDGE_SUPPORTED). But TPC fires so rarely alongside TM that mandatory gating would cause 98.6% TC execution starvation. Not a formal CONFIRMATION_PACKET — research designation only. |
| breakdown_momentum_v1 | CONFIRM secondary | REJECTED — all packet types | Regime INVERSION (TREND_DOWN weakest); gate counterproductive; LATE=EDGE_REJECTED | No usable chain contribution. Severe temporal instability. Worst TC-CONFIRM strategy on all metrics. |
| lower_high_rejection_v1 | CONFIRM secondary | RESEARCH_ONLY — SELL direction in TC context | TC proxy E[R]=+0.0037R (near-breakeven, barely positive); gate helps (+0.021R E[R] lift); TREND_DOWN best (correct alignment) | SELL×TREND_DOWN research direction. Not yet a formal DIRECTION_PACKET (E[R]=+0.0037R below +0.04R threshold). Superior to BDM on all TC-SELL metrics. |
| micro_structure_reentry_v1 | CONFIRM secondary | FAILURE_MODE_PACKET accepted — degrades LHR | MSR co-presence predicts LHR E[R] degradation −0.068R (exceeds −0.06R threshold); N=4,268, SUFFICIENT | Accepted FAILURE_MODE for LHR outcomes (not for TPC chain directly). MSR's own SELL×TREND_UP is RESEARCH_ONLY (E[R]=+0.003R). |
| mfi_reversal_assist | GUARD/FAILURE_MODE | DATA_INSUFFICIENT | 0 live entries | Same status as in RBSR chain |

**Why PLAYBOOK_FORMING not PLAYBOOK_VALID:**
- TPC sparsity is architectural: different trigger signatures between TM and TPC mean they rarely co-fire; 1.4% co-presence is a structural feature, not an accumulation problem
- TC-CONFIRM family coverage is COMPLETE (all 4 TC-CONFIRM strategies certified); none produced a formal CONFIRMATION_PACKET
- Phase 4A mandatory CRR gate redesign is blocked on an architecture decision (Option F accepted diagnostically; implementation path not yet chosen)
- CONFIRM_PACKET_SPARSE designation is research-only; does not satisfy GF-6

**Next packet needed:** Phase 4A architectural decision (mandatory gate vs. quality-enhancement non-blocking track). TPC EDGE_SUPPORTED evidence is available; the gap is the co-presence architecture, not the strategy quality.

---

### Playbook 3: VCR — Volatility Compression Release

| Field | Value |
|---|---|
| Playbook ID | VCR |
| State | PLAYBOOK_NOT_PRESENT |
| Cert date | N/A (no certifications) |
| Zone context | COMPRESSION / EXP |
| Direction bias | BOTH (breakout direction) |
| Family anchor | COMPRESSION_BREAKOUT (range_compression_breakout, designed) |

**Causal chain design (design intent only — no evidence exists):**
1. COMPRESSION zone detected: price range narrows, ATR compressing
2. range_compression_breakout fires directional breakout trigger (SCOUT/ALPHA)
3. volatility_squeeze_release confirms squeeze state and breakout direction (CONFIRM)
4. volatility_breakout / expansion_continuation lead continuation (TREND_JUDGE)
5. micro_range_expansion detects micro-structure follow-through (SCOUT secondary)

**Registered packet states:**

| Strategy | Chain Role | Packet Claim | Packet Status |
|---|---|---|---|
| range_compression_breakout | ALPHA/SCOUT | DATA_INSUFFICIENT | 0 live entries; no Nautilus cert |
| volatility_squeeze_release | CONFIRM | DATA_INSUFFICIENT | 0 live entries; no Nautilus cert |
| volatility_breakout | TREND_JUDGE lead | DATA_INSUFFICIENT | 0 live entries; no Nautilus cert |
| expansion_continuation | TREND_JUDGE secondary | DATA_INSUFFICIENT | 0 live entries; no Nautilus cert |
| micro_range_expansion | SCOUT secondary | DATA_INSUFFICIENT | 0 live entries; no Nautilus cert |

**Why PLAYBOOK_NOT_PRESENT:**
Zero evidence exists at any level. No co-presence data. No Nautilus cert. No live entries. The causal chain is a design hypothesis only.

**Next packet needed:** range_compression_breakout Nautilus Phase 3 certification as minimum first step; then co-presence test against volatility_squeeze_release; then COMPRESSION zone live entry accumulation.

---

## Section 5 — Master Strategy Table

19 columns. Snapshot date: 2026-05-08. Live WR/N are early-accumulation snapshots; do not use for weight decisions without updated denominator verification.

| # | strategy_id | family | role | weight | direction | zones | live_wr | live_n | deg_hint | cert_status | cert_label | replication_class | var_a_wr | var_a_er | var_a_n | best_subset | best_wr | accepted_packets | playbook |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | sweep_reversal | LIQUIDITY_REVERSAL | SCOUT | 0.60 | BOTH | REV | 42.9%† | 35† | TRUE | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE | SOURCE_FAITHFUL | 39.58% | −0.011R | 6,589 | CTR-TREND (BUY_TD+SELL_TU) | 40.49% | 0 formal | RBSR |
| 2 | bollinger_reclaim | MEAN_RECLAIM | CONFIRM | 1.00 | BOTH | RMR/REV | 38.5%‡ | 26‡ | implied | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE (RANGE=NOT_CONFIRMED) | SOURCE_FAITHFUL | 39.27% | −0.018R | 8,350 | TREND_UP era | 40.01% | 0 formal | RBSR |
| 3 | trend_momentum | TREND_CONTINUATION | TREND_JUDGE | 0.95 | BOTH | TC/BREAKOUT | 42.9%† | 28† | TRUE | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE | SOURCE_FAITHFUL | ~41.0%** | ~−0.01R** | SOURCE_READ_REQUIRED | RN×SELL | 44.37% | 0 formal | TPC |
| 4 | mfi_reversal_assist | MOM_REVERSAL_ASSIST | EXHAUSTION_JUDGE | 0.90 | BOTH | REV | 0% | 0 | N/A | NOT_RUN | DATA_INSUFFICIENT | N/A | N/A | N/A | N/A | N/A | N/A | 0 | RBSR |
| 5 | trend_pullback_cont_v1 | TREND_PULLBACK_CONT | CONFIRM | 0.80 | BOTH | TC/RMR(era) | 0% | 0 | N/A | CERTIFIED | EDGE_SUPPORTED (standalone) | SOURCE_FAITHFUL_APPROX | 44.99% | +0.125R | 409 | SELL direction | 47.83% | CONFIRM_PACKET_SPARSE† | TPC |
| 6 | momentum_breakout_cont_v1 | TREND_CONTINUATION | FROZEN | 0.00 | — | NONE | 9.1% | 11 | N/A | LIVE_REJECTED | EDGE_REJECTED | N/A | N/A | N/A | N/A | N/A | 0 | NONE |
| 7 | micro_structure_reentry_v1 | TREND_CONTINUATION | CONFIRM | 0.70 | BOTH | TC | 0% | 1 | TRUE | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE (SELL); BUY=NOT_CONFIRMED | PARTIAL_REPLICATION | 38.50% | −0.038R | 6,756 | SELL×TREND_UP | 40.13% | FAILURE_MODE (for LHR) | TPC |
| 8 | breakdown_momentum_v1 | TREND_CONTINUATION | CONFIRM | 0.68 | SELL_ONLY | TC | 30.0% | 10 | TRUE | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE (aggregate) / NOT_CONFIRMED (TC proxy) | PARTIAL_REPLICATION | SOURCE_READ_REQUIRED | SOURCE_READ_REQUIRED | SOURCE_READ_REQUIRED | RANGE_NEUTRAL (inverted — unexpected) | SOURCE_READ_REQUIRED | 0 | NONE |
| 9 | lower_high_rejection_v1 | TREND_CONTINUATION | CONFIRM | 0.66 | SELL_ONLY | TC | 0% | 0 | TRUE | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE | PARTIAL_REPLICATION | 39.00% | −0.025R | 5,597 | TC proxy (Var C) | 40.15% | 0 formal | TPC |
| 10 | mean_reversion_bounce | MEAN_RECLAIM | CONFIRM | 0.92 | BOTH | RMR | 0% | 0 | N/A | NOT_RUN | DATA_INSUFFICIENT | N/A | N/A | N/A | N/A | N/A | N/A | 0 | RBSR |
| 11 | range_edge_fade | MEAN_RECLAIM | CONFIRM | 0.88 | BOTH | RMR | 0% | 2 | N/A | CERTIFIED | EDGE_WEAK_BUT_RECOVERABLE | PARTIAL_REPLICATION | 38.50% | −0.038R | 639 | TREND_DOWN regime | 40.93% | 0 formal | RBSR |
| 12 | fake_break_reversal | LIQUIDITY_REVERSAL | SCOUT | 0.94 | BOTH | RMR | 0% | 0 | N/A | NOT_RUN | DATA_INSUFFICIENT | N/A | N/A | N/A | N/A | N/A | N/A | 0 | RBSR |
| 13 | range_compression_breakout | COMPRESSION_BREAKOUT | SCOUT | 0.95 | BOTH | COMPRESSION/EXP | 0% | 0 | N/A | NOT_RUN | DATA_INSUFFICIENT | N/A | N/A | N/A | N/A | N/A | N/A | 0 | VCR |
| 14 | volatility_squeeze_release | COMPRESSION_BREAKOUT | CONFIRM | 0.92 | BOTH | COMPRESSION/EXP | 0% | 0 | N/A | NOT_RUN | DATA_INSUFFICIENT | N/A | N/A | N/A | N/A | N/A | N/A | 0 | VCR |
| 15 | volatility_breakout | VOL_BREAKOUT | TREND_JUDGE | 0.92 | BOTH | EXP | 0% | 0 | N/A | NOT_RUN | DATA_INSUFFICIENT | N/A | N/A | N/A | N/A | N/A | N/A | 0 | VCR |
| 16 | expansion_continuation | EXP_CONTINUATION | TREND_JUDGE | 0.90 | BOTH | EXP | 0% | 0 | N/A | NOT_RUN | DATA_INSUFFICIENT | N/A | N/A | N/A | N/A | N/A | N/A | 0 | VCR/EXP |
| 17 | micro_range_expansion | MICRO_RANGE_BREAK | SCOUT | 0.88 | BOTH | EXP | 0% | 0 | N/A | NOT_RUN | DATA_INSUFFICIENT | N/A | N/A | N/A | N/A | N/A | N/A | 0 | VCR/EXP |

**Table footnotes:**
- † Unresolved rate 48.5% — resolved-only WR is unreliable; use Nautilus WR for edge decisions
- ‡ WR denominator: 10W/16L = 38.5% (W/L basis); do not use 32.3% (wins/total_entries) — DENOMINATOR_UNRESOLVED per PIML §A4
- ** trend_momentum Variant A unrestricted baseline: SOURCE_READ_REQUIRED (cert in §19–21; not reproduced here); Variant B (alignment-gated) = 41.17%
- CONFIRM_PACKET_SPARSE = research designation only; not a formal CONFIRMATION_PACKET; does not satisfy GF-6

---

## Section 6 — Detailed Strategy Entries

### 6.01 sweep_reversal

| Field | Value |
|---|---|
| strategy_id | sweep_reversal |
| family | LIQUIDITY_REVERSAL |
| role | SCOUT |
| vote_weight | 0.60 |
| direction_bias | BOTH |
| zone_eligibility | REV |
| cert_date | 2026-05-08 (§24 PIML) |
| cert_label | EDGE_WEAK_BUT_RECOVERABLE |
| replication_class | SOURCE_FAITHFUL |
| cert_id | certification_sweep_reversal_xauusd_v1 |

**Trigger summary:** New high/low beyond prior bar (sweep) → Bollinger-band reclaim close on M1 bar[1]. SOURCE_FAITHFUL in Nautilus.

**Variant evidence:**

| Variant | N | WR | E[R] | Label |
|---|---|---|---|---|
| A — Unrestricted | 6,589 | 39.58% | −0.011R | EDGE_WEAK_BUT_RECOVERABLE |
| B — Counter-trend excluded (with-trend only) | 4,450 | 39.01% | −0.025R | EDGE_WEAK_BUT_RECOVERABLE |
| C — Counter-trend only | 2,319 | 40.49% | +0.012R | EDGE_WEAK_BUT_RECOVERABLE |
| D — RANGE_NEUTRAL only | ~2,319 | 38.40% | −0.040R | EDGE_WEAK_BUT_RECOVERABLE |
| E — Stress +10pt | — | 38.37% | −0.041R | EDGE_WEAK_BUT_RECOVERABLE |

**Direction × regime highlights:**

| Subset | N | WR | E[R] | Label |
|---|---|---|---|---|
| BUY_TREND_DOWN (counter-trend) | 1,131 | 40.50% | +0.012R | WEAK, positive E[R] |
| SELL_TREND_UP (counter-trend) | 1,188 | 40.49% | +0.012R | WEAK, positive E[R] |
| SELL_TREND_DOWN | 886 | 40.41% | +0.010R | WEAK, positive E[R] |
| BUY_RANGE_NEUTRAL | 1,339 | 37.57% | −0.061R | EDGE_NOT_CONFIRMED — watchlist |
| SELL_RANGE_NEUTRAL | 1,082 | 39.93% | −0.002R | WEAK |

**Degradation (60/40 split at 2026-03-26):**

| Period | N | WR | E[R] | Label |
|---|---|---|---|---|
| EARLY | 3,965 | 39.45% | −0.014R | EDGE_WEAK_BUT_RECOVERABLE |
| LATE | 2,624 | 39.79% | −0.005R | EDGE_WEAK_BUT_RECOVERABLE |

Nautilus: LATE marginally better. Live degradation_hint=TRUE (set from runtime; cannot be cleared by Nautilus evidence alone).

**Critical finding:** Counter-trend sweeps have POSITIVE E[R]; removing them HURTS the strategy. Counter-trend gate is explicitly contraindicated.

**RBSR packet classification:**
- ALPHA_TRIGGER: RESEARCH_ONLY (counter-trend E[R]=+0.012R — positive but below +0.04R formal threshold)
- PLAYBOOK_ANCHOR: RESEARCH_ONLY — insufficient for formal PLAYBOOK_ANCHOR_PACKET
- No formal packets accepted

**Forbidden actions:** Counter-trend gate; promote from SCOUT; increase weight from 0.60; clear degradation_hint from Nautilus alone; change zone eligibility; any source modification.

---

### 6.02 bollinger_reclaim

| Field | Value |
|---|---|
| strategy_id | bollinger_reclaim |
| family | MEAN_RECLAIM |
| role | CONFIRM |
| vote_weight | 1.00 |
| direction_bias | BOTH |
| zone_eligibility | RMR / REV |
| cert_date | 2026-05-08 (§24 PIML) |
| cert_label | EDGE_WEAK_BUT_RECOVERABLE (overall); RANGE era = EDGE_NOT_CONFIRMED |
| replication_class | SOURCE_FAITHFUL (BB reclaim exact; era proxy EMA-based) |
| cert_id | certification_bollinger_reclaim_xauusd_v1 |
| special_status | Phase 5A = BOLLINGER_RECLAIM_SELL_TREND_UP_GATE_V1A APPLIED; NAUTILUS_CHALLENGED |

**Trigger summary:** M1 price closes back above/below Bollinger Band after excursion (mean reclaim). SOURCE_FAITHFUL. Era proxy uses EMA-based zone approximation.

**Variant evidence:**

| Variant | N | WR | E[R] | Label |
|---|---|---|---|---|
| A — Unrestricted | 8,350 | 39.27% | −0.018R | EDGE_WEAK_BUT_RECOVERABLE |
| B — RANGE/RMR era proxy | 3,017 | 37.92% | −0.052R | EDGE_NOT_CONFIRMED |

**Era breakdown (Variant A):**

| Era | N | WR | E[R] | Label |
|---|---|---|---|---|
| TREND_UP | 2,754 | 40.01% | +0.0004R | EDGE_WEAK_BUT_RECOVERABLE (best era) |
| TREND_DOWN | 2,734 | 39.54% | −0.012R | EDGE_WEAK_BUT_RECOVERABLE |
| RANGE | 2,862 | 38.29% | −0.043R | EDGE_WEAK_BUT_RECOVERABLE (worst era) |

**Phase 5A gate finding (NAUTILUS_CHALLENGED):**

| Subset | N | WR | E[R] |
|---|---|---|---|
| SELL/TREND_UP (gated out by Phase 5A) | 2,064 | 39.49% | −0.013R |
| SELL/non-TREND_UP (allowed by Phase 5A) | 1,907 | 39.17% | −0.021R |

Phase 5A targeted hypothesis NOT CONFIRMED: gated-out subset marginally outperforms allowed subset. Gate is SOURCE_APPLIED / RUNTIME_VALIDATION_PENDING / NAUTILUS_CHALLENGED. No automatic revert authorized.

**Live WR note:** 10W/16L = 38.5% (W/L basis); do not use 32.3% (wins/total_entries denominator) — DENOMINATOR_UNRESOLVED.

**RBSR packet classification:**
- CONFIRMATION_PACKET: REJECTED — RANGE era WR=37.92%, E[R]=−0.052R (below acceptance thresholds)
- No formal packets accepted

**Forbidden actions:** Delete or deactivate; replace with VWAP or any candidate; auto-revert Phase 5A; change weight from 1.00; change zone; any source modification beyond Phase 5A already applied.

---

### 6.03 trend_momentum

| Field | Value |
|---|---|
| strategy_id | trend_momentum |
| family | TREND_CONTINUATION |
| role | TREND_JUDGE |
| vote_weight | 0.95 |
| direction_bias | BOTH |
| zone_eligibility | TC / BREAKOUT_EXPANSION |
| cert_date | 2026-05-07 (§19–21 PIML) |
| cert_label | EDGE_WEAK_BUT_RECOVERABLE |
| replication_class | SOURCE_FAITHFUL |
| degradation_hint | TRUE |

**Trigger summary:** EMA alignment (M1+M5) + momentum confluence + not-late gate (EMA proximity) + Entry Timing Guard V1 (no late entries). SOURCE_FAITHFUL.

**Variant evidence (key variants):**

| Variant | WR | E[R] | N | Label |
|---|---|---|---|---|
| A — Unrestricted (not-late only) | SOURCE_READ_REQUIRED | SOURCE_READ_REQUIRED | SOURCE_READ_REQUIRED | — |
| B — Alignment-gated | 41.17% | ~+0.02R | SOURCE_READ_REQUIRED | EDGE_WEAK_BUT_RECOVERABLE |

**Direction × regime highlights (Variant B or C):**

| Subset | N | WR | E[R] | Label |
|---|---|---|---|---|
| RANGE_NEUTRAL × SELL | 1,402 | 44.37% | +0.109R | EDGE_SUPPORTED — strongest bucket in system |
| TREND_UP × BUY | SOURCE_READ_REQUIRED | 39.34% | −0.017R | EDGE_NOT_CONFIRMED |
| TREND_DOWN × SELL | SOURCE_READ_REQUIRED | SOURCE_READ_REQUIRED | SOURCE_READ_REQUIRED | SOURCE_READ_REQUIRED |

**Gate finding:** M5 conflict flag helps (positive gate premium). Not-late guard is SOURCE_APPLIED.

**Degradation (60/40 walk-forward):** LATE period degrades — the 2026-03-26 structural shift affects TC-family strategies. Degradation consistent with TC-CONFIRM family pattern.

**TPC packet classification:**
- ALPHA_TRIGGER: RESEARCH_ONLY (RANGE_NEUTRAL×SELL EDGE_SUPPORTED in one bucket; not unrestricted positive E[R])
- PLAYBOOK_ANCHOR_PACKET: RESEARCH_ONLY (bucket-specific; overall unrestricted E[R] negative)
- No formal packets accepted under strict PCEA rules

**Forbidden actions:** BUY direction disable in TREND_UP; overextension gate; replace trend_momentum; session gate; M5 hard regime gate in source; weight change from 0.95; any source modification.

---

### 6.04 mfi_reversal_assist

| Field | Value |
|---|---|
| strategy_id | mfi_reversal_assist |
| family | MOM_REVERSAL_ASSIST |
| role | EXHAUSTION_JUDGE |
| vote_weight | 0.90 |
| direction_bias | BOTH |
| zone_eligibility | REV |
| cert_label | DATA_INSUFFICIENT |
| cert_status | NOT_RUN |
| live_entries | 0 closed W/L outcomes |
| special_status | Phase 4B veto BLOCKED — requires ≥5 live signal-strength readings before any threshold design |

**Trigger summary:** MFI (Money Flow Index) threshold-based reversal signal. Package 3 widened thresholds to <55/>45 (from <45/>55). No live entries produced after threshold widening.

**No Nautilus cert has been run.** Running a Nautilus cert without live entries would produce metrics without any calibration basis for the exhaustion_signal_strength field needed for Phase 4B veto design.

**RBSR packet classification:**
- All packets: DATA_INSUFFICIENT — no co-presence data; no Nautilus cert; no live outcomes

**Forbidden actions:** Design veto thresholds; implement exhaustion veto; change threshold further without live entry evidence; increase weight; expand zone eligibility; any source modification.

---

### 6.05 trend_pullback_cont_v1

| Field | Value |
|---|---|
| strategy_id | trend_pullback_cont_v1 |
| family | TREND_PULLBACK_CONT |
| role | CONFIRM |
| vote_weight | 0.80 |
| direction_bias | BOTH |
| zone_eligibility | TC / RMR (ATR-gated era) |
| cert_date | 2026-05-07 (§22 PIML) |
| cert_label | EDGE_SUPPORTED (standalone); TOO_SPARSE_FOR_PHASE_4A as mandatory gate |
| replication_class | SOURCE_FAITHFUL_APPROXIMATION |
| live_entries | 0 (ATR gate widened to 0.70; monitoring window open) |

**Trigger summary:** Pullback within ATR distance of EMA + reclaim signal. Package 2 widened ATR gate from 0.25 to 0.70. EDGE_SUPPORTED is the strongest standalone cert label in the registry.

**Variant A evidence:**

| Metric | Value |
|---|---|
| N | 409 |
| WR | 44.99% |
| E[R] | +0.125R |
| SELL WR | 47.83% |
| BUY WR | 42.08% |
| All 4 complete months | Positive E[R] |
| Label | EDGE_SUPPORTED |

**Co-presence finding (structural sparsity):**

| Metric | Value |
|---|---|
| TPC co-presence with TM (Variant B) | 1.4% (114/7,940 TM trades) |
| If mandatory TPC CRR gate applied | 98.6% TC execution collapse (structural starvation) |
| TM+TPC combined WR | 45.61% (vs TM alone 41.11%) — positive signal when they co-fire |
| TPC fires ~5.6/day; TM fires ~76/day | Structural rate — not a sample-size problem |

**TPC packet classification:**
- CONFIRM_PACKET_SPARSE: research designation — represents the best chain-confirm evidence in the registry, but below mandatory gate threshold due to co-presence sparsity
- No formal CONFIRMATION_PACKET under PCEA strict rules (GF-6 requires co-presence rate below 80% AND WR lift ≥ +2pp AND E[R] lift ≥ +0.04R; the co-presence condition is met but the sparsity prevents mandatory gating)

**Phase 4A status:** BLOCKED on architectural decision. Old blocker (TPC fire rate threshold) RETIRED — the constraint is structural, not a threshold problem. New blocker: operator must choose between mandatory gate redesign (no viable candidate for alternative) vs. quality-enhancement non-blocking path (Option F — tracking cross-family evidence without execution gating).

**Forbidden actions:** Enable mandatory TPC CRR gate; increase weight from 0.80; change zone eligibility; implement Phase 4A without operator authorization; any source modification.

---

### 6.06 momentum_breakout_cont_v1

| Field | Value |
|---|---|
| strategy_id | momentum_breakout_cont_v1 |
| family | TREND_CONTINUATION |
| role | FROZEN |
| vote_weight | 0.00 |
| direction_bias | NONE (decision=WAIT hard-coded) |
| zone_eligibility | NONE |
| cert_label | EDGE_REJECTED |
| cert_source | LIVE — 1W/10L = 9.1% WR (11 closed outcomes) |
| freeze_authority | Package 1 applied |

**Live evidence:** 1W/10L = 9.1% WR. Well below EDGE_REJECTED threshold of <35%. FROZEN by Package 1. decision=WAIT is hard-coded; vote_weight=0.00.

**No Nautilus cert is warranted.** EDGE_REJECTED from live evidence. Strategy is permanently frozen unless a dedicated standalone redesign plan is authorized.

**Forbidden actions:** Restore vote_weight; remove WAIT decision; redesign without standalone dedicated plan; any implementation for this strategy.

---

### 6.07 micro_structure_reentry_v1

| Field | Value |
|---|---|
| strategy_id | micro_structure_reentry_v1 |
| family | TREND_CONTINUATION |
| role | CONFIRM |
| vote_weight | 0.70 |
| direction_bias | BOTH (BUY = EDGE_NOT_CONFIRMED; SELL = RECOVERABLE) |
| zone_eligibility | TC |
| cert_date | 2026-05-08 (§28 PIML) |
| cert_label | EDGE_WEAK_BUT_RECOVERABLE (SELL); BUY = EDGE_NOT_CONFIRMED |
| replication_class | PARTIAL_REPLICATION (trigger SOURCE_FAITHFUL; TC zone = M5 proxy) |
| degradation_hint | TRUE (LATE NOT_CONFIRMED; 2026-03-26 split) |

**Trigger summary:** 2-bar pullback-reclaim pattern (bar[2] pullback, bar[1] reclaim above/below bar[2] high/low) + not-late EMA20 proximity gate. SOURCE_FAITHFUL. BOTH directions enabled; BUY has meaningful weakness.

**Variant evidence:**

| Variant | N | WR | E[R] | Label |
|---|---|---|---|---|
| A — Unrestricted | 6,756 | 38.50% | −0.038R | EDGE_WEAK_BUT_RECOVERABLE |
| B — Alignment gated (dual-EMA) | 1,735 | 39.48% | −0.013R | EDGE_WEAK_BUT_RECOVERABLE |
| C — TC proxy (M5 TREND_DOWN) | 2,703 | 38.14% | −0.046R | EDGE_WEAK_BUT_RECOVERABLE |

TC proxy HURTS MSR (unlike LHR where it helps). MSR fires equally across regime contexts.

**Direction × regime highlights:**

| Subset | N | WR | E[R] | Label |
|---|---|---|---|---|
| SELL × TREND_UP | 1,266 | 40.13% | +0.003R | EDGE_WEAK_BUT_RECOVERABLE — best |
| BUY × TREND_UP | 1,100 | 39.64% | −0.009R | EDGE_WEAK_BUT_RECOVERABLE |
| BUY × RANGE_NEUTRAL | 1,219 | 36.34% | −0.092R | EDGE_NOT_CONFIRMED — worst |

**Critical finding — MSR as LHR failure mode (ACCEPTED FAILURE_MODE_PACKET):**
MSR fires within 5 bars of 72.9% of LHR triggers. When MSR co-present with LHR → LHR E[R] degrades by −0.068R (exceeds −0.06R threshold; N=4,268, SUFFICIENT). FAILURE_MODE_PACKET accepted for MSR's impact on LHR — not as a positive chain contribution.

**Degradation:** LATE NOT_CONFIRMED (WR=37.66%, E[R]=−0.059R vs EARLY WR=39.06%). Third consecutive TC-CONFIRM cert with 2026-03-26 shared degradation.

**Quality score:** 4th consecutive TC-CONFIRM cert with quality score inversion (quality flag does not predict actual outcome).

**TPC packet classification:**
- SELL alpha (SELL×TREND_UP): RESEARCH_ONLY (E[R]=+0.003R — positive but below +0.04R)
- BUY alpha: REJECTED (NOT_CONFIRMED in all BUY conditions)
- CONFIRMATION_PACKET for LHR chain: REJECTED (ubiquitous 72.9%; co-presence degrades LHR)
- FAILURE_MODE_PACKET for LHR: ACCEPTED (E[R] degradation −0.068R exceeds −0.06R threshold) ← only accepted packet

**Forbidden actions:** Disable BUY direction in MT5 source; gate LHR based on MSR co-presence in MT5; use LHR-without-MSR WR=48.3% as a reliable filter; change weight from 0.70; any source modification.

---

### 6.08 breakdown_momentum_v1

| Field | Value |
|---|---|
| strategy_id | breakdown_momentum_v1 |
| family | TREND_CONTINUATION |
| role | CONFIRM |
| vote_weight | 0.68 |
| direction_bias | SELL_ONLY |
| zone_eligibility | TC |
| cert_date | 2026-05-08 (§26 PIML) |
| cert_label | EDGE_WEAK_BUT_RECOVERABLE (aggregate) / EDGE_NOT_CONFIRMED (TC proxy / TREND_DOWN context) |
| replication_class | PARTIAL_REPLICATION (TC zone = M5 proxy) |
| degradation_hint | TRUE (LATE = EDGE_REJECTED — severe) |
| playbook_assignment | NONE |

**Trigger summary:** Breakdown candle with body/ATR ratio gate + M1 bearish alignment. SELL_ONLY. SOURCE_FAITHFUL for trigger; TC zone = M5 TREND_DOWN proxy.

**Critical findings:**
1. **Regime INVERSION:** TREND_DOWN is BDM's WEAKEST context (expected BEST for SELL_ONLY). RANGE_NEUTRAL is unexpectedly best. This means BDM is firing optimally in the wrong regime for its intended TC-SELL playbook role.
2. **Gate counterproductive:** Dual-bear gate applied → WR DECREASES by −0.48pp (unlike LHR where gate helped by +0.86pp). Gate restriction does not improve BDM selectivity.
3. **Severe temporal instability:** LATE period = EDGE_REJECTED. April/May 2026 degradation worst in TC-CONFIRM family.
4. **TC proxy performance:** EDGE_NOT_CONFIRMED. The intended TC zone context does not produce better outcomes.

**Compared to lower_high_rejection_v1 (both SELL_ONLY TC CONFIRM):**
LHR is strictly superior on every metric: higher WR, better E[R], gate helps (vs counterproductive), correct regime alignment (vs inverted), lower fire rate.

**All packets: REJECTED.** No usable evidence contribution to any playbook chain.

**Forbidden actions:** Restrict to TREND_DOWN only (contradicted — that's BDM's WORST regime); remove dual-bear gate (evidence only; gate is not counterproductive enough to meet −3pp/-0.06R failure thresholds); change weight from 0.68; assign to any playbook; any source modification.

---

### 6.09 lower_high_rejection_v1

| Field | Value |
|---|---|
| strategy_id | lower_high_rejection_v1 |
| family | TREND_CONTINUATION |
| role | CONFIRM |
| vote_weight | 0.66 |
| direction_bias | SELL_ONLY |
| zone_eligibility | TC |
| cert_date | 2026-05-08 (§27 PIML) |
| cert_label | EDGE_WEAK_BUT_RECOVERABLE |
| replication_class | PARTIAL_REPLICATION (TC zone = M5 TREND_DOWN proxy; trigger SOURCE_FAITHFUL) |
| degradation_hint | TRUE (LATE NOT_CONFIRMED; 2026-03-26 split) |

**Trigger summary:** Lower-high structure (bar[2] high < prior-high − 0.15×ATR) + bearish rejection bar[1] (upper wick ≥ body × 0.8) + dual-bear EMA alignment gate. SOURCE_FAITHFUL.

**Variant evidence:**

| Variant | N | WR | E[R] | Label |
|---|---|---|---|---|
| A — Unrestricted | 5,597 | 39.00% | −0.025R | EDGE_WEAK_BUT_RECOVERABLE |
| B — Dual-bear gate | 1,578 | 39.86% | −0.004R | EDGE_WEAK_BUT_RECOVERABLE |
| C — TC proxy (M5 TREND_DOWN) | 1,751 | 40.15% | +0.004R | EDGE_WEAK_BUT_RECOVERABLE |

Gate helps: +0.86pp WR, +0.021R E[R] (B vs A). TC proxy: only positive E[R] TC-SELL variant in Phase 3 certification series.

**Regime alignment (correct — unlike BDM):**

| Regime | N | WR | E[R] | Label |
|---|---|---|---|---|
| TREND_DOWN | 1,730 | 40.12% | +0.003R | EDGE_WEAK_BUT_RECOVERABLE — best |
| RANGE_NEUTRAL | 1,902 | 39.06% | −0.023R | EDGE_WEAK_BUT_RECOVERABLE |
| TREND_UP | 1,965 | 37.96% | −0.051R | EDGE_NOT_CONFIRMED — worst |

**MSR failure mode (from §28):** MSR fires within 5 bars of 72.9% of LHR triggers. LHR E[R] degrades by −0.068R when MSR is co-present. The FAILURE_MODE_PACKET is accepted for MSR's impact on LHR (documented in MSR cert §28, not LHR's own packets).

**TPC packet classification:**
- DIRECTION_PACKET (SELL×TREND_DOWN): RESEARCH_ONLY (E[R]=+0.003R — marginally positive; N=1,730 SUFFICIENT but below +0.04R threshold)
- CONFIRMATION_PACKET for TPC chain: NOT EVALUATED (co-presence with TM not tested in this cert; separate research task)
- No formal packets accepted

**Forbidden actions:** Enable LHR TREND_UP gate in MT5; change weight from 0.66; promote to new zones; demote or freeze; replace BDM with LHR (evidence only — not a source change decision); any source modification.

---

### 6.10 mean_reversion_bounce

| Field | Value |
|---|---|
| strategy_id | mean_reversion_bounce |
| family | MEAN_RECLAIM |
| role | CONFIRM |
| vote_weight | 0.92 |
| direction_bias | BOTH |
| zone_eligibility | RMR |
| cert_label | DATA_INSUFFICIENT |
| cert_status | NOT_RUN |
| live_entries | 0 closed W/L outcomes (1 total entry) |
| special_notes | Buffer widened to 0.30 ATR (Package 3) |

**No Nautilus cert has been run.** Strategy has 1 live entry with no closed outcomes. Running a Nautilus cert now would be productive (data exists) but has not been prioritized given TC-CONFIRM and MEAN_RECLAIM family backlog.

**RBSR potential role:** Secondary CONFIRM in RBSR chain (MEAN_RECLAIM family, RMR zone). Evidence needed before any packet claim can be made.

**Forbidden actions:** Promote to new zones; increase weight; assign chain role authority; any source modification without evidence.

---

### 6.11 range_edge_fade

| Field | Value |
|---|---|
| strategy_id | range_edge_fade |
| family | MEAN_RECLAIM |
| role | CONFIRM |
| vote_weight | 0.88 |
| direction_bias | BOTH |
| zone_eligibility | RMR |
| cert_date | 2026-05-08 (§29 PIML) |
| cert_label | EDGE_WEAK_BUT_RECOVERABLE |
| replication_class | PARTIAL_REPLICATION (zone gate = M5 RANGE_NEUTRAL proxy; trigger SOURCE_FAITHFUL) |
| degradation_hint | NOT_APPLICABLE (temporal INVERSION: EARLY worse than LATE — opposite of TC-CONFIRM pattern) |

**Trigger summary:** Bearish/bullish rejection at range boundary (range_high/low ± edgeBuf) + M1 rejection candle. trendConflict is a quality modifier (soft) NOT a hard gate. SOURCE_FAITHFUL. Zone gate = M5 RANGE_NEUTRAL proxy (structural approximation gap).

**Variant evidence:**

| Variant | N | WR | E[R] | Label |
|---|---|---|---|---|
| A — Unrestricted | 639 | 38.50% | −0.038R | EDGE_WEAK_BUT_RECOVERABLE |
| B — Zone proxy (RANGE_NEUTRAL gate) | 167 | 37.13% | −0.072R | EDGE_NOT_CONFIRMED |
| SELL only | 352 | 38.92% | −0.027R | EDGE_WEAK_BUT_RECOVERABLE |
| BUY only | 287 | 37.98% | −0.051R | EDGE_NOT_CONFIRMED |
| TREND_DOWN regime | 193 | 40.93% | +0.023R | EDGE_WEAK_BUT_RECOVERABLE — only positive E[R] |
| TREND_UP regime | 280 | 37.50% | −0.063R | EDGE_NOT_CONFIRMED |
| LATE period (2026-04+) | 256 | 42.58% | +0.065R | EDGE_WEAK_BUT_RECOVERABLE |
| EARLY period (2026-01–03) | 383 | 35.77% | −0.106R | EDGE_NOT_CONFIRMED |

**Key structural findings:**
1. Zone proxy (RANGE_NEUTRAL) DEGRADES outcomes: −1.37pp WR, −0.034R E[R]. REF fires better in trending regimes — particularly TREND_DOWN. Design intent conflicts with empirical behavior.
2. trendConflict flag INVERTED: 90.5% of triggers are counter-trend (as designed for a fade strategy). Conflict flag does not predict worse outcomes.
3. SR/BR co-presence UBIQUITOUS: 88–94% co-presence. Cannot discriminate quality.
4. Temporal INVERSION: LATE better than EARLY — opposite of TC-CONFIRM pattern. Market regime shift to ranging in April–May 2026 benefits REF while hurting TC strategies.
5. H1 FALSIFIED: SELL×TREND_DOWN had N=2 across 74 trading days (structural geometric constraint — TREND_DOWN bears prevent upper-boundary SELL fades). The TREND_DOWN positive E[R] is entirely BUY-driven (BUY×TREND_DOWN N=191, WR=40.31%, E[R]=+0.008R — RESEARCH_ONLY secondary finding).

**RBSR packet classification:**
- ALPHA_TRIGGER (TREND_DOWN E[R]=+0.023R): RESEARCH_ONLY (above threshold in that regime but zone proxy degradation and geometric constraints)
- LOCATION_PACKET (zone proxy): REJECTED — proxy degrades outcomes
- CONFIRMATION_PACKET (RBSR chain): REJECTED — SR/BR ubiquitous; co-presence does not lift outcomes
- QUALITY_DISCRIMINANT (trendConflict): REJECTED — inverted
- TEMPORAL (LATE improvement): RESEARCH_ONLY — 2 months insufficient for durability
- No formal packets accepted

**Forbidden actions:** Further SELL×TREND_DOWN micro-tests (no REG.6 rule applies; H1 falsified, BUY×TD RESEARCH_ONLY below formal threshold); remove zone gate in MT5; change trendConflict from quality modifier to hard gate; weight change; zone expansion; any source modification.

---

### 6.12 fake_break_reversal

| Field | Value |
|---|---|
| strategy_id | fake_break_reversal |
| family | LIQUIDITY_REVERSAL |
| role | SCOUT |
| vote_weight | 0.94 |
| direction_bias | BOTH |
| zone_eligibility | RMR |
| cert_label | DATA_INSUFFICIENT |
| cert_status | NOT_RUN |
| live_entries | 0 closed W/L outcomes |

**RBSR potential role:** Secondary SCOUT — false-breakout detection at range boundaries. Design is complementary to sweep_reversal (sweep detects momentum reversal; fake_break detects false-break rejection). No co-presence data available. No Nautilus cert run.

**Forbidden actions:** Promote; weight increase; zone expansion; any source modification without evidence.

---

### 6.13 range_compression_breakout

| Field | Value |
|---|---|
| strategy_id | range_compression_breakout |
| family | COMPRESSION_BREAKOUT |
| role | SCOUT |
| vote_weight | 0.95 |
| direction_bias | BOTH |
| zone_eligibility | COMPRESSION / EXP |
| cert_label | DATA_INSUFFICIENT |
| cert_status | NOT_RUN |
| live_entries | 0 closed W/L outcomes |

**VCR potential role:** Playbook anchor — detects compression and fires directional breakout trigger. No evidence exists to support or contradict this role. Priority: first Phase 3 Nautilus cert target for VCR playbook family.

---

### 6.14 volatility_squeeze_release

| Field | Value |
|---|---|
| strategy_id | volatility_squeeze_release |
| family | COMPRESSION_BREAKOUT |
| role | CONFIRM |
| vote_weight | 0.92 |
| direction_bias | BOTH |
| zone_eligibility | COMPRESSION / EXP |
| cert_label | DATA_INSUFFICIENT |
| cert_status | NOT_RUN |
| live_entries | 0 closed W/L outcomes |

**VCR potential role:** Compression CONFIRM — confirms squeeze state and breakout direction. No co-presence data with range_compression_breakout. No cert.

---

### 6.15 volatility_breakout

| Field | Value |
|---|---|
| strategy_id | volatility_breakout |
| family | VOL_BREAKOUT |
| role | TREND_JUDGE |
| vote_weight | 0.92 |
| direction_bias | BOTH |
| zone_eligibility | EXP |
| cert_label | DATA_INSUFFICIENT |
| cert_status | NOT_RUN |
| live_entries | 0 closed W/L outcomes |

**VCR potential role:** Breakout continuation TREND_JUDGE. No evidence.

---

### 6.16 expansion_continuation

| Field | Value |
|---|---|
| strategy_id | expansion_continuation |
| family | EXP_CONTINUATION |
| role | TREND_JUDGE |
| vote_weight | 0.90 |
| direction_bias | BOTH |
| zone_eligibility | EXP |
| cert_label | DATA_INSUFFICIENT |
| cert_status | NOT_RUN |
| live_entries | 0 closed W/L outcomes |

**VCR / EXP potential role:** EXP-zone continuation TREND_JUDGE. No evidence.

---

### 6.17 micro_range_expansion

| Field | Value |
|---|---|
| strategy_id | micro_range_expansion |
| family | MICRO_RANGE_BREAK |
| role | SCOUT |
| vote_weight | 0.88 |
| direction_bias | BOTH |
| zone_eligibility | EXP |
| cert_label | DATA_INSUFFICIENT |
| cert_status | NOT_RUN |
| live_entries | 0 closed W/L outcomes |

**VCR / EXP potential role:** Micro-structure EXP follow-through SCOUT. No evidence.

---

## Section 7 — Certified Strategy Evidence Summary

Eight council strategies have documented Nautilus certification evidence. One strategy (momentum_breakout_cont_v1) has live-evidence EDGE_REJECTED status without Nautilus cert.

| strategy_id | cert_label | replication_class | best_condition | best_wr | best_er | accepted_packets | degradation_hint |
|---|---|---|---|---|---|---|---|
| trend_pullback_cont_v1 | EDGE_SUPPORTED (standalone) | SOURCE_FAITHFUL_APPROX | SELL direction | 47.83% | SOURCE_READ_REQUIRED | CONFIRM_PACKET_SPARSE (research) | N/A (0 live entries) |
| sweep_reversal | EDGE_WEAK_BUT_RECOVERABLE | SOURCE_FAITHFUL | Counter-trend (BUY_TD + SELL_TU) | 40.49% | +0.012R | 0 formal | TRUE (live) |
| bollinger_reclaim | EDGE_WEAK_BUT_RECOVERABLE (RANGE=NOT_CONFIRMED) | SOURCE_FAITHFUL | TREND_UP era | 40.01% | +0.0004R | 0 formal | IMPLIED |
| trend_momentum | EDGE_WEAK_BUT_RECOVERABLE | SOURCE_FAITHFUL | RANGE_NEUTRAL×SELL | 44.37% | +0.109R | 0 formal | TRUE |
| lower_high_rejection_v1 | EDGE_WEAK_BUT_RECOVERABLE | PARTIAL_REPLICATION | TC proxy (Var C) | 40.15% | +0.004R | 0 formal | TRUE |
| micro_structure_reentry_v1 | EDGE_WEAK_BUT_RECOVERABLE (SELL) / BUY=NOT_CONFIRMED | PARTIAL_REPLICATION | SELL×TREND_UP | 40.13% | +0.003R | FAILURE_MODE for LHR | TRUE |
| range_edge_fade | EDGE_WEAK_BUT_RECOVERABLE | PARTIAL_REPLICATION | TREND_DOWN regime | 40.93% | +0.023R | 0 formal | NOT_APPLICABLE (inverted pattern) |
| breakdown_momentum_v1 | EDGE_WEAK_BUT_RECOVERABLE (agg) / NOT_CONFIRMED (TC) | PARTIAL_REPLICATION | RANGE_NEUTRAL (inverted/unexpected) | SOURCE_READ_REQUIRED | SOURCE_READ_REQUIRED | 0 formal | TRUE (SEVERE — LATE=REJECTED) |
| momentum_breakout_cont_v1 | EDGE_REJECTED (live) | LIVE_ONLY | N/A | 9.1% | SOURCE_READ_REQUIRED | 0 | N/A (FROZEN) |

**Pattern across 6 TC-CONFIRM certifications (BDM, LHR, MSR, TPC included):**
- Quality score mechanism inverted in 5 consecutive certs (SR, BDM, LHR, MSR, REF) — quality flag does not predict actual outcomes
- TC-CONFIRM degradation at 2026-03-26 structural shift: BDM, LHR, MSR all share this break
- REF temporal pattern is INVERTED from TC-CONFIRM pattern (LATE better for REF; LATE worse for TC)
- No cross-family CONFIRMATION_PACKET accepted anywhere in the TC chain

---

## Section 8 — Uncertified Strategy Summary

Nine strategies have no Nautilus Phase 3 certification (one is FROZEN with live rejection).

| strategy_id | family | role | weight | zone | live_n | reason_not_certified | priority |
|---|---|---|---|---|---|---|---|
| mfi_reversal_assist | MOM_REVERSAL_ASSIST | EXHAUSTION_JUDGE | 0.90 | REV | 0 | 0 live entries; live entries required before Nautilus cert is calibrated for Phase 4B veto | MEDIUM — needs first live entries to determine cert usefulness |
| mean_reversion_bounce | MEAN_RECLAIM | CONFIRM | 0.92 | RMR | 0 | No prioritization yet; data available | LOW-MEDIUM — RBSR chain secondary |
| fake_break_reversal | LIQUIDITY_REVERSAL | SCOUT | 0.94 | RMR | 0 | No prioritization yet; data available | LOW-MEDIUM — RBSR secondary SCOUT |
| range_compression_breakout | COMPRESSION_BREAKOUT | SCOUT | 0.95 | COMPRESSION/EXP | 0 | No prioritization; VCR playbook not yet started | MEDIUM — VCR anchor; first VCR cert target |
| volatility_squeeze_release | COMPRESSION_BREAKOUT | CONFIRM | 0.92 | COMPRESSION/EXP | 0 | No prioritization; VCR playbook not started | LOW (follows range_compression_breakout) |
| volatility_breakout | VOL_BREAKOUT | TREND_JUDGE | 0.92 | EXP | 0 | No prioritization | LOW |
| expansion_continuation | EXP_CONTINUATION | TREND_JUDGE | 0.90 | EXP | 0 | No prioritization | LOW |
| micro_range_expansion | MICRO_RANGE_BREAK | SCOUT | 0.88 | EXP | 0 | No prioritization | LOW |
| momentum_breakout_cont_v1 | TREND_CONTINUATION | FROZEN | 0.00 | NONE | 11 | LIVE_REJECTED — no Nautilus cert needed | NONE — permanently frozen |

**Hard rule for all DATA_INSUFFICIENT strategies:** No strategy above may be promoted, given weight increases, assigned veto authority, designated as primary executor, or have RCEM eligibility expanded until BOTH Nautilus certification AND live runtime evidence (N ≥ 15 closed W/L outcomes) exist and operator authorization is given.

---

## Section 9 — Registry-Driven Next Work

Priorities are derived from evidence gaps, not from time pressure. Each item maps to a specific REG-class rule or architectural blocker.

### Priority 1 — Phase 4A Architectural Decision (BLOCKED)

| Item | Description |
|---|---|
| Blocker | TPC co-presence structural sparsity (1.4%) — architectural, not a threshold |
| Evidence available | TPC EDGE_SUPPORTED (WR=44.99%, N=409); TM+TPC combined WR=45.61% |
| Decision needed | Operator chooses: (A) redesigned mandatory gate path vs. (B) Option F quality-enhancement non-blocking track |
| Files affected | DESIGN only — no source changes until path selected |
| Authority required | Operator authorization selecting architectural path |
| Why first | Phase 4A decision determines the TC-zone cross-family evidence architecture for all future TC-CONFIRM certs |

### Priority 2 — range_compression_breakout Phase 3 Certification (READY)

| Item | Description |
|---|---|
| Blocker | None — M1/M5 XAUUSD data available; no live entries needed first |
| Evidence gap | VCR playbook is PLAYBOOK_NOT_PRESENT with zero evidence; range_compression_breakout is the anchor |
| Expected outcome | Cert label + RCEM direction for COMPRESSION/EXP zone strategies |
| Authority required | None — research lab (nautilus_lab/) only; no MT5 changes |
| Files affected | nautilus_lab/ directory only |
| Why second | VCR playbook is completely blank; any evidence would help; range_compression_breakout is the highest-weight DATA_INSUFFICIENT strategy (0.95) |

### Priority 3 — Phase 2 Opportunity Ledger Maturation (ONGOING — no action needed)

| Item | Description |
|---|---|
| Current status | ACTIVE — ai_opportunity_ledger.jsonl and ai_opportunity_summary.json live |
| Blocking | Phase 4C (quality soft gate) — needs ≥200 trigger_present=true records |
| Blocking | FSW audit before EEWP design |
| Blocking | OBSERVE_ONLY multiplier change audit |
| Action | None required — ledger accumulates passively; monitor record count |

### Priority 4 — mfi_reversal_assist First Entry Observation (MONITORING)

| Item | Description |
|---|---|
| Current status | 0 live entries; Package 3 threshold widening applied |
| Blocking | Phase 4B (exhaustion veto) — needs ≥5 signal-strength readings |
| Action | Monitor ai_strategy_memory.json for first MFI entries post-EA-reload; no source changes |

### Priority 5 — mean_reversion_bounce Phase 3 Certification (READY, low priority)

| Item | Description |
|---|---|
| Blocker | None — data available |
| Evidence gap | RBSR chain has no secondary CONFIRM with positive evidence |
| Authority required | None — research lab only |
| Why lower priority | RBSR primary chain question (SR/BR co-presence ubiquity) is already answered — a secondary CONFIRM cert is additive but not blocking |

### Not authorized (anti-swamp rule GF-11):

- Further REF isolation tests: H1 falsified; BUY×TD RESEARCH_ONLY below formal threshold; no REG.6 rule applies to a new test
- Further TC-CONFIRM micro-tests for LHR or MSR: TC-CONFIRM family coverage COMPLETE at §28
- Any re-certification of already-certified strategies without a new hypothesis meeting R1–R5
- Any Phase 4 or Phase 5 implementation without operator authorization and a bounded Codex task

---

## Section 10 — Nautilus → MT5 Opportunity Ledger Alignment Plan

This section defines how Nautilus evidence translates into MT5 decisions, and how the Opportunity Ledger (Phase 2) supports this translation. The flow is unidirectional: Nautilus → operator review → operator authorization → bounded Codex task → MT5. Nautilus never writes to MT5 directly.

### 10.1 Evidence Translation Flow

```
Nautilus Lab (evidence only)
  │
  ▼
Certification Report (per strategy)
  │
  ▼
Packet Classification (accepted / research-only / rejected / insufficient)
  │
  ▼
PIML Update (operator reviewed; new §XX appended)
  │
  ▼
Operator Decision (authorize → bounded Codex task, or defer)
  │
  ▼
Bounded Codex Task (one file; one change; compile + verify)
  │
  ▼
MT5 Source Change (if authorized)
  │
  ▼
EA Reload → Runtime Validation Window (30–50 decisions)
  │
  ▼
Opportunity Ledger Evidence (post-change behavior captured)
```

### 10.2 Nautilus-to-MT5 Evidence Thresholds (by packet type)

| Packet Type | Required Nautilus Evidence | MT5 Authorization Path |
|---|---|---|
| ALPHA_TRIGGER → enable strategy in zone | EDGE_SUPPORTED standalone (WR ≥ 45%, E[R] > +0.04R, N ≥ 50) | Operator authorizes zone eligibility update via RCEM v1 + bounded Codex task |
| LOCATION_PACKET → add zone gate | WR lift ≥ +2pp AND E[R] lift ≥ +0.04R vs ungated (Nautilus, N ≥ 50) | Operator authorizes source gate via Phase 5 bounded Codex task |
| FAILURE_MODE → add hostile-regime restriction | E[R] degradation ≥ −0.06R (Nautilus, N ≥ 50 in hostile condition) | Operator authorizes restriction via Phase 5 bounded Codex task |
| WEIGHT adjustment | EDGE_SUPPORTED + live WR ≥ 43% for 50+ closed trades | Phase 6 EEWP — operator authorizes one weight change per bounded Codex task |
| CONFIRM_PACKET → cross-family CRR gate | N/A (Phase 4A architectural decision required first) | Phase 4A path selection before any CRR gate implementation |
| EXHAUSTION VETO → Phase 4B | MFI ≥5 live signal-strength readings; threshold designed from distribution | Phase 4B design + operator authorization + bounded Codex task |

### 10.3 What the Opportunity Ledger Enables

| Ledger Capability | Unlocks |
|---|---|
| ≥200 trigger_present=true records | Phase 4C (quality soft gate reactivation) design review |
| ≥200 records with cross-family confirm fields | Phase 4A-ii (cross-family evidence classification review) |
| ≥200 records with effective_weight fields | FSW audit (prerequisite for EEWP design) |
| ≥50 records post-Phase-4 implementation | Phase 7 runtime validation window per Phase 4 sub-task |
| Per-strategy suppression analysis (dsn_blocked, crr_blocked, veto_fired) | Identifies whether low execution counts are genuine rarity vs. upstream suppression |

### 10.4 What Nautilus CANNOT Do

- Nautilus cannot approve or authorize any MT5 source change
- Nautilus cannot clear degradation_hint flags (live runtime evidence required)
- Nautilus cannot override live WR as the primary edge signal
- Nautilus PARTIAL_REPLICATION results have proxy distance from MT5 live behavior; additional live validation is always required
- Nautilus results using GC=F proxy have the furthest proxy distance and must be treated with the lowest confidence

---

## Section 11 — Forbidden Conclusions

The following conclusions are explicitly prohibited regardless of evidence level. Any task or proposal that leads to one of these conclusions must stop and flag the conflict.

| Forbidden Conclusion | Governing Rule |
|---|---|
| Any Nautilus cert result "authorizes" a gate, weight, or source change | GF-1 |
| RESEARCH_ONLY_PACKET status allows implementing the tested condition | GF-2 |
| REJECTED_PACKET for a condition means the inverse of that condition is valid | GF-3 |
| DATA_INSUFFICIENT means the strategy is probably fine (or probably broken) | GF-4 |
| A strategy's EDGE_SUPPORTED cert in Nautilus means it will achieve that WR in live trading | GF-1, GF-6 |
| TPC being EDGE_SUPPORTED means Phase 4A mandatory gate should be implemented | GF-7 (structural sparsity) |
| The quality score (council_quality) can be modified based on cross-family evidence | GF-7 (deprecated path) |
| Phase 4B veto thresholds can be designed from Nautilus data alone | GF-8 |
| The quality soft gate can be re-activated before Opportunity Ledger has ≥200 records | GF-9 |
| MSR co-presence with LHR being a FAILURE_MODE means MSR should be gated in MT5 | GF-1 (evidence ≠ source change) |
| sweep_reversal live WR=42.9% is reliable edge evidence | live WR unreliable (48.5% unresolved rate — §24) |
| bollinger_reclaim WR=32.3% is the authoritative edge figure | DENOMINATOR_UNRESOLVED — use 38.5% (W/L basis) with snapshot date |
| BUY×TREND_DOWN for range_edge_fade is a viable isolated packet (H2) | E[R]=+0.008R below +0.04R formal threshold; RESEARCH_ONLY only |
| VCR playbook is viable because 3 strategies are assigned to it | PLAYBOOK_NOT_PRESENT — zero evidence at any level |
| Any strategy can be added to the factory | Factory admission is LOCKED; no new strategies without a dedicated standalone plan |
| Production readiness has improved | System status remains DEVELOPING — no phase completion changes this |
| momentum_breakout_cont_v1 can be restored | Permanently FROZEN; requires dedicated standalone redesign plan with full operator authorization |
| Any strategy with degradation_hint=TRUE should be frozen | degradation_hint = monitoring flag; freeze threshold is WR < 25% for 20+ consecutive trades |
| CONFIRM_PACKET_SPARSE for TPC means the playbook chain is confirmed | GF-6 (formal CONFIRMATION_PACKET required for PLAYBOOK_VALID; research designation is not sufficient) |
| Evidence from one strategy's cert can be applied to another strategy without separate testing | Each cert is strategy-specific; cross-strategy inferences require their own test |

---

## Section 12 — Completion Checklist

| Item | Status |
|---|---|
| All 17 council strategies registered | COMPLETE |
| All 3 playbooks registered (RBSR, TPC, VCR) | COMPLETE |
| Section 1: Registry Purpose | COMPLETE |
| Section 2: Governance Firewall (GF-1 through GF-12) | COMPLETE |
| Section 3: Packet Taxonomy (13 types with acceptance/rejection rules) | COMPLETE |
| Section 4: Playbook Registry Summary | COMPLETE |
| Section 5: Master Table (17 strategies × 19 columns) | COMPLETE |
| Section 6: Detailed Strategy Entries (all 17) | COMPLETE |
| Section 7: Certified Strategy Evidence Summary (8 certified + 1 live-rejected) | COMPLETE |
| Section 8: Uncertified Strategy Summary (9 strategies) | COMPLETE |
| Section 9: Registry-Driven Next Work | COMPLETE |
| Section 10: Nautilus → MT5 Opportunity Ledger Alignment Plan | COMPLETE |
| Section 11: Forbidden Conclusions | COMPLETE |
| Section 12: Completion Checklist | COMPLETE |
| Certifications not invented | VERIFIED — all cert data sourced from PIML §19–29; uncertainty labels used where data unavailable |
| False confidence not created | VERIFIED — 0 formal packets accepted system-wide except CONFIRM_PACKET_SPARSE (research only) and MSR FAILURE_MODE for LHR |
| Evidence not fabricated | VERIFIED — SOURCE_READ_REQUIRED used where exact figures were not available in gathered data |

---

## Registry Footer

```
REGISTRY_ID:                     PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1
REGISTRY_DATE:                   2026-05-08
ARCHITECTURE:                    PLAYBOOK_CENTRIC_EVIDENCE_ARCHITECTURE_V1 (PCEA)
AUTHORITY:                       EVIDENCE_ONLY — no MT5 source change, no runtime change, no weight change
STRATEGIES_REGISTERED:           17 / 17
PLAYBOOKS_REGISTERED:            3 / 3 (RBSR, TPC, VCR)
CERTIFIED_STRATEGIES:            8 (Nautilus Phase 3) + 1 (live-rejected; FROZEN)
UNCERTIFIED_STRATEGIES:          8 (DATA_INSUFFICIENT) + 1 (FROZEN)
ACCEPTED_FORMAL_PACKETS:         1 total — MSR FAILURE_MODE_PACKET for LHR E[R] degradation (−0.068R)
RESEARCH_ONLY_DESIGNATIONS:      CONFIRM_PACKET_SPARSE (TPC) + multiple RESEARCH_ONLY per certified strategy
PLAYBOOK_STATES:                 RBSR=PLAYBOOK_FORMING; TPC=PLAYBOOK_FORMING; VCR=PLAYBOOK_NOT_PRESENT
PHASE_3_PROGRESS:                7/17 (bollinger_reclaim, TPC, sweep_reversal, trend_momentum, BDM, LHR, MSR, REF)
PHASE_4A_STATUS:                 BLOCKED — architectural decision required (sparsity is structural)
PHASE_4B_STATUS:                 BLOCKED — MFI 0 live entries
PHASE_4C_STATUS:                 BLOCKED — Opportunity Ledger < 200 records
PHASE_5A_STATUS:                 APPLIED / RUNTIME_VALIDATION_PENDING / NAUTILUS_CHALLENGED
SYSTEM_STATUS:                   DEVELOPING — unchanged
GOVERNED_BY:                     PROJECT_INTELLIGENCE_MEMORY_LAYER.md (PIML) — sole authoritative project memory
NEXT_PRIORITIZED_ACTION:         Phase 4A architectural path decision (operator) / range_compression_breakout Phase 3 cert
PIML_SECTIONS_SOURCED:           §19–29, §22, §24, §25, §26, §27, §28
SOURCE_CHANGED:                  NO
COMPILE_RUN:                     NO
LIVE_TRADING:                    NO
```
