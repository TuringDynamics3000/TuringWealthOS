from compiler.parser import parse_rules
from compiler.compiler import compile_rules

def load_authority_engine(dsl_path: str):
    rules = parse_rules(dsl_path)
    return compile_rules(rules)
