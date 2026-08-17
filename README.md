# MNN Chatbot (SWI-Prolog)

This repository provides an inspectable symbolic chatbot using explicit Prolog facts and rules.

## Quick start

```prolog
?- [mnnchatbot].
?- reset_state.
?- new_session(S).
?- add_area("Botany", A).
?- add_law(A, area_law(A, growth_law, [series_trend(plant_height, increasing)], growing, 70, system)).
?- series_add(plant_height, day1, 10).
?- series_add(plant_height, day2, 11).
?- series_add(plant_height, day3, 13).
?- chat(S, "Is the plant growing?", R).
```

Run tests:

```bash
swipl -q -s tests/test_mnnchatbot.pl -g run_tests,halt
```
