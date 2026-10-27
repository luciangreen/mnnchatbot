# MNN Format

Primary inspectable structures:
- `mnn_node(Node, Type, Data)`
- `mnn_link(Source, Relation, Target, Strength)`
- `activation(Context, Node, Weight)`
- `concept/2`, `property/3`, `relation/4`

Links are followed in a breadth-first traversal. Seed nodes start at weight `1.0`; each traversed link multiplies the current weight by its strength. A node is not revisited at an equal or greater depth, and activation stops at the configured depth, threshold, or node-count bound.

Activation controls:
- `max_activation_depth/1`
- `activation_threshold/1`
- `max_active_nodes/1`

Inspect one traversal with `activation_trace(InputNodes, Trace)` or record activations for a context with `activate(InputNodes, Context, Nodes)`. Use `learn_relation/4` to add a weighted link with provenance, or assert `mnn_link/4` directly when bootstrapping test data.

Other related facts include `confidence/2`, `contradiction/3`, `supersedes/2`, and `provenance/4`. Contradiction and supersession facts are storage structures; automatic belief revision is not yet implemented.

`save_mnn/1` persists the supported fact families listed in `storable_fact/1`; it does not persist transient activation traces, session turns, or all runtime state. `load_mnn/1` consults the resulting Prolog file.
