import sys
import math
from enum import Enum, auto

class Token:
    def __init__(self, kind, str="", val=0, right=None):
        self.kind = kind
        self.str = str
        self.val = val
        self.right = right


class TokenKind(Enum):
    Reserved = auto()
    Number = auto()
    EOF = auto()
    HEAD = auto()


class TokenStream:

    def __init__(self, code):
        self.code = code

        self.head = self.parse(code)
        self.current = self.head

    @property
    def next(self):
        return self.current.right

    @property
    def kind(self):
        return self.current.kind

    def forward(self):
        self.current = self.next

    @property
    def is_last(self):
        return self.next.kind == TokenKind.EOF

    def parse_number(self, code, ind):
        c = code[ind]
        val = 0
        while c.isdigit():
            val *= 10
            val += int(c)
            ind += 1
            if ind == len(code):
                break
            c = code[ind]
        return val, ind

    def parse(self, code):
        head = Token(TokenKind.HEAD)
        cur = head
        ind = 0
        while ind < len(code):
            c = code[ind]
            if c == " ":
                ind += 1
                continue
            elif c in "+-/*()^":
                token = Token(TokenKind.Reserved, c)
                cur.right = token
                cur = token
                ind += 1
            elif c.isdigit():
                val, ind = self.parse_number(code, ind)
                token = Token(TokenKind.Number, "", val)
                cur.right = token
                cur = token
        cur.right = Token(TokenKind.EOF)
        return head

    def consume(self, op):
        right = self.next
        if right.kind != TokenKind.Reserved or right.str != op:
            return False
        self.forward()
        return True

    def expect(self, op):
        right = self.next
        if right.kind != TokenKind.Reserved or right.str != op:
            raise ValueError(f"記号 : {op} を読み込もうとしましたが、ありませんでした")
        self.forward()

    def expect_number(self):
        right = self.next
        if right.kind != TokenKind.Number:
            raise ValueError("数値を期待しましたが、ありませんでした")
        self.forward()
        return right.val


class Node:
    def __init__(self, kind, lhs, rhs, val=None):
        self.kind = kind
        self.lhs = lhs
        self.rhs = rhs
        self.val = val


class NodeKind(Enum):
    ADD = auto()
    SUB = auto()
    MUL = auto()
    DIV = auto()
    NUM = auto()
    POW = auto()

def calculate(node):
    if node.kind == NodeKind.NUM:
        return node.val

    l = calculate(node.lhs)
    r = calculate(node.rhs)

    if node.kind == NodeKind.ADD:
        return l + r
    elif node.kind == NodeKind.SUB:
        return l - r
    elif node.kind == NodeKind.MUL:
        return l * r
    elif node.kind == NodeKind.DIV:
        return l / r
    else: # node.kind == NodeKind.POW
        return math.pow(l, r)

# expression : add
def expression(token_stream):
    return add(token_stream)

# add     : mul ("+" mul | "-" mul)*
def add(token_stream):
    node = mul(token_stream)

    while True:
        if token_stream.consume("+"):
            node = Node(NodeKind.ADD, node, mul(token_stream))
        elif token_stream.consume("-"):
            node = Node(NodeKind.SUB, node, mul(token_stream))
        else:
            return node

# mul     : unary ("*" unary | "/" unary)*
def mul(token_stream):
    node = unary(token_stream)

    while True:
        if token_stream.consume("*"):
            node = Node(NodeKind.MUL, node, unary(token_stream))
        elif token_stream.consume("/"):
            node = Node(NodeKind.DIV, node, unary(token_stream))
        else:
            return node

# unary : ("+" | "-")? unary | primary
def unary(token_stream):
    if token_stream.consume("+"):
        return unary(token_stream)
    if token_stream.consume("-"):
        return Node(NodeKind.SUB, Node(NodeKind.NUM, None, None, 0), unary(token_stream))
    return power(token_stream)

# power : primary ("^" primary)?
def power(token_stream):
    node = primary(token_stream)
    if token_stream.consume("^"):
        return Node(NodeKind.POW, node, primary(token_stream))
    return node

# primary : number | "(" expr ")"
def primary(token_stream):
    if token_stream.consume("("):
        node = expression(token_stream)
        token_stream.expect(")")
        return node
    number = token_stream.expect_number()
    return Node(NodeKind.NUM, None, None, number)


def main():
    code = sys.argv[1]
    tokens = TokenStream(code)
    node = expression(tokens)
    r =  calculate(node)
    print(r)


if __name__ == "__main__":
    main()
