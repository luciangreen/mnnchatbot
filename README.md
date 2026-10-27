# MNN Chatbot (SWI-Prolog)

This repository provides an inspectable, in-process symbolic chatbot implemented with SWI-Prolog. Knowledge, activation, rule selection, time-series observations, conversation turns, and source provenance are represented as Prolog facts.

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
?- explain_last(S, Why).
```

`chat/3` maintains session turns and context. The example asks the chatbot to reason from an explicitly recorded height series; it does not train a statistical model.

## Features

- **MNN facts and bounded spreading activation:** inspectable nodes and weighted links, with depth, activation, and node-count limits.
- **Symbolic rules and scoped laws:** condition lists are evaluated as Prolog goals; rules resolve by priority, then confidence.
- **Text processing and import:** sentence/token-based extraction of candidate concepts, relations, rules, laws, dates, and time-series mentions. Imports retain document structure and provenance.
- **Time-series reasoning:** add and query observations, compute changes and endpoint trends, and use plant-height trends in the sample chat response.
- **Conversation and explanations:** session turns, topic/entity context, attention weights, `explain_last/2`, and response planning.
- **Author mode:** parse, validate, preview, commit, and undo a small set of authoring proposals.
- **Persistence:** save/load MNN facts and save/load session turns and context.

See [ARCHITECTURE.md](ARCHITECTURE.md), [MNN_FORMAT.md](MNN_FORMAT.md), [TEXT_PROCESSING.md](TEXT_PROCESSING.md), [TIME_SERIES.md](TIME_SERIES.md), [AREAS_AND_LAWS.md](AREAS_AND_LAWS.md), and [AUTHOR_MODE.md](AUTHOR_MODE.md) for APIs, examples, and current limitations. [TESTING.md](TESTING.md) documents the runnable test suite.

## Test and run

Install SWI-Prolog, then run the test suite from the repository root:

```bash
swipl -q -s tests/test_mnnchatbot.pl -g run_tests,halt
```

Start the interactive chatbot:

```bash
swipl -q -s mnnchatbot.pl -g chatbot
```

## Implementation status

The public predicates and core symbolic flows described above are implemented and covered by the tests. This is an early prototype: text extraction uses simple token and substring heuristics; imported text is not automatically converted into trusted rules; chat reasoning is intentionally narrow; author mode supports only a few proposal forms; and persistence is a plain Prolog-term dump, not a versioned or isolated database. See [TESTING.md](TESTING.md) for coverage and [PROGRAM_REQUIREMENTS.md](PROGRAM_REQUIREMENTS.md) for the current system scope.
