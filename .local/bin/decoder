#!/usr/bin/env python3

import re
import base64

def decode(string, pattern, match):
    """Decode base64 to an URL"""
    while (match == None):
        url = base64.b64decode(string).decode('utf-8')
        match = re.search(pattern, url)
        if (match != None):
            print(f"URL: {match.string}")
        else:
            clean = re.sub(r'\(.+\)', '', url)
            string = clean

string = input("Enter base64 decoded string: ")
pattern=r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)" # Pattern to match URL

decode(string, pattern, None)
