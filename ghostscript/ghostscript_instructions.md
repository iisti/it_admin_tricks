# How to use Ghostscript

## Merge multiple PDFs into one
### Windows PowerShell instructions
1. Install Ghostscript
1. In PowerShell go into the directory where the PDFs are.
1. To merge PDFs run something similar as below:
    ~~~
    gswin64 -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="merged.pdf" "pdf01.pdf" "pdf02.pdf" "pdf03.pdf"
    ~~~ 
