import hashlib

def get_partial_sha256_hash(input_string, length=8):
    sha256_hash = hashlib.sha256(input_string.encode()).hexdigest()
    return sha256_hash[:length]

def get_hashed_snake_case(camel_str):
    if camel_str is None:
        raise ValueError("camel_str cannot be None")
    hash = get_partial_sha256_hash(camel_str)
    camel_str = camel_str.replace(" ", "_")
    return camel_str + "___" + hash
