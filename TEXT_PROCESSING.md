# Text Processing

Import and extraction:
- `import_text/2`
- `process_text/2`
- `process_sentence/2`
- `extract_entities/2`, `extract_concepts/2`, `extract_relations/2`
- `extract_rules/2`, `extract_laws/2`, `extract_dates/2`, `extract_time_series/2`
- `summarise_text/2`

`process_sentence/2` returns a dict containing the original text, lowercase tokens, a negation flag, a detected modality, a coarse question type, and an intent. For example:

```prolog
?- process_sentence("Could the plant stop growing?", I).
I = interpretation{intent:question, ...}.
```

`process_text/2` returns a dict with sentences and aggregate candidate concepts, relations, rules, and laws. These extractors are intentionally heuristic: concepts are content tokens, relations recognize a simple `X is Y` pattern, and rule/law/time-series candidates are based on text markers. Dates are identified by a `YYYY-...` token shape. Extraction does not assert extracted candidates as executable knowledge.

Traceability structures:
- `document/2`, `section/3`, `paragraph/3`, `sentence/3`
- `sentence_fact/3`, `sentence_concept/3`, `sentence_relation/4`, `text_fact/3`

`import_text(File, DocumentId)` reads a local text file and stores its text, paragraphs, sentences, extracted concepts and relations, and source provenance. Import failures (for example, a missing file) are reported by Prolog's file-reading predicate. The current importer assigns sentence indexes within each paragraph and does not provide a query or deletion API for imported documents.
