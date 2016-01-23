# webCV

This is a wip/prototype that simpifies the maintenance of a
resume through separation of concerns.

## Motivation

My previous setup was in LaTeX, which give beautiful results but is
not the best to keep presentation separated from data. It is also
primarily good for print and not for online display.

Another requirement is that it must easily allow multiple languages to
coexist in the same file, and accept parameters to vary the presented
content in various ways.

## How it works

The resume data is stored in an xml file. An xslt transformation
translates the data to html, which is then styled with a css
stylesheet.

The xml format does not have an explicit schema yet. It has been
written to follow the format of a LaTeX template inspired from [this
one](http://www.rpi.edu/dept/arc/training/latex/resumes/res2.pdf),
found [here](http://www.rpi.edu/dept/arc/training/latex/resumes/).

