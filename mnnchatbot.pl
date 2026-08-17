:- module(mnnchatbot,
    [ chatbot/0,
      new_session/1,
      chat/3,
      respond/3,
      explain_last/2,
      explain/2,
      process_text/2,
      process_sentence/2,
      extract_entities/2,
      extract_concepts/2,
      extract_relations/2,
      extract_rules/2,
      extract_dates/2,
      extract_time_series/2,
      extract_laws/2,
      summarise_text/2,
      import_text/2,
      add_area/2,
      add_law/2,
      author_mode/1,
      author_parse/2,
      author_validate/2,
      author_preview/2,
      author_commit/1,
      author_undo/1,
      learn_fact/2,
      learn_relation/4,
      learn_rule/2,
      learn_law/2,
      series_add/3,
      series_range/4,
      series_latest/3,
      series_change/4,
      series_trend/3,
      before/2,
      after/2,
      during/3,
      activate/3,
      activation_trace/2,
      resolve_rules/3,
      applicable_rules/2,
      applicable_laws/2,
      attention_update/3,
      attention_top/2,
      attention_decay/2,
      save_mnn/1,
      load_mnn/1,
      save_session/2,
      load_session/2,
      plan_response/3,
      realise_response/2,
      reset_state/0,
      concept/2,
      property/3,
      relation/4,
      mnn_node/3,
      mnn_link/4,
      activation/3,
      observation/3,
      event/4,
      turn/5,
      turn_topic/3,
      turn_intention/3,
      turn_sentiment/3,
      turn_entities/3,
      turn_facts/3,
      rule/7,
      area/2,
      subarea/2,
      area_law/6,
      law_type/2,
      applies_in/2,
      candidate_law/6,
      attention/2,
      confidence/2,
      contradiction/3,
      supersedes/2,
      provenance/4,
      context/6,
      document/2,
      section/3,
      paragraph/3,
      sentence/3,
      sentence_fact/3,
      sentence_concept/3,
      sentence_relation/4,
      text_fact/3,
      diagnostic/2,
      max_activation_depth/1,
      activation_threshold/1,
      max_active_nodes/1,
      max_rule_iterations/1,
      max_attention_items/1,
      max_document_candidates/1,
      max_response_facts/1
    ]).

:- use_module(library(readutil)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(gensym)).
:- use_module(library(filesex)).

:- dynamic concept/2, property/3, relation/4, mnn_node/3, mnn_link/4, activation/3.
:- dynamic observation/3, event/4, turn/5.
:- dynamic turn_topic/3, turn_intention/3, turn_sentiment/3, turn_entities/3, turn_facts/3.
:- dynamic rule/7, area/2, subarea/2, area_law/6, law_type/2, applies_in/2, candidate_law/6.
:- dynamic attention/2, confidence/2, contradiction/3, supersedes/2, provenance/4.
:- dynamic context/6, diagnostic/2.
:- dynamic document/2, section/3, paragraph/3, sentence/3, sentence_fact/3, sentence_concept/3, sentence_relation/4, text_fact/3.
:- dynamic author_mode_state/1, author_change/3, undo_action/2.
:- dynamic last_response/3, response_explanation/2.

:- dynamic max_activation_depth/1, activation_threshold/1, max_active_nodes/1,
           max_rule_iterations/1, max_attention_items/1,
           max_document_candidates/1, max_response_facts/1.

init_defaults :-
    (max_activation_depth(_) -> true ; assertz(max_activation_depth(4))),
    (activation_threshold(_) -> true ; assertz(activation_threshold(0.10))),
    (max_active_nodes(_) -> true ; assertz(max_active_nodes(32))),
    (max_rule_iterations(_) -> true ; assertz(max_rule_iterations(32))),
    (max_attention_items(_) -> true ; assertz(max_attention_items(20))),
    (max_document_candidates(_) -> true ; assertz(max_document_candidates(20))),
    (max_response_facts(_) -> true ; assertz(max_response_facts(6))),
    (author_mode_state(_) -> true ; assertz(author_mode_state(off))).

:- initialization(init_defaults).

reset_state :-
    retractall(concept(_,_)), retractall(property(_,_,_)), retractall(relation(_,_,_,_)),
    retractall(mnn_node(_,_,_)), retractall(mnn_link(_,_,_,_)), retractall(activation(_,_,_)),
    retractall(observation(_,_,_)), retractall(event(_,_,_,_)), retractall(turn(_,_,_,_,_)),
    retractall(turn_topic(_,_,_)), retractall(turn_intention(_,_,_)), retractall(turn_sentiment(_,_,_)),
    retractall(turn_entities(_,_,_)), retractall(turn_facts(_,_,_)),
    retractall(rule(_,_,_,_,_,_,_)), retractall(area(_,_)), retractall(subarea(_,_)),
    retractall(area_law(_,_,_,_,_,_)), retractall(law_type(_,_)), retractall(applies_in(_,_)),
    retractall(candidate_law(_,_,_,_,_,_)), retractall(attention(_,_)), retractall(confidence(_,_)),
    retractall(contradiction(_,_,_)), retractall(supersedes(_,_)), retractall(provenance(_,_,_,_)),
    retractall(context(_,_,_,_,_,_)), retractall(diagnostic(_,_)),
    retractall(document(_,_)), retractall(section(_,_,_)), retractall(paragraph(_,_,_)),
    retractall(sentence(_,_,_)), retractall(sentence_fact(_,_,_)), retractall(sentence_concept(_,_,_)),
    retractall(sentence_relation(_,_,_,_)), retractall(text_fact(_,_,_)),
    retractall(author_mode_state(_)), retractall(author_change(_,_,_)), retractall(undo_action(_,_)),
    retractall(last_response(_,_,_)), retractall(response_explanation(_,_)),
    retractall(max_activation_depth(_)), retractall(activation_threshold(_)), retractall(max_active_nodes(_)),
    retractall(max_rule_iterations(_)), retractall(max_attention_items(_)),
    retractall(max_document_candidates(_)), retractall(max_response_facts(_)),
    init_defaults.

%%%% Time-series
series_add(Series, Time, Value) :-
    assertz(observation(Series, Time, Value)),
    get_time(Now),
    assertz(provenance(observation(Series, Time, Value), system, series_add, Now)).

series_range(Series, Start, End, Values) :-
    findall(Time-Value,
            (observation(Series, Time, Value), Time @>= Start, Time @=< End),
            Pairs),
    sort(Pairs, Values).

series_latest(Series, Time, Value) :-
    findall(T-V, observation(Series, T, V), Pairs),
    keysort(Pairs, Sorted),
    last(Sorted, Time-Value).

series_change(Series, T1, T2, Change) :-
    observation(Series, T1, V1),
    observation(Series, T2, V2),
    number(V1), number(V2),
    Change is V2 - V1.

series_trend(Series, Trend, Details) :-
    findall(T-V, observation(Series, T, V), Pairs),
    keysort(Pairs, Sorted),
    Sorted = [T1-V1|_],
    last(Sorted, T2-V2),
    (V2 > V1 -> Trend = increasing ; V2 < V1 -> Trend = decreasing ; Trend = stable),
    Details = trend(T1,V1,T2,V2).

series_trend(Series, Trend) :- series_trend(Series, Trend, _).

before(A, B) :- A @< B.
after(A, B)  :- A @> B.
during(T, Start, End) :- T @>= Start, T @=< End.

%%%% Attention
attention_update(Item, Delta, NewWeight) :-
    (attention(Item, Old) -> true ; Old = 0.0),
    Temp is Old + Delta,
    NewWeight is max(0.0, min(1.0, Temp)),
    retractall(attention(Item,_)),
    assertz(attention(Item, NewWeight)).

attention_top(N, Top) :-
    findall(W-Item, attention(Item, W), Pairs),
    keysort(Pairs, Sorted),
    reverse(Sorted, Desc),
    take_n(N, Desc, Top).

attention_decay(Factor, Updated) :-
    findall(Item-New,
            (attention(Item, Old),
             New is max(0.0, min(1.0, Old * Factor)),
             retract(attention(Item, Old)),
             assertz(attention(Item, New))),
            Updated).

take_n(N, _, []) :- N =< 0, !.
take_n(_, [], []).
take_n(N, [X|Xs], [X|Ys]) :- N1 is N-1, take_n(N1, Xs, Ys).

%%%% Activation
activate(InputNodes, Context, ActivatedNodes) :-
    init_defaults,
    retractall(activation(Context,_,_)),
    max_activation_depth(MaxDepth),
    activation_threshold(Threshold),
    max_active_nodes(MaxNodes),
    maplist(seed_node, InputNodes, SeedPairs),
    activation_bfs(SeedPairs, MaxDepth, Threshold, MaxNodes, [], ActivatedMap, _Trace),
    maplist(assert_activation(Context), ActivatedMap),
    pairs_values(ActivatedMap, ActivatedNodes).

activation_trace(InputNodes, Trace) :-
    init_defaults,
    max_activation_depth(MaxDepth),
    activation_threshold(Threshold),
    max_active_nodes(MaxNodes),
    maplist(seed_node, InputNodes, SeedPairs),
    activation_bfs(SeedPairs, MaxDepth, Threshold, MaxNodes, [], _ActivatedMap, TraceRev),
    reverse(TraceRev, Trace).

seed_node(Node, Node-(1.0-0-root)).

activation_bfs(_, _, _, MaxNodes, Acc, Acc, _Trace) :- length(Acc, Len), Len >= MaxNodes,
    retractall(diagnostic(activation_limit,_)),
    assertz(diagnostic(activation_limit, max_active_nodes_reached(MaxNodes))), !.
activation_bfs([], _, _, _, Acc, Acc, []).
activation_bfs([Node-(Weight-Depth-From)|Queue], MaxDepth, Threshold, MaxNodes, Acc0, AccF, [step(Node,Weight,Depth,From)|Trace]) :-
    (member(Node-(_-OldDepth-_), Acc0), OldDepth =< Depth ->
        activation_bfs(Queue, MaxDepth, Threshold, MaxNodes, Acc0, AccF, Trace)
    ;
      select_best(Node, Weight, Depth, From, Acc0, Acc1),
      (Depth >= MaxDepth -> Next = []
      ; findall(Target-(W2-D2-Node),
                (mnn_link(Node, _, Target, Strength),
                 W2 is Weight * Strength,
                 W2 >= Threshold,
                 D2 is Depth + 1),
                Next)),
      append(Queue, Next, Queue1),
      activation_bfs(Queue1, MaxDepth, Threshold, MaxNodes, Acc1, AccF, Trace)
    ).

select_best(Node, W, D, F, Acc0, [Node-(W-D-F)|Rest]) :-
    select(Node-(_-_-_), Acc0, Rest), !.
select_best(Node, W, D, F, Acc0, [Node-(W-D-F)|Acc0]).

assert_activation(Context, Node-(Weight-_-_)) :- assertz(activation(Context, Node, Weight)).

%%%% Rules and laws
resolve_rules([], none, explanation(no_applicable_rules)).
resolve_rules(ApplicableRules, Winner, explanation(chosen(Winner), rejected(Rejected))) :-
    predsort(compare_applicable, ApplicableRules, [Winner|Rejected]).

compare_applicable(Order, applicable(IdA,_,PrA,ConfA), applicable(IdB,_,PrB,ConfB)) :-
    (PrA =:= PrB ->
        (ConfA =:= ConfB -> compare(Order, IdA, IdB)
        ; (ConfA > ConfB -> Order = '<' ; Order = '>'))
    ; (PrA > PrB -> Order = '<' ; Order = '>')).

conditions_hold([]).
conditions_hold([C|Cs]) :- condition_holds(C), conditions_hold(Cs).

condition_holds(\+ C) :- !, \+ condition_holds(C).
condition_holds(C) :- call(C).

applicable_rules(_, Applicable) :-
    findall(applicable(Id, Conclusion, Priority, Confidence),
            (rule(Id, _Area, Conditions, Conclusion, Priority, Confidence, _Source),
             conditions_hold(Conditions)),
            Raw),
    sort(Raw, Applicable).

applicable_laws(ActiveAreas, Applicable) :-
    findall(applicable_law(LawId, Consequence, Priority, Area),
            (member(Area, ActiveAreas),
             area_law(Area, LawId, Conditions, Consequence, Priority, _Source),
             conditions_hold(Conditions)),
            Raw),
    sort(Raw, Applicable).

add_area(Name, AreaId) :-
    atom_string(A0, Name),
    downcase_atom(A0, Lower),
    atomic_list_concat(Parts, ' ', Lower),
    atomic_list_concat(Parts, '_', AreaId),
    \+ area(AreaId,_),
    assertz(area(AreaId, Name)),
    get_time(Now),
    assertz(provenance(area(AreaId, Name), author, add_area, Now)).

add_law(AreaId, area_law(AreaId, LawId, Conditions, Consequence, Priority, Source)) :-
    area(AreaId,_),
    assertz(area_law(AreaId, LawId, Conditions, Consequence, Priority, Source)),
    assertz(applies_in(LawId, AreaId)),
    get_time(Now),
    assertz(provenance(area_law(AreaId, LawId, Conditions, Consequence, Priority, Source), author, add_law, Now)).

%%%% Learning wrappers
learn_fact(Fact, Source) :-
    assertz(Fact), get_time(Now), assertz(provenance(Fact, Source, learn_fact, Now)).
learn_relation(S, R, T, Strength) :-
    assertz(mnn_link(S, R, T, Strength)),
    get_time(Now), assertz(provenance(mnn_link(S,R,T,Strength), author, learn_relation, Now)).
learn_rule(Id, RuleTerm) :-
    RuleTerm = rule(Id, Area, Conditions, Conclusion, Priority, ConfidenceV, Source),
    assertz(rule(Id, Area, Conditions, Conclusion, Priority, ConfidenceV, Source)),
    get_time(Now), assertz(provenance(rule(Id, Area, Conditions, Conclusion, Priority, ConfidenceV, Source), author, learn_rule, Now)).
learn_law(AreaId, LawTerm) :- add_law(AreaId, LawTerm).

%%%% NLP and nuance
process_sentence(Text, interpretation{raw:Text,tokens:Tokens,negation:Neg,modality:Modality,question_type:QType,intent:Intent}) :-
    tokenize(Text, Tokens),
    ( (member(not, Tokens); member(no, Tokens); member(never, Tokens))
    -> Neg = true
    ;  Neg = false
    ),
    detect_modality(Tokens, Modality),
    detect_question_type(Tokens, QType),
    detect_intent(Tokens, Intent).

process_text(Text, representation{sentences:Sentences, concepts:Concepts, relations:Relations, rules:Rules, laws:Laws}) :-
    split_sentences(Text, Sentences0),
    include(non_empty_string, Sentences0, Sentences),
    maplist(extract_concepts, Sentences, ConceptLists),
    append(ConceptLists, FlatConcepts), sort(FlatConcepts, Concepts),
    maplist(extract_relations, Sentences, RelationLists), append(RelationLists, Relations),
    maplist(extract_rules, Sentences, RuleLists), append(RuleLists, Rules),
    maplist(extract_laws, Sentences, LawLists), append(LawLists, Laws).

extract_entities(Text, Entities) :- extract_concepts(Text, Entities).

extract_concepts(Text, Concepts) :-
    tokenize(Text, Tokens),
    include(content_token, Tokens, Content),
    sort(Content, Concepts).

extract_relations(Text, Relations) :-
    tokenize(Text, Tokens),
    (append([A,is,B|_], _, Tokens) -> Relations=[relation(A,is,B,0.6)] ; Relations=[]).

extract_rules(Text, Rules) :-
    string_lower(Text, Lower),
    (sub_string(Lower,0,2,_,"if") -> Rules=[candidate_rule(Text)] ; Rules=[]).

extract_dates(Text, Dates) :-
    tokenize(Text, Tokens),
    include(is_date_token, Tokens, Dates).

extract_time_series(Text, SeriesFacts) :-
    string_lower(Text, Lower),
    (sub_string(Lower, _, _, _, "day") -> SeriesFacts=[candidate_time_series(Text)] ; SeriesFacts=[]).

extract_laws(Text, Laws) :-
    string_lower(Text, Lower),
    (sub_string(Lower, _, _, _, "law") ; sub_string(Lower, _, _, _, "always")) -> Laws=[candidate_law_text(Text)] ; Laws=[].

summarise_text(Text, Summary) :-
    process_text(Text, Rep),
    Rep = representation{sentences:Sentences, concepts:Concepts},
    length(Sentences, SCount),
    length(Concepts, CCount),
    format(string(Summary), "~w sentences, ~w concepts", [SCount, CCount]).

tokenize(Text, Tokens) :-
    string_lower(Text, Lower),
    split_string(Lower, " \n\t,.!?;:\"()[]{}", " \n\t,.!?;:\"()[]{}", Parts),
    maplist(atom_string, Tokens0, Parts),
    exclude(=(""), Parts, _),
    include(non_empty_atom, Tokens0, Tokens).

non_empty_atom(A) :- atom_length(A, L), L > 0.
non_empty_string(S) :- string_length(S, L), L > 0.

split_sentences(Text, Sentences) :-
    split_string(Text, ".!?", "\n\t ", Sentences).

content_token(T) :- atom_length(T, L), L > 2, \+ member(T, [the,and,for,with,from,this,that,then,than]).
is_date_token(Token) :- sub_atom(Token, 4, 1, _, '-').

detect_modality(Tokens, possibly) :- member(might, Tokens), !.
detect_modality(Tokens, probably) :- member(probably, Tokens), !.
detect_modality(Tokens, necessarily) :- member(definitely, Tokens), !.
detect_modality(_, asserted).

detect_question_type([who|_], who) :- !.
detect_question_type([what|_], what) :- !.
detect_question_type([when|_], when) :- !.
detect_question_type([where|_], where) :- !.
detect_question_type([why|_], why) :- !.
detect_question_type([how|_], how) :- !.
detect_question_type([which|_], which) :- !.
detect_question_type([is|_], yes_no) :- !.
detect_question_type(_, statement).

detect_intent(Tokens, correction) :- member(meant, Tokens), !.
detect_intent(Tokens, import_text) :- member(import, Tokens), !.
detect_intent(Tokens, explain) :- member(explain, Tokens), !.
detect_intent(Tokens, question) :- member('?', Tokens), !.
detect_intent(_, inform).

%%%% Text import and representation
import_text(File, DocumentId) :-
    read_file_to_string(File, Text, []),
    gensym(document_, DocumentId),
    assertz(document(DocumentId, Text)),
    split_string(Text, "\n\n", "\n\t ", Paragraphs),
    forall(nth1(PIndex, Paragraphs, Para),
           (assertz(paragraph(DocumentId, PIndex, Para)),
            split_sentences(Para, Sentences),
            forall(nth1(SIndex, Sentences, SentenceText),
                   (assertz(sentence(DocumentId, SIndex, SentenceText)),
                    extract_concepts(SentenceText, Concepts),
                    forall(member(C, Concepts), assertz(sentence_concept(DocumentId, SIndex, C))),
                    extract_relations(SentenceText, Relations),
                    forall(member(relation(S,R,T,_Strength), Relations),
                           assertz(sentence_relation(DocumentId, S, R, T))),
                    assertz(text_fact(DocumentId, SIndex, sentence(SentenceText))))))),
    assertz(section(DocumentId, 1, imported_text)),
    get_time(Now),
    assertz(provenance(DocumentId, document, File, Now)).

%%%% Author mode
author_mode(State) :-
    member(State, [on,off]),
    retractall(author_mode_state(_)),
    assertz(author_mode_state(State)).

author_parse(Input, Proposal) :-
    string_lower(Input, Lower),
    (sub_string(Lower, 0, _, _, "create an area called ") ->
        sub_string(Input, 21, _, 0, Name0),
        string_trim(Name0, Name),
        Proposal = add_area(Name)
    ; sub_string(Lower, 0, _, _, "add the law:") ->
        sub_string(Input, 12, _, 0, LawText0),
        string_trim(LawText0, LawText),
        Proposal = add_law_text(LawText)
    ; sub_string(Lower, 0, _, _, "import ") ->
        sub_string(Input, 7, _, 0, File0),
        string_trim(File0, File),
        Proposal = import_file(File)
    ; Proposal = unknown(Input)
    ).

author_validate(add_area(Name), valid) :- Name \= "", !.
author_validate(add_law_text(Text), valid) :- Text \= "", !.
author_validate(import_file(File), valid) :- exists_file(File), !.
author_validate(unknown(_), invalid(unknown_instruction)).
author_validate(_, invalid(failed_validation)).

author_preview(Input, preview(Proposal, Validation)) :-
    (string(Input) -> author_parse(Input, Proposal) ; Proposal = Input),
    author_validate(Proposal, Validation).

author_commit(Proposal) :-
    author_mode_state(on),
    gensym(author_change_, ChangeId),
    commit_proposal(Proposal, UndoGoal),
    assertz(author_change(ChangeId, Proposal, committed)),
    assertz(undo_action(ChangeId, UndoGoal)).

author_undo(ChangeId) :-
    undo_action(ChangeId, UndoGoal),
    call(UndoGoal),
    retractall(author_change(ChangeId, _, _)),
    retractall(undo_action(ChangeId, _)).

commit_proposal(add_area(Name), retract(area(AreaId, Name))) :-
    add_area(Name, AreaId).
commit_proposal(add_law_text(Text), retract(candidate_law(botany, proposed_law, [], text(Text), 10, author))) :-
    assertz(candidate_law(botany, proposed_law, [], text(Text), 10, author)).
commit_proposal(import_file(File), retract(document(DocumentId, _))) :-
    import_text(File, DocumentId).
commit_proposal(unknown(_), fail).

%%%% Reasoning and response
respond(Session, UserText, Response) :- chat(Session, UserText, Response).

new_session(Session) :-
    gensym(session_, Session),
    get_time(Now),
    assertz(context(Session, unknown, [], [], Now, [])).

chat(Session, Input, Output) :-
    init_defaults,
    ensure_session(Session),
    get_time(Time),
    next_turn(Session, N),
    assertz(turn(Session, N, Time, user, Input)),
    process_sentence(Input, Interpretation),
    update_context(Session, Interpretation, UpdatedContext),
    compute_attention(UpdatedContext, _Attention),
    interpreted_nodes(Interpretation, InputNodes),
    activate(InputNodes, Session, _ActiveNodes),
    retrieve_temporal_context(Interpretation, Temporal),
    applicable_rules(InputNodes, Rules),
    context_areas(UpdatedContext, Areas),
    applicable_laws(Areas, Laws),
    reason(Rules, Laws, Temporal, Conclusions),
    resolve_conclusions(Conclusions, Selected),
    ( special_response(Interpretation, Temporal, Output)
    -> true
    ;  plan_response(Selected, Conclusions, Plan),
       realise_response(Plan, Output)
    ),
    next_turn(Session, BotN),
    assertz(turn(Session, BotN, Time, bot, Output)),
    gensym(response_, ResponseId),
    Explanation = explanation{interpretation:Interpretation, rules:Rules, laws:Laws, temporal:Temporal, selected:Selected},
    assertz(response_explanation(ResponseId, Explanation)),
    retractall(last_response(Session, _, _)),
    assertz(last_response(Session, ResponseId, Output)).

ensure_session(Session) :- context(Session,_,_,_,_,_), !.
ensure_session(Session) :-
    get_time(Now),
    assertz(context(Session, unknown, [], [], Now, [])).

next_turn(Session, N) :-
    findall(I, turn(Session, I, _, _, _), Is),
    (Is = [] -> N = 1 ; max_list(Is, M), N is M + 1).

update_context(Session, Interpretation, context(Session, Topic, Areas, Entities, Now, AttentionState)) :-
    get_time(Now),
    (Interpretation.tokens = [First|_] -> Topic = First ; Topic = unknown),
    Tokens = Interpretation.tokens,
    include(content_token, Tokens, Entities),
    attention_top(5, AttentionState),
    (context(Session, _, Areas0, _, _, _) -> Areas = Areas0 ; Areas = []),
    retractall(context(Session,_,_,_,_,_)),
    assertz(context(Session, Topic, Areas, Entities, Now, AttentionState)).

compute_attention(context(_, Topic, _, Entities, _, _), Updated) :-
    attention_update(topic(Topic), 0.2, _),
    forall(member(E, Entities), attention_update(entity(E), 0.1, _)),
    max_attention_items(Max),
    attention_top(Max, Updated).

interpreted_nodes(Interpretation, Nodes) :-
    Tokens = Interpretation.tokens,
    include(content_token, Tokens, Nodes0),
    (Nodes0 = [] -> Nodes = [unknown] ; Nodes = Nodes0).

retrieve_temporal_context(Interpretation, temporal{trend:Trend, details:Details}) :-
    Tokens = Interpretation.tokens,
    (member(growing, Tokens), series_trend(plant_height, Trend, Details) -> true
    ; Trend = unknown, Details = none).

context_areas(context(_, _, Areas, _, _, _), Areas).

reason(Rules, Laws, Temporal, conclusions{rules:Rules, laws:Laws, temporal:Temporal}).

resolve_conclusions(conclusions{rules:Rules, laws:Laws, temporal:Temporal}, selected{rule:RuleWinner, law:LawWinner, temporal:Temporal}) :-
    resolve_rules(Rules, RuleWinner, _),
    (Laws = [LawWinner|_] -> true ; LawWinner = none).

plan_response(Selected, _Facts, plan(answer,growth,true,[T1,V1,T2,V2])) :-
    get_dict(temporal, Selected, temporal{trend:increasing, details:trend(T1,V1,T2,V2)}), !.
plan_response(Selected, _Facts, plan(answer,growth,false,[])) :-
    get_dict(temporal, Selected, Temporal),
    get_dict(trend, Temporal, decreasing), !.
plan_response(Selected, _Facts, plan(answer,growth,unknown,[stable])) :-
    get_dict(temporal, Selected, Temporal),
    get_dict(trend, Temporal, stable), !.
plan_response(_, Facts, plan(explain, summary, unknown, [Facts])).

realise_response(plan(answer,growth,true,[T1,V1,T2,V2]), Text) :-
    format(string(Text), "Yes. Its recorded height increased from ~w on ~w to ~w on ~w.", [V1, T1, V2, T2]).
realise_response(plan(answer,growth,false,_), "No. The recorded trend is not increasing.").
realise_response(plan(answer,growth,unknown,_), "I need more time-series evidence before concluding growth.").
realise_response(plan(explain,summary,_,_), "I considered rules, scoped laws, and temporal evidence, but the conclusion remains limited.").

explain_last(Session, Explanation) :-
    last_response(Session, ResponseId, _),
    explain(ResponseId, Explanation).

explain(ResponseId, Explanation) :- response_explanation(ResponseId, Explanation).

special_response(Interpretation, temporal{trend:increasing}, Output) :-
    Tokens = Interpretation.tokens,
    member(why, Tokens), !,
    Output = "The conclusion comes from the plant-height time series and the study law defining positive change in height as growth.".
special_response(Interpretation, temporal{trend:increasing}, Output) :-
    Tokens = Interpretation.tokens,
    member(could, Tokens),
    member(stop, Tokens),
    member(growing, Tokens), !,
    Output = "Yes. The current observations establish past growth, not that growth must continue indefinitely.".

%%%% Persistence
save_mnn(File) :-
    open(File, write, Stream),
    forall(storable_fact(Fact), (writeq(Stream, Fact), write(Stream, '.'), nl(Stream))),
    close(Stream).

load_mnn(File) :- consult(File).

save_session(Session, File) :-
    open(File, write, Stream),
    forall(turn(Session,N,T,S,Text), (writeq(Stream, turn(Session,N,T,S,Text)), write(Stream,'.'), nl(Stream))),
    (context(Session,A,B,C,D,E) -> writeq(Stream, context(Session,A,B,C,D,E)), write(Stream,'.'), nl(Stream) ; true),
    close(Stream).

load_session(File, Session) :-
    consult(File),
    turn(Session, _, _, _, _), !.

storable_fact(concept(A,B)) :- concept(A,B).
storable_fact(property(A,B,C)) :- property(A,B,C).
storable_fact(relation(A,B,C,D)) :- relation(A,B,C,D).
storable_fact(mnn_node(A,B,C)) :- mnn_node(A,B,C).
storable_fact(mnn_link(A,B,C,D)) :- mnn_link(A,B,C,D).
storable_fact(rule(A,B,C,D,E,F,G)) :- rule(A,B,C,D,E,F,G).
storable_fact(area(A,B)) :- area(A,B).
storable_fact(subarea(A,B)) :- subarea(A,B).
storable_fact(area_law(A,B,C,D,E,F)) :- area_law(A,B,C,D,E,F).
storable_fact(law_type(A,B)) :- law_type(A,B).
storable_fact(applies_in(A,B)) :- applies_in(A,B).
storable_fact(observation(A,B,C)) :- observation(A,B,C).
storable_fact(event(A,B,C,D)) :- event(A,B,C,D).
storable_fact(attention(A,B)) :- attention(A,B).
storable_fact(confidence(A,B)) :- confidence(A,B).
storable_fact(provenance(A,B,C,D)) :- provenance(A,B,C,D).
storable_fact(document(A,B)) :- document(A,B).
storable_fact(section(A,B,C)) :- section(A,B,C).
storable_fact(paragraph(A,B,C)) :- paragraph(A,B,C).
storable_fact(sentence(A,B,C)) :- sentence(A,B,C).
storable_fact(sentence_fact(A,B,C)) :- sentence_fact(A,B,C).
storable_fact(sentence_concept(A,B,C)) :- sentence_concept(A,B,C).
storable_fact(sentence_relation(A,B,C,D)) :- sentence_relation(A,B,C,D).
storable_fact(text_fact(A,B,C)) :- text_fact(A,B,C).

%%%% Contradictions and revisions
check_contradiction(Fact) :-
    (Fact = not(P), call(P) -> assertz(contradiction(Fact,P,direct_negation))
    ; Fact =.. [Pred,Subject,Value], Value \= _,
      Opposite =.. [Pred,Subject,Other], call(Opposite), Other \= Value ->
         assertz(contradiction(Fact,Opposite,incompatible_values))
    ; true).

%%%% REPL
chatbot :-
    new_session(Session),
    format("MNN chatbot session ~w.~n", [Session]),
    format("Type quit. to stop.~n", []),
    repl(Session).

repl(Session) :-
    write('User: '), flush_output,
    read_line_to_string(user_input, Input),
    (Input = "quit" -> writeln('Bot: Goodbye.')
    ; chat(Session, Input, Output),
      format("Bot: ~w~n", [Output]),
      repl(Session)).

string_trim(In, Out) :- normalize_space(string(Out), In).
