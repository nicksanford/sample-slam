#!/usr/bin/env python3
import base64
import sys

while line := sys.stdin.readline():
    sys.stdout.buffer.write(base64.b64decode(line))
