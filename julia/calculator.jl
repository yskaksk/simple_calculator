abstract type AbstractTokenKind end
struct TkNumber <: AbstractTokenKind end
struct TkReserved <: AbstractTokenKind end
struct TkHEAD <: AbstractTokenKind end
struct TkEOF <: AbstractTokenKind end

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

function token_head()::Token
    return Token(TkHEAD())
end

function token_eof()::Token
    return Token(TkEOF())
end

function parse_number(code::Vector{Char}, ind::Int)
    c = code[ind]
    val = 0
    while isdigit(c)
        val *= 10
        val += parse(Int, c)
        ind += 1
        if ind > length(code)
            break
        end
        c = code[ind]
    end
    return val, ind
end

function parse_code(code::Vector{Char})::Token
    head = token_head()
    cur = head
    ind = 1
    while ind <= length(code)
        c = code[ind]
        if c == ' '
            ind += 1
            continue
        elseif c in ['+', '-']
            cur.next = Token(c)
            cur = cur.next
            ind += 1
            continue
        elseif isdigit(c)
            val, ind = parse_number(code, ind)
            cur.next = Token(val)
            cur = cur.next
            continue
        end
    end
    cur.next = token_eof()
    return head
end

function consume(op::Char, cur::Token)::Bool
    next = cur.next
    if !(next.kind isa TkReserved) || next.char != op
        return false
    end
    return true
end

function expect(op::Char, cur::Token)::Nothing
    next = cur.next
    if !(next.kind isa TkReserved) || next.char != op
        error("$op を読み込めませんでした")
    end
end

function expect_number(cur::Token)
    next = cur.next
    if !(next.kind isa TkNumber)
        error("数値をよみこめませんでした")
    end
    return next.val
end

function main()
    code = ARGS[1] |> Vector{Char}
    head = parse_code(code)
    result = expect_number(head)
    cur = head.next
    while !(cur.next.kind isa TkEOF)
        plus = consume('+', cur)
        if plus
            cur = cur.next
            val = expect_number(cur)
            result += val
            cur = cur.next
            continue
        end
        expect('-', cur)
        cur = cur.next
        val = expect_number(cur)
        result -= val
        cur = cur.next
    end
    print(result)
end

main()
