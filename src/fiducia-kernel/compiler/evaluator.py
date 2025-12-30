def evaluate_condition(condition: dict, context: dict) -> bool:
    for key, value in condition.items():
        if key not in context:
            return False
        if context[key] != value:
            return False
    return True
