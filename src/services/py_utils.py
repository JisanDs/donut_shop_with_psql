import re
import os
import sys
import ctypes


BASH_DIR = os.path.dirname(os.path.abspath(__file__))
clib_path = os.path.join(BASH_DIR, "hasher.so") # find full path of the shared object file
hasher = ctypes.CDLL(clib_path) # load file from the path

hasher.make_hased.argtypes = [ctypes.c_char_p] # this is passing argument type (C character pointer) of the C function
hasher.make_hased.restype = ctypes.c_int # this is the return type (C integer) of the C function


def make_hash(passwd: str) -> int:
    encode_pass = passwd.encode('utf-8')
    return hasher.make_hased(encode_pass)


def is_email(email: str) -> bool:
    pattrn = r"^(?:[a-zA-Z0-9_.#$%&'*/=?^`{|}\-~])+@(?:[a-zA-Z0-9])+\.(?:[a-zA-Z0-9]){2,}$"
    if re.search(pattrn, email):
        return True
    return False


def is_valid_passwd(passwd: str) -> bool:
    if len(passwd) <= 8:
        return False
    pattrn = r"^(?=.*\d+)(?=.*[a-z]+)(?=.*[A-Z]+)(?=.[_.#$%&'*/=?^`{|}\-~]*)(?!.*password).{8,}$"
    if re.search(pattrn, passwd):
        return True
    return False
