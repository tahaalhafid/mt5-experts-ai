# PLAN-6 STAGE 0 BASELINE
## [DEPRECATED 2026-04-20 — Content migrated to PROJECT_INTELLIGENCE_MEMORY_LAYER.md, Section 7.2, PLAN-6 entry, Stage 0 block. This file is NON_AUTHORITATIVE. Do not update or reference.]
## Council Signal Supply + NO_TRADE Truth — Measurement Anchor
### Locked: 2026-04-20 | Source: 2,126 XAUUSD runtime records

---

## Governing Principle

Truth first → activation second → diversity third → productivity fourth → re-measure last

---

## 1. Effective Council Width

| Measure | Value |
|---------|-------|
| Nominal strategy count | 17 |
| Zone-dormant (COMPRESSION / EXPANSION — unreachable zone paths) | 8 |
| Zero lifetime XAUUSD votes | 6 |
| Effective live participation set | 3–4 strategies |
| Dominant strategy (sweep_reversal share) | 81.5% of all votes |

**Root cause:** 8 strategies are zone-locked to `COUNCIL_ZONE_COMPRESSION` / `COUNCIL_ZONE_EXPANSION` — zone types not produced by the current classifier. These strategies can never vote in live operation regardless of market conditions.

---

## 2. NO_TRADE Rate Baseline

| Measure | Value |
|---------|-------|
| Total records analyzed | 2,126 XAUUSD |
| NO_TRADE records | 872 (41.0%) |
| Average env_score on NO_TRADE bars | 0.764 |
| Primary driver | `momentum_ok = body/range >= 0.35` (single M1 candle) |

**Key finding:** 41% NO_TRADE rate is driven primarily by a single-bar M1 candle quality check, not by genuinely bad market conditions. Average env_score of 0.764 on NO_TRADE bars confirms the market environment is structurally sound when NO_TRADE fires — the signal is a local candle artefact masquerading as a market-wide untradability verdict.

---

## 3. Zone-Specific Signal Suppression

| Zone | Zero-vote rate |
|------|----------------|
| RANGE_MEAN_RECLAIM | 87.1% |
| TREND_CONTINUATION | 52% rejection rate |
| Dominant active zone | RANGE_MEAN_RECLAIM (most visited) |

**Root cause for RANGE:** `sweep_reversal` (liquidity-reversal family) is the only materially participating strategy in RANGE zones. Mean-reclaim strategies that would naturally cover RANGE have near-zero activation.

---

## 4. Fallback Zone Behavior

When `r.tradable = true` but no specific zone matches AND `reg.summary` does not contain "RANGE": fallback routes to `COUNCIL_ZONE_NO_TRADE` with `zone_confidence = 0.45`. This is a truthfulness defect: a tradable market with unclassified regime is not the same as an untradable market.

---

## 5. What This Baseline Anchors

Stage 1 target: repair the `momentum_ok` hard gate and the tradable-but-unclassified fallback NO_TRADE path.

Stages 2–7 targets (not yet authorized): strategy zone coverage repair, family diversity repair, zero-vote strategy investigation, signal supply recovery, re-measure.

---

## 6. What Does NOT Change at Stage 1

- Genuinely bad spread / liquidity / volatility → still hard NO_TRADE
- Strategy logic, governor behavior, pre-filter thresholds → frozen
- Council architecture, zone enum count → unchanged
- Authority model → unchanged
