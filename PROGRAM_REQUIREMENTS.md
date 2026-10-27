# Program Requirements Coverage

The implementation provides inspectable Prolog facts for symbolic nodes and links, rules and scoped laws, time-series observations, attention, provenance, imported documents, and conversation turns.

| Requirement area | Current implementation | Limits |
|---|---|---|
| Conversation | `new_session/1`, `chat/3`, `respond/3`, turn/context storage, `explain_last/2` | In-process state; narrow response behavior rather than general dialogue understanding |
| MNN activation | `activate/3`, `activation_trace/2`, weighted links, configurable traversal limits | No learned embeddings or adaptive activation weights |
| Symbolic reasoning | Rules, priority/confidence resolution, area-scoped laws | Conditions are executable Prolog goals; no natural-language rule compiler |
| Text processing | Sentence/token extraction and document import with provenance | Heuristic candidate extraction; candidates are not automatically asserted as knowledge |
| Temporal reasoning | Observation range/latest/change/trend predicates | Trends compare endpoints; chat currently handles plant-growth questions only |
| Authoring | Preview, validation, commit, undo for area/law-text/import proposals | Small command vocabulary; law text is not compiled into logic |
| Persistence | MNN facts and session turns/context can be saved and loaded | Plain Prolog terms, no schema/versioning, transactionality, or storage isolation |

Runnable test coverage and exact commands are documented in [TESTING.md](TESTING.md). The README links to the API documentation for each feature family.
