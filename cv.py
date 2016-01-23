#!/usr/bin/python3

import argparse
import os
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--lang", "-l", type=str, default="FR")
parser.add_argument("--privacy", "-p", type=str, default="private")
parser.add_argument("--brevity", "-b", type=int, default=0)
parser.add_argument("--cvpath", "-p", type=str, default="./cv.xml")
parser.add_argument("--transformpath", "-t", type=str, default="./cvxhtml.xsl")

args = parser.parse_args()

cmd = ["xsltproc"]
cmd += ["--stringparam", "language", args.lang]
cmd += ["--stringparam", "privacy", args.privacy]
cmd += ["--stringparam", "brevity", str(args.brevity)]
cmd += [args.transformpath, args.cvpath]

subprocess.call(cmd)
