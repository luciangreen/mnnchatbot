# Areas and Laws

Areas are scoped knowledge domains:
- `area/2`, `subarea/2`

Scoped laws:
- `area_law(Area, LawId, Conditions, Consequence, Priority, Source)`
- `law_type/2`
- `applies_in/2`
- `candidate_law/6`

Create an area with `add_area(Name, AreaId)` and attach a law with `add_law(AreaId, Law)`. `applicable_laws(ActiveAreas, Applicable)` evaluates each law's condition list against the current Prolog database and returns only matching laws scoped to one of the supplied areas. Rule candidates are ordered by descending priority, then descending confidence, then identifier.

Conditions are executable Prolog goals, not a parsed or sandboxed rule language. Keep authored conditions trusted. The structures `law_type/2`, `applies_in/2`, and `candidate_law/6` are available for explicit knowledge organization; the candidate text extractor does not automatically promote its output into an `area_law/6`.

Example:

```prolog
?- add_area("Botany", Botany),
   add_law(Botany, area_law(Botany, growth_law,
       [series_trend(plant_height, increasing)], growth, 70, author)).
```
