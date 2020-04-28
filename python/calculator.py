import sys

class Token:
    def __init__(self, str="", val=0, right=None):
        self.str = str
        self.val = val
        self.right = right

class TkReserved(Token):
    pass

class TkNumber(Token):
    pass

class TkEOF(Token):
    pass

class TkHead(Token):
    pass

def parse_number(code, ind):
    c = code[ind]
    val = 0
    while c.isdigit():
        val *= 10
        val += int(c)
        ind += 1
        if ind == len(code):
            break
        c = code[ind]
    return val, ind - 1

def parse(code):
    head = TkHead()
    cur = head
    ind = 0
    while ind < len(code):
        c = code[ind]
        if c == " ":
            ind += 1
            continue
        elif c in "+-":
            token = TkReserved(c, 1)
            cur.right = token
            cur = token
            ind += 1
        elif c.isdigit():
            val, ind = parse_number(code, ind)
            token = TkNumber("", val)
            cur.right = token
            cur = token
            ind += 1
    cur.right = TkEOF()

    return head

def consume(op, cur):
    right = cur.right
    if not isinstance(right, TkReserved) or right.str != op:
        return False, right
    return True, right

def expect(op, cur):
    right = cur.right
    if not isinstance(right, TkReserved) or right.str != op:
        raise ValueError(f"記号 : {op} を読み込もうとしましたが、ありませんでした")
    return right

def expect_number(cur):
    right = cur.right
    if not isinstance(right, TkNumber):
        raise ValueError("数値を期待しましたが、ありませんでした")
    return right.val, right

def main():
    code = sys.argv[1]
    head = parse(code)
    num, cur = expect_number(head)
    result = num
    while not isinstance(cur.right, TkEOF):
        ok, tok = consume("+", cur)
        if ok:
            num, cur = expect_number(tok)
            result += num
            continue
        tok = expect("-", cur)
        num, cur = expect_number(tok)
        result -= num
    return result

if __name__ == "__main__":
    r = main()
    print(r)
