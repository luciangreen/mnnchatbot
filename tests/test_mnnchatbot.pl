:- begin_tests(mnnchatbot).

:- use_module('../mnnchatbot').

test(reset_state) :-
    reset_state,
    \+ concept(_,_).

test(attention_update_and_decay) :-
    reset_state,
    attention_update(test_item, 0.7, W1),
    assertion(W1 =:= 0.7),
    attention_decay(0.5, _),
    attention(test_item, W2),
    assertion(W2 =:= 0.35).

test(series_and_trend) :-
    reset_state,
    series_add(plant_height, day1, 10),
    series_add(plant_height, day2, 11),
    series_add(plant_height, day3, 13),
    series_latest(plant_height, day3, 13),
    series_trend(plant_height, increasing, trend(day1,10,day3,13)).

test(activation_bounded_cycle) :-
    reset_state,
    assertz(mnn_link(a, related, b, 0.9)),
    assertz(mnn_link(b, related, a, 0.9)),
    activation_trace([a], Trace),
    assertion(Trace \= []),
    length(Trace, Len),
    max_active_nodes(Max),
    assertion(Len =< Max).

test(rule_priority_resolution) :-
    reset_state,
    assertz(rule(r1, general, [true], result(low), 10, 0.6, test)),
    assertz(rule(r2, general, [true], result(high), 20, 0.5, test)),
    mnnchatbot:applicable_rules([], Rules),
    resolve_rules(Rules, applicable(r2,result(high),20,0.5), _).

test(area_and_law_scoping) :-
    reset_state,
    add_area("Botany", Area),
    add_law(Area, area_law(Area, growth_law, [true], growth_possible, 70, system)),
    mnnchatbot:applicable_laws([Area], Laws),
    assertion(member(applicable_law(growth_law,growth_possible,70,Area), Laws)).

test(text_import_and_provenance) :-
    reset_state,
    File = '/home/runner/work/mnnchatbot/mnnchatbot/examples/plants.txt',
    import_text(File, Doc),
    document(Doc, _),
    provenance(Doc, document, File, _).

test(author_mode_commit_undo) :-
    reset_state,
    author_mode(on),
    author_commit(add_area("Botany")),
    area(botany, "Botany"),
    once(mnnchatbot:author_change(ChangeId, add_area("Botany"), committed)),
    once(author_undo(ChangeId)),
    \+ area(botany, "Botany").

test(chat_growth_response) :-
    reset_state,
    add_area("Botany", _),
    series_add(plant_height, day1, 10),
    series_add(plant_height, day2, 11),
    series_add(plant_height, day3, 13),
    new_session(S),
    once(chat(S, "Is the plant growing?", Response)),
    sub_string(Response, 0, _, _, "Yes.").

test(persistence_roundtrip) :-
    reset_state,
    assertz(concept(c1, rain)),
    save_mnn('/tmp/mnn_state.pl'),
    reset_state,
    load_mnn('/tmp/mnn_state.pl'),
    concept(c1, rain).

:- end_tests(mnnchatbot).
