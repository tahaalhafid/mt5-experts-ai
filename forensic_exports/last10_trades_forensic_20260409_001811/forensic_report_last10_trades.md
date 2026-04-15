# Post-Run Forensic Report (Last 10 Entered Trades)

## Scope And Method
- Actual trade entry span captured (UTC): FACT:2026-04-08 16:03:30 -> FACT:2026-04-08 22:40:07
- Selection rule: last 10 `TRADE_OPEN` events with `opened_ok=true`, extended backward beyond 6 hours as needed.
- Data-tag convention: `FACT:` direct extraction, `INFERRED:` deterministic derivation, `UNAVAILABLE` missing in available surfaces.

## Compact Master Table
|#|decision_id|symbol|dir|entry_time_utc|exit_time_utc|outcome|result_money|regime|sr_bucket|advisory_state|
|---|---|---|---|---|---|---|---|---|---|---|
|1|XAUUSD-1775687836-100535-352|FACT:XAUUSD|FACT:SELL|FACT:2026-04-08 22:40:07|FACT:2026-04-08 22:45:55|FACT:WIN|FACT:1.1|FACT:RANGE_DIRTY|FACT:SR_REJECTION_RISK|FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached|
|2|XAUUSD-1775687230-100525-350|FACT:XAUUSD|FACT:SELL|FACT:2026-04-08 22:34:12|FACT:2026-04-08 22:36:29|FACT:LOSS|FACT:-33.5|FACT:TREND_DOWN|FACT:SR_CANONICAL_NEAR|FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached|
|3|XAUUSD-1775687230-100525-350|FACT:XAUUSD|FACT:SELL|FACT:2026-04-08 22:30:30|FACT:2026-04-08 22:31:47|FACT:LOSS|FACT:-31.8|FACT:TREND_DOWN|FACT:SR_CANONICAL_NEAR|FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached|
|4|XAUUSD-1775686536-100513-342|FACT:XAUUSD|FACT:SELL|FACT:2026-04-08 22:16:51|FACT:2026-04-08 22:19:02|FACT:WIN|FACT:60.5|FACT:TREND_DOWN|FACT:SR_CANONICAL_NEAR|FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached|
|5|XAUUSD-1775683413-100461-310|FACT:XAUUSD|FACT:SELL|FACT:2026-04-08 21:24:54|FACT:2026-04-08 21:42:03|FACT:WIN|FACT:102.7|FACT:EXPANSION|FACT:SR_UNKNOWN|FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached|
|6|XAUUSD-1775681784-100434-290|FACT:XAUUSD|FACT:SELL|FACT:2026-04-08 20:57:40|FACT:2026-04-08 21:00:13|FACT:WIN|FACT:49|FACT:TREND_DOWN|FACT:SR_CONTINUATION_OBSTRUCTED|FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached|
|7|XAUUSD-1775678857-100385-256|FACT:XAUUSD|FACT:BUY|FACT:2026-04-08 20:08:48|FACT:2026-04-08 20:12:43|FACT:WIN|FACT:8.6|FACT:RANGE_BALANCED|FACT:SR_CANONICAL_NEAR|FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached|
|8|XAUUSD-1775676870-100352-228|FACT:XAUUSD|FACT:SELL|FACT:2026-04-08 19:35:40|FACT:2026-04-08 19:40:05|FACT:LOSS|FACT:-35.2|FACT:TREND_DOWN|FACT:SR_CANONICAL_NEAR|FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached|
|9|XAUUSD-1775674237-100308-192|FACT:XAUUSD|FACT:SELL|FACT:2026-04-08 18:51:51|FACT:2026-04-08 18:55:15|FACT:WIN|FACT:47.6|FACT:COMPRESSION|FACT:SR_UNKNOWN|FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached|
|10|XAUUSD-1775664074-100139-38|FACT:XAUUSD|FACT:SELL|FACT:2026-04-08 16:03:30|FACT:2026-04-08 16:04:34|FACT:WIN|FACT:51.3|FACT:RANGE_DIRTY|FACT:SR_REJECTION_RISK|FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached|

## Expanded Per-Trade Sections

### Trade #1 — XAUUSD-1775687836-100535-352
- Identity: symbol=FACT:XAUUSD, direction=FACT:SELL, ticket/position=FACT:8117647957, close_deal=FACT:7663218973
- Timing: entry=FACT:2026-04-08 22:40:07, exit=FACT:2026-04-08 22:45:55, holding=INFERRED:348s, session=INFERRED:OFF_HOURS
- Entry context: strategy=FACT:sweep_reversal, family=FACT:LIQUIDITY_REVERSAL, plan_mode=FACT:HYBRID, decision_mode=FACT:COUNCIL
- Regime/environment: regime=FACT:RANGE_DIRTY, regime_conf=FACT:0.58, vol=FACT:HIGH_VOL, structure=FACT:CLEAN, contradiction=FACT:contradiction=False
- Council: profile=FACT:MEAN_RECLAIM, regime_fit=FACT:0.58, summary=FACT:[AI-EA] [INFO] Runtime decision (COUNCIL): [Regime=RANGE_DIRTY conf=0.58 trad=0.58] SELL | Mode=COUNCIL | Final=SELL | Zone=RANGE_MEAN_RECLAIM | ZoneConf=0.82 | PrefStyle=MEAN_RECLAIM | EnvScore=0.80 | CouncilQ=0.86 | Consensus=1.00 | ConsensusLabel=HIGH_CONVICTION | Conflict=0.00 | Dominant=SELL | Best=sweep_reversal | Regime=RANGE|HIGH_VOL|TIGHT_SPREAD|CLEAN | Council pipeline passed | zone=RANGE_MEAN_RECLAIM | pref_style=MEAN_RECLAIM | best_strategy=sweep_reversal | support=sweep_reversal,bollinger_reclaim | consensus=HIGH_CONVICTION | diversity=0.70 | gov_state=EXHAUSTION_SENSITIVE | fail_pressure=NONE | governor=AI Governor: exhaustion-sensitive mode | zone=RANGE_MEAN_RECLAIM | best_strategy=sweep_reversal | quality=0.86 | exhaustion=true
- ATAS/advisory: eligible=FACT:false, strength=FACT:0.438, contradiction=FACT:False, hold_bias=FACT:False, influenced=FACT:false, note=FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached
- Support/resistance: sr_bucket=FACT:SR_REJECTION_RISK, confluence=FACT:context_captured, level_flags=FACT:rejection_risk, interpreted_effect=INFERRED:potentially_hurt
- Lifecycle/execution: entry_price=UNAVAILABLE, fill=UNAVAILABLE, slippage=UNAVAILABLE, SL=UNAVAILABLE, TP=UNAVAILABLE, management=FACT:see_MQL5_log_for_ticket_8117647957, exit_reason=UNAVAILABLE
- Outcome/attribution: outcome=FACT:WIN, result_money=FACT:1.1, result_points=UNAVAILABLE, R=UNAVAILABLE, primary_attr=UNAVAILABLE, secondary_attr=UNAVAILABLE, motif=FACT:strategy=sweep_reversal|direction=SELL|regime=RANGE_DIRTY|vol=HIGH_VOL|struct=CLEAN|setup=SETUP_NEUTRAL|sr=SR_REJECTION_RISK|contradiction=0
- AI/governance posture: ai_authority=UNAVAILABLE, ai_readiness=UNAVAILABLE, ai_bridge=FACT:False, advisory_state=FACT:ATAS_ADVISORY_INELIGIBLE, gate=UNAVAILABLE
- What most affected this trade: FACT:Outcome=WIN profit=1.1 | FACT:Context regime=RANGE_DIRTY vol=HIGH_VOL sr=SR_REJECTION_RISK | FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached

### Trade #2 — XAUUSD-1775687230-100525-350
- Identity: symbol=FACT:XAUUSD, direction=FACT:SELL, ticket/position=FACT:8117550550, close_deal=FACT:7663065838
- Timing: entry=FACT:2026-04-08 22:34:12, exit=FACT:2026-04-08 22:36:29, holding=INFERRED:137s, session=INFERRED:OFF_HOURS
- Entry context: strategy=FACT:sweep_reversal, family=FACT:LIQUIDITY_REVERSAL, plan_mode=FACT:HYBRID, decision_mode=FACT:COUNCIL
- Regime/environment: regime=FACT:TREND_DOWN, regime_conf=FACT:0.85, vol=FACT:HIGH_VOL, structure=FACT:CLEAN, contradiction=FACT:contradiction=False
- Council: profile=FACT:MEAN_RECLAIM, regime_fit=FACT:0.57, summary=FACT:[AI-EA] [INFO] Runtime decision (COUNCIL): [Regime=TREND_DOWN conf=0.85 trad=0.57] SELL | Mode=COUNCIL | Final=SELL | Zone=RANGE_MEAN_RECLAIM | ZoneConf=0.82 | PrefStyle=MEAN_RECLAIM | EnvScore=0.82 | CouncilQ=0.86 | Consensus=1.00 | ConsensusLabel=HIGH_CONVICTION | Conflict=0.00 | Dominant=SELL | Best=sweep_reversal | Regime=RANGE|HIGH_VOL|TIGHT_SPREAD|CLEAN | Council pipeline passed | zone=RANGE_MEAN_RECLAIM | pref_style=MEAN_RECLAIM | best_strategy=sweep_reversal | support=sweep_reversal,bollinger_reclaim | consensus=HIGH_CONVICTION | diversity=0.70 | gov_state=EXHAUSTION_SENSITIVE | fail_pressure=NONE | governor=AI Governor: exhaustion-sensitive mode | zone=RANGE_MEAN_RECLAIM | best_strategy=sweep_reversal | quality=0.86 | exhaustion=true
- ATAS/advisory: eligible=FACT:false, strength=FACT:0.355, contradiction=FACT:False, hold_bias=FACT:False, influenced=FACT:false, note=FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached
- Support/resistance: sr_bucket=FACT:SR_CANONICAL_NEAR, confluence=FACT:context_captured, level_flags=UNAVAILABLE, interpreted_effect=INFERRED:potentially_helpful
- Lifecycle/execution: entry_price=UNAVAILABLE, fill=UNAVAILABLE, slippage=UNAVAILABLE, SL=UNAVAILABLE, TP=UNAVAILABLE, management=FACT:see_MQL5_log_for_ticket_8117550550, exit_reason=UNAVAILABLE
- Outcome/attribution: outcome=FACT:LOSS, result_money=FACT:-33.5, result_points=UNAVAILABLE, R=UNAVAILABLE, primary_attr=UNAVAILABLE, secondary_attr=UNAVAILABLE, motif=FACT:strategy=sweep_reversal|direction=SELL|regime=TREND_DOWN|vol=HIGH_VOL|struct=CLEAN|setup=SETUP_NEUTRAL|sr=SR_CANONICAL_NEAR|contradiction=0
- AI/governance posture: ai_authority=UNAVAILABLE, ai_readiness=UNAVAILABLE, ai_bridge=FACT:False, advisory_state=FACT:ATAS_ADVISORY_INELIGIBLE, gate=UNAVAILABLE
- What most affected this trade: FACT:Outcome=LOSS profit=-33.5 | FACT:Context regime=TREND_DOWN vol=HIGH_VOL sr=SR_CANONICAL_NEAR | FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached

### Trade #3 — XAUUSD-1775687230-100525-350
- Identity: symbol=FACT:XAUUSD, direction=FACT:SELL, ticket/position=FACT:8117489594, close_deal=FACT:7662984954
- Timing: entry=FACT:2026-04-08 22:30:30, exit=FACT:2026-04-08 22:31:47, holding=INFERRED:77s, session=INFERRED:OFF_HOURS
- Entry context: strategy=FACT:trend_momentum, family=FACT:TREND_CONTINUATION, plan_mode=FACT:HYBRID, decision_mode=FACT:COUNCIL
- Regime/environment: regime=FACT:TREND_DOWN, regime_conf=FACT:0.85, vol=FACT:HIGH_VOL, structure=FACT:CLEAN, contradiction=FACT:contradiction=False
- Council: profile=FACT:CONTINUATION, regime_fit=FACT:0.49, summary=FACT:[AI-EA] [INFO] Runtime decision (COUNCIL): [Regime=TREND_DOWN conf=0.85 trad=0.49] SELL | Mode=COUNCIL | Final=SELL | Zone=TREND_CONTINUATION | ZoneConf=0.87 | PrefStyle=CONTINUATION | EnvScore=0.86 | CouncilQ=0.76 | Consensus=1.00 | ConsensusLabel=NARROW | Conflict=0.00 | Dominant=SELL | Best=trend_momentum | Regime=TREND_BEAR|HIGH_VOL|TIGHT_SPREAD|CLEAN | Council pipeline passed | zone=TREND_CONTINUATION | pref_style=CONTINUATION | best_strategy=trend_momentum | support=trend_momentum,momentum_breakout_cont_v1,breakdown_momentum_v1 | consensus=NARROW | diversity=0.35 | gov_state=DEFENSIVE | fail_pressure=NONE | governor=AI Governor: narrow or conflicted consensus, tightened gate and nudged leader | state=DEFENSIVE | best_strategy=trend_momentum | consensus=NARROW | diversity=0.35 | conflict=0.00
- ATAS/advisory: eligible=FACT:false, strength=FACT:0.37, contradiction=FACT:False, hold_bias=FACT:False, influenced=FACT:false, note=FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached
- Support/resistance: sr_bucket=FACT:SR_CANONICAL_NEAR, confluence=FACT:context_captured, level_flags=UNAVAILABLE, interpreted_effect=INFERRED:potentially_helpful
- Lifecycle/execution: entry_price=UNAVAILABLE, fill=UNAVAILABLE, slippage=UNAVAILABLE, SL=UNAVAILABLE, TP=UNAVAILABLE, management=FACT:see_MQL5_log_for_ticket_8117489594, exit_reason=UNAVAILABLE
- Outcome/attribution: outcome=FACT:LOSS, result_money=FACT:-31.8, result_points=UNAVAILABLE, R=UNAVAILABLE, primary_attr=UNAVAILABLE, secondary_attr=UNAVAILABLE, motif=FACT:strategy=trend_momentum|direction=SELL|regime=TREND_DOWN|vol=HIGH_VOL|struct=CLEAN|setup=SETUP_NEUTRAL|sr=SR_CANONICAL_NEAR|contradiction=0
- AI/governance posture: ai_authority=UNAVAILABLE, ai_readiness=UNAVAILABLE, ai_bridge=FACT:False, advisory_state=FACT:ATAS_ADVISORY_INELIGIBLE, gate=UNAVAILABLE
- What most affected this trade: FACT:Outcome=LOSS profit=-31.8 | FACT:Context regime=TREND_DOWN vol=HIGH_VOL sr=SR_CANONICAL_NEAR | FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached

### Trade #4 — XAUUSD-1775686536-100513-342
- Identity: symbol=FACT:XAUUSD, direction=FACT:SELL, ticket/position=FACT:8117294770, close_deal=FACT:7662783422
- Timing: entry=FACT:2026-04-08 22:16:51, exit=FACT:2026-04-08 22:19:02, holding=INFERRED:131s, session=INFERRED:OFF_HOURS
- Entry context: strategy=FACT:sweep_reversal, family=FACT:LIQUIDITY_REVERSAL, plan_mode=FACT:HYBRID, decision_mode=FACT:COUNCIL
- Regime/environment: regime=FACT:TREND_DOWN, regime_conf=FACT:0.85, vol=FACT:HIGH_VOL, structure=FACT:CLEAN, contradiction=FACT:contradiction=False
- Council: profile=FACT:MEAN_RECLAIM, regime_fit=FACT:0.61, summary=FACT:[AI-EA] [INFO] Runtime decision (COUNCIL): [Regime=TREND_DOWN conf=0.85 trad=0.61] SELL | Mode=COUNCIL | Final=SELL | Zone=RANGE_MEAN_RECLAIM | ZoneConf=0.82 | PrefStyle=MEAN_RECLAIM | EnvScore=0.83 | CouncilQ=0.87 | Consensus=1.00 | ConsensusLabel=HIGH_CONVICTION | Conflict=0.00 | Dominant=SELL | Best=sweep_reversal | Regime=RANGE|HIGH_VOL|TIGHT_SPREAD|CLEAN | Council pipeline passed | zone=RANGE_MEAN_RECLAIM | pref_style=MEAN_RECLAIM | best_strategy=sweep_reversal | support=sweep_reversal,bollinger_reclaim | consensus=HIGH_CONVICTION | diversity=0.70 | gov_state=EXHAUSTION_SENSITIVE | fail_pressure=NONE | governor=AI Governor: exhaustion-sensitive mode | zone=RANGE_MEAN_RECLAIM | best_strategy=sweep_reversal | quality=0.87 | exhaustion=true
- ATAS/advisory: eligible=FACT:false, strength=FACT:0.361, contradiction=FACT:False, hold_bias=FACT:False, influenced=FACT:false, note=FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached
- Support/resistance: sr_bucket=FACT:SR_CANONICAL_NEAR, confluence=FACT:context_captured, level_flags=UNAVAILABLE, interpreted_effect=INFERRED:potentially_helpful
- Lifecycle/execution: entry_price=UNAVAILABLE, fill=UNAVAILABLE, slippage=UNAVAILABLE, SL=UNAVAILABLE, TP=UNAVAILABLE, management=FACT:see_MQL5_log_for_ticket_8117294770, exit_reason=UNAVAILABLE
- Outcome/attribution: outcome=FACT:WIN, result_money=FACT:60.5, result_points=UNAVAILABLE, R=UNAVAILABLE, primary_attr=UNAVAILABLE, secondary_attr=UNAVAILABLE, motif=FACT:strategy=sweep_reversal|direction=SELL|regime=TREND_DOWN|vol=HIGH_VOL|struct=CLEAN|setup=SETUP_NEUTRAL|sr=SR_CANONICAL_NEAR|contradiction=0
- AI/governance posture: ai_authority=UNAVAILABLE, ai_readiness=UNAVAILABLE, ai_bridge=FACT:False, advisory_state=FACT:ATAS_ADVISORY_INELIGIBLE, gate=UNAVAILABLE
- What most affected this trade: FACT:Outcome=WIN profit=60.5 | FACT:Context regime=TREND_DOWN vol=HIGH_VOL sr=SR_CANONICAL_NEAR | FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached

### Trade #5 — XAUUSD-1775683413-100461-310
- Identity: symbol=FACT:XAUUSD, direction=FACT:SELL, ticket/position=FACT:8116245706, close_deal=FACT:7661956776
- Timing: entry=FACT:2026-04-08 21:24:54, exit=FACT:2026-04-08 21:42:03, holding=INFERRED:1029s, session=INFERRED:US
- Entry context: strategy=FACT:trend_momentum, family=FACT:TREND_CONTINUATION, plan_mode=FACT:HYBRID, decision_mode=FACT:COUNCIL
- Regime/environment: regime=FACT:EXPANSION, regime_conf=FACT:0.62, vol=FACT:HIGH_VOL, structure=FACT:CLEAN, contradiction=FACT:contradiction=False
- Council: profile=FACT:CONTINUATION, regime_fit=FACT:0.52, summary=FACT:[AI-EA] [INFO] Runtime decision (COUNCIL): [Regime=EXPANSION conf=0.62 trad=0.52] SELL | Mode=COUNCIL | Final=SELL | Zone=TREND_CONTINUATION | ZoneConf=0.88 | PrefStyle=CONTINUATION | EnvScore=0.86 | CouncilQ=0.70 | Consensus=0.81 | ConsensusLabel=NARROW | Conflict=0.23 | Dominant=SELL | Best=trend_momentum | Regime=TREND_BEAR|HIGH_VOL|TIGHT_SPREAD|CLEAN | Council pipeline passed | zone=TREND_CONTINUATION | pref_style=CONTINUATION | best_strategy=trend_momentum | support=bollinger_reclaim,trend_momentum | consensus=NARROW | diversity=0.35 | gov_state=DEFENSIVE | fail_pressure=NONE | governor=AI Governor: narrow or conflicted consensus, tightened gate and nudged leader | state=DEFENSIVE | best_strategy=trend_momentum | consensus=NARROW | diversity=0.35 | conflict=0.23
- ATAS/advisory: eligible=FACT:false, strength=FACT:0.302, contradiction=FACT:False, hold_bias=FACT:False, influenced=FACT:false, note=FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached
- Support/resistance: sr_bucket=FACT:SR_UNKNOWN, confluence=FACT:context_captured, level_flags=UNAVAILABLE, interpreted_effect=UNAVAILABLE
- Lifecycle/execution: entry_price=UNAVAILABLE, fill=UNAVAILABLE, slippage=UNAVAILABLE, SL=UNAVAILABLE, TP=UNAVAILABLE, management=FACT:see_MQL5_log_for_ticket_8116245706, exit_reason=UNAVAILABLE
- Outcome/attribution: outcome=FACT:WIN, result_money=FACT:102.7, result_points=UNAVAILABLE, R=UNAVAILABLE, primary_attr=UNAVAILABLE, secondary_attr=UNAVAILABLE, motif=FACT:strategy=trend_momentum|direction=SELL|regime=EXPANSION|vol=HIGH_VOL|struct=CLEAN|setup=SETUP_NEUTRAL|sr=SR_UNKNOWN|contradiction=0
- AI/governance posture: ai_authority=UNAVAILABLE, ai_readiness=UNAVAILABLE, ai_bridge=FACT:False, advisory_state=FACT:ATAS_ADVISORY_INELIGIBLE, gate=UNAVAILABLE
- What most affected this trade: FACT:Outcome=WIN profit=102.7 | FACT:Context regime=EXPANSION vol=HIGH_VOL sr=SR_UNKNOWN | FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached

### Trade #6 — XAUUSD-1775681784-100434-290
- Identity: symbol=FACT:XAUUSD, direction=FACT:SELL, ticket/position=FACT:8115655071, close_deal=FACT:7660947990
- Timing: entry=FACT:2026-04-08 20:57:40, exit=FACT:2026-04-08 21:00:13, holding=INFERRED:153s, session=INFERRED:US
- Entry context: strategy=FACT:trend_momentum, family=FACT:TREND_CONTINUATION, plan_mode=FACT:HYBRID, decision_mode=FACT:COUNCIL
- Regime/environment: regime=FACT:TREND_DOWN, regime_conf=FACT:0.85, vol=FACT:HIGH_VOL, structure=FACT:CLEAN, contradiction=FACT:contradiction=False
- Council: profile=FACT:CONTINUATION, regime_fit=FACT:0.62, summary=FACT:[AI-EA] [INFO] Runtime decision (COUNCIL): [Regime=TREND_DOWN conf=0.85 trad=0.62] SELL | Mode=COUNCIL | Final=SELL | Zone=TREND_CONTINUATION | ZoneConf=0.91 | PrefStyle=CONTINUATION | EnvScore=0.89 | CouncilQ=0.71 | Consensus=0.81 | ConsensusLabel=NARROW | Conflict=0.23 | Dominant=SELL | Best=trend_momentum | Regime=TREND_BEAR|HIGH_VOL|TIGHT_SPREAD|CLEAN | Council pipeline passed | zone=TREND_CONTINUATION | pref_style=CONTINUATION | best_strategy=trend_momentum | support=bollinger_reclaim,trend_momentum | consensus=NARROW | diversity=0.35 | gov_state=DEFENSIVE | fail_pressure=NONE | governor=AI Governor: narrow or conflicted consensus, tightened gate and nudged leader | state=DEFENSIVE | best_strategy=trend_momentum | consensus=NARROW | diversity=0.35 | conflict=0.23
- ATAS/advisory: eligible=FACT:false, strength=FACT:0.382, contradiction=FACT:False, hold_bias=FACT:False, influenced=FACT:false, note=FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached
- Support/resistance: sr_bucket=FACT:SR_CONTINUATION_OBSTRUCTED, confluence=FACT:context_captured, level_flags=UNAVAILABLE, interpreted_effect=UNAVAILABLE
- Lifecycle/execution: entry_price=UNAVAILABLE, fill=UNAVAILABLE, slippage=UNAVAILABLE, SL=UNAVAILABLE, TP=UNAVAILABLE, management=FACT:see_MQL5_log_for_ticket_8115655071, exit_reason=UNAVAILABLE
- Outcome/attribution: outcome=FACT:WIN, result_money=FACT:49, result_points=UNAVAILABLE, R=UNAVAILABLE, primary_attr=UNAVAILABLE, secondary_attr=UNAVAILABLE, motif=FACT:strategy=trend_momentum|direction=SELL|regime=TREND_DOWN|vol=HIGH_VOL|struct=CLEAN|setup=SETUP_NEUTRAL|sr=SR_CONTINUATION_OBSTRUCTED|contradiction=0
- AI/governance posture: ai_authority=UNAVAILABLE, ai_readiness=UNAVAILABLE, ai_bridge=FACT:False, advisory_state=FACT:ATAS_ADVISORY_INELIGIBLE, gate=UNAVAILABLE
- What most affected this trade: FACT:Outcome=WIN profit=49 | FACT:Context regime=TREND_DOWN vol=HIGH_VOL sr=SR_CONTINUATION_OBSTRUCTED | FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached

### Trade #7 — XAUUSD-1775678857-100385-256
- Identity: symbol=FACT:XAUUSD, direction=FACT:BUY, ticket/position=FACT:8114718143, close_deal=FACT:7659899479
- Timing: entry=FACT:2026-04-08 20:08:48, exit=FACT:2026-04-08 20:12:43, holding=INFERRED:235s, session=INFERRED:US
- Entry context: strategy=FACT:sweep_reversal, family=FACT:LIQUIDITY_REVERSAL, plan_mode=FACT:HYBRID, decision_mode=FACT:COUNCIL
- Regime/environment: regime=FACT:RANGE_BALANCED, regime_conf=FACT:0.58, vol=FACT:HIGH_VOL, structure=FACT:CLEAN, contradiction=FACT:contradiction=False
- Council: profile=FACT:MEAN_RECLAIM, regime_fit=FACT:0.57, summary=FACT:[AI-EA] [INFO] Runtime decision (COUNCIL): [Regime=RANGE_BALANCED conf=0.58 trad=0.57] BUY | Mode=COUNCIL | Final=BUY | Zone=RANGE_MEAN_RECLAIM | ZoneConf=0.82 | PrefStyle=MEAN_RECLAIM | EnvScore=0.75 | CouncilQ=0.85 | Consensus=1.00 | ConsensusLabel=HIGH_CONVICTION | Conflict=0.00 | Dominant=BUY | Best=sweep_reversal | Regime=RANGE|HIGH_VOL|TIGHT_SPREAD|CLEAN | Council pipeline passed | zone=RANGE_MEAN_RECLAIM | pref_style=MEAN_RECLAIM | best_strategy=sweep_reversal | support=sweep_reversal,bollinger_reclaim | consensus=HIGH_CONVICTION | diversity=0.70 | gov_state=EXHAUSTION_SENSITIVE | fail_pressure=NONE | governor=AI Governor: exhaustion-sensitive mode | zone=RANGE_MEAN_RECLAIM | best_strategy=sweep_reversal | quality=0.85 | exhaustion=true
- ATAS/advisory: eligible=FACT:false, strength=FACT:0.333, contradiction=FACT:False, hold_bias=FACT:False, influenced=FACT:false, note=FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached
- Support/resistance: sr_bucket=FACT:SR_CANONICAL_NEAR, confluence=FACT:context_captured, level_flags=UNAVAILABLE, interpreted_effect=INFERRED:potentially_helpful
- Lifecycle/execution: entry_price=UNAVAILABLE, fill=UNAVAILABLE, slippage=UNAVAILABLE, SL=UNAVAILABLE, TP=UNAVAILABLE, management=FACT:see_MQL5_log_for_ticket_8114718143, exit_reason=UNAVAILABLE
- Outcome/attribution: outcome=FACT:WIN, result_money=FACT:8.6, result_points=UNAVAILABLE, R=UNAVAILABLE, primary_attr=UNAVAILABLE, secondary_attr=UNAVAILABLE, motif=FACT:strategy=sweep_reversal|direction=BUY|regime=RANGE_BALANCED|vol=HIGH_VOL|struct=CLEAN|setup=SETUP_NEUTRAL|sr=SR_CANONICAL_NEAR|contradiction=0
- AI/governance posture: ai_authority=UNAVAILABLE, ai_readiness=UNAVAILABLE, ai_bridge=FACT:False, advisory_state=FACT:ATAS_ADVISORY_INELIGIBLE, gate=UNAVAILABLE
- What most affected this trade: FACT:Outcome=WIN profit=8.6 | FACT:Context regime=RANGE_BALANCED vol=HIGH_VOL sr=SR_CANONICAL_NEAR | FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached

### Trade #8 — XAUUSD-1775676870-100352-228
- Identity: symbol=FACT:XAUUSD, direction=FACT:SELL, ticket/position=FACT:8114174336, close_deal=FACT:7659306455
- Timing: entry=FACT:2026-04-08 19:35:40, exit=FACT:2026-04-08 19:40:05, holding=INFERRED:265s, session=INFERRED:US
- Entry context: strategy=FACT:bollinger_reclaim, family=FACT:MEAN_RECLAIM, plan_mode=FACT:HYBRID, decision_mode=FACT:COUNCIL
- Regime/environment: regime=FACT:TREND_DOWN, regime_conf=FACT:0.85, vol=FACT:HIGH_VOL, structure=FACT:CLEAN, contradiction=FACT:contradiction=False
- Council: profile=FACT:MEAN_RECLAIM, regime_fit=FACT:0.60, summary=FACT:[AI-EA] [INFO] Runtime decision (COUNCIL): [Regime=TREND_DOWN conf=0.85 trad=0.60] SELL | Mode=COUNCIL | Final=SELL | Zone=RANGE_MEAN_RECLAIM | ZoneConf=0.82 | PrefStyle=MEAN_RECLAIM | EnvScore=0.78 | CouncilQ=0.70 | Consensus=1.00 | ConsensusLabel=NARROW | Conflict=0.00 | Dominant=SELL | Best=bollinger_reclaim | Regime=RANGE|HIGH_VOL|TIGHT_SPREAD|CLEAN | Council pipeline passed | zone=RANGE_MEAN_RECLAIM | pref_style=MEAN_RECLAIM | best_strategy=bollinger_reclaim | support=bollinger_reclaim | consensus=NARROW | diversity=0.35 | gov_state=EXHAUSTION_SENSITIVE | fail_pressure=NONE | governor=AI Governor: narrow or conflicted consensus, tightened gate and nudged leader | state=EXHAUSTION_SENSITIVE | best_strategy=bollinger_reclaim | consensus=NARROW | diversity=0.35 | conflict=0.00
- ATAS/advisory: eligible=FACT:false, strength=FACT:0.377, contradiction=FACT:False, hold_bias=FACT:False, influenced=FACT:false, note=FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached
- Support/resistance: sr_bucket=FACT:SR_CANONICAL_NEAR, confluence=FACT:context_captured, level_flags=UNAVAILABLE, interpreted_effect=INFERRED:potentially_helpful
- Lifecycle/execution: entry_price=UNAVAILABLE, fill=UNAVAILABLE, slippage=UNAVAILABLE, SL=UNAVAILABLE, TP=UNAVAILABLE, management=FACT:see_MQL5_log_for_ticket_8114174336, exit_reason=UNAVAILABLE
- Outcome/attribution: outcome=FACT:LOSS, result_money=FACT:-35.2, result_points=UNAVAILABLE, R=UNAVAILABLE, primary_attr=UNAVAILABLE, secondary_attr=UNAVAILABLE, motif=FACT:strategy=bollinger_reclaim|direction=SELL|regime=TREND_DOWN|vol=HIGH_VOL|struct=CLEAN|setup=SETUP_NEUTRAL|sr=SR_CANONICAL_NEAR|contradiction=0
- AI/governance posture: ai_authority=UNAVAILABLE, ai_readiness=UNAVAILABLE, ai_bridge=FACT:False, advisory_state=FACT:ATAS_ADVISORY_INELIGIBLE, gate=UNAVAILABLE
- What most affected this trade: FACT:Outcome=LOSS profit=-35.2 | FACT:Context regime=TREND_DOWN vol=HIGH_VOL sr=SR_CANONICAL_NEAR | FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached

### Trade #9 — XAUUSD-1775674237-100308-192
- Identity: symbol=FACT:XAUUSD, direction=FACT:SELL, ticket/position=FACT:8113340742, close_deal=FACT:7658357635
- Timing: entry=FACT:2026-04-08 18:51:51, exit=FACT:2026-04-08 18:55:15, holding=INFERRED:204s, session=INFERRED:US
- Entry context: strategy=FACT:sweep_reversal, family=FACT:LIQUIDITY_REVERSAL, plan_mode=FACT:HYBRID, decision_mode=FACT:COUNCIL
- Regime/environment: regime=FACT:COMPRESSION, regime_conf=FACT:0.62, vol=FACT:HIGH_VOL, structure=FACT:CLEAN, contradiction=FACT:contradiction=False
- Council: profile=FACT:MEAN_RECLAIM, regime_fit=FACT:0.57, summary=FACT:[AI-EA] [INFO] Runtime decision (COUNCIL): [Regime=COMPRESSION conf=0.62 trad=0.57] SELL | Mode=COUNCIL | Final=SELL | Zone=RANGE_MEAN_RECLAIM | ZoneConf=0.82 | PrefStyle=MEAN_RECLAIM | EnvScore=0.87 | CouncilQ=0.87 | Consensus=1.00 | ConsensusLabel=HIGH_CONVICTION | Conflict=0.00 | Dominant=SELL | Best=sweep_reversal | Regime=RANGE|HIGH_VOL|TIGHT_SPREAD|CLEAN | Council pipeline passed | zone=RANGE_MEAN_RECLAIM | pref_style=MEAN_RECLAIM | best_strategy=sweep_reversal | support=sweep_reversal,bollinger_reclaim | consensus=HIGH_CONVICTION | diversity=0.70 | gov_state=EXHAUSTION_SENSITIVE | fail_pressure=NONE | governor=AI Governor: exhaustion-sensitive mode | zone=RANGE_MEAN_RECLAIM | best_strategy=sweep_reversal | quality=0.87 | exhaustion=true
- ATAS/advisory: eligible=FACT:false, strength=FACT:0.305, contradiction=FACT:False, hold_bias=FACT:False, influenced=FACT:false, note=FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached
- Support/resistance: sr_bucket=FACT:SR_UNKNOWN, confluence=FACT:context_captured, level_flags=UNAVAILABLE, interpreted_effect=UNAVAILABLE
- Lifecycle/execution: entry_price=UNAVAILABLE, fill=UNAVAILABLE, slippage=UNAVAILABLE, SL=UNAVAILABLE, TP=UNAVAILABLE, management=FACT:see_MQL5_log_for_ticket_8113340742, exit_reason=UNAVAILABLE
- Outcome/attribution: outcome=FACT:WIN, result_money=FACT:47.6, result_points=UNAVAILABLE, R=UNAVAILABLE, primary_attr=UNAVAILABLE, secondary_attr=UNAVAILABLE, motif=FACT:strategy=sweep_reversal|direction=SELL|regime=COMPRESSION|vol=HIGH_VOL|struct=CLEAN|setup=SETUP_NEUTRAL|sr=SR_UNKNOWN|contradiction=0
- AI/governance posture: ai_authority=UNAVAILABLE, ai_readiness=UNAVAILABLE, ai_bridge=FACT:False, advisory_state=FACT:ATAS_ADVISORY_INELIGIBLE, gate=UNAVAILABLE
- What most affected this trade: FACT:Outcome=WIN profit=47.6 | FACT:Context regime=COMPRESSION vol=HIGH_VOL sr=SR_UNKNOWN | FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached

### Trade #10 — XAUUSD-1775664074-100139-38
- Identity: symbol=FACT:XAUUSD, direction=FACT:SELL, ticket/position=FACT:8108699225, close_deal=FACT:7653114362
- Timing: entry=FACT:2026-04-08 16:03:30, exit=FACT:2026-04-08 16:04:34, holding=INFERRED:64s, session=INFERRED:US
- Entry context: strategy=FACT:sweep_reversal, family=FACT:LIQUIDITY_REVERSAL, plan_mode=FACT:HYBRID, decision_mode=FACT:COUNCIL
- Regime/environment: regime=FACT:RANGE_DIRTY, regime_conf=FACT:0.58, vol=FACT:HIGH_VOL, structure=FACT:CLEAN, contradiction=FACT:contradiction=False
- Council: profile=FACT:MEAN_RECLAIM, regime_fit=FACT:0.54, summary=FACT:[AI-EA] [INFO] Runtime decision (COUNCIL): [Regime=RANGE_DIRTY conf=0.58 trad=0.54] SELL | Mode=COUNCIL | Final=SELL | Zone=RANGE_MEAN_RECLAIM | ZoneConf=0.82 | PrefStyle=MEAN_RECLAIM | EnvScore=0.86 | CouncilQ=0.87 | Consensus=1.00 | ConsensusLabel=HIGH_CONVICTION | Conflict=0.00 | Dominant=SELL | Best=sweep_reversal | Regime=RANGE|HIGH_VOL|TIGHT_SPREAD|CLEAN | Council pipeline passed | zone=RANGE_MEAN_RECLAIM | pref_style=MEAN_RECLAIM | best_strategy=sweep_reversal | support=sweep_reversal,bollinger_reclaim | consensus=HIGH_CONVICTION | diversity=0.70 | gov_state=EXHAUSTION_SENSITIVE | fail_pressure=NONE | governor=AI Governor: exhaustion-sensitive mode | zone=RANGE_MEAN_RECLAIM | best_strategy=sweep_reversal | quality=0.87 | exhaustion=true
- ATAS/advisory: eligible=FACT:false, strength=FACT:0.459, contradiction=FACT:False, hold_bias=FACT:False, influenced=FACT:false, note=FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached
- Support/resistance: sr_bucket=FACT:SR_REJECTION_RISK, confluence=FACT:context_captured, level_flags=FACT:rejection_risk, interpreted_effect=INFERRED:potentially_hurt
- Lifecycle/execution: entry_price=UNAVAILABLE, fill=UNAVAILABLE, slippage=UNAVAILABLE, SL=UNAVAILABLE, TP=UNAVAILABLE, management=FACT:see_MQL5_log_for_ticket_8108699225, exit_reason=UNAVAILABLE
- Outcome/attribution: outcome=FACT:WIN, result_money=FACT:51.3, result_points=UNAVAILABLE, R=UNAVAILABLE, primary_attr=UNAVAILABLE, secondary_attr=UNAVAILABLE, motif=FACT:strategy=sweep_reversal|direction=SELL|regime=RANGE_DIRTY|vol=HIGH_VOL|struct=CLEAN|setup=SETUP_NEUTRAL|sr=SR_REJECTION_RISK|contradiction=0
- AI/governance posture: ai_authority=UNAVAILABLE, ai_readiness=UNAVAILABLE, ai_bridge=FACT:False, advisory_state=FACT:ATAS_ADVISORY_INELIGIBLE, gate=UNAVAILABLE
- What most affected this trade: FACT:Outcome=WIN profit=51.3 | FACT:Context regime=RANGE_DIRTY vol=HIGH_VOL sr=SR_REJECTION_RISK | FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached

## Cross-Trade Patterns Across Last 10
- Outcomes: wins=7, losses=3, flats=0
- Repeated failure causes: FACT:SR_CANONICAL_NEAR:3
- Repeated success causes: FACT:SR_UNKNOWN:2; FACT:SR_CANONICAL_NEAR:2; FACT:SR_REJECTION_RISK:2; FACT:SR_CONTINUATION_OBSTRUCTED:1
- Repeated regime issues: FACT:TREND_DOWN:5; FACT:RANGE_DIRTY:2; FACT:COMPRESSION:1; FACT:RANGE_BALANCED:1; FACT:EXPANSION:1
- Repeated advisory uselessness: FACT:state=ATAS_ADVISORY_INELIGIBLE;reasons=atas_shadow_not_attached:10
- Learning help/hurt signal: UNAVAILABLE (performance journal lock prevented per-trade learning delta extraction)
- Selectivity/permissiveness note: INFERRED:10 entries captured; rejected-decision count outside this table

## Missing Fields / Artifacts And Why
- `ai_performance_journal.jsonl` was intentionally not read while MT5 may be running (AGENTS live-locked file governance).
- Because of that lock and available bounded surfaces, confidence-envelope deltas and some execution geometry fields are unavailable for this run.
- Per-trade requested/fill/slippage/MFE/MAE/points/R values are unavailable in parsed sources and remain explicitly marked `UNAVAILABLE`.

## Artifacts In This Package
- `last10_trades_master_table.csv`
- `last10_trades_master_table.json`
- `last10_trades_expanded.json`
- `raw_source_references.json`
- `cross_trade_patterns_summary.json`

