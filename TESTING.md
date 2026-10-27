# Tests

## Requirements

- SWI-Prolog (`swipl`)
- No third-party Prolog packages are required; the implementation uses SWI-Prolog libraries.

## Run the suite

From the repository root:

```bash
swipl -q -s tests/test_mnnchatbot.pl -g run_tests,halt
```

The test file resolves `examples/plants.txt` relative to the loaded `mnnchatbot.pl`, so it does not depend on a runner-specific checkout path.

## Coverage

The PlUnit suite covers:

- state reset and attention weighting/decay
- time-series latest-value and trend behavior
- bounded activation in a cyclic graph
- priority-based rule resolution and area-scoped law lookup
- document import and source provenance
- question intent and coarse text extraction
- author-mode commit and undo
- a plant-growth chat response
- MNN persistence round-trip

To run a focused test, load the suite and invoke its test by name, for example:

```bash
swipl -q -s tests/test_mnnchatbot.pl -g "run_tests(mnnchatbot:question_intent),halt"
```

The tests mutate process-global dynamic predicates. Each test that depends on a clean database calls `reset_state/0`; avoid running these tests concurrently in the same Prolog process.

## Manual smoke test

```bash
swipl -q -s mnnchatbot.pl
```

At the Prolog prompt, create a session and query it:

```prolog
?- reset_state, new_session(S), chat(S, "Hello", Reply).
```

For a temporal response, add increasing observations for `plant_height` and ask whether the plant is growing, as shown in the README.
