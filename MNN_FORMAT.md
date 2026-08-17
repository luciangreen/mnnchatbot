# MNN Format

Primary inspectable structures:
- `mnn_node(Node, Type, Data)`
- `mnn_link(Source, Relation, Target, Strength)`
- `activation(Context, Node, Weight)`
- `concept/2`, `property/3`, `relation/4`

Activation controls:
- `max_activation_depth/1`
- `activation_threshold/1`
- `max_active_nodes/1`
