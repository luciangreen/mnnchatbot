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

Conversation turns are stored as:
- `turn(Session, N, Time, Speaker, Text)`
