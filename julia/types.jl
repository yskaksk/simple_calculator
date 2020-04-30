abstract type AbstractTokenKind end
struct TkNumber <: AbstractTokenKind end
struct TkReserved <: AbstractTokenKind end
struct TkHEAD <: AbstractTokenKind end
struct TkEOF <: AbstractTokenKind end

abstract type AbstractNodeKind end
struct NdADD <: AbstractNodeKind end
struct NdSUB <: AbstractNodeKind end
struct NdMUL <: AbstractNodeKind end
struct NdDIV <: AbstractNodeKind end
struct NdNUM <: AbstractNodeKind end

mutable struct Token
    kind::AbstractTokenKind
    char::Union{Char, Nothing}
    val::Int
    next::Union{Token, Nothing}
    function Token(kind::AbstractTokenKind)
        new(kind, nothing, 0, nothing)
    end
    function Token(val::Int)
        new(TkNumber(), nothing, val, nothing)
    end
    function Token(c::Char)
        new(TkReserved(), c, 0, nothing)
    end
end

mutable struct TokenStream
    current::Token
end

struct Node
    kind::AbstractNodeKind
    lhs::Union{Node, Nothing}
    rhs::Union{Node, Nothing}
    val::Int
end

Node(val::Int) = Node(NdNUM(), nothing, nothing, val)
Node(kind::AbstractNodeKind, lhs::Node, rhs::Node) = Node(kind, lhs, rhs, 0)
