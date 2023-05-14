#!/usr/bin/env python3

import re
import sys
import base64

def decode(string, pattern, match):
    """Decode base64 to an URL"""
    result = ''
    while (match == None):
        url = base64.b64decode(string).decode('utf-8')
        match = re.search(pattern, url)
        if (match != None):
            result = match.string
        else:
            clean = re.sub(r'\(.+\)', '', url)
            string = clean
    return result

def main():
    if (len(sys.argv)) == 1:
        string = input("Enter base64 encoded string: ")
    else:
        string = sys.argv[1]
    pattern=r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)" # Pattern to match URL
    print(f"URL: {decode(string, pattern, None)}")

if __name__=="__main__":
    main()
