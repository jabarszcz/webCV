#webCV

This is a wip/prototype/start of a tool that simpifies the maintenance
of a resume.

## Why ?

Before this, I had a setup where my resume was written in LaTeX, but
because I need it in two languages and I prefer to keep it in one
file, I had put it all in m4 macros to choose the language. That
solution had no separation of concerns, it was hard to maintain and
its output was mainly for print.

This tool aims to improve on my last setup by having the content of my
resume in an xml file, with xslt transformations for the various
outputs, as needed.

There is also a need to easily make multiple versions of a CV :
emphasizing different areas or varying depth.