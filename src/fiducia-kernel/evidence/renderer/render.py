from renderer.normaliser import normalise_evidence, verify_integrity
from renderer.markdown import render_markdown

def render(evidence: dict) -> dict:
    normalised = normalise_evidence(evidence)

    if not verify_integrity(normalised):
        raise ValueError('Evidence integrity check failed')

    return {
        'json': normalised,
        'markdown': render_markdown(normalised)
    }
