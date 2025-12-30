import requests

def anchor_to_redbelly(merkle_root: str, endpoint: str) -> str:
    payload = { 'merkle_root': merkle_root }
    resp = requests.post(endpoint, json=payload, timeout=10)

    if resp.status_code != 200:
        raise RuntimeError('RedBelly anchor failed')

    return resp.json().get('tx_reference')
