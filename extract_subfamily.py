#!/usr/bin/env python

from fontTools import ttLib
from fontTools.varLib import instancer
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('input', help="input file")
parser.add_argument('output', help="output file")
parser.add_argument('subfamily', help="subfamily to extract")

args = parser.parse_args()

varfont = ttLib.TTFont(args.input)
name = varfont["name"]
for instance in varfont["fvar"].instances:
    if name.getDebugName(instance.subfamilyNameID) == args.subfamily:
        partial = instancer.instantiateVariableFont(varfont,
                                                    instance.coordinates)
        partial.save(args.output)
        exit(0)

print(f"Not found {args.subfamily} in {args.input}. Possible subfamilies:")
for instance in varfont["fvar"].instances:
    print(f" * {name.getDebugName(instance.subfamilyNameID)}")
exit(1)
