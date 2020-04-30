include("types.jl")

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
        elseif c in ['+', '-', '*', '/', '(', ')']
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

function calculate(node::Node)
    if node.kind isa NdNUM
        return node.val
    end
    l = calculate(node.lhs)
    r = calculate(node.rhs)
    if node.kind isa NdADD
        return l + r
    elseif node.kind isa NdSUB
        return l - r
    elseif node.kind isa NdMUL
        return l * r
    else # if node.kind isa NdDIV
        return l / r
    end
end

function expression!(ts::TokenStream)::Node
    return add!(ts)
end

function add!(ts::TokenStream)::Node
    node = mul!(ts)
    while true
        if consume('+', ts.current)
            ts.current = ts.current.next
            node = Node(NdADD(), node, mul!(ts))
        elseif consume('-', ts.current)
            ts.current = ts.current.next
            node = Node(NdSUB(), node, mul!(ts))
        else
            break
        end
    end
    return node
end

function mul!(ts::TokenStream)::Node
    node = unary!(ts)
    while true
        if consume('*', ts.current)
            ts.current = ts.current.next
            node = Node(NdMUL(), node, unary!(ts))
        elseif consume('/', ts.current)
            ts.current = ts.current.next
            node = Node(NdDIV(), node, unary!(ts))
        else
            break
        end
    end
    return node
end

function unary!(ts::TokenStream)::Node
    if consume('+', ts.current)
        ts.current = ts.current.next
        return unary!(ts)
    elseif consume('-', ts.current)
        ts.current = ts.current.next
        return Node(NdSUB(), Node(0), unary!(ts))
    else
        return primary!(ts)
    end
end

function primary!(ts::TokenStream)::Node
    if consume('(', ts.current)
        ts.current = ts.current.next
        node = expression!(ts)
        try
            expect(')', ts.current)
        catch
            error("カッコの数が一致しません")
        end
        ts.current = ts.current.next
        return node
    end
    val = expect_number(ts.current)
    ts.current = ts.current.next
    return Node(val)
end

function main()
    ARGS[1] |> Vector{Char} |> parse_code |> TokenStream |> expression! |> calculate |> print
end

main()
