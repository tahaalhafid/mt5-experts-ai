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
- create or use terminal-root folder `backup_archives/`
- create a timestamped backup archive before any edit
- do not overwrite old backups
- the backup must cover all files relevant to the requested scope
- backup destination must remain outside source scope
- if backup creation fails, STOP and do not modify anything

Preferred naming:
`backup_archives/pre_change_<YYYYMMDD_HHMMSS>_<short_scope>.zip`

If a backup script exists, use it.
If no backup script exists yet, create the backup carefully and explicitly before any modification.

No edit is allowed before backup exists.

### 2.1) Explicit governed backup scope
Every pre-change backup must explicitly include the two governed roots below:

- `MQL5/Experts/AI`
- `MQL5/Files/AI`

Backup destination rule:
- backup output must be written to terminal-root `backup_archives/`
- do not write backup zips inside `MQL5/Experts/AI` or `MQL5/Files/AI`

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
