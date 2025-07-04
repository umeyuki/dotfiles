def add(a, b):
    """2つの数を加算する"""
    return a + b

def subtract(a, b):
    """2つの数を減算する"""
    return a - b

def multiply(a, b):
    """2つの数を乗算する"""
    return a * b

def divide(a, b):
    """2つの数を除算する"""
    if b == 0:
        raise ValueError("Division by zero is not allowed")
    return a / b