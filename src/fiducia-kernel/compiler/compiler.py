from compiler.evaluator import evaluate_condition

def compile_rules(rules):
    def authority(context: dict):
        reasons = []
        outcome = 'PERMIT'

        for rule in rules:
            if evaluate_condition(rule.condition, context):
                reasons.append({
                    'rule_id': rule.id,
                    'outcome': rule.outcome
                })
                if rule.outcome == 'DENY':
                    outcome = 'DENY'

        return {
            'outcome': outcome,
            'reasons': reasons
        }

    return authority
