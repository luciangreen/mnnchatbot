# Architecture

The system keeps its working knowledge in dynamic Prolog facts. `reset_state/0` clears the knowledge, conversation, provenance, and configuration facts, then reinstates default limits. Each `new_session/1` creates a context record; the implementation runs in one Prolog process and does not provide per-user storage isolation.

`chat/3` follows explicit stages:
1. interpret input (`process_sentence/2`)
2. update context (`context/6`)
3. update attention (`attention_update/3`)
4. activate MNN (`activate/3` + `activation_trace/2`)
5. gather temporal context (`series_*`)
6. evaluate rules/laws (`applicable_rules/2`, `applicable_laws/2`)
7. resolve and plan response (`resolve_conclusions/2`, `plan_response/3`)
8. realize text (`realise_response/2`)

The stages are deliberately inspectable, not a general natural-language understanding pipeline. The current temporal response path recognizes plant-growth questions against the `plant_height` series. Rules and laws can participate when their Prolog conditions hold, but the default chat path does not learn arbitrary facts from user utterances.

Session and MNN persistence are separate: `save_session/2` stores a session's turns and context, while `save_mnn/1` writes supported knowledge facts. Both formats are plain Prolog terms loaded by `consult/1`; they are intended for trusted local files.
