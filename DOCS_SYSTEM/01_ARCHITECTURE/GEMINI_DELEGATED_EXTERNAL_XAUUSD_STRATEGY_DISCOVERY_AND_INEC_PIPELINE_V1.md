# GEMINI_DELEGATED_EXTERNAL_XAUUSD_STRATEGY_DISCOVERY_AND_INEC_PIPELINE_V1

**Date:** 2026-05-11
**Mission type:** Claude-led orchestration — Gemini is research agent — Claude is decision authority
**Scope:** External XAUUSD strategy discovery → INEC certification → (if approved) implementation design
**Authority:** MT5 = runtime authority. Nautilus = research/certification lab only. Gemini = external research delegatee only.

---

## A. Pipeline Purpose

This document specifies the full four-gate pipeline for introducing external strategy candidates into the MT5 council EA system. The pipeline enforces operator authorization at each gate and prevents any direct implementation without evidence-based certification.

**Why this pipeline exists:**
- The current system has zero formally certified CONFIRMATION_PACKETs
- VCR (Volatility Compression Release) playbook is PLAYBOOK_NOT_PRESENT
- Internal strategy set has known gaps in LOCATION, TIMING, ROOM, and STOP_GEOMETRY packet roles
- External research may surface candidates that fill these gaps more efficiently than designing new strategies from scratch

---

## B. Authority Model

| Agent | Role | Authority |
|---|---|---|
| Claude | Decision authority | Task framing, candidate evaluation, INEC design, all gate approvals, implementation design |
| Gemini | Research delegatee | External web research, evidence gathering, candidate dossier preparation |
| Codex | Implementer | Source implementation only at Gate 3 and only if operator authorizes |
| MT5 | Runtime authority | Never delegated; sole execution and trading authority |
| Nautilus | Certification lab | Research and replay evidence only; no runtime authority |

---

## C. Approval Gates

| Gate | Trigger | Authorized When |
|---|---|---|
| APPROVAL_GATE_0 | Operator authorizes Gemini external research | Operator explicitly confirms |
| APPROVAL_GATE_1 | Operator approves Claude's INEC candidate selection | After Gemini returns full dossier and Claude evaluates |
| APPROVAL_GATE_2 | Operator approves INEC plan → implementation design conversion | After INEC certification is complete |
| APPROVAL_GATE_3 | Operator approves Codex source implementation | After Gate 2; outside scope of this document's mission |

---

## D. Current System Gaps Driving This Mission

### D1. ZERO Accepted CONFIRMATION_PACKET (CRITICAL)
No formally certified CONFIRMATION_PACKET exists in the system. All 3 active playbooks (RBSR, TPC, IFR) are below PLAYBOOK_VALID because no cross-family confirm has achieved the required WR lift ≥+2pp AND E[R] lift ≥+0.04R. An external cross-family confirmation candidate could unblock all three playbooks simultaneously.

### D2. VCR Playbook Absent (HIGH)
`VOLATILITY_COMPRESSION_RELEASE = PLAYBOOK_NOT_PRESENT`. Zero COMPRESSION/EXP zone data exists. No ALPHA_TRIGGER_PACKET is certified for this regime. This is the largest untapped market-structure zone in the system.

### D3. LOCATION and TIMING Packets Empty (HIGH)
`event_order_valid=false` in all 53+ opportunity ledger records because no pre-decision context/location anchor exists. An external LOCATION or TIMING candidate could enable valid pre-decision event ordering and unlock playbook_thesis_complete=true.

### D4. ROOM and STOP_GEOMETRY Packets Absent (MEDIUM)
`room_state=UNKNOWN` and `stop_geometry_state=UNKNOWN` in all OL records. No strategy currently fills the ROOM_PACKET or STOP_GEOMETRY_PACKET roles. A room-to-target or ATR-relative stop-validity concept could materially improve trade survival rates.

### D5. EXHAUSTION Signal Weak (MEDIUM)
mfi_reversal_assist has only 2 live entries — insufficient for Phase 4B (exhaustion veto) calibration. An external EXHAUSTION or FAILURE_MODE candidate for TC/BREAKOUT zones could provide the signal density needed.

---

## E. Candidate Acceptance Requirements

### E1. Must Fill
An external candidate must materially improve at least one of:
1. CONFIRMATION_PACKET for RBSR or TPC playbook (cross-family lift ≥+2pp WR)
2. ALPHA_TRIGGER_PACKET for VCR zone (COMPRESSION/EXP, WR ≥40%, N≥50)
3. FAILURE_MODE_PACKET in TC or BREAKOUT (E[R] degradation ≥ −0.06R)
4. LOCATION or TIMING packet improving event_order_valid rate
5. ROOM or STOP_GEOMETRY packet with measurable MAE/MFE improvement

### E2. Must Not Violate
- No duplicate of existing MEAN_RECLAIM, TREND_CONTINUATION, or LIQUIDITY_REVERSAL logic
- No grid / martingale / DCA / recovery
- No sub-second execution requirement
- No hidden discretionary rules
- No proprietary orderflow data (unless labeled FUTURE_EXTERNAL_DATA_CANDIDATE)
- No raw score authority (must be categorical)
- Compatible with V1 / IRREW / PCEA authority boundaries

---

## F. INEC Certification Framework (Applied Post Gate-1)

### F1. Cost Model (Fixed)
- Spread: 10 points, Slippage: 2 points
- Stop: ATR(M1,14) × 1.20, RR: 1.50
- Breakeven WR: 40%

### F2. Certification Variants
| Variant | Description |
|---|---|
| A — Unrestricted | All bars, no filter, baseline |
| B — Primary filter | Best structural filter for this candidate |
| C — Subset | Counter-trend or adverse-regime subset |
| D — Stress | +10pt spread above base |
| E — Walk-forward | 60/40 chronological split if N ≥ 30 |

### F3. Acceptance Thresholds
| Packet Type | Threshold |
|---|---|
| ALPHA_TRIGGER_PACKET | WR ≥ 40% OR E[R] > 0, N ≥ 50, survives Variant D |
| CONFIRMATION_PACKET | Co-presence WR lift ≥ +2pp AND E[R] lift ≥ +0.04R; co-presence < 80% |
| FAILURE_MODE_PACKET | E[R] degradation ≥ −0.06R OR WR degradation ≥ −3pp |
| LOCATION_PACKET | WR improvement ≥ +3pp when location condition present; N ≥ 30 |
| TIMING_PACKET | WR improvement ≥ +2pp when event-order valid; N ≥ 30 |
| ROOM_PACKET | MFE ≥ 1.0R rate improvement ≥ +5pp |
| STOP_GEOMETRY_PACKET | MAE reduction ≥ −0.10R with no WR decrease |

### F4. Rejection Thresholds
- WR < 35% across all variants with N ≥ 30 → REJECTED_PACKET
- E[R] < −0.05R across all regime splits → REJECTED_PACKET
- Cannot be proxied from OHLCV → REPLICATION_BLOCKED
- N < 15 or sample span < 14 days → DATA_INSUFFICIENT
- Co-presence rate > 60% → SYSTEM_RISK_TOO_HIGH (starvation risk)

---

## G. Output File Map

| Stage | File | Gate Condition |
|---|---|---|
| Pipeline spec | This file (01_ARCHITECTURE) | Gate 0 authorized |
| Gemini dossier | `DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/GEMINI_EXTERNAL_XAUUSD_STRATEGY_CANDIDATE_RESEARCH_V1.md` | After Gemini returns |
| Claude selection + INEC plan | `DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/CLAUDE_EXTERNAL_STRATEGY_SELECTION_AND_INEC_PLAN_V1.md` | After Gate 1 authorized |
| PIML update | `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` | After each gate completion |

---

## H. What Will Not Happen

- No source (.mqh) changes
- No compile
- No MT5 reload
- No runtime file modification
- No strategy added to operating cohort
- No Codex implementation
- No Production Ready claim
- No gate assumed without explicit operator confirmation

---

```
DOC_ID:                 GEMINI_DELEGATED_EXTERNAL_XAUUSD_STRATEGY_DISCOVERY_AND_INEC_PIPELINE_V1
DATE:                   2026-05-11
LOCATION:               DOCS_SYSTEM/01_ARCHITECTURE/
APPROVAL_GATE_0:        AUTHORIZED
APPROVAL_GATE_1:        PENDING — awaiting Gemini research + Claude evaluation
APPROVAL_GATE_2:        BLOCKED by Gate 1
APPROVAL_GATE_3:        BLOCKED by Gate 2 (outside this mission scope)
SOURCE_CHANGED:         NO
PRODUCTION_READY:       FALSE
SYSTEM_STATUS:          DEVELOPING
```
