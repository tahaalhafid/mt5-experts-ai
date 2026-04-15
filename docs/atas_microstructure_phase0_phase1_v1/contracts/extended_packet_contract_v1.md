# Extended Packet Contract v1

## Artifact
- Family: `context_packet_extended`
- Schema file: `schemas/context_packet_extended_v1.schema.json`
- Version: `ATAS_CONTEXT_PACKET_EXTENDED_V1`

## Purpose
Carry optional interpretive and research-grade context that is not required for runtime attachment and not binding for authority.

## Authority Class
- `EXTERNAL_NON_AUTHORITATIVE_EXTENDED_INTERPRETIVE_PACKET`

## Design Rules
- Extended packet is optional by contract.
- Extended packet is non-binding for runtime authority.
- Extended packet may be absent without affecting core-packet validity.
- Extended interpretive confidence is capped (`<= 0.49`).

## Allowed Content
- Interpretive hints.
- Optional motif/context tags.
- Explanation-focused context summaries.
- Additional diagnostics for research and model-development pathways.

## Forbidden Content
- Final decision package ownership.
- Final regime ownership.
- Final canonical level ownership.
- Final tradability ownership.
- Execution/risk/governor commands.

## Consumption Rule
- MT5 must not rely on extended packet for hard runtime authority semantics in Phase 0/1.
