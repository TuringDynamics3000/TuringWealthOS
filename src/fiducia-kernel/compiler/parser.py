import yaml
from ast import Rule

def parse_rules(path: str):
    with open(path, 'r') as f:
        raw = yaml.safe_load(f)

    rules = []
    for r in raw.get('rules', []):
        rules.append(
            Rule(
                id=r['id'],
                condition=r['when'],
                outcome=r['then']
            )
        )
    return rules
