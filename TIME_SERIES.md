# Time Series

Stored structures:
- `observation(Series, Time, Value)`
- `event(Time, Subject, Predicate, Object)`

Main predicates:
- `series_add/3`
- `series_range/4`
- `series_latest/3`
- `series_change/4`
- `series_trend/3`
- `before/2`, `after/2`, `during/3`

Observations are stored as facts and are not deduplicated. `series_range/4` returns sorted `Time-Value` pairs using Prolog term ordering; `series_latest/3` and `series_trend/3` use the greatest time term, so use consistently comparable time keys (for example, ISO date atoms). `series_change/4` requires numeric endpoint values. A trend compares only the first and last observations, not every intermediate value.

Example:

```prolog
?- series_add(temperature, '2026-01-01', 8),
   series_add(temperature, '2026-01-02', 10),
   series_trend(temperature, Trend, Details).
Trend = increasing,
Details = trend('2026-01-01', 8, '2026-01-02', 10).
```

Conversation turns are stored as:
- `turn(Session, N, Time, Speaker, Text)`

The current chat response uses temporal evidence only for its prototype plant-growth path, which reads `plant_height`. Other series can be queried through these predicates but are not automatically used to answer arbitrary questions.
