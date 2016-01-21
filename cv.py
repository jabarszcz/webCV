#!/usr/bin/python3

import argparse
import os
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--lang", "-l", type=str, default="FR")
parser.add_argument("--privacy", "-p", type=str, default="private")
parser.add_argument("--brevity", "-b", type=int, default=0)
parser.add_argument("--currentdir", "-c", type=str, default=".")

args = parser.parse_args()

cmd = ["xsltproc"]

cmd += ["--stringparam", "language", args.lang]
cmd += ["--stringparam", "privacy", args.privacy]
cmd += ["--stringparam", "brevity", str(args.brevity)]

cmd += ["cvxhtml.xsl", "cv.xml"]


subprocess.call(cmd, cwd=args.currentdir)
