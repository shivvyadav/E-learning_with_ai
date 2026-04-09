from pathlib import Path

path = Path('lib/features/profile/screens/profile_screen.dart')
text = path.read_text(encoding='utf-8')

def check_balance(s, open_c, close_c):
    count = 0
    for i, ch in enumerate(s):
        if ch == open_c:
            count += 1
        elif ch == close_c:
            count -= 1
        if count < 0:
            return False, i
    return count == 0, None

for pair in [('(', ')'), ('{', '}'), ('[', ']')]:
    ok, pos = check_balance(text, pair[0], pair[1])
    print(pair, ok, pos)
