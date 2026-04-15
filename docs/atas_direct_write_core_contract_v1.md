# ATAS Direct Write Core Contract v1

## Scope
Bounded external ATAS microstructure advisory packet for MT5 thin intake only.

- Active path: `ATAS C# writer -> MQL5/Files/AI/atas_microstructure_context.json -> MT5 thin intake`
- Authority class: non-authoritative external advisory context
- MT5 remains sole owner of runtime/decision/risk/governor/execution/final market meaning

## Fixed File
`MQL5/Files/AI/atas_microstructure_context.json`

## Schema Version
`ATAS_DIRECT_WRITE_CORE_V1`

## Contract Shape
```json
{
  "artifact_role": "ATAS_DIRECT_WRITE_CORE_PACKET",
  "artifact_authority_class": "EXTERNAL_NON_AUTHORITATIVE_MICROSTRUCTURE_ADVISORY",
  "schema_version": "ATAS_DIRECT_WRITE_CORE_V1",
  "envelope": {
    "packet_id": "atas_dw_1770000000000",
    "written_at": "2026-04-12T08:30:00.0000000+00:00",
    "fresh_until": "2026-04-12T08:33:00.0000000+00:00",
    "source_symbol": "GC",
    "execution_symbol": "XAUUSD",
    "source_mode": "LIVE",
    "packet_validity": "VALID"
  },
  "quality": {
    "quality_state": "MEDIUM",
    "confidence_ceiling": 0.65,
    "suppression_active": false,
    "suppression_flags": "NONE",
    "suppression_reason_codes": "NONE"
  },
  "signal_payload": {
    "liquidity_sweep_state": "NO_SWEEP",
    "absorption_state": "ASK_ABSORPTION_BUILDING",
    "delta_bias_state": "POSITIVE",
    "imbalance_state": "BUY_IMBALANCE_PRESENT",
    "liquidity_stability_state": "STABLE",
    "continuation_exhaustion_hint": "LOW"
  },
  "non_authoritative_note": "Bounded ATAS microstructure advisory only. MT5 remains final runtime/decision/risk/execution authority."
}
```

## MT5 Intake Acceptance Rules (Thin)
- Required: `schema_version`, `packet_id`, `written_at`, `fresh_until`, `source_symbol`, `execution_symbol`, `source_mode`, `packet_validity`, `quality_state`, `confidence_ceiling`
- `schema_version` must equal `ATAS_DIRECT_WRITE_CORE_V1`
- `source_mode` must be `LIVE`
- `execution_symbol` must match MT5 runtime execution symbol
- `packet_validity` must be `VALID`
- `suppression_active` must be `false`
- `quality_state` must be `HIGH` or `MEDIUM`
- `confidence_ceiling` must be `>= 0.35`
- Packet must be fresh (`now <= fresh_until` and age within bounded max context age)

## Rejection Behavior
If file is missing/stale/invalid/malformed, MT5 ignores packet and continues base logic unchanged.
