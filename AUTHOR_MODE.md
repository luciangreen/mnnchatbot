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

The currently recognized instructions are:

```text
create an area called Botany
add the law: plants need water
import examples/plants.txt
```

`author_preview/2` accepts either an instruction string or a proposal term. Validation checks for a nonempty area/law text or an existing import file. Commits require author mode to be on and record an `author_change/3` entry plus an undo action. The supported proposal set is deliberately small; law text is retained as a candidate and is not translated into an executable rule. Undo is in-memory and applies only while its undo action remains present.

Example:

```prolog
?- author_mode(on),
   author_preview("create an area called Botany", Preview),
   author_commit(add_area("Botany")).
```
