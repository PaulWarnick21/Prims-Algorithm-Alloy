 /*
Imports the ordering module to be used with the Time signature below
*/
open util/ordering[Time]

/*
  By including ordering, Time is used to represent each state of the algorithm with the
  initial time (x.first) being before the first step of the algorithm has run and the
  final time (x.last) being the final stage of the algorithm (i.e. Once the MST has been found).
*/
sig Time {}

/*
  The first structural element of model, here we are modelling the nodes in a graph and defining
  a relation "covered" which will represent the set of nodes that have already been added to our tree
  (meaning the nodes that the algorithm has already considered). Additonally, this relation will include
  at which time each node has been covered. For example: Only Node1 might be covered in the
  initial state while the entire set of nodes (Node1, Node2, ... , NodeN) should be covered in the 
  final state.
*/
sig Node {covered: set Time}

/*
  Our second structual element of the model, edges represent a link between two other nodes. For
  the purpose of our algorithm we need each edge to have a weight to represent the value of the
  edge. A real world example could be the length of a highway between two cities. Within the body
  of the signature we specify the weight to be a non-negative integer (as is the requirement of our
  algorithm). Addtionally, we have another relatation "nodes" which represents the two nodes the
  current edge connects. Within the body we specify each edge to have 2 nodes. Finally, another
  relation "chosen" represents at which time state each edge was chosen (i.e. added to the
  tree). For example: There should be no chosen edges in the initial state and the final state of
  chosen should represent our MST.
*/
sig Edge {weight: Int, nodes: set Node, chosen: set Time}  {
    weight >= 0 and #nodes = 2 // Ensures weight is a non-negative int and each edge has 2 nodes
}

/*
  This predicate is used to check whether an edge has one node that is covered and another that
  has not yet been covered (i.e. it's cutting between the set of covered nodes and the set of
  uncovered ones). This is a major aspect of Prim's algorithm as it works of the basis of selecting
  the cutting edge with the least weight at every step. Within the body, the left half of the "and"
  represents the nodes within the covered set at time "t" while the right half represents the set of
  node not in the covered set at time "t".
*/
pred cutting (e: Edge, t: Time) {
    (some e.nodes & covered.t) and (some e.nodes & (Node - covered.t))
}

/*
  The step predicate is used to describe the behaviour of our model at each "step" of the
  algorithm's execution. Here, " t " and " t' " will be used to represent the state of the model in
  consecutive time instances (more detail in "fact prim" below). There are two options within this
  predicate with the first being "Condition One" and the second being "Condition Two".

  Condition One represents the state of the model when the algorithm is finished, specifically, if all the
  nodes have been covered, then the nodes covered at time t' is equal to the nodes covered at time t,
  AND the edge chosen at time t' equals the edge chosen at time t.

  Condition Two represents each state of the model while the algorithm is executing, specifically, the
  edges chosen at time t' is equal to the edges chosen at time t PLUS a "new edge" AND the nodes
  covered at time t' equals the nodes covered at time t PLUS the new node introduced by the new
  edge.
*/
pred step (t, t': Time) {
    // Condition One
    covered.t = Node => 
        chosen.t' = chosen.t and covered.t' = covered.t 
    // Condition Two
    else some e: Edge {
        /*
          Here we use our cutting predicate from above to find the "new edge". We specify this new
          edge has to be a cutting edge AND it there must not be another cutting edge with a smaller
          weight
        */
        cutting[e,t] and (no e2: Edge | cutting[e2,t] and e2.weight < e.weight)
        // The chosen set at time t' is equal to the previous chosen set plus our above edge "e"
        chosen.t' = chosen.t + e
        // The nodes covered at time t' equals the previously covered nodes plus the nodes of "e"
        covered.t' = covered.t + e.nodes}
}

/*
  Here we list all of the constraints to ensure our model behaves to the specifications of Prim's
  algorithm. The first constraint tells Alloy that the initial state of the covered set should contain only
  one element (i.e. our starting node) and that the initial state of the chosen set should be empty (we
  haven't chosen any edges yet). The second constraint specifies that all pairs of consecutive time
  instances (t and t.next) satisfy the step predicate. Lastly, the final constraint tells Alloy that in the
  final state, all of the nodes in our graph should be covered.
*/
fact prim {
    one covered.first and no chosen.first
    all t: Time - last | step[t, t.next]
    covered.last = Node
}

// The below section is used to test our code to ensure we've properly modelled Prim's algorithm

/*
  First we need to ensure our model generates a spanning tree such that:
   - (First Condition) The final set of chosen nodes must match the set of all nodes
   - (Second Condition) The tree must contain the smallest number of edges possible, specifically,
     the total number number of edges is ones less then the number of nodes in the graph
   - (Third Condition) All nodes are reachable by every other node
*/
pred spanningTree (edges: set Edge) {
    // First Condition
    (one Node and no Edge) => no edges else edges.nodes = Node
    // Second Condition
    #edges = (#Node).minus[1]
    // Third Condition
    let adj = {a, b: Node | some e: edges | a + b in e.nodes} |
       Node -> Node in *adj
}

/*
  We check that the previous predicate holds for the final state of the chosen nodes (limited scope)
*/
correct: check { spanningTree [chosen.last] } for 5 but 10 Edge, 5 Int

/*
  Secondly, we need to ensure the model generates a Minimal Spanning Tree (MST). We check
  that for all combinations of edges that satisfy a spanning tree, none exist with a total weight sum
  less then the total edge weight sum of our selected "chosen" edges. Notice again we've specified
  a limited scope: **This operation is very robust and takes around 20 minutes to complete**
*/
smallest: check {
    no edges: set Edge { 
        spanningTree[edges]
        (sum e: edges | e.weight) < (sum e: chosen.last | e.weight)}
} for 5 but 10 Edge, 5 Int

