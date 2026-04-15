// Phase 2 kickoff scaffolding only.
// Non-operative interfaces for future ATAS microstructure engines.
// This file is intentionally not wired into live MT5 runtime authority paths.

namespace AtasMicrostructurePhase2Kickoff.V1;

public interface IOrderFlowState
{
    string PacketId { get; }
    string TraceId { get; }
    string EventTimeUtc { get; }
    string ExecutionSymbol { get; }
    string LiquiditySweepState { get; }
    string AbsorptionState { get; }
    string DeltaBiasState { get; }
    string ImbalanceState { get; }
}

public interface ILiquidityState
{
    string PacketId { get; }
    string EventTimeUtc { get; }
    string ExecutionSymbol { get; }
    string LiquidityStabilityState { get; }
}

public interface ILevelInteractionState
{
    string PacketId { get; }
    string EventTimeUtc { get; }
    string ExecutionSymbol { get; }
    string? LevelInteractionType { get; }
    string? SupportResistanceConfluenceState { get; }
}

public interface IMicrostructureEnvironmentEvidence
{
    string PacketId { get; }
    string EventTimeUtc { get; }
    string ExecutionSymbol { get; }
    string? MarketStateClass { get; }
    string? SessionContext { get; }
    string? PriceSpaceRelation { get; }
}

public interface IQualityValidityState
{
    string PacketId { get; }
    string EventTimeUtc { get; }
    string FreshUntilUtc { get; }
    string EvaluatedAtUtc { get; }
    string FreshnessState { get; }
    string QualityState { get; }
    string AttachmentState { get; }
}
