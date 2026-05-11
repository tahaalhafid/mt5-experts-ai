# AGENTS.md

## Project Identity

This workspace is not a simple MT5 Expert Advisor.

It is a governed MT5 trading system with:
- one primary MT5 runtime entrypoint
- many modular MQL5 source modules
- runtime-emitted status surfaces
- execution authority and governance layers
- dashboard visibility layers
- AI review / advisory layers
- evidence, journal, and support artifacts
- historical lineage and pilot/evidence surfaces
- factory/repository support structure

You must analyze and modify this workspace as a whole governed system, not as isolated files.

You must think in terms of:
- runtime truth
- execution authority
- plan/configuration truth
- historical lineage/evidence
- derived/visibility surfaces
- support/runtime artifacts
- operational coherence

Do not collapse these categories into one another.

---

## Core Operating Principle

Truth first.
Authority first.
Runtime meaning first.
Governance boundaries first.
Smallest correct patch first.

Do not optimize for cosmetic change.
Do not optimize for refactor size.
Do not optimize for “cleaner-looking” architecture at the expense of actual system meaning.

The goal is to preserve and improve a live governed trading system without introducing semantic drift.

---

## Permanent Governance Locks

### Rule 1) Mandatory AGENTS pre-read
Before executing any task, Codex must:
- locate and read this workspace `AGENTS.md`
- treat `AGENTS.md` as mandatory governance for the active workspace
- apply these rules before any backup, edit, verification, archive, or runtime interaction

### Rule 2) Live-locked runtime journal exclusion
While MT5 is running, treat this file as a known live-locked append-only runtime journal:
- `MQL5/Files/AI/ai_performance_journal.jsonl`

During live operation, Codex must NOT:
- open it for read unless strictly necessary
- retry it repeatedly
- copy it
- zip it
- archive it
- modify it
- block a task because of it

If backup/archive is required during live operation:
- explicitly exclude `MQL5/Files/AI/ai_performance_journal.jsonl`
- continue without retry loops
- record in the related manifest/review note that it was skipped because it was live-locked

If this file is needed later:
- capture it only in a cold snapshot after MT5 is stopped

---

## Mandatory Workflow Before Any Edit

### 1) Understand before editing
Before changing anything, you must first understand:

- the current workspace structure
- the source-code plane
- the runtime/support artifact plane
- the difference between:
  - execution authority
  - runtime authoritative status
  - plan/configuration surfaces
  - historical lineage/pilot/evidence surfaces
  - dashboard/visibility surfaces
  - support/journal/runtime artifact surfaces

If these distinctions are unclear, stop and state the ambiguity explicitly before editing.

### 2) Backup is mandatory
Before modifying any file, you MUST create a full backup of the current system state.

Required behavior:
- create a timestamped backup archive in the external governed backup root before any edit
- do not overwrite old backups
- the backup must cover all files relevant to the requested scope
- backup destination must be external to the MQL5/terminal project tree (see Section 2.1)
- if backup creation fails, STOP and do not modify anything

Governed external backup root (forward policy):
`D:\MT5_Project_Backups\`

Naming convention (unchanged):
`D:\MT5_Project_Backups\pre_change_<YYYYMMDD_HHMMSS>_<short_scope>.zip`

If a backup script exists, use it.
If no backup script exists yet, create the backup carefully and explicitly before any modification.

No edit is allowed before backup exists.

**PIML Backup Exception**
`PROJECT_INTELLIGENCE_MEMORY_LAYER.md` and its linked archival `.txt` files (in `plans/archive/`) are governed internal memory artifacts — not runtime files, not source authority files, not execution logic. Editing these files does not require creating a backup before edit. This exception is narrow: it applies only to these memory/archive files and must not be generalised to any other project file. All other backup duties remain fully in force.

### 2.1) Explicit governed backup scope
Every pre-change backup must explicitly include the two governed roots below:

- `MQL5/Experts/AI`
- `MQL5/Files/AI`

Backup destination rule:
- backup output must be written to the external governed root: `D:\MT5_Project_Backups\`
- do not write backup zips inside `MQL5/Experts/AI`, `MQL5/Files/AI`, or anywhere inside the terminal installation tree
- in-tree backup creation (e.g., `terminal-root/backup_archives/`) is no longer the governed default

Historical backup note:
- archives already created under `backup_archives/` inside the terminal tree remain valid for rollback purposes
- they are grandfathered as past artifacts and do not need to be moved
- the external-path policy applies to all future backup-requiring missions only

Recursive-archive exclusion rule:
- existing `.zip` backup artifacts inside source trees must not be re-archived
- legacy backup folders inside source scope must not be recursively compressed into new backups
- avoid cumulative compression of prior backup artifacts

Adapter location note:
- external adapter path is `MQL5/Files/AI/external_adapter/atas_semantic_adapter/`
- this adapter path is included in governed backup scope because it is inside `MQL5/Files/AI`
- this does NOT make the adapter part of MT5 runtime authority
- MT5 remains consumer-only for external shadow packet artifacts
- adapter remains external utility logic

### 3) Scope lock
Change only what is explicitly required.

Do not:
- broaden scope
- redesign unrelated areas
- opportunistically refactor
- “clean up” unrelated files
- alter adjacent systems unless the requested fix logically requires it

Always prefer the smallest correct patch that solves the real problem.

---

## Truth and Authority Discipline

You must classify system surfaces mentally and explicitly.

Every important file or surface should be understood as one of the following:

- EXECUTION_AUTHORITY
- RUNTIME_AUTHORITATIVE_STATUS
- PLAN_OR_CONFIGURATION_AUTHORITY
- HISTORICAL_LINEAGE_OR_EVIDENCE
- DERIVED_OR_VISIBILITY_ONLY
- JOURNAL_OR_SUPPORT_ARTIFACT

Do not mix these classes.

### Critical interpretation rules

#### 1) Plan files are not automatically execution authority
A plan/configuration file such as `ai_current_plan.*` may describe:
- active plan shell
- runtime configuration truth
- compatibility shell
- compiled plan inputs

But it is NOT automatically the final execution authority unless proven by runtime logic.

#### 2) Runtime authority must be proven from current runtime surfaces
Current execution authority may instead be expressed by runtime-emitted surfaces such as:
- `runtime_governance_status.*`
- `execution_authority_status.*`
- `active_operating_cohort.*`

Do not demote these by assumption.

#### 3) Historical package/pilot surfaces are not automatically live runtime truth
Package, transfer, pilot, archive, or evidence-design surfaces may be:
- historical lineage
- migration truth
- evidence posture
- pilot design
- governance history

They are NOT automatically current execution authority.

#### 4) Dashboard surfaces are usually derived/visibility surfaces
Dashboard cards, projections, summaries, or snapshots are typically:
- derived
- visibility-only
- operator-facing summaries

Do not treat dashboard output as canonical execution truth unless explicitly proven.

#### 5) AI review does not imply AI authority
AI readiness, review, advisory, interpretability, or shadow surfaces do NOT imply:
- execution authority
- trade generation authority
- runtime mutation authority
- auto-apply authority

Never infer AI authority from AI presence.

#### 6) Export blocking does not automatically mean internal runtime blocking
A blocked export/release posture may coexist with internally active runtime execution.
Do not collapse export posture into runtime posture unless the code and surfaces prove they are the same.

---

## Authority Boundary Preservation

You must not weaken, override, or silently reinterpret any of the following without explicit instruction:

- execution authority boundaries
- governance boundaries
- active operating cohort boundaries
- cohort admission semantics
- runtime freeze lineage meaning
- risk envelope and guardrail semantics
- AI authority limits
- export/release blocking semantics
- dashboard read-only discipline

No silent authority escalation is allowed.

No hidden execution broadening is allowed.

No silent conversion of historical lineage into current authority is allowed.

No silent conversion of evidence surfaces into execution surfaces is allowed.

---

## Runtime Behavior Discipline

Do not change runtime trading behavior unless the requested task explicitly requires it.

This includes:
- decision routing
- trade admission
- execution gating
- authority cutover logic
- risk/guardrail enforcement
- plan influence
- AI influence
- dashboard event propagation
- runtime status emission

If you change runtime behavior, you must state it explicitly and precisely.

If you do NOT change runtime behavior, say so explicitly.

No silent behavior drift is allowed.

---

## Source-Code Discipline

When editing MQL5 source:

- think in real compile terms
- preserve declaration order and scope correctness
- avoid speculative syntax
- avoid fragmentary edits that break compile
- preserve functional ownership boundaries where possible
- prefer local targeted fixes over broad rewrites

Do not introduce:
- broken string literals
- malformed declarations
- dangling identifiers
- guessed function names
- guessed globals
- guessed builder functions
- guessed field mappings

If compile risk is high, say so explicitly.

If a change is source-level only and not compile-verified, say so explicitly.

---

## Runtime/Support Artifact Discipline

The runtime/support folder contains many file types with different authority levels.

These may include:
- current runtime-emitted truth
- plan/configuration artifacts
- journal artifacts
- evidence summaries
- historical lineage/pilot artifacts
- dashboard-facing summaries
- support or repository manifests

Do not casually rewrite files in this artifact plane.

Before modifying any runtime/support artifact, determine:

1. Is this file authoritative runtime truth?
2. Is this file derived/visibility only?
3. Is this file historical lineage/evidence only?
4. Is this file support/journal only?
5. Will modifying it change runtime meaning, or only displayed meaning?

If you cannot answer that, stop and state the ambiguity.

### Special caution
Do not:
- rewrite journals cosmetically
- normalize evidence files casually
- rewrite dashboard support surfaces as if they were source-of-truth
- mutate historical lineage files to “fix” a current runtime problem
- change support artifacts when the real issue is in a source writer

Always prefer fixing the writer/owner when the problem is source-side.

---

## Dashboard Discipline

The dashboard is read-only operational/governance visibility unless explicitly requested otherwise.

Do not transform the dashboard into:
- a control layer
- a mutation surface
- an operator-intent console
- an authority layer
- a debug wall

Allowed dashboard work is usually limited to:
- visibility correction
- display separation
- state propagation
- bounded event display
- bounded integrity/freshness display
- layout improvement
- clarity of runtime vs export vs lineage meanings

Do not add:
- operator commands
- mutation controls
- silent write-backs
- authority-like controls
- implicit runtime actions from UI

---

## Historical Lineage vs Current Runtime Truth

You must preserve the separation between:

### Historical / lineage / evidence surfaces
Examples may include:
- package transfer status files
- pilot evidence design files
- archive/reference files
- historical governance outputs

### Current runtime truth
Examples may include:
- runtime governance status
- execution authority status
- active operating cohort status
- current risk envelope status
- current meaningful runtime event
- current operational integrity

Do not allow historical surfaces to masquerade as current execution authority.

Do not treat historical pilot surfaces as live runtime authority unless explicitly proven.

---

## AI Boundary Discipline

AI must remain bounded exactly as currently defined unless explicitly instructed otherwise.

Presence of:
- AI review
- AI readiness
- AI interpretation
- AI advisory outputs
- AI operational notes
does NOT mean:
- AI is enabled for execution
- AI can generate trades
- AI can veto execution unless explicitly defined
- AI can mutate runtime
- AI can auto-apply learning

Do not create or imply any AI authority escalation.

If AI review is present while AI authority is OFF or NOT_READY, preserve that distinction clearly.

---

## Regime Authority Discipline

This system operates with three primary computation chains and a derivative consumer network. All three chains are intentional and architecturally valid. Their roles are canonically declared here.

### Three Primary Computation Chains

1. **MarketRegimeSnapshot** (`market_regime.mqh` `BuildMarketRegimeSnapshot()`) — 4-axis intermediate descriptor (TREND_BULL/TREND_BEAR/RANGE | HIGH_VOL/NORMAL_VOL/LOW_VOL | TIGHT/NORMAL/WIDE_SPREAD | CLEAN/NOISY). This is an upstream input to `ClassifyCouncilZone()`, NOT equivalent to gRegime. Its summary string never contains "COMPRESSION" or any gRegime 8-label value. Shared indicator inputs (EMA20/50, ATR14 on M1/M5) with gRegime are a deliberate design choice, not contamination.

2. **RegimeClassificationV1 / gRegime** (`regime_classification_layer_v1.mqh` `BuildRegimeClassificationV1()`) — 8-label complex classifier. COMPRESSION detected via `ATR14_M1/ATR100_M1 ≤ 0.72`. Admission Authority (see ERA below).

3. **Council Zone** (`council_environment.mqh` `ClassifyCouncilZone()`) — 7-label routing classifier. Takes `MarketRegimeSnapshot &reg` as input, NOT gRegime. COMPRESSION detected via `!continuation_bias && !reversal_bias && momentum_score < 0.45 && volatility_score < 0.55`. Routing/Execution Authority (see ExRA below).

**Label vocabulary overlap is not identity.** Both gRegime and council zone use "COMPRESSION" but compute it via different indicator chains and different temporal windows. `gRegime=COMPRESSION` and `council_zone=COMPRESSION` are not the same fact. Disagreement between gRegime and council zone is a measurement question arising from their different detection logic, NOT a signal that one invalidates the other.

### External Regime Authority (ERA) = gRegime (REGIME_CLASSIFICATION_V1)

`gRegime` is the sole authority for all external admission and structural governance decisions:

- Trade admission gates (allowed_regimes CSV, confidence/tradability floors) — `main_ea.mq5:10541`
- CouncilDirtyEnvironmentGate (gRegime="COMPRESSION" post-routing block) — `main_ea.mq5:9633`
- AI scope key indexing (`"COUNCIL|" + direction + "|" + gRegime.regime_label`) — `main_ea.mq5:7568`
- Failure classification (`failure_taxonomy.mqh` — `ClassifyDecisionFailureV1`)
- Journal analytics stratification (`journal_analytics.mqh`)

ERA must not be replaced or shadowed by council zone labels in these surfaces.

### Execution Routing Authority (ExRA) = council zone (ClassifyCouncilZone)

The council zone is the sole authority for all execution routing and strategy-layer decisions:

- Strategy eligibility routing (`CouncilAssignStrategyMeta` — ACTIVE/REDUCED/OBSERVE_ONLY/BLOCKED)
- Zone alignment scoring (`CouncilZoneAlignmentScore` — `council_strategies.mqh:435`)
- Pre-AI filter threshold selection (zone-adaptive block in `RunCouncilPreAIFilter`)
- Preferred and blocked style assignment

ExRA must not be replaced or shadowed by gRegime labels in these surfaces.

### Cross-Authority Rules

1. **No cross-reading without reconciliation contract.** A surface that is ERA-owned must not read or substitute council zone labels. A surface that is ExRA-owned must not read or substitute gRegime labels. The six known violations are governed exceptions documented in PLAN-ARCH-DR and OPERATION_GUARDRAILS.md — they are being resolved in stages, not silently tolerated.

2. **New surfaces must declare authority.** Any new surface that reads regime state must declare in its implementation whether it is ERA-governed or ExRA-governed. No undeclared cross-reads are allowed.

3. **Analytics carry both.** Any analytics surface spanning ERA and ExRA decisions must carry both `regime_label` (ERA) and `zone_name` (ExRA) as independent fields. Neither field substitutes for the other.

4. **Vocabulary overlap is not identity.** Both systems use the label "COMPRESSION" but compute it via different indicator chains at different decision layers. `gRegime=COMPRESSION` (REGIME_CLASSIFICATION_V1, ATR14/ATR100 ≤ 0.72) and `council_zone=COMPRESSION` (ClassifyCouncilZone, !continuation_bias && !reversal_bias && momentum_score < 0.45 && volatility_score < 0.55) are not the same fact and must not be conflated.

5. **AI and advisory/learning consumers must key council-mode outputs by council zone.** Any surface that provides AI advisory, advisory scope, or learning motif services in council-mode execution must be keyed by the council zone (ExRA), not by gRegime (ERA). The six confirmed violations include LEARNING_CONTAMINATION in `institutional_learning_layer_v1.mqh:338` where all council-mode motifs are keyed by gRegime — this causes learning contamination across distinct routing situations. P3.1A (AI scope rebind) and P3.1B (motif-key extension) are one AI deconfliction bundle and must be implemented together.

6. **Bridge is measurement-only.** Adding gRegime to DECISION records (P2.B) or adding zone_bucket to learning motifs (P3.1B) are the only permitted bridges between ERA and ExRA. No bridge for governance, control, threshold modification, or veto logic. A bridge that says "route X is invalid if ERA is Y" reproduces the CouncilDirtyEnvironmentGate violation at a higher abstraction level and is forbidden.

7. **gRegime=COMPRESSION does NOT veto council routing.** The CouncilDirtyEnvironmentGate (P4 violation) that blocks execution after council has already routed is a known harmful asymmetry being addressed in Stage P4. Do not reproduce this pattern in any new logic. gRegime=COMPRESSION is admission-layer signal only. It says nothing about whether council routing to TREND_CONTINUATION or any other zone was correct.

8. **P2.A is FULLY_CLOSED (2026-04-22).** The double-comma serialization defect was repaired by correcting three provenance helper functions in `performance_journal.mqh` (lines 160–185). Current TRADE records (post 2026-04-22 19:55 binary timestamp) parse cleanly under strict json.loads(). Historical TRADE records written before 2026-04-22 19:55 may still contain double commas before the provenance block — consumers replaying pre-fix journal history must apply substring/regex extraction for those records only. Do not apply double-comma workarounds to current runtime records.

---

## Freshness and Coherence Discipline

Where freshness or coherence surfaces exist, treat them seriously.

If a critical surface is:
- stale
- missing
- partially stale
- out of sync with newer runtime truth

do not “fix” the problem by merely changing display output.

First determine:
- is the writer not running?
- is the timestamp field wrong?
- is the path mismatched?
- is the surface historical while being displayed as current?
- is the dashboard reading the wrong artifact?

Fix the real owner/path/propagation problem, not the symptom, unless the task explicitly calls for visibility-only clarification.

---

## Change Reporting Discipline

After every modification, report exactly:

- files modified
- files created
- files intentionally not modified
- backup path created before changes
- what changed functionally
- what did NOT change
- whether runtime behavior changed
- whether authority semantics changed
- whether governance semantics changed
- whether dashboard behavior changed
- whether only visibility changed
- whether compile was actually verified or not

Do not give vague summaries.
Do not hide scope.
Do not imply broader success than what was actually changed.

---

## Project Intelligence Memory Layer (PIML)

The file `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` is the governed execution/intelligence memory for this project.

### Purpose

It exists to reduce rediscovery cost and improve execution continuity across sessions. It holds the master architecture tree, execution program registry, functional tree, file/function index, and other structured project truth.

### State Anchor Fast-Read Rule

`PROJECT_INTELLIGENCE_MEMORY_LAYER.md` contains a `## CURRENT STATE ANCHOR` block positioned near the top of the file (after Section 0 governance). This is the primary fast-read entry point.

When a mission is primarily about **current status, next step, waiting condition, active plan state, frozen boundaries, or what changed**, read the `CURRENT STATE ANCHOR` block first — not the full file, not Section 7, not Section 2. If the anchor provides sufficient context, stop there.

Only read deeper sections (e.g. Section 7.2 for plan detail, Section 2 for architecture nodes) when the anchor is insufficient for the specific mission.

After any execution that changes project truth at the anchor level, update the `CURRENT STATE ANCHOR` immediately. Anchor-level changes include:
- A compile completes or fails
- An observation window starts or closes
- A plan state changes (e.g. PARTIALLY_EXECUTED → ACTIVE)
- A waiting gate resolves or a new one appears
- A deferred branch moves
- A major milestone completes
- The immediate next step changes

### Lightweight Selective-Read Rule

Do NOT read the whole file on every task. Use a selective read:

- For status / next-step questions: read the `CURRENT STATE ANCHOR` block only
- For plan detail: read the relevant Section 7.2 entry only
- For architecture context: read the specific node(s) in Section 2 only
- If the mission clearly does not need the file: skip the read entirely
- Full-file reads are justified only for deep architecture discovery or file-level population missions

### Automatic Update Rule

After every execution mission, ask:

> Did this mission change any project truth that belongs in the memory file?

If YES — update only the directly impacted section(s) immediately.
If NO — no update required.

Examples of truth changes that require a PIML update:
- A source file was created or deleted
- A subsystem was materially evolved (architecture node truth changed)
- A plan stage completed or plan status changed
- A plan was split, merged, deferred, or cancelled
- A new dependency or consumer relationship became real
- A completed slice changed the active plan truth

### Update Scope Rule

Update only the directly impacted section(s). Do not sweep the whole file after every mission. Do not redesign the file structure — update only the data inside the existing structure.

### Monitoring Output Convention

After every execution mission, include at the end of the report:

```
PIML_READ: YES / NO
PIML_UPDATE: YES / NO
PIML_SECTIONS: <brief section refs — only if update was YES>
```

Keep monitoring lines brief. This is short confirmation only, not a verbose memory log.

---

## Preferred Working Method

Use this order:

1. Read the workspace as a system
2. Identify truth and authority hierarchy
3. Identify the actual owner/writer of the relevant surfaces
4. Create backup
5. Apply the smallest correct patch
6. Re-check semantic consistency
7. Re-check compile risk
8. Report exact impact

---

## Forbidden Behaviors

You must not:

- edit without backup
- refactor broadly without request
- change authority semantics by inference
- broaden execution silently
- broaden cohort silently
- treat dashboard output as canonical truth by convenience
- rewrite runtime/support artifacts casually
- convert evidence surfaces into authority surfaces
- convert historical lineage into current truth
- use AI review as proof of AI authority
- weaken export/release blocking semantics by display trickery
- weaken runtime guardrails silently
- make speculative MQL changes without compile-aware discipline
- hide material risk or ambiguity

If something is uncertain, say it is uncertain.

If something is an inference, label it as inference.

If something is directly evidenced by code or artifacts, label it as evidenced.

---

## Final Rule

This system must be treated as a governed live trading system with layered truth, layered authority, and mixed runtime/support artifacts.

Your job is not merely to edit files.

Your job is to preserve:
- truth
- authority
- governance
- operational coherence
- semantic clarity
- smallest-correct-change discipline
