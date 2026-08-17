# Author Mode

Enable or disable:

```prolog
?- author_mode(on).
?- author_mode(off).
```

Pipeline predicates:
- `author_parse/2`
- `author_validate/2`
- `author_preview/2`
- `author_commit/1`
- `author_undo/1`

All commits create auditable change records and undo actions.
