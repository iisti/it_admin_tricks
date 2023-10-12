# How to convert PDF to docx with pdf2docx

* https://github.com/dothinking/pdf2docx

## WSL installation
* Installation
    ~~~
    sudo apt install python3 python3-pip
    pip3 install pdf2docx
    ~~~

* Error when installing pdf2docx
    ~~~ 
    error: command 'x86_64-linux-gnu-gcc' failed with exit status 1
    ~~~
    * Similar to this https://github.com/pymupdf/PyMuPDF/issues/358
    * Fix
        ~~~
        pip3 install --upgrade pip
        pip3 install pdf2docx
        ~~~

## Usage of pdf2docx cli
    ~~~
    pdf2docx convert document.pdf document.docx
    Parsing Page 3: 3/3...
    Creating Page 3: 3/3...
    --------------------------------------------------
    Terminated in 0.7371879999991506s.
    ~~~
