# Core Packet Contract v1

## Artifact
- Family: `context_packet_core`
- Schema file: `schemas/context_packet_core_v1.schema.json`
- Version: `ATAS_CONTEXT_PACKET_CORE_V1`

## Purpose
Provide a bounded, non-authoritative microstructure context packet with strict freshness and provenance fields.

## Authority Class
- `EXTERNAL_NON_AUTHORITATIVE_CONTEXT_PACKET`
- Mandatory notice: MT5 remains final runtime authority.

## Required Sections
- `identity_lineage`
- `source_binding`
- `time_freshness`
- `quality_confidence`
- `microstructure_observation`
- `cross_instrument_basis_evidence`
- `governance_flags`

## Contract Rules
- Core packet must be minimal and deterministic.
- Core packet may contain basis-evidence fields but not final decision/regime/tradability ownership fields.
- Core packet is the only future candidate for bounded MT5 consumption gating work.
- Core packet must never contain risk/governor/execution command semantics.

## Forbidden Fields in Core Packet
- Final regime verdict ownership fields.
- Final canonical level ownership fields.
- Final tradability verdict ownership fields.
- Decision package or execution command fields.
- Risk/governor override fields.

## Freshness/Provenance Mandate
- Freshness must be evaluable using UTC-normalized timestamps.
- Lineage fields are mandatory for all core packets.
