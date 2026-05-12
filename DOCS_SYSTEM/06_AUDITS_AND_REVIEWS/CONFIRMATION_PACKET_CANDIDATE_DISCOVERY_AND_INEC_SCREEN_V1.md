# CONFIRMATION_PACKET_CANDIDATE_DISCOVERY_AND_INEC_SCREEN_V1

**Date:** 2026-05-12
**Type:** INEC co-presence screen — research only
**Scope:** Confirmation candidate discovery + bounded INEC screen for interior-range CONFIRMATION_PACKET gap
**BUILD_FREEZE:** ACTIVE — no source changes, no compile, no reload
**Authority:** EVIDENCE_ONLY. runtime_authority_status: NONE

---

## A. Executive Verdict

```
CONFIRMATION_PACKET_GAP_REMAINS_OPEN_NEEDS_NEW_SEARCH
```

Three independent INEC screen iterations (V1/V2/V3) across 9 candidates failed to produce a certifiable interior-range CONFIRMATION_PACKET. All candidates with sufficient lift were reclassified as trigger quality filters or suffered methodological disqualification. The one marginally passing independent signal (M5BC_CORR for SR-SELL) is disqualified by extreme starvation risk (93% filter rate, N=225 for SELL direction). The confirmation gap is structurally driven by absence of a market-logic signal that fires in interior-range conditions — a gap that simple bar-shape and timeframe-context candidates cannot fill. Gemini external research (Gate 0 authorized in GEMINI_DELEGATED pipeline) remains the authorized path forward.

Notable byproduct finding: **TBB reveals a critical SR trigger quality bifurcation** — SR trades with directional trigger bars win at 57.3% vs 21.2% for non-directional trigger bars (N=3356 vs N=3233). This is a TRIGGER_REFINEMENT finding, not a CONFIRMATION_PACKET, but it has high production value for SR quality.

---

## B. Research Candidate List

Nine candidates evaluated across three screen iterations:

| ID | Candidate | Definition | Screen |
|---|---|---|---|
| C1 | BCLC (Bar Close Location Confirmation) | Trigger bar close in top/bottom 60% of bar range | V1 |
| C2 | MRR (M1 Range Reclaim) | Close inside 50% of M1 high-low range | V1 |
| C3 | PBHB (Prior Bar High/Low Break) | Current bar breaks prior bar's extreme in direction | V1 |
| C4 | PTBM (Prior-bar Body Momentum) | Trigger_bar-1: close in top/bottom 50% of range + body ≥30% of range | V2 |
| C5 | PTAI (Prior-bar ATR Impulse) | Trigger_bar-1: body ≥ 0.40 × ATR(M1,14) | V2 |
| C6 | TWOBAR (Two-bar Momentum) | Trigger bar AND prior bar both directional (close > open) | V2 |
| C7 | M5BC_RAW (M5 Bar Context, uncorrected) | Current M5 bar direction at trigger time via asof() | V2 |
| C8 | TBB (Trigger Bar Bullish/Bearish) | Trigger bar direction: close > open for BUY / close < open for SELL | V3 |
| C9 | M5BC_CORR (M5 Bar Context, corrected) | Previous CLOSED M5 bar direction: asof(ts - 5min) | V3 |

**Primary alpha trades tested:** sweep_reversal (N=6589) and trend_momentum (N=8445).
**Data:** XAUUSD M1 + M5 OHLCV 2025-11-07 to 2026-05-07 (nautilus_lab export).
**Cost model:** spread=10pts + slippage=2pts, stop=ATR(M1,14)×1.20, RR=1.50.

---

## C. Top 3 Candidates (Pre-Classification)

### C.1 — TBB (Trigger Bar Bullish/Bearish)

**Rule:** For BUY SR trade: trigger bar (bar[1]) has close > open. For SELL: close < open.
**Independence:** NONE — same bar as the alpha trigger. This is trigger-bar quality, not external confirmation.
**V3 Results (SR):**

| Subset | N | WR_pres | WR_absent | WR_lift | ER_lift | Class |
|---|---|---|---|---|---|---|
| SR all | 3356 / 6589 (51%) | 0.573 | 0.212 | +0.3617 | +0.9044 | ACCEPT |
| SR BUY | 1833 (51%) | 0.572 | — | +0.3737 | +0.9342 | ACCEPT |
| SR SELL | 1523 (50%) | 0.575 | — | +0.3480 | +0.8700 | ACCEPT |
| TM all | 3669 (43%) | 0.388 | 0.394 | −0.0058 | −0.0145 | REJECT |

**Sensitivity:** WR_pres_trimmed (−3 top wins) = 0.573 (unchanged). Result is highly robust.
**Classification:** TRIGGER_SUB_FILTER — not eligible as CONFIRMATION_PACKET.
**Finding:** SR trigger has severe quality bifurcation. Non-directional trigger bars win only 21.2%. This is TRIGGER_REFINEMENT evidence — actionable but out of CONFIRMATION_PACKET scope.

### C.2 — M5BC_CORR (Previous Closed M5 Bar Direction)

**Rule:** The M5 bar that CLOSED before the trigger time is directionally aligned with the trade (body ≥30% of M5 bar range). Implemented as asof(trigger_time − 5min) on M5 data.
**Independence:** Genuinely independent — separate timeframe, separate bar.
**V3 Results:**

| Subset | N | WR_pres | WR_absent | WR_lift | ER_lift | Class |
|---|---|---|---|---|---|---|
| SR all | 458 / 6589 (7%) | 0.424 | 0.394 | +0.0299 | +0.0747 | ACCEPT |
| SR BUY | 233 (7%) | 0.408 | — | +0.0181 | +0.0454 | RESEARCH_ONLY |
| SR SELL | 225 (7%) | 0.440 | — | +0.0413 | +0.1032 | ACCEPT |
| TM all | 4049 (48%) | 0.383 | 0.399 | −0.0160 | −0.0399 | REJECT_HARMFUL |

**V2 look-ahead comparison:** V2 M5BC_RAW (uncorrected) showed +46pp / N=1284 for SR. Correcting to previous closed bar reduces lift from +46pp to +3pp and N from 1284 to 458. The +46pp was entirely look-ahead artifact.
**Sensitivity:** WR_pres_trimmed = 0.420 (was 0.424) — stable.
**Classification:** RESEARCH_ONLY — meets ≥+2pp WR threshold in aggregate but fails CONFIRMATION_PACKET certification criteria (see Section G).

### C.3 — PTBM (Prior-bar Body Momentum)

**Rule:** Bar[2] (bar before trigger bar): bullish (close > open) + close in top 50% of bar range + body ≥30% of bar range.
**Independence:** Genuine — separate bar, fully closed before trigger.
**V2 Results:**

| Subset | N | WR_pres | WR_absent | WR_lift | ER_lift | Class |
|---|---|---|---|---|---|---|
| SR | 1730 (26%) | 0.405 | 0.393 | +0.0127 | +0.0318 | RESEARCH_ONLY |
| TM | 2724 (32%) | 0.388 | 0.392 | −0.0040 | −0.0100 | REJECT |

**Classification:** RESEARCH_ONLY for SR. Insufficient for CONFIRMATION_PACKET.

---

## D. INEC Screen Summary

Three screen iterations run. All scripts executed via `cert_confirmation_packet_candidates_v1/v2/v3.py` in `nautilus_lab/scripts/`. Results in `outputs/confirmation_packet_screen/`.

| Screen | Candidates | Primary Finding | Outcome |
|---|---|---|---|
| V1 | BCLC, MRR, PBHB | +36pp lift for SR — methodological artifact (trigger bar correlation) | ALL DISQUALIFIED |
| V2 | PTBM, PTAI, TWOBAR, M5BC_RAW | TWOBAR accepted but dominated by trigger bar; M5BC_RAW look-ahead defect identified | TWOBAR → reclassified; M5BC_RAW → invalidated; PTBM → RESEARCH_ONLY; PTAI → REJECT |
| V3 | TBB, M5BC_CORR | TBB strong but TRIGGER_SUB_FILTER; M5BC_CORR +3pp at 7% co-presence | TBB → TRIGGER_SUB_FILTER; M5BC_CORR → RESEARCH_ONLY |

**Methodology notes:**
- V1 artifact: BCLC/PBHB select top-quality SR trigger bars (strong close-location) which are already embedded in the SR trigger definition. This measures within-trigger quality, not independent confirmation.
- V2 look-ahead: M5BC used `asof(ts)` on M5 open-times, returning the CURRENT (still-open) M5 bar whose close is not yet known. Corrected in V3 with `asof(ts − 5min)`.
- V3 TBB classification: trigger bar direction is NOT independent of the trigger — it uses bar[1] for both the alpha trigger (BB band touch, range bound) and the confirmation check. Not eligible as CONFIRMATION_PACKET by definition.

---

## E. Confirmation Lift Table (Complete)

| Candidate | Primary | N_pres | Co-pres% | WR_all | WR_pres | WR_abs | WR_lift | ER_lift | Classification |
|---|---|---|---|---|---|---|---|---|---|
| BCLC | SR | 1756 | 27% | 0.396 | 0.662 | — | +0.3625 | — | ARTIFACT |
| MRR | SR | 393 | 6% | 0.396 | 0.763 | — | +0.3909 | — | ARTIFACT |
| PBHB | SR | 1813 | 28% | 0.396 | 0.647 | — | +0.3472 | — | ARTIFACT |
| PTBM | SR | 1730 | 26% | 0.396 | 0.405 | 0.393 | +0.0127 | +0.0318 | RESEARCH_ONLY |
| PTAI | SR | 1511 | 23% | 0.396 | 0.398 | 0.395 | +0.0034 | +0.0084 | REJECT |
| TWOBAR | SR | 1492 | 23% | 0.396 | 0.576 | 0.343 | +0.2326 | +0.5815 | TRIGGER_SUB_FILTER (TBB-dominated) |
| M5BC_RAW | SR | 1284 | 19% | 0.396 | 0.767 | 0.306 | +0.4612 | +1.1531 | LOOK-AHEAD DEFECT |
| **TBB** | **SR** | **3356** | **51%** | **0.396** | **0.573** | **0.212** | **+0.3617** | **+0.9044** | **TRIGGER_SUB_FILTER** |
| **M5BC_CORR** | **SR** | **458** | **7%** | **0.396** | **0.424** | **0.394** | **+0.0299** | **+0.0747** | **RESEARCH_ONLY** |
| PTBM | TM | 2724 | 32% | 0.391 | 0.388 | 0.392 | −0.0040 | −0.0100 | REJECT |
| PTAI | TM | 2201 | 26% | 0.391 | 0.386 | 0.393 | −0.0067 | −0.0166 | REJECT |
| TWOBAR | TM | 1872 | 22% | 0.391 | 0.384 | 0.393 | −0.0098 | −0.0243 | REJECT |
| TBB | TM | 3669 | 43% | 0.391 | 0.388 | 0.394 | −0.0058 | −0.0145 | REJECT |
| M5BC_CORR | TM | 4049 | 48% | 0.391 | 0.383 | 0.399 | −0.0160 | −0.0399 | REJECT_HARMFUL |

---

## F. Starvation and Frequency Analysis

| Candidate | SR Co-pres% | TM Co-pres% | Starvation (if hard gate on SR) | Notes |
|---|---|---|---|---|
| BCLC | 27% | 30% | HIGH — 73% filter | ARTIFACT, disqualified |
| PTBM | 26% | 32% | HIGH — 74% filter | RESEARCH_ONLY, too weak |
| TBB | 51% | 43% | MEDIUM — 49% filter | TRIGGER_SUB_FILTER — strategy-specific to SR |
| M5BC_CORR | 7% | 48% | CRITICAL — 93% filter for SR | 93% starvation disqualifying for hard gate |

M5BC_CORR starvation: only 458 SR trades over 6 months would pass the gate = ~2.5 trades/day. The SR baseline is ~36/day. A 93% filter is incompatible with a hard CONFIRMATION gate.

PTBM standalone fire rates: 652/day (67.5% of all M1 bars) — confirms it fires frequently but produces no useful confirmation signal.

---

## G. Rejected Candidates and Reasons

| Candidate | Rejection Reason | Classification |
|---|---|---|
| BCLC | Artifact: trigger bar close-location is structurally correlated with SR's own reclaim strength. Measures within-trigger quality, not external confirmation. | ARTIFACT |
| MRR | Artifact: same class as BCLC — within-trigger quality measure. | ARTIFACT |
| PBHB | Artifact: same class as BCLC. | ARTIFACT |
| PTAI | Lift +0.34pp for SR, negative for TM. Below all thresholds. | REJECT_WEAK |
| TWOBAR | Dominated by TBB component (trigger bar direction). The truly independent part (prior bar direction) contributes only ~+1pp — see PTBM result. | TRIGGER_SUB_FILTER |
| M5BC_RAW | Look-ahead defect: `asof(ts)` returns current unclosed M5 bar. +46pp lift was artifact. Corrected to M5BC_CORR. | LOOK-AHEAD_DEFECT |
| TBB (SR) | Meets threshold but is NOT independent — checks trigger bar direction. Same bar[1] as the alpha trigger. Classified TRIGGER_SUB_FILTER. | TRIGGER_SUB_FILTER |
| TBB (TM) | −0.6pp lift, REJECT. | REJECT |
| M5BC_CORR (TM) | −1.6pp lift, REJECT_HARMFUL. | REJECT_HARMFUL |
| M5BC_CORR (SR-BUY) | +1.8pp lift, N=233 — RESEARCH_ONLY. Below ≥2pp threshold for BUY direction. | RESEARCH_ONLY |

---

## H. Best Candidate Recommendation

**No candidate certified as CONFIRMATION_PACKET.**

**Strongest genuinely independent candidate:** M5BC_CORR for SR-SELL only.
- N=225, WR_pres=0.440, lift=+4.1pp, ER_lift=+0.10R
- Meets WR threshold (+4.1pp ≥ +2pp) for SELL direction only
- Disqualifying issues: (1) N=225 SELL only — adequate but not sufficient for production cert; (2) 93% starvation if used as hard gate; (3) harmful for TM (−1.6pp) — cannot be used cross-strategy; (4) BUY direction fails (RESEARCH_ONLY); (5) strategy-specific to SR and direction-asymmetric
- Path forward: if N increases with more data, and can be qualified as ADVISORY (not hard gate), M5BC_CORR for SR-SELL is the strongest RESEARCH_ONLY candidate

**Highest-value byproduct finding:** TBB for SR (TRIGGER_SUB_FILTER)
- SR trigger bar direction splits WR: directional → 57.3%, non-directional → 21.2%
- This is not a CONFIRMATION_PACKET — it's evidence that the SR TRIGGER needs refinement
- Recommendation: log as TRIGGER_REFINEMENT task for SR — adding `close1 > open1` condition to DetectBollingerReclaimTrigger() for BUY (and `close1 < open1` for SELL) would eliminate 49% of SR trades but nearly triple the win rate
- Out of scope for CONFIRMATION_PACKET mission — requires BUILD_FREEZE lift and separate Codex task

---

## I. Confirmation Gap Status

**Gap remains fully open.**

The structural root cause (from BLOCKER_CLOSURE_PACKAGE_1) is unchanged: all three existing CONFIRM-role strategies (bollinger_reclaim, mean_reversion_bounce, range_edge_fade) require price at structural extremes (BB band touch, range bounds). In interior-range sessions, no CONFIRM-role strategy fires → `confirm_role_present=false` → structural gate rejects every decision.

The candidates tested in this screen are bar-shape and timeframe-context filters. They capture:
- How strong the current trigger bar is (TBB, BCLC, PBHB)
- Whether the prior bar was directional (PTBM, PTAI)
- Whether the prior closed M5 bar was directional (M5BC_CORR)

None of these constitute a new CONFIRM-role strategy that can fire in interior-range conditions. The gap requires a strategy with its own market-structure trigger that:
1. Fires when price is not at BB band or range extreme
2. Can be assigned COUNCIL_ROLE_CONFIRM
3. Has WR ≥40% as standalone trigger
4. Passes INEC certification independently

This is a different class of signal than what was tested here.

---

## J. Next Closure Package Recommendation

**Recommended: GEMINI_EXTERNAL_STRATEGY_DISCOVERY_GATE1_EXECUTION**

The Gemini research pipeline (GEMINI_DELEGATED_EXTERNAL_XAUUSD_STRATEGY_DISCOVERY_AND_INEC_PIPELINE_V1) has already completed Gate 0. Gemini returned a research dossier in `DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/GEMINI_EXTERNAL_XAUUSD_STRATEGY_CANDIDATE_RESEARCH_V1.md`. Claude's selection audit is in `DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/CLAUDE_EXTERNAL_STRATEGY_SELECTION_AND_INEC_PLAN_V1.md`. Gate 1 is PENDING.

The BLOCKER_CLOSURE_PACKAGE_1 report (2026-05-12) also identified this as the next step: "next: GEMINI re-brief for CONFIRMATION_PACKET."

**Secondary recommendation:** Log TBB finding as TRIGGER_REFINEMENT task for SR. This is independent of BUILD_FREEZE — it requires a Codex source change to `DetectBollingerReclaimTrigger()` once BUILD_FREEZE is lifted. The WR improvement (+18pp for directional subset) is high value.

**What NOT to do:**
- Do not certify M5BC_CORR as CONFIRMATION_PACKET — starvation risk prohibitive
- Do not implement TBB as CONFIRMATION_PACKET — it is trigger quality, not external confirmation
- Do not run additional bar-shape screen iterations — diminishing returns confirmed

---

## K. Files Updated

| File | Path | Action |
|---|---|---|
| `cert_confirmation_packet_candidates_v1.py` | `nautilus_lab/scripts/` | Created prior session — V1 BCLC/MRR/PBHB screen |
| `cert_confirmation_packet_candidates_v2.py` | `nautilus_lab/scripts/` | Created prior session — V2 PTBM/PTAI/TWOBAR/M5BC_RAW |
| `cert_confirmation_packet_candidates_v3.py` | `nautilus_lab/scripts/` | Created this session — V3 TBB/M5BC_CORR look-ahead correction |
| `sr_trades_v2_independent.csv` | `nautilus_lab/outputs/confirmation_packet_screen/` | V2 enriched SR trades |
| `tm_trades_v2_independent.csv` | `nautilus_lab/outputs/confirmation_packet_screen/` | V2 enriched TM trades |
| `sr_trades_v3_corrected.csv` | `nautilus_lab/outputs/confirmation_packet_screen/` | V3 enriched SR trades |
| `tm_trades_v3_corrected.csv` | `nautilus_lab/outputs/confirmation_packet_screen/` | V3 enriched TM trades |
| `confirmation_packet_screen_v2_results.json` | `nautilus_lab/outputs/confirmation_packet_screen/` | V2 results JSON |
| `confirmation_packet_screen_v3_results.json` | `nautilus_lab/outputs/confirmation_packet_screen/` | V3 results JSON |
| `CONFIRMATION_PACKET_CANDIDATE_DISCOVERY_AND_INEC_SCREEN_V1.md` | `DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/` | This report |
| `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` | `MQL5/Experts/AI/` | Updated (via docs workflow) |
| `DOCS_SYSTEM_INDEX.md` | `MQL5/Experts/AI/DOCS_SYSTEM/` | Updated — 06_AUDITS_AND_REVIEWS now 9 files |

**Branch used:** `docs/blocker-closure-roadmap-state-v1` (existing branch, new commit)

---

## L. What Remains Forbidden

BUILD_FREEZE is **ACTIVE**. The following remain prohibited until BUILD_FREEZE is explicitly lifted by operator:

- MT5 `.mqh` / `.mq5` source file modifications
- Compile or build execution
- MT5 Strategy Tester runs with current source
- MT5 EA reload
- Codex implementation tasks of any kind
- PIML phase advancement without explicit operator authorization
- CONFIRMATION_PACKET certification without operator Gate 1 approval
- TBB trigger refinement implementation (requires BUILD_FREEZE lift + separate Codex package)

---

## M. Final Decision

```
CONFIRMATION_PACKET_GAP_REMAINS_OPEN_NEEDS_NEW_SEARCH

VERDICT_DATE:               2026-05-12
SCREENS_RUN:                V1 (3 candidates) + V2 (4 candidates) + V3 (2 candidates)
CANDIDATES_CERTIFIED:       0
CANDIDATES_REJECTED:        7 (artifact, weak, or harmful)
TRIGGER_SUB_FILTERS_FOUND:  1 (TBB for SR — high production value, separate task)
RESEARCH_ONLY:              2 (PTBM for SR, M5BC_CORR for SR-SELL)
CONFIRMATION_GAP_OPEN:      YES — interior-range CONFIRM-role trigger absent
NEXT_ACTION:                GEMINI_EXTERNAL_STRATEGY_DISCOVERY_GATE1_EXECUTION
BUILD_FREEZE:               ACTIVE
SOURCE_CHANGED:             NO
COMPILE_RUN:                NO
MT5_RELOAD:                 NO
```

```
DOC_ID:     CONFIRMATION_PACKET_CANDIDATE_DISCOVERY_AND_INEC_SCREEN_V1
CREATED:    2026-05-12
CONTEXT:    CONFIRMATION_PACKET_CANDIDATE_DISCOVERY_AND_INEC_SCREEN_V1
STATUS:     FINAL
```
