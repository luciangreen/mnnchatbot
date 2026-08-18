# Program Requirements Coverage

The implementation keeps reasoning state explicit in Prolog facts for MNN nodes/links, rules, laws, time-series observations, attention, provenance, and conversation turns.

Core APIs exposed:
- `new_session/1`, `chat/3`, `respond/3`, `explain_last/2`
- `import_text/2`, `process_text/2`
- `add_area/2`, `add_law/2`, `author_mode/1`
- `save_mnn/1`, `load_mnn/1`, `save_session/2`, `load_session/2`
