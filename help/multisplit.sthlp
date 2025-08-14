{smcl}
{* *! version 1.3.0 14aug2025 Ashiqur Rahman Rony}
{cmd:help multisplit}
{hline}

{title:Title}

{cmd:multisplit} — Split a multiple-response variable into dummy variables with label preservation

{hline}
{title:Syntax}

{pstd}
{cmd:multisplit} {it:varname} [, {cmd:prefix(}{it:string}{cmd:)}}]

{hline}
{title:Description}

{pstd}
{cmd:multisplit} takes a multiple-response variable (e.g., a survey question with space-separated codes) and generates dummy variables (0/1) for each unique code.  

Existing dummy variables are dropped and regenerated. Labels from previous dummies are preserved. Dummy variables are initialized as missing (.) and then set to 1/0 for valid cases.

{hline}
{title:Options}

{dlgtab:prefix(string)}
Specifies the prefix for dummy variables. If omitted, the main variable name is used.

{hline}
{title:Remarks}

{pstd}
Useful for multiple-response survey data where codes are space-separated (e.g., "1 3 6").  

This command automates repetitive tasks:

{p 8 12 2}- Drops existing dummy variables.  
{p 8 12 2}- Preserves and reapplies labels.  
{p 8 12 2}- Detects new codes in the main variable.  
{p 8 12 2}- Generates all dummies, including codes with no current responses.  
{p 8 12 2}- Initializes dummies as missing (.) and then replaces with 1/0 for valid cases.

Works with multiple spaces/tabs and supports both numeric and string codes.

{hline}
{title:Examples}

{pstd}
Split variable using default prefix (same as variable name):
{cmd:. multisplit g208}

Split variable with a custom prefix:
{cmd:. multisplit g208, prefix(home)}

Update values and regenerate dummies with preserved labels:
{cmd:. replace g208 = "1 3" if id == 5}
{cmd:. multisplit g208}

{hline}
{title:Stored results}

{pstd}None.

{hline}
{title:Author}

{pstd}
Ashiqur Rahman Rony  
Email: ashiqurrahman.stat@gmail.com  
License: Apache License 2.0

{hline}
