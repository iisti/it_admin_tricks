# Visual Studio Code Instructions

## Set Tab size of Markdown files

File -> Preferences -> Configure User Snippets -> markdown.json

~~~sh
{
	// Place your snippets for markdown here. Each snippet is defined under a snippet name and has a prefix, body and 
	// description. The prefix is what is used to trigger the snippet and the body will be expanded and inserted. Possible variables are:
	// $1, $2 for tab stops, $0 for the final cursor position, and ${1:label}, ${2:another} for placeholders. Placeholders with the 
	// same ids are connected.
	// Example:
	// "Print to console": {
	// 	"prefix": "log",
	// 	"body": [
	// 		"console.log('$1');",
	// 		"$2"
	// 	],
	// 	"description": "Log output to console"
	// }
	"[markdown]": {
		"editor.tabSize": 2
	}
}
~~~

## Set Tab size of Terraform files

1. Ctrl + Shift + P
2. Type: `Open User Settings (JSON)`
3. Add section

	~~~json
	"[terraform]": {
	    "editor.formatOnSave": true,
	    "editor.defaultFormatter": "hashicorp.terraform",
	    "editor.tabSize": 2, // optionally
	  },
	  "[terraform-vars]": {
	    "editor.tabSize": 2 // optionally
	  },
	~~~

## Set title scrollbar size to large

Search ing settings for text below and set `large` instead of `default`.

~~~text
workbench title scrollbar sizing
~~~

## Extensions

### nginx-formatter

* https://marketplace.visualstudio.com/items?itemName=raynigon.nginx-formatter

Format nginx configiration file with key combination `Shift + Alt + F`
