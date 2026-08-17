# Architecture

`chat/3` follows explicit stages:
1. interpret input (`process_sentence/2`)
2. update context (`context/6`)
3. update attention (`attention_update/3`)
4. activate MNN (`activate/3` + `activation_trace/2`)
5. gather temporal context (`series_*`)
6. evaluate rules/laws (`applicable_rules/2`, `applicable_laws/2`)
7. resolve and plan response (`resolve_conclusions/2`, `plan_response/3`)
8. realize text (`realise_response/2`)
