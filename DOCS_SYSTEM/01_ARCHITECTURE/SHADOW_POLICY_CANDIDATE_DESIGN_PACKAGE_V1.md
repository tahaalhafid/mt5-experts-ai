# SHADOW_POLICY_CANDIDATE_DESIGN_PACKAGE_V1

**Package type:** DESIGN — Shadow Policy Candidate Specification  
**Date:** 2026-05-09  
**Authority:** EVIDENCE_ONLY — No MT5 source change. No runtime change. No compile. No reload.  
**Governed by:** PROJECT_INTELLIGENCE_MEMORY_LAYER.md (PIML) — sole authoritative project memory  
**Based on:** PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md + ARCHITECTURE_BUILD_PACKAGE_V1.md + IMPLEMENTATION_SPEC_PACKAGE_V1.md + PLAYBOOK_ARCHITECTURE_FULL_IMPLEMENTATION_PACKAGE_V1_REPORT.md + V1C_CLEANUP_PACKAGE_V1_REPORT.md + PCEA_V1C_RUNTIME_EVIDENCE_REVIEW_PACKAGE_V1 findings  
**System status:** DEVELOPING — unchanged  
**Runtime authority:** V1 (MT5 EA) — permanent; not transferred to any document, shadow layer, or policy candidate  

---

## 1. Executive Summary

PCEA V1C is live and runtime-validated. The V1C implementation added the playbook shadow state layer, the event order trace layer, and full V1C JSONL schema output to the Opportunity Ledger. V1C cleanup (K1/K2/K3) was implemented compile-clean on 2026-05-09 and has not yet been validated live — the market is currently closed.

With V1C producing live records and the cleanup compiled but pending a reload, the next useful work is not more runtime validation — it is design. The system now has a functioning evidence collection layer but no analysis framework for what to do with the evidence. This package fills that gap by defining what candidate shadow policies are worth tracking, what evidence each requires, and what conditions must be met before any policy could ever be considered for runtime promotion.

**This package defines shadow policy candidates only. No shadow policy candidate is authorized for runtime consumption by this package or by any document derived from it.**

**Key facts entering this design:**
- 28 V1C records reviewed across 7h11m window (post-reload of V1C binary)
- RBSR most active (15 records, 53.6%); TPC active (11 records, 39.3%); VCR entirely absent (0 records)
- PLAYBOOK_FORMING = 75%; PLAYBOOK_NOT_PRESENT = 21.4%; PLAYBOOK_CONTRADICTED = 3.6%; PLAYBOOK_VALID = 0%
- runtime_authority_status = "NONE" universal — decision invariance confirmed
- Phase 4A, 4B, and 4C all blocked
- K1/K2/K3 cleanup compiled and awaiting first reload validation
- System remains DEVELOPING

---

## 2. Current Evidence Baseline

### 2.1 V1C Ledger State

| Metric | Value | Classification |
|---|---|---|
| Total ledger records (all versions) | 35 | Verified |
| V1C records available for analysis | 28 | Verified |
| Review window span | 7h11m (2026-05-08 16:28–23:39) | Verified |
| EA sessions in window | 2 | Verified |
| Unique strategies observed triggering | 8 of 17 | Verified |
| schema_version in summary | OL_SUMMARY_V1C_PLAYBOOK_SHADOW | Verified |
| runtime_authority_status | "NONE" universal | Verified |
| Decision invariance | CONFIRMED — 0 playbook-driven decisions | Verified |

### 2.2 Playbook Activity

| Playbook | Records | % of V1C | State Distribution |
|---|---|---|---|
| RBSR (Range Boundary Sweep Reversal) | 15 | 53.6% | FORMING dominant |
| TPC (Trend Pullback Continuation) | 11 | 39.3% | FORMING dominant; 1 CONTRADICTED |
| VCR (Volatility Compression Release) | 0 | 0.0% | ABSENT — no triggering strategies |
| UNVERIFIED (post-cleanup: now RBSR) | 2 | 7.1% | UNKNOWN pre-cleanup; post-cleanup maps to RBSR |

**RBSR activity:** Strongly supported — bollinger_reclaim (7 records), mfi_reversal_assist (4 records), sweep_reversal (3 records), mean_reversion_bounce (1 record pre-cleanup), plus fake_break_reversal (0 triggers in window). RBSR is the most evidence-rich playbook in V1C data. Verified.

**TPC sparsity:** Confirmed live. trend_pullback_cont_v1 = 0 triggers in 20 evaluated bars. Phase 4A (cross-family CRR) relies on TPC firing; TPC non-firing is not a threshold problem but an architectural one (1.4% co-presence with trend_momentum in Nautilus, confirmed live). Verified.

**VCR absence:** All 5 VCR strategies had trigger_seen=0. Likely regime-driven (COMPRESSION/EXP zones not active in window). Not a coding error confirmed, but not cleared either. Plausible but unverified (requires COMPRESSION zone activity to confirm strategy detection works).

**mfi_reversal_assist first live entries:** Confirmed. trigger_seen=3, trigger_executed=2, 4 V1C records. Prior state was DATA_INSUFFICIENT (0 entries). Phase 4B (exhaustion veto) was blocked on 0 entries — this blocker is softening. Current count (2) is below the minimum required for threshold calibration (5). Strongly supported.

### 2.3 Dominant Missing Links in V1C Records

| Missing Link | Estimated Occurrences | Root Cause | Addressable? |
|---|---|---|---|
| PRE_DECISION_EVENT_ORDER | ~22/28 records | Stage 18.5 post-decision position — structural | No, not in V1C |
| FORMAL_CONFIRMATION_PACKET | ~22/28 records | TPC never fires = no cross-family confirm | Architectural, not threshold |
| TPC_PULLBACK_OR_REENTRY_CONFIRM | ~10/11 TPC records | TPC sparsity confirmed live | Phase 4A architecture decision required |

### 2.4 Phase Gate Status

| Phase | Status | Blocker | Classification |
|---|---|---|---|
| Phase 2 (Opportunity Ledger) | ACTIVE — immature | Below 200-record threshold (28 V1C records) | Verified |
| Phase 3 (Nautilus certs) | IN_PROGRESS — 7/17 | 10 strategies uncertified | Verified |
| Phase 4A (Cross-family CRR) | BLOCKED | TPC trigger_seen=0 live; architectural decision required | Verified |
| Phase 4B (Exhaustion veto) | PARTIALLY_UNBLOCKED | MFI entries=2 of minimum 5 threshold | Strongly supported |
| Phase 4C (Quality soft gate) | BLOCKED | Ledger below 200-record threshold | Verified |
| Phase 5A | APPLIED / UNVALIDATED | Runtime validation pending reload | Strongly supported |
| Phase 6 (EEWP) | DESIGN_ONLY | Blocked on Phase 2 + Phase 3 (≥8 certs) + Phase 4 runtime | Verified |

### 2.5 V1C Cleanup Status (K1/K2/K3)

| Caveat | Status | Expected Runtime Effect |
|---|---|---|
| K1: late_evidence=true universal | FIXED — compile-clean; awaiting reload | late_evidence_seen_count will remain 0 post-reload; field discriminating again |
| K2: mean_reversion_bounce/fake_break_reversal UNKNOWN | FIXED — compile-clean; awaiting reload | Both strategies now map to RBSR; registry_unknown_strategy_seen_count should drop to 0 |
| K3: bollinger_reclaim REJECTED | FIXED — compile-clean; awaiting reload | All future bollinger_reclaim records will show RESEARCH_ONLY |
| Pre-cleanup UNKNOWN/REJECTED records | PRESERVED in JSONL — not backfilled | 7 bollinger_reclaim records still show REJECTED; 2 mean_reversion_bounce records still show UNKNOWN |

**Evidence classification summary:**
- V1C architecture live and validated: Verified
- RBSR most active playbook: Verified
- TPC sparsity confirmed live: Verified
- VCR entirely absent: Plausible but unverified (regime-conditional)
- mfi_reversal_assist first entries: Strongly supported
- K1/K2/K3 fixed source-level: Verified (compile-clean)
- K1/K2/K3 fixed runtime-level: INSUFFICIENT (awaiting post-cleanup reload validation)
- Phase 4A blocked: Verified
- Phase 4B softening: Strongly supported
- Phase 4C blocked: Verified

---

## 3. Definition of Shadow Policy Candidate

A **Shadow Policy Candidate (SPC)** is a non-runtime hypothesis that can be evaluated from recorded Opportunity Ledger evidence. It is a testable prediction about whether a specific playbook or evidence condition correlates with better or worse trade outcomes, when evaluated against the ledger after-the-fact.

**A Shadow Policy Candidate is not:**
- A runtime gate
- A score or quality modifier
- A vote_weight adjustment
- A CRR or DSN condition
- A trade permission or block
- A playbook VALID declaration
- A production-ready proposal

**A Shadow Policy Candidate IS:**
- A hypothesis that can be evaluated from existing ledger fields
- A measurement definition: which fields, which comparison, which metric
- A falsifiable prediction: PASS/FAIL criteria defined in advance
- A minimum evidence requirement: defined before evaluation
- A risk profile: false-positive rate, starvation risk, decision-path neutrality

### 3.1 Required Fields for Every SPC

Each registered Shadow Policy Candidate must specify all of the following:

| Field | Description |
|---|---|
| `policy_id` | Unique SPC identifier (e.g., SPC-001) |
| `target_playbook` | RBSR, TPC, VCR, or ALL_PLAYBOOKS |
| `target_packet` | Specific packet type(s) the policy hypothesizes about |
| `policy_type` | One of the allowed types (§3.2) |
| `evidence_fields_used` | Exact ledger fields the policy reads for evaluation |
| `shadow_decision_output` | What the policy outputs per record (WOULD_HAVE_BLOCKED / WOULD_HAVE_CONFIRMED / WOULD_HAVE_REDUCED / ATTRIBUTION_NOTE_ONLY) |
| `acceptance_metric` | Measurable outcome comparison that would constitute policy support |
| `rejection_metric` | Measurable outcome comparison that would constitute policy rejection |
| `sample_requirement` | Minimum records / outcomes needed before evaluation |
| `false_positive_risk` | Risk that policy fires incorrectly and misleads analysis |
| `starvation_risk` | Risk that policy fires too broadly and eliminates valid signal |
| `runtime_authority_status` | Always: NONE |
| `current_status` | BLOCKED / EARLY_RESEARCH / PROMISING / POST_CLEANUP_MONITORING / READY_TO_ACCUMULATE |

### 3.2 Allowed Policy Types

| Type | Purpose |
|---|---|
| FAILURE_MODE_SHADOW | Hypothesis: a specific failure mode condition (e.g., MFI counter-direction) degrades outcomes |
| CONFIRMATION_SHADOW | Hypothesis: a specific confirmation condition improves outcomes above baseline |
| MISSING_LINK_SHADOW | Hypothesis: absence of a specific chain link predicts worse outcomes |
| EVENT_ORDER_SHADOW | Hypothesis: event ordering violations correlate with outcome degradation |
| REGIME_CONTEXT_SHADOW | Hypothesis: a specific regime context increases or decreases playbook outcome quality |
| PLAYBOOK_STATE_SHADOW | Hypothesis: a specific playbook state (FORMING vs CONTRADICTED) predicts outcomes |
| EXECUTION_GEOMETRY_SHADOW | Hypothesis: specific room/stop geometry conditions within playbook context predict outcomes |
| ATTRIBUTION_ONLY_SHADOW | Not a predictive hypothesis — a labeling/attribution-only policy for analytical classification |

No other type is recognized unless justified and labeled with explicit rationale.

### 3.3 Governance Firewall for All SPCs

The following constraints are absolute for this entire package and all downstream work derived from it:

| Rule | Constraint |
|---|---|
| GFS-1 | Shadow policy design does NOT authorize implementation. An SPC being defined here cannot be activated in MT5 without a separate bounded Codex task receiving explicit operator authorization. |
| GFS-2 | Shadow policy design does NOT authorize runtime consumption. No SPC may be read by the decision pipeline, aggregator, pre-AI filter, governor, or any execution path. |
| GFS-3 | Shadow policy design does NOT authorize gate, score, weight, council_quality, HIGH_CONVICTION, CRR, DSN, risk, execution, role, trigger, or stop/target changes. |
| GFS-4 | PLAYBOOK_VALID does not mean trade. A PLAYBOOK_VALID state in any SPC analysis is an evidence classification only — it does not authorize execution. |
| GFS-5 | PLAYBOOK_CONTRADICTED does not mean block. A PLAYBOOK_CONTRADICTED state in any SPC analysis is an evidence classification only — it does not block execution. |
| GFS-6 | FAILURE_MODE_PACKET does not mean veto. An accepted FAILURE_MODE_PACKET is a research finding only — it does not authorize a runtime veto. |
| GFS-7 | CONFIRMATION_PACKET does not mean requirement. An accepted CONFIRMATION_PACKET is a research finding only — it does not mandate a CRR-style gate. |
| GFS-8 | V1 remains permission authority. All SPC analysis is retrospective and advisory only. The MT5 EA continues to hold all execution permissions. |
| GFS-9 | Execution Geometry remains survivability authority. SPC analysis does not propose or modify stop/target geometry. |
| GFS-10 | Attribution owns learning. SPC outcomes feed into research design and evidence classification — not into live trading parameters. |

---

## 4. Candidate Policy Registry

Ten candidate shadow policies are registered. Each is defined with full SPC fields per §3.1.

---

### SPC-001 — TPC Missing Confirmation Shadow

| Field | Value |
|---|---|
| policy_id | SPC-001 |
| target_playbook | TREND_PULLBACK_CONTINUATION |
| target_packet | CONFIRMATION_PACKET (missing link) |
| policy_type | MISSING_LINK_SHADOW |
| current_status | BLOCKED_FOR_EVALUATION |

**Hypothesis:** When trend_momentum fires but trend_pullback_cont_v1 does NOT fire (FORMAL_CONFIRMATION_PACKET missing), TC execution outcomes are materially worse than when both co-fire.

**Evidence fields used:**
- `playbook_id` (filter to TPC records)
- `strategy_id` (identify trend_momentum records)
- `playbook_state` (FORMING = confirm absent)
- `missing_links` (contains FORMAL_CONFIRMATION_PACKET or TPC_PULLBACK_OR_REENTRY_CONFIRM)
- `completed_links` (TPC_SPARSE_CONFIRM absent)
- `packet_registry_status`
- `final_decision` (BUY/SELL)
- `outcome` (WIN/LOSS — from performance journal cross-reference)

**Shadow decision output:**
`WOULD_HAVE_BLOCKED` — records where trend_momentum fired AND confirmation absent.

**Acceptance metric:**
Outcome WR in "FORMAL_CONFIRMATION_PACKET missing" group ≥ 3pp below "FORMAL_CONFIRMATION_PACKET present" group, with E[R] differential ≥ −0.06R. N ≥ 30 in both groups.

**Rejection metric:**
No material WR or E[R] differential between groups (< 1pp WR gap; < 0.03R E[R] gap); or the "absent" group outperforms the "present" group.

**Sample requirement:**
- Minimum 50 executed TC decisions in V1C ledger
- Minimum 10 records where TPC confirmation was present (co-fire events)
- Minimum 30 records where TPC confirmation was absent
- Post-cleanup records only (K2 cleanup removes confounding UNKNOWN records)

**False-positive risk:** LOW for analytical evaluation — field clearly distinguishes present/absent states. If ever proposed for runtime: HIGH — missing formal confirmation would block ~98.6% of TC trades (TPC co-presence structural 1.4%), causing near-total TC starvation.

**Starvation risk (if implemented):** CRITICAL — per Nautilus data, TPC co-fires with trend_momentum in only 1.4% of trend_momentum trades. A mandatory confirmation gate would eliminate 98.6% of TC executions. This policy must NEVER be implemented as a hard gate without a prior architecture decision resolving TPC sparsity.

**Blocked by:** TPC trigger_seen=0 in live V1C window. Cannot evaluate "present" group with 0 TPC co-fires. BLOCKED until trend_pullback_cont_v1 accumulates ≥ 10 co-execution records in V1C ledger.

**Forbidden:** Implement as gate. Implement as score. Propose as mandatory CRR condition. Any activation without TPC sparsity resolution.

---

### SPC-002 — TPC Contradicted / Exhaustion Warning Shadow

| Field | Value |
|---|---|
| policy_id | SPC-002 |
| target_playbook | TREND_PULLBACK_CONTINUATION |
| target_packet | FAILURE_MODE_PACKET (exhaustion contradiction) |
| policy_type | FAILURE_MODE_SHADOW |
| current_status | EARLY_RESEARCH |

**Hypothesis:** When a TPC record shows PLAYBOOK_CONTRADICTED (exhaustion_warning active alongside trend_anchor), TC execution outcomes are materially worse than PLAYBOOK_FORMING records.

**Evidence fields used:**
- `playbook_id` (filter to TPC)
- `playbook_state` (CONTRADICTED vs FORMING)
- `contradicted_links` (TPC_EXHAUSTION_WARNING)
- `failure_mode_present`, `failure_mode_type`
- `strategy_id` (mfi_reversal_assist fire presence)
- `final_decision`
- `outcome`

**Shadow decision output:**
`WOULD_HAVE_BLOCKED` — records where PLAYBOOK_CONTRADICTED and exhaustion_warning was the contradiction source.

**Acceptance metric:**
CONTRADICTED group WR ≥ 3pp below FORMING group, with E[R] differential ≥ −0.06R. N ≥ 20 CONTRADICTED records.

**Rejection metric:**
No WR/E[R] differential between groups; or CONTRADICTED group outperforms FORMING group.

**Sample requirement:**
- Minimum 20 CONTRADICTED TPC records
- Minimum 50 FORMING TPC records
- Outcome data (WIN/LOSS) available for both groups

**False-positive risk:** MEDIUM — exhaustion_warning is a boolean field in CouncilRuntimeResult; it may fire on conditions unrelated to genuine exhaustion. Requires mfi_reversal_assist live data to contextualize.

**Starvation risk (if implemented):** MEDIUM — exhaustion_warning fires in a minority of TC bars; starvation risk is moderate and depends on frequency.

**Blocked by partially:** Only 1 CONTRADICTED record observed in V1C window. Minimum 20 required for evaluation. Current count insufficient.

**Requires:** mfi_reversal_assist continued accumulation (currently 2 executions; Phase 4B requires 5 minimum for veto design, 30+ for this policy evaluation).

**Forbidden:** Implement as veto before Phase 4B threshold reached. Conflate exhaustion_warning flag with actual mfi_reversal_assist signal strength.

---

### SPC-003 — RBSR MFI Counter-Direction Failure-Mode Shadow

| Field | Value |
|---|---|
| policy_id | SPC-003 |
| target_playbook | RANGE_BOUNDARY_SWEEP_RECLAIM |
| target_packet | FAILURE_MODE_PACKET (MFI counter-direction) |
| policy_type | FAILURE_MODE_SHADOW |
| current_status | PROMISING_BUT_SAMPLE_INSUFFICIENT |

**Hypothesis:** When mfi_reversal_assist fires in the direction OPPOSITE to the RBSR sweep anchor (failure_mode_type = MFI_COUNTER_DIRECTION), RBSR execution outcomes are materially worse than when mfi_reversal_assist fires in the SAME direction or is absent.

**Basis:** Prior Nautilus composite evidence in ARCHITECTURE_BUILD_PACKAGE_V1.md suggests MFI counter-direction degrades sweep/reclaim outcomes. The RBSR failure mode logic in OL_ComputePlaybookShadowStates() specifically detects this condition (rbsr_failure = MFI firing in opposite direction to sweep anchor). V1C records already emit failure_mode_present and failure_mode_type for this condition.

**Evidence fields used:**
- `playbook_id` (filter to RBSR)
- `failure_mode_present` (true when MFI counter fires)
- `failure_mode_type` = "MFI_COUNTER_DIRECTION"
- `contradicted_links` (RBSR_MFI_COUNTER_DIRECTION)
- `playbook_state` (CONTRADICTED)
- `strategy_id` (mfi_reversal_assist trigger present)
- `final_decision`
- `outcome`

**Shadow decision output:**
`WOULD_HAVE_BLOCKED` — records where failure_mode_present=true and failure_mode_type=MFI_COUNTER_DIRECTION.

**Acceptance metric:**
CONTRADICTED (MFI_COUNTER) RBSR group WR ≥ 3pp below non-CONTRADICTED RBSR group. E[R] differential ≥ −0.06R. N ≥ 20 CONTRADICTED RBSR records.

**Rejection metric:**
No WR/E[R] differential; or MFI_COUNTER group outperforms baseline.

**Sample requirement:**
- Minimum 20 records with RBSR PLAYBOOK_CONTRADICTED / failure_mode_type=MFI_COUNTER_DIRECTION
- Minimum 50 non-CONTRADICTED RBSR records for comparison
- Outcome cross-reference available

**False-positive risk:** MEDIUM — the counter-direction failure mode depends on mfi_reversal_assist signal direction alignment; requires sufficient MFI entries to evaluate meaningfully. Pre-cleanup data contains UNKNOWN records for mean_reversion_bounce that should be excluded.

**Starvation risk (if implemented):** LOW-MEDIUM — CONTRADICTED state is a minority case (1 record observed in 28); blocking on this condition would affect a small fraction of RBSR trades.

**Blocked by:** mfi_reversal_assist has only 2 live executions; insufficient to populate the CONTRADICTED group meaningfully. MFI_COUNTER_DIRECTION CONTRADICTED records require both a sweep anchor AND opposing MFI signal simultaneously — low-frequency event.

**Requires:** mfi_reversal_assist continued accumulation; minimum 20 CONTRADICTED RBSR records.

**Forbidden:** Implement as veto before Phase 4B threshold and this SPC's own sample minimum. Conflate RBSR MFI failure mode with TPC exhaustion_warning (different failure mode types).

---

### SPC-004 — RBSR Same-Direction MFI Confirmation Shadow

| Field | Value |
|---|---|
| policy_id | SPC-004 |
| target_playbook | RANGE_BOUNDARY_SWEEP_RECLAIM |
| target_packet | CONFIRMATION_PACKET (optional co-presence) |
| policy_type | CONFIRMATION_SHADOW |
| current_status | RESEARCH_ONLY |

**Hypothesis:** When mfi_reversal_assist fires in the SAME direction as the sweep anchor (same-direction, no failure mode), RBSR outcomes are marginally better than when mfi_reversal_assist is absent.

**Basis:** Prior Nautilus/composite evidence suggested same-direction MFI presence improved SR/BR outcomes but did not clear formal CONFIRMATION_PACKET acceptance thresholds (+2pp WR lift AND +0.04R E[R] lift). This SPC tracks whether live RBSR evidence supports or contradicts this marginal finding.

**Evidence fields used:**
- `playbook_id` (filter to RBSR)
- `failure_mode_present` (must be false — same-direction only)
- `optional_evidence_present` (mfi_reversal_assist fires same-direction)
- `completed_links` (RBSR_MFI_CONTEXT present)
- `strategy_id` (mfi_reversal_assist in ACTIVE/REDUCED state)
- `final_decision`, `outcome`

**Shadow decision output:**
`WOULD_HAVE_CONFIRMED` — records where mfi_reversal_assist fires same-direction without failure mode.

**Acceptance metric:**
MFI same-direction group WR ≥ 2pp above MFI absent group AND E[R] lift ≥ +0.04R. N ≥ 30 in each group. Co-presence rate must be ≤ 80% (discriminating).

**Rejection metric:**
No WR/E[R] differential; co-presence rate > 80% (ubiquitous); MFI-present group underperforms MFI-absent group.

**Sample requirement:**
- Minimum 50 RBSR executed decisions with outcome data
- Minimum 15 records with mfi_reversal_assist same-direction co-presence
- Minimum 15 records without mfi_reversal_assist

**False-positive risk:** MEDIUM — mfi_reversal_assist fires are currently sparse (2 executions in V1C window); small samples will inflate apparent WR differences.

**Starvation risk (if implemented as gate):** HIGH — MFI fires infrequently; mandatory confirmation would severely restrict RBSR executions. Must remain CONFIRMATION_SHADOW (quality enhancement candidate) not mandatory gate.

**Blocked by:** mfi_reversal_assist insufficient data (2 entries). Full evaluation requires 15+ same-direction co-presence records.

**Forbidden:** Implement as mandatory confirmation gate. Conflate with SPC-003 (counter-direction). Use as evidence for Phase 4B veto design.

---

### SPC-005 — RBSR Mean-Reversion-Bounce Inclusion Shadow

| Field | Value |
|---|---|
| policy_id | SPC-005 |
| target_playbook | RANGE_BOUNDARY_SWEEP_RECLAIM |
| target_packet | RESEARCH_ONLY_PACKET (secondary reclaim evidence) |
| policy_type | ATTRIBUTION_ONLY_SHADOW (transitioning to CONFIRMATION_SHADOW) |
| current_status | POST_CLEANUP_MONITORING_REQUIRED |

**Hypothesis:** mean_reversion_bounce, now correctly mapped to RBSR after K2 cleanup, contributes observable evidence to RBSR causal chain assessment. Its inclusion as RBSR_SECONDARY_RECLAIM_EVIDENCE in completed_links improves RBSR attribution accuracy.

**Basis:** mean_reversion_bounce was assigned UNKNOWN packet status before K2 cleanup due to missing registry/playbook mapping. The cleanup correctly routes it to RBSR with RESEARCH_ONLY status. The strategy has trigger_seen=1 in the V1C review window (2 UNKNOWN records before cleanup). Post-cleanup records will show it contributing to RBSR completed_links as RBSR_SECONDARY_RECLAIM_EVIDENCE.

**Evidence fields used:**
- `playbook_id` (filter to RBSR)
- `completed_links` (RBSR_SECONDARY_RECLAIM_EVIDENCE present)
- `packet_registry_status` (should now show RESEARCH_ONLY, not UNKNOWN)
- `strategy_id` (mean_reversion_bounce)
- `supporting_evidence_present` (should change from false to true when mrb fires)
- `final_decision`, `outcome` (for longitudinal tracking)

**Shadow decision output:**
`ATTRIBUTION_NOTE_ONLY` — this SPC verifies cleanup correctness before graduating to CONFIRMATION_SHADOW.

**Acceptance metric (for cleanup verification):**
Post-cleanup records for mean_reversion_bounce show packet_registry_status="RESEARCH_ONLY" (not "UNKNOWN"); playbook_id="RANGE_BOUNDARY_SWEEP_RECLAIM"; RBSR_SECONDARY_RECLAIM_EVIDENCE appears in completed_links when mrb fires.

**Rejection metric:**
Post-cleanup records still show UNKNOWN or PLAYBOOK_ASSIGNMENT_UNVERIFIED for mean_reversion_bounce.

**Sample requirement:**
- Minimum 5 post-cleanup mean_reversion_bounce V1C records (to confirm K2 fix live)
- For future CONFIRMATION_SHADOW upgrade: minimum 30 records with outcome data

**False-positive risk:** LOW for cleanup verification. For future confirmation analysis: MEDIUM — mean_reversion_bounce currently has 0 live W/L outcomes; early evidence will carry high variance.

**Starvation risk (if implemented):** LOW — this strategy is a secondary RBSR contributor; it would not dominate execution decisions.

**Blocked by:** K2 cleanup binary not yet reloaded. No post-cleanup records exist. Monitoring cannot begin until the cleanup binary is deployed.

**Forbidden:** Elevate to CONFIRMATION_SHADOW before 5+ post-cleanup records confirm K2 fix. Promote mean_reversion_bounce to mandatory CONFIRM role. Increase vote_weight without Nautilus certification and live N ≥ 15 W/L outcomes.

---

### SPC-006 — Bollinger Reclaim Packet Status Correction Shadow

| Field | Value |
|---|---|
| policy_id | SPC-006 |
| target_playbook | RANGE_BOUNDARY_SWEEP_RECLAIM |
| target_packet | RESEARCH_ONLY_PACKET (corrected from REJECTED) |
| policy_type | ATTRIBUTION_ONLY_SHADOW |
| current_status | POST_CLEANUP_VERIFICATION_REQUIRED |

**Hypothesis:** bollinger_reclaim's packet_registry_status of "REJECTED" in pre-cleanup V1C records was a semantic error. Post-cleanup records correctly label it "RESEARCH_ONLY." The corrected status accurately reflects that bollinger_reclaim is an ACTIVE strategy with EDGE_WEAK_BUT_RECOVERABLE certification, not a frozen or rejected one.

**Basis:** K3 cleanup changed bollinger_reclaim's OL_PacketRegistryStatusForStrategy() return value from "REJECTED" to "RESEARCH_ONLY". This matches the strategy's cert_label (EDGE_WEAK_BUT_RECOVERABLE) and its role as the primary RBSR CONFIRM-chain candidate. The "REJECTED" label was causing all bollinger_reclaim RBSR records to be misclassified in any analysis filtering by packet_registry_status.

**Evidence fields used:**
- `strategy_id` = "bollinger_reclaim"
- `packet_registry_status` (should be "RESEARCH_ONLY" post-cleanup)
- `playbook_id` = "RANGE_BOUNDARY_SWEEP_RECLAIM"
- Record timestamp (before vs. after cleanup reload)

**Shadow decision output:**
`ATTRIBUTION_NOTE_ONLY` — verification that cleanup is live.

**Acceptance metric:**
All bollinger_reclaim records after cleanup reload show packet_registry_status="RESEARCH_ONLY". Pre-cleanup records (7 records showing "REJECTED") are preserved in JSONL unchanged — this is expected and correct.

**Rejection metric:**
Post-reload bollinger_reclaim records continue to show "REJECTED".

**Sample requirement:**
- Minimum 3 post-cleanup bollinger_reclaim V1C records

**False-positive risk:** NEGLIGIBLE — this is a status label verification, not an outcome analysis.

**Starvation risk:** NONE — ATTRIBUTION_ONLY_SHADOW with no decision impact.

**Blocked by:** K3 cleanup binary not yet reloaded. First priority after reload validation.

**Transition path:** Once K3 is verified live, SPC-006 is complete as ATTRIBUTION_ONLY_SHADOW. RBSR bollinger_reclaim analysis can then proceed using RESEARCH_ONLY-labeled records accurately.

**Note on CONFIRMATION_PACKET rejection (registry status):** Separately from this cleanup, the registry has established that bollinger_reclaim's CONFIRMATION_PACKET claim is formally REJECTED (RANGE era E[R]=−0.052R; WR=37.92% < 40% breakeven). The RESEARCH_ONLY packet status in V1C reflects the strategy's active role and certification tier — it does NOT reverse the REJECTED CONFIRMATION_PACKET finding. These are two different status fields at two different levels.

**Forbidden:** Interpret "RESEARCH_ONLY" packet status as reversal of CONFIRMATION_PACKET rejection. Use K3 cleanup as evidence for bollinger_reclaim weight increase.

---

### SPC-007 — VCR Absence Monitor

| Field | Value |
|---|---|
| policy_id | SPC-007 |
| target_playbook | VOLATILITY_COMPRESSION_RELEASE |
| target_packet | DATA_INSUFFICIENT_PACKET (all VCR strategies) |
| policy_type | ATTRIBUTION_ONLY_SHADOW |
| current_status | BLOCKED_UNTIL_COMPRESSION_EXPANSION_ZONE_ACTIVITY |

**Hypothesis:** VCR's absence in V1C records is regime-conditional (COMPRESSION/EXP zones not active during the review window), not a strategy detection failure. Confirming this requires observing at least one COMPRESSION or EXP zone session.

**Basis:** All 5 VCR strategies had trigger_seen=0 across 20 evaluated bars. Playbook state = PLAYBOOK_NOT_PRESENT in all VCR records (0 records, since none triggered). The underlying question is whether the zone detection → strategy detection pipeline works correctly for VCR, or whether VCR strategies are broken/dormant regardless of zone.

**Evidence fields used:**
- V1C records where playbook_id would be "VOLATILITY_COMPRESSION_RELEASE"
- Zone field from the Opportunity Ledger (zone = COMPRESSION or EXP)
- strategy_id for any of the 5 VCR strategies (trigger_seen > 0)
- ai_opportunity_summary.json evaluations_seen per VCR strategy (confirming bars were evaluated)

**Shadow decision output:**
`ATTRIBUTION_NOTE_ONLY` — confirms whether VCR detection pipeline is alive.

**Acceptance metric:**
At least 1 VCR strategy fires (trigger_seen ≥ 1) during a COMPRESSION or EXP zone session. VCR records appear in V1C JSONL with PLAYBOOK_NOT_PRESENT or PLAYBOOK_FORMING.

**Rejection metric:**
COMPRESSION or EXP zone activity confirmed (from council_environment fields) but VCR strategies still show trigger_seen=0. Would indicate broken detection for VCR zone, not just regime absence.

**Sample requirement:**
- Minimum 5 COMPRESSION or EXP zone bars in V1C evaluation window

**False-positive risk:** LOW — this is an operational check, not an outcome hypothesis.

**Starvation risk:** NONE — ATTRIBUTION_ONLY_SHADOW.

**Blocked by:** No COMPRESSION/EXP zone activity in observed window. Cannot evaluate until regime conditions occur.

**Requires:** Active monitoring across regime transitions; flag next COMPRESSION/EXP session for VCR check.

**Forbidden:** Assume VCR strategies are broken before zone activity confirmed. Disable or remove VCR strategies based on absence data alone.

---

### SPC-008 — Event Order Readiness Shadow

| Field | Value |
|---|---|
| policy_id | SPC-008 |
| target_playbook | ALL_PLAYBOOKS |
| target_packet | EVENT_ORDER_CONTRACT (structural prerequisite) |
| policy_type | EVENT_ORDER_SHADOW |
| current_status | STRUCTURAL_BLOCKER_FOR_RUNTIME_POLICY |

**Hypothesis:** The current V1C architecture cannot produce PLAYBOOK_VALID states because event_order_valid=false universally (Stage 18.5 post-decision position). Defining the architectural requirements for a future version (V1D or higher) that could produce PLAYBOOK_VALID requires specifying exactly what pre-decision timestamps and instrumentation would be needed.

**Basis:** All 28 V1C records show event_order_valid=false, pre_decision_available=false, event_order_violation_reason="POST_DECISION_SHADOW_ASSEMBLY". This is a known structural limitation of Stage 18.5, documented in the V1C implementation report. PLAYBOOK_VALID is specifically withheld by design (not a bug). The Event Order Contract (§6 of ARCHITECTURE_BUILD_PACKAGE_V1.md) defines the 8-step required sequence that evidence must follow.

**Evidence fields used:**
- `event_order_valid` (currently always false)
- `pre_decision_available` (currently always false)
- `event_order_violation_reason`
- `late_evidence` (post-K1 cleanup: should be false unless genuinely late)
- Timestamp fields in OL_EventOrderTrace struct

**Shadow decision output:**
`ATTRIBUTION_NOTE_ONLY` — characterizes the structural gap; cannot evaluate policy outcomes.

**Acceptance metric (for readiness assessment):**
A future V1D implementation would produce: event_order_valid=true in records where evidence genuinely preceded the decision, and pre_decision_available=true when pre-decision timestamps are available. Required prerequisite: Stage 18.5 must be replaced or augmented with a pre-decision instrumentation point.

**Rejection metric:**
V1D still places instrumentation post-decision — event_order_valid would remain universally false.

**Sample requirement:**
Not evaluable from V1C data. This SPC is a design specification for future architecture, not a current measurement.

**False-positive risk:** Not applicable — ATTRIBUTION_ONLY_SHADOW.

**Starvation risk:** Not applicable — ATTRIBUTION_ONLY_SHADOW.

**Blocked by:** Structural limitation of Stage 18.5. No workaround within V1C. Requires architectural decision (V1D scope or higher) to resolve.

**Key output of this SPC for next architecture work:**
For PLAYBOOK_VALID to be emissible and meaningful, the following must exist in a future version:
1. A pre-decision instrumentation point (before `runtime.final_decision` assignment at L1586/1596/1608)
2. Timestamps for: context establishment, location confirmation, trigger fire, confirmation fire, failure-mode evaluation
3. These timestamps must be passed to OL_ComputeEventOrderTrace() before the decision
4. Only then can event_order_valid=true be emitted for records where all 8 EOC steps are satisfied

**Forbidden:** Claim PLAYBOOK_VALID is meaningful under V1C. Claim that current late_evidence=false (post-K1 cleanup) means event order was valid.

---

### SPC-009 — Playbook CONTRADICTED State Outcome Shadow

| Field | Value |
|---|---|
| policy_id | SPC-009 |
| target_playbook | ALL_PLAYBOOKS (initially TPC, then RBSR) |
| target_packet | FAILURE_MODE_PACKET (categorical state predictor) |
| policy_type | PLAYBOOK_STATE_SHADOW |
| current_status | INSUFFICIENT_DATA |

**Hypothesis:** Records where playbook_state = PLAYBOOK_CONTRADICTED have materially worse trade outcomes than records where playbook_state = PLAYBOOK_FORMING.

**Basis:** This is the most fundamental hypothesis the playbook architecture is designed to eventually test. If CONTRADICTED states reliably predict worse outcomes than FORMING states, this provides the first empirical evidence that the playbook causal chain has real predictive value for outcome quality. Only 1 CONTRADICTED record was observed in the 28-record V1C review window — far below the 20+ minimum required.

**Evidence fields used:**
- `playbook_state` (FORMING vs CONTRADICTED)
- `playbook_id` (to disaggregate by playbook)
- `failure_mode_present`, `failure_mode_type`
- `contradicted_links`
- `final_decision`
- `outcome` (WIN/LOSS from performance journal cross-reference)

**Shadow decision output:**
`WOULD_HAVE_BLOCKED` — records where PLAYBOOK_CONTRADICTED state was active at decision time.

**Acceptance metric:**
CONTRADICTED group WR ≥ 5pp below FORMING group AND E[R] differential ≥ −0.06R. N ≥ 20 CONTRADICTED records with outcome data. Must hold across both RBSR and TPC independently (not just aggregate).

**Rejection metric:**
No material WR/E[R] differential between CONTRADICTED and FORMING groups after sufficient accumulation. Or CONTRADICTED group outperforms FORMING group.

**Sample requirement:**
- Minimum 20 CONTRADICTED records with outcome data (across all playbooks)
- Minimum 50 FORMING records with outcome data for comparison baseline
- Must disaggregate by playbook (RBSR vs TPC)

**False-positive risk:** MEDIUM — PLAYBOOK_CONTRADICTED currently requires both a trigger AND an opposing mfi signal (RBSR) or exhaustion_warning AND anchor (TPC). Low-frequency events in small sample create high variance.

**Starvation risk (if implemented):** MEDIUM — CONTRADICTED state is minority case; blocking on it would affect a manageable fraction of executions. Starvation depends on how frequently exhaustion_warning fires in TPC zone.

**Blocked by:** Only 1 CONTRADICTED record observed. Minimum 20 required. Cannot evaluate.

**Long-term significance:** This SPC, if confirmed with adequate data, would provide the first live evidence that the playbook architecture captures real outcome-predictive information. It is the highest-value hypothesis in the registry if sufficient data can be accumulated.

**Forbidden:** Implement CONTRADICTED state as blocking condition before this SPC is evaluated. Conflate the 1 observed CONTRADICTED record as evidence of the hypothesis.

---

### SPC-010 — RBSR Activity Concentration Shadow

| Field | Value |
|---|---|
| policy_id | SPC-010 |
| target_playbook | RANGE_BOUNDARY_SWEEP_RECLAIM |
| target_packet | ALPHA_TRIGGER_PACKET (concentration diagnostic) |
| policy_type | REGIME_CONTEXT_SHADOW |
| current_status | ACCUMULATION_REQUIRED |

**Hypothesis:** RBSR's dominance in V1C records (53.6% of all records) reflects a genuine regime condition where REV/RMR zone activity dominated the review window — not that RBSR strategies are over-triggering or noisy. Alternatively: RBSR triggers may fire across zones where they should not be active, inflating apparent RBSR activity.

**Basis:** 15 of 28 V1C records are RBSR. In the V1C summary, bollinger_reclaim had the highest trigger frequency (trigger_seen=6, trigger_executed=5). This concentration could mean (a) market was predominantly in REV/RMR regime during the window, or (b) RBSR strategies have overly broad trigger conditions or zone eligibility. The two explanations have opposite implications for policy design.

**Evidence fields used:**
- `playbook_id` = "RANGE_BOUNDARY_SWEEP_RECLAIM"
- `zone` field in ledger records (from council environment — REV/RMR vs other zones)
- `regime_label` or `era_label_v1` (RANGE_NEUTRAL, TREND_UP, TREND_DOWN per bar)
- `strategy_id` distribution within RBSR records
- `final_decision`, `outcome`

**Shadow decision output:**
`ATTRIBUTION_NOTE_ONLY` — regime distribution characterization.

**Acceptance metric:**
RBSR activity concentration is regime-explained: ≥ 70% of RBSR records occur in REV or RMR zone context, consistent with designed zone eligibility. No RBSR triggers fire in TC or COMPRESSION zones where they should be BLOCKED.

**Rejection metric:**
RBSR triggers appear in non-eligible zones (TC, COMPRESSION, EXP) at significant rates (> 20% of RBSR records). Would indicate zone eligibility misconfiguration.

**Sample requirement:**
- Minimum 50 RBSR records with zone context available
- Zone field must be present in ledger records (requires ledger schema to include zone data — currently available in opportunity_summary.json but not individual JSONL records per strategy)

**False-positive risk:** LOW for regime characterization. For outcome analysis: MEDIUM — small RBSR samples inflate WR variance.

**Starvation risk:** NONE — ATTRIBUTION_ONLY_SHADOW for regime diagnosis.

**Blocked by:** Zone field not currently available in per-record V1C JSONL output. ai_opportunity_summary.json contains evaluations_seen counts but not zone breakdowns per record. Would require ledger schema enhancement to capture zone context per-record.

**Required ledger enhancement:** To fully evaluate SPC-010, a future ledger version must include `zone_label` and `regime_label` fields per trigger-present record. This is a Layer 1 (Attribution/Ledger Alignment) work item per ARCHITECTURE_BUILD_PACKAGE_V1.md Package B.

**Forbidden:** Reduce RBSR vote_weights based on concentration without confirming zone misconfiguration. Assume over-triggering without zone data.

---

## 5. Required Ledger Evidence Per Candidate

The following minimums apply. All pre-cleanup data must be treated with caution — bollinger_reclaim REJECTED records and mean_reversion_bounce UNKNOWN records should be excluded from SPC analysis requiring clean packet_registry_status.

| SPC | Min V1C Records | Min Target Playbook Records | Min Contradicted Records | Min Outcome Records | Post-Cleanup Only? | Status |
|---|---|---|---|---|---|---|
| SPC-001 | 50 executed TC | 50 TPC | N/A | 30 W/L | YES (K2 required) | BLOCKED |
| SPC-002 | 70 TPC records | 70 TPC | 20 CONTRADICTED | 50 W/L | NO | BLOCKED |
| SPC-003 | 70 RBSR records | 70 RBSR | 20 CONTRADICTED | 50 W/L | NO | BLOCKED |
| SPC-004 | 80 RBSR records | 80 RBSR | N/A | 50+ W/L | YES (K2 preferred) | BLOCKED |
| SPC-005 | 5 post-cleanup | 5 RBSR post-cleanup | N/A | 30 W/L (for upgrade) | YES — post-cleanup required | BLOCKED (pending reload) |
| SPC-006 | 3 post-cleanup | 3 bollinger_reclaim post-cleanup | N/A | N/A | YES — post-cleanup required | BLOCKED (pending reload) |
| SPC-007 | 5 COMPRESSION/EXP zone | 5 VCR zone | N/A | N/A | NO | BLOCKED (regime) |
| SPC-008 | N/A — design SPC | N/A | N/A | N/A | N/A | STRUCTURAL_BLOCKER |
| SPC-009 | 70 total | 20 CONTRADICTED, 50 FORMING | 20 CONTRADICTED | 20 W/L CONTRADICTED | YES (K2/K3 preferred) | BLOCKED |
| SPC-010 | 50 RBSR | 50 RBSR | N/A | N/A | YES (K2/K3 preferred) | BLOCKED (zone field missing) |

**General thresholds (from ARCHITECTURE_BUILD_PACKAGE_V1.md and Registry):**

| Level | Records Required | Purpose |
|---|---|---|
| Structural review | 30–50 V1C records | Schema integrity, state distribution characterization |
| Preliminary candidate review | 100+ V1C records | First outcome comparisons; high variance expected |
| Policy design review | 200+ V1C records | Phase 4C threshold; quality gate design basis |
| Contradiction/failure-mode review | 20+ relevant CONTRADICTED events | SPC-002, SPC-003, SPC-009 minimum |
| Phase 4B veto threshold calibration | 5 MFI signal strength readings (min); 30+ preferred | SPC-002 and SPC-004 dependency |

**Current state (2026-05-09 post-cleanup, pre-reload):** 28 V1C records, 0 outcomes cross-referenced, 7 bollinger_reclaim REJECTED, 2 mean_reversion_bounce UNKNOWN. Every SPC is blocked for evaluation. No SPC can be advanced until the cleanup binary is reloaded and records begin accumulating post-cleanup.

---

## 6. Shadow Evaluation Output Fields

The following fields define the output format for a future Shadow Policy Evaluator report. These are **analysis output fields only** — they must not be added to the runtime MT5 EA until separately authorized under a bounded Codex task.

| Field | Type | Description |
|---|---|---|
| `shadow_policy_id` | string | SPC identifier (e.g., "SPC-003") |
| `ledger_record_id` | string | Cross-reference to the V1C JSONL record being evaluated |
| `shadow_policy_triggered` | bool | True if the SPC condition was met on this record |
| `shadow_policy_reason` | string | Free-text reason the policy triggered or did not trigger |
| `would_have_blocked` | bool | True if this SPC, if implemented, would have blocked the trade |
| `would_have_reduced` | bool | True if this SPC, if implemented, would have reduced weight/confidence |
| `would_have_confirmed` | bool | True if this SPC, if implemented, would have added confirmation |
| `actual_final_decision` | string | The actual decision made by V1 (BUY/SELL/WAIT/REJECT) |
| `actual_outcome` | string | WIN/LOSS/OPEN/FLAT — cross-referenced from performance journal |
| `delta_outcome_if_simulated` | string | Hypothetical outcome delta if the shadow policy had been applied |
| `false_positive_marker` | bool | True if policy triggered but outcome was WIN (potential false positive) |
| `starvation_marker` | bool | True if policy triggered on a record that was the only signal in a window |
| `evidence_sufficiency` | string | SUFFICIENT / ADEQUATE / MARGINAL / INSUFFICIENT for this evaluation |
| `evaluation_timestamp` | string | When the evaluator generated this assessment |
| `pre_cleanup_flag` | bool | True if the underlying V1C record predates K1/K2/K3 cleanup (requires caution) |

**Important:** These fields do not exist in the current runtime. They are evaluation report fields for an external/offline analysis tool. No MT5 source file is modified by this section.

---

## 7. Candidate Acceptance and Rejection Rules

### 7.1 Advancement Criteria (a candidate can advance from BLOCKED to READY_TO_EVALUATE when)

All of the following must be true:

1. Evidence sample requirement from §5 is met for the specific SPC
2. Outcome data (WIN/LOSS cross-reference) is available and verified for relevant records
3. Starvation risk is assessed and found acceptable (< 30% starvation for the specific context, or explicitly justified above that threshold)
4. False-positive risk is measured (not estimated) from the available sample
5. Decision-path neutrality is preserved (the SPC reads from ledger fields only; no feedback path to decision pipeline)
6. The SPC does not duplicate an existing gate (CRR, DSN, Level Brake, P4, V1) — it must measure something not already gated
7. The SPC improves interpretation or future design clarity — must have a clear answer use-case

### 7.2 Rejection Criteria (a candidate is rejected if)

Any of the following is true:

- **No measurable marginal contribution:** The SPC output provides no information that the existing ledger fields do not already provide.
- **Only reduces sample without outcome improvement:** The SPC fires broadly but does not improve outcome quality in any tested condition.
- **Creates > 30% starvation without explicit justification and operator authorization:** Applies to any SPC proposed for runtime implementation.
- **Relies on late/unverifiable evidence:** The SPC uses fields that are known to be post-decision (e.g., `event_order_valid=false` does not discriminate under V1C; `late_evidence=true` pre-cleanup was non-discriminating).
- **Contradicts V1 authority:** The SPC's output would, if implemented, override a V1 decision layer without explicit authorization.
- **Cannot be evaluated from ledger fields:** The SPC requires data not present in V1C JSONL or the performance journal.
- **Is merely narrative:** The SPC does not have measurable acceptance and rejection criteria.

### 7.3 Upgrade Criteria (a candidate can be promoted from RESEARCH to PROMISING when)

1. Preliminary evaluation (100+ records) shows direction of effect consistent with hypothesis
2. Sample is MARGINAL or better (N ≥ 30 in comparison groups)
3. Effect size is at least 50% of the acceptance metric threshold
4. False-positive rate is below 40% in preliminary sample

### 7.4 Implementation Criteria (a candidate can advance to implementation proposal when)

This threshold is very high. All must be true:

1. Sample is SUFFICIENT (N ≥ 100 in each comparison group with outcome data)
2. Acceptance metric is met with statistical stability (60/40 walk-forward split, both halves consistent)
3. Starvation simulation shows < 30% execution reduction OR explicit operator authorization for higher rate
4. False-positive rate < 25% in SUFFICIENT sample
5. Decision-path isolation verified by code inspection before any Codex task
6. Separate bounded Codex task authorized by operator
7. PIML updated to reflect implementation plan

---

## 8. Current Candidate Prioritization

Priority is assigned based on: (a) how much the SPC depends on current evidence, (b) whether it can be advanced without waiting for extended evidence accumulation, (c) the downstream value of the finding.

| Priority | SPC | Rationale |
|---|---|---|
| 1 | **SPC-006** Bollinger status correction verification | Most immediately actionable after reload. Requires only 3 post-cleanup records. Clears 7 pre-cleanup REJECTED records from future analysis. Required before any RBSR outcome analysis can use bollinger_reclaim records reliably. |
| 2 | **SPC-005** Mean-reversion-bounce post-cleanup RBSR mapping | Second most immediately actionable. Requires only 5 post-cleanup records. Clears 2 pre-cleanup UNKNOWN records. Required before mean_reversion_bounce can contribute clean RBSR evidence. |
| 3 | **SPC-007** VCR absence monitor | Low evidence requirement (5 COMPRESSION zone bars). High informational value — determines whether VCR is regime-absent or broken. Relevant to every future VCR policy design decision. |
| 4 | **SPC-010** RBSR activity concentration | Medium priority. Requires ledger zone_label field (currently missing — Layer 1 enhancement needed). Relevant to understanding whether RBSR domination in V1C records is a zone-selection issue or a regime-distribution issue. |
| 5 | **SPC-003** RBSR MFI counter-direction failure-mode | High value if confirmed — would establish the first live FAILURE_MODE evidence. Blocked by MFI accumulation (2 entries of 20 needed). Priority 5 reflects its importance vs. its medium-term horizon. |
| 6 | **SPC-004** RBSR same-direction MFI confirmation | Closely related to SPC-003; evaluates the positive corollary. Also blocked by MFI accumulation. Priority 6 because SPC-003 (failure mode detection) is more immediately actionable than SPC-004 (confirmation). |
| 7 | **SPC-009** Contradicted-state outcome | Highest long-term value hypothesis in the registry. Blocked by 1 CONTRADICTED record vs. 20 required. Long accumulation horizon but most important if confirmed. |
| 8 | **SPC-002** TPC contradicted/exhaustion warning | Meaningful if confirmed. Blocked by small CONTRADICTED sample (1 record). Closely linked to SPC-009 but TPC-specific. |
| 9 | **SPC-001** TPC missing confirmation | High analytical value but starvation risk is CRITICAL if ever implemented. Blocked by TPC trigger_seen=0. Long-horizon candidate. |
| 10 | **SPC-008** Event Order readiness | STRUCTURAL_BLOCKER — not evaluable from V1C data. Priority 10 not because it lacks importance but because it requires architectural decisions beyond accumulation. |

**Priority adjustment rationale vs. requested order:**
- SPC-007 moved up to 3 (from 7) because it requires only 5 COMPRESSION zone bars — lower threshold than any outcome-based SPC — and VCR characterization is needed for any future VCR policy design.
- SPC-010 moved up to 4 (from 10) because it addresses the RBSR concentration question that affects interpretation of all RBSR outcome data; however, it remains priority 4 not 2 because it requires a ledger enhancement.
- SPC-009 moved up to 7 (from 9) because it is the highest-value hypothesis in the system; despite the long accumulation horizon, it should be tracked actively.
- SPC-008 dropped to 10 (from 8) because it is a structural design specification, not an evidence accumulation target; it cannot advance without an architecture decision.

---

## 9. What Is Blocked

The following are all BLOCKED, FORBIDDEN, or NOT_AUTHORIZED as of 2026-05-09:

| Item | Status | Reason |
|---|---|---|
| Any runtime policy implementation | FORBIDDEN | No SPC is authorized for runtime consumption by this package |
| Phase 4A (cross-family CRR upgrade) | BLOCKED | TPC trigger_seen=0 live; architectural decision required (DESIGN_V1_REVIEW_AMENDMENTS A6); Phase 4A BLOCKED pending 5+ distinct live TPC firings and 20%+ eligible-bar rate |
| Phase 4B (exhaustion veto) | BLOCKED | mfi_reversal_assist = 2 live entries; minimum 5 signal-strength readings required before any veto threshold design; BLOCKED_INSUFFICIENT_CALIBRATION_DATA per DESIGN_V1_REVIEW_AMENDMENTS A7 |
| Phase 4C (quality soft gate) | BLOCKED | Opportunity Ledger = 28 V1C records; minimum 200 required before any suppression gate |
| VCR policy of any kind | BLOCKED | 0 VCR records; VCR chain design is hypothesis only; no evidence exists |
| PLAYBOOK_VALID as execution signal | FORBIDDEN | PLAYBOOK_VALID is never emitted in V1C; even if emitted in future versions, it would not authorize execution |
| PLAYBOOK_CONTRADICTED as execution block | FORBIDDEN | PLAYBOOK_CONTRADICTED is an attribution-only label; 1 CONTRADICTED record confirms non-blocking behavior in V1C |
| Production candidate status | NOT_AUTHORIZED | System remains DEVELOPING; no phase completion changes this |
| SPC implementation as gate or score | FORBIDDEN | All SPCs are analytical research only |
| Weight changes based on SPC analysis | FORBIDDEN | Weight changes require Phase 6 path: Phase 2 live + Phase 3 (≥8 certs) + Phase 4 runtime sample; EEWP is DESIGN_ONLY |
| Nautilus as runtime authority | FORBIDDEN | Nautilus = evidence only; operator = approval path |
| bollinger_reclaim CONFIRMATION_PACKET reinstatement | FORBIDDEN | Registry finding stands: CONFIRMATION_PACKET = REJECTED (RANGE era E[R]=−0.052R); K3 cleanup does not reverse this finding |
| mean_reversion_bounce role or weight promotion | FORBIDDEN | DATA_INSUFFICIENT; 0 live W/L outcomes; Nautilus not run |
| TPC mandatory confirmation gate without sparsity resolution | FORBIDDEN | TPC 1.4% co-presence structural; mandatory gate = 98.6% TC starvation |
| Any SPC advancing without meeting sample_requirement | FORBIDDEN | See §7.1; advancement criteria are mandatory |

---

## 10. Next Large Package Recommendation

### Recommended: POST_CLEANUP_RUNTIME_VALIDATION_AND_ACCUMULATION_PACKAGE_V1

**Purpose:** Validate the K1/K2/K3 cleanup is live and functioning correctly, then accumulate sufficient V1C evidence to enable SPC evaluation.

**Scope:**

**Part A — Cleanup Validation (highest priority):**
1. EA reload with the cleanup binary (V1C_CLEANUP_PACKAGE_V1 compiled 2026-05-09 00:57:43)
2. Verify K3: bollinger_reclaim records show packet_registry_status="RESEARCH_ONLY" (not "REJECTED")
3. Verify K2: mean_reversion_bounce records (if triggered) show playbook_id="RANGE_BOUNDARY_SWEEP_RECLAIM" and packet_registry_status="RESEARCH_ONLY"
4. Verify K1: late_evidence_seen_count in ai_opportunity_summary.json summary remains 0 after flush
5. Confirm fake_break_reversal is also RESEARCH_ONLY in any records it generates
6. Confirm registry_unknown_strategy_seen_count does not increment for mean_reversion_bounce or fake_break_reversal

**Part B — Post-Cleanup Evidence Accumulation:**
7. Accumulate minimum 100 post-cleanup V1C records as the next major evidence threshold
8. Monitor mfi_reversal_assist trigger frequency (3 entries needed to reach minimum 5 for Phase 4B; need signal strength distribution)
9. Monitor for any COMPRESSION/EXP zone activity to begin VCR characterization (SPC-007)
10. Monitor TPC fire rate — track toward 5 distinct live firings (Phase 4A minimum condition)

**Part C — Evidence Snapshot at 100 Records:**
11. Re-run the V1C evidence review at the 100-record threshold
12. Assess whether SPC-003 / SPC-004 RBSR outcome comparisons are possible (requires outcome data)
13. Update Phase 4A/4B/4C blocker status from live evidence
14. Generate updated ai_strategy_memory.json analysis for mfi_reversal_assist WR/count

**This is not a micro-test.** It is a single-session (or short multi-session) monitoring and validation pass. The output is one evidence snapshot report, not 10 intermediate checks.

**What this package does NOT do:**
- It does not implement any Phase 4A/4B/4C change
- It does not implement any SPC as a gate
- It does not modify source files
- It does not change weights, roles, or triggers
- It does not update PIML unless explicitly requested

**Exit criteria for this package:**
- K1/K2/K3 confirmed live in post-cleanup records: YES/NO
- Post-cleanup V1C records accumulated: count reported
- mfi_reversal_assist signal strength readings: count reported
- TPC live triggers since reload: count reported
- VCR zone activity observed: YES/NO
- Any Phase 4 blocker status change: reported

**Dependency:** Requires market to be open and EA to be reloaded. Do not execute during market close.

---

## 11. Production-Readiness Impact

This package improves **policy design readiness** only. It does not improve production readiness directly. System status remains DEVELOPING.

### 11.1 What This Package Changes

| Item | Before | After |
|---|---|---|
| Shadow policy candidates defined | NONE | 10 candidates registered with full SPC fields |
| Policy evaluation criteria | NONE | Acceptance, rejection, and upgrade criteria defined |
| Evidence thresholds | Informally referenced | Formally defined per SPC |
| Shadow evaluation output format | NONE | 15-field output format defined |
| SPC prioritization | NONE | 10-candidate priority ranking with rationale |

### 11.2 What Remains Before Production Candidate

Production candidate requires all of the following (none are close):

| Criterion | Current State | Required State |
|---|---|---|
| Phase 3 certifications complete | 7/17 strategies | All 17/17 strategies (10 uncertified) |
| IRREW Phase 4 live | BLOCKED on all sub-tasks | Phase 4A + 4B + 4C implemented and runtime-validated |
| 200+ trades under IRREW | 0 (IRREW not live) | 200+ post-IRREW closed trades |
| Stable WR ≥ 42% for 60 days | Not measured | 60-day sustained WR ≥ 42% under IRREW |
| VCR characterized or formally parked | Absent | At least 5 COMPRESSION zone sessions OR explicit operator "park VCR" decision |
| Event order limitation addressed | Stage 18.5 structural | Either: V1D pre-decision instrumentation, or explicit operator "V1C is the permanent design" declaration |
| Safety hardening | Basic | Rollback criteria per each Phase 4 change; starvation monitors live |
| Controlled pilot criteria defined | NONE | Operator-defined capital limit, drawdown limit, max-lot constraint, and explicit go/no-go criteria |

No phase completion or SPC evaluation changes DEVELOPING status. Production readiness is a governance decision, not an algorithmic one.

---

## 12. Completion Checklist

| Item | Status |
|---|---|
| PROJECT_INTELLIGENCE_MEMORY_LAYER.md reviewed | DONE — PIML sections 0, CURRENT_STATE_ANCHOR, packages 1–3, and rehabilitation plan reviewed |
| PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md reviewed | DONE — sections 1–6, packet taxonomy, all 3 playbook states, master strategy table reviewed |
| ARCHITECTURE_BUILD_PACKAGE_V1.md reviewed | DONE — sections 1–4, 5 work packages, Event Order Contract, ledger alignment spec reviewed |
| IMPLEMENTATION_SPEC_PACKAGE_V1.md reviewed | DONE — governance firewall, 5 Codex candidates, dependency chain reviewed |
| PLAYBOOK_ARCHITECTURE_FULL_IMPLEMENTATION_PACKAGE_V1_REPORT.md reviewed | DONE — V1C schema fields, implementation details, known limitations, compile result reviewed |
| V1C_CLEANUP_PACKAGE_V1_REPORT.md reviewed | DONE — K1/K2/K3 fixes, compile result, expected post-cleanup behavior reviewed |
| PCEA_V1C_RUNTIME_EVIDENCE_REVIEW_PACKAGE_V1 findings used | DONE — 28-record evidence baseline, phase blocker status, caveat materialization reviewed |
| 10 shadow policy candidates defined with full SPC fields | DONE |
| Candidate prioritization defined with rationale | DONE |
| Sample requirements defined per candidate | DONE |
| Shadow evaluation output format defined | DONE |
| Acceptance, rejection, and upgrade criteria defined | DONE |
| Governance firewall stated | DONE |
| Blocked items listed | DONE |
| Next large package recommended | DONE |
| Production-readiness impact stated | DONE |
| No source files modified | CONFIRMED |
| No runtime .json/.jsonl files modified | CONFIRMED |
| No PIML update | CONFIRMED |
| No compile | CONFIRMED |
| No reload | CONFIRMED |
| No approval requested | CONFIRMED |

---

## Footer

```
PACKAGE_ID:                    SHADOW_POLICY_CANDIDATE_DESIGN_PACKAGE_V1
DATE:                          2026-05-09
SOURCE_CHANGED:                NO
COMPILE_RUN:                   NO
STRATEGY_TESTER_USED:          NO
LIVE_TRADING:                  NO
MT5_AUTHORITY_TRANSFERRED:     NO
NAUTILUS_EXECUTION_AUTHORITY:  NO
PRODUCTION_READY_CLAIMED:      NO
RUNTIME_FILES_MODIFIED:        NO
PIML_UPDATED:                  NO

CANDIDATES_REGISTERED:         10 (SPC-001 through SPC-010)
ALL_CANDIDATES_STATUS:         BLOCKED_FOR_EVALUATION or POST_CLEANUP_MONITORING
EARLIEST_ACTIONABLE_SPC:       SPC-006 (3 post-cleanup bollinger_reclaim records needed)
LOWEST_SAMPLE_SPC:             SPC-006 (3 records), SPC-005 (5 records), SPC-007 (5 zone bars)
HIGHEST_VALUE_SPC:             SPC-009 (CONTRADICTED-state outcome; 20 CONTRADICTED records needed)
HIGHEST_RISK_IF_IMPLEMENTED:   SPC-001 (TPC missing confirmation gate = 98.6% TC starvation)

NEXT_PACKAGE:                  POST_CLEANUP_RUNTIME_VALIDATION_AND_ACCUMULATION_PACKAGE_V1
NEXT_PACKAGE_TRIGGER:          EA reload after market open; cleanup binary already compiled
SYSTEM_STATUS:                 DEVELOPING — unchanged
```
