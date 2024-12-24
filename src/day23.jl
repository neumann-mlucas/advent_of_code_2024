using Combinatorics

TEST_INP = """
kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn
"""
TEST_OUT_P1 = 7

const Graph = Dict{String,Set{String}}

function clean_input(inp::String)::Graph
    conn = [split(line, "-") for line in split(strip(inp), "\n")]

    graph = Dict{String,Set{String}}()
    for (a, b) in conn
        push!(get!(graph, a, Set{String}()), b)
        push!(get!(graph, b, Set{String}()), a)
    end
    return graph
end

function find_3_cliques(graph::Graph)::Set{Tuple}
    npairs = combinations(collect(keys(graph)), 2)

    triangles = Set()
    for (a, b) in npairs
        if !(a in graph[b] && b in graph[a])
            continue
        end

        for c in intersect(graph[a], graph[b])
            if a in graph[c] && b in graph[c]
                t = tuple(sort([a, b, c])...)
                push!(triangles, t)
            end
        end
    end
    triangles
end

function get_t_cliques(triangles)
    filter(t -> any(startswith.(t, 't')), triangles)
end

function clustering_coefficient(graph::Graph, node::String)::Float64
    neighbors = vcat(graph[node]...)
    k = length(neighbors)

    if k < 2
        return 0
    end

    actual_edges = 0
    for (a, b) in combinations(neighbors, 2)
        if a in graph[b]
            actual_edges += 1
        end
    end

    max_edges = k * (k - 1) // 2
    actual_edges / max_edges
end

function find_all_connected(graph)
    # all-connected-nodes have the highest clustering coefficient in the problem input
    coefs = [(clustering_coefficient(graph, node), node) for node in keys(graph)]

    max_coef = maximum(c for (c, _) in coefs)
    all_connected = [n for (c, n) in coefs if c == max_coef]

    join(sort(all_connected), ",")
end

day23p1(inp) = clean_input(inp) |> find_3_cliques |> get_t_cliques |> length
day23p2(inp) = clean_input(inp) |> find_all_connected

function main()
    @assert day23p1(TEST_INP) == TEST_OUT_P1

    input = read(open("dat/day23.txt", "r"), String)
    day23p1(input) |> println
    day23p2(input) |> println
end

main()
