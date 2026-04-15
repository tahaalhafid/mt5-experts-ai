# External Dashboard Data Contract v1

## Contract intent

This contract describes read-only dashboard outputs and availability signaling rules.

The dashboard is descriptive only and does not represent execution authority.

## Availability semantics

- `UNAVAILABLE`: source missing, unreadable, or field absent.
- Derived values are explicitly built from bounded upstream fields.
- No field is fabricated when upstream data is absent.

## Output families

### 1) Overview

`/api/overview`

- `cards[]`
  - `title`
  - `value`
  - `badge`
  - `sub`
- `event`
  - `type`
  - `time`
  - `decision_id`
  - `note`
  - `reason`

### 2) Runtime context

`/api/context`

- `runtime`: diagnostic runtime summary fields
- `decision_envelope`: latest envelope fields
- `shadow_context`: ATAS shadow context payload fields
- `shadow_status`: MT5 shadow-status surface fields
- `advisory`: governed advisory state fields

### 3) Trades

`/api/trades?limit=<n>`

- `rows[]` (bounded merged row model)
  - identity: `trade_lineage_key`, `decision_id`, `position_id`, `close_deal_id`
  - context: `symbol`, `direction`, `entry_time`, `exit_time`, strategy/regime/structure/SR/advisory fields
  - envelope: base/final confidence, policy risk, regime fit, learning deltas, acceptance posture
  - attribution/outcome: primary/secondary attribution, result, profit

### 4) Rejections/non-entry

`/api/rejections?limit=<n>`

- `rows[]`
  - `ts`, `decision_id`, `symbol`, `strategy_id`, `direction`
  - `outcome`, `regime_label`, `zone_semantic`, `reason`

### 5) Forensics/evidence surfaces

`/api/forensics`

- `surfaces[]`
  - `name`
  - `state`
  - `reason`
  - `path`
  - `updated`

### 6) Levels comparative

`/api/levels`

- `final_layer`
  - `supports[]`, `resistances[]` with `price`, `source`, `note`, `confluence`
  - `state`, `reason`
- `atas_layer`
  - `supports[]`, `resistances[]` with `price`, `source`, `note`, `confluence`
  - `state`, `reason`
- `tolerance`

### 7) Search/inspect

`/api/inspect?q=<token>`

- `query`
- `matches[]`
  - `surface`
  - `decision_id`
  - `position_id`
  - `ts`
  - `summary`
  - `row` (raw source row)

## Read-only safety contract

- No API endpoint writes to MT5 runtime files.
- No API endpoint exposes execution/risk/governor controls.
- No endpoint modifies authority state or advisory gating.
