# Areas and Laws

Areas are scoped knowledge domains:
- `area/2`, `subarea/2`

Scoped laws:
- `area_law(Area, LawId, Conditions, Consequence, Priority, Source)`
- `law_type/2`
- `applies_in/2`
- `candidate_law/6`

Law application is area-scoped through `applicable_laws/2`.
