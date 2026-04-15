# Advisory Attachment and External Context Reliability Contract v1

## Scope
Bounded reliability diagnostics only for governed ATAS advisory attachment/eligibility/usability.

This contract does not:
- force advisory influence
- bypass advisory gates
- grant external authority
- alter MT5 execution/risk/governor authority

## Reliability Dimensions
The advisory path is now diagnosed across:
- payload presence
- shadow attachment
- source quality
- freshness
- session validity
- symbol mapping validity
- translation/semantic-only state
- structural relevance
- level-context relevance

## Strengthened Advisory Status Fields
Status/packet/decision/trade evidence now preserve:
- `advisory_available`
- `advisory_eligible`
- `advisory_shadow_attached`
- `advisory_state`
- `advisory_outcome`
- `advisory_attachment_state`
- `advisory_gate_reason_code`
- `advisory_ineligibility_reason_code`
- `advisory_block_class`
- `advisory_usage_state`
- `advisory_zero_effect_reason`

## Attachment State Classes
- `ADVISORY_ABSENT`
- `ADVISORY_PRESENT_NOT_ATTACHED`
- `ADVISORY_ATTACHED_SOURCE_QUALITY_BLOCKED`
- `ADVISORY_ATTACHED_FRESHNESS_BLOCKED`
- `ADVISORY_ATTACHED_SESSION_BLOCKED`
- `ADVISORY_ATTACHED_MAPPING_BLOCKED`
- `ADVISORY_ATTACHED_TRANSLATION_BLOCKED`
- `ADVISORY_ATTACHED_INELIGIBLE`
- `ADVISORY_ATTACHED_ELIGIBLE`

## Usage State Classes
- `ADVISORY_ABSENT`
- `ADVISORY_PRESENT_NOT_ATTACHED`
- `ADVISORY_BLOCKED`
- `ADVISORY_DISPLAY_ONLY`
- `ADVISORY_USED_SOFT_SIGNAL`
- `ADVISORY_USED_HOLD_SIGNAL`
- `ADVISORY_ELIGIBLE_ZERO_EFFECT`
- `ADVISORY_ELIGIBLE_NO_ACTION`

## Block Class Mapping
`advisory_block_class` is derived from reason code and currently emits:
- `ATTACHMENT_BLOCKED`
- `FRESHNESS_BLOCKED`
- `MAPPING_BLOCKED`
- `SESSION_BLOCKED`
- `TRANSLATION_BLOCKED`
- `SOURCE_QUALITY_BLOCKED`
- `LEVEL_CONTEXT_BLOCKED`
- `RELEVANCE_BLOCKED`
- `STRUCTURAL_BLOCKED`
- `OTHER_BLOCKED`
- `NONE`

## Reason-Code Examples
Existing/strengthened reason codes include:
- `atas_shadow_payload_unavailable`
- `atas_shadow_not_attached`
- `atas_shadow_quality_insufficient`
- `atas_shadow_freshness_invalid`
- `session_not_eligible`
- `symbol_mapping_invalid`
- `semantic_only_fallback_disallowed`
- `level_context_insufficient`
- `insufficient_relevance_or_confluence`
- `hold_budget_exhausted_display_only`

## Governance Lock
All advisory diagnostics are descriptive and non-authoritative.
No direct trade send/cancel/size/risk/governor control is granted by these fields.

