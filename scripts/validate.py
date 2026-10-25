from pathlib import Path
from tree_sitter import Language, Parser
import tree_sitter_swift
import plistlib
parser = Parser(Language(tree_sitter_swift.language()))
for p in [*Path('NightOwl').glob('*.swift'), *Path('Tests').glob('*.swift')]:
    root=parser.parse(p.read_bytes()).root_node
    assert not root.has_error, f'Swift syntax error in {p}: {root}'
    print('PASS syntax:',p)
info=plistlib.loads(Path('NightOwl/Info.plist').read_bytes())
assert info['CFBundleExecutable']=='NightOwl'
assert info['MinimumOSVersion']=='16.0'
print('PASS iPhone app metadata')
