{smcl}
{* *! version 1.2.0 14aug2025 Ashikur Rahman}
{cmd:help multisplit}
{hline}

{title:Title}

{cmd:multisplit} — Split a multiple-response variable into dummy variables

{hline}
{title:Syntax}

{pstd}
{cmd:multisplit} {it:varname} [, {cmd:prefix(}{it:string}{cmd:)}]

{hline}
{title:Description}

{pstd}
{cmd:multisplit} takes a multiple-response variable (e.g., a survey question with codes separated by spaces) and creates dummy variables (0/1) for each unique code.

Existing dummy variables are dropped and regenerated. Labels from previous dummies are preserved.

{hline}
{title:Options}

{pstd}
{cmd:prefix(string)} — Prefix for dummy variables. Default is the same as the main variable name.

{hline}
{title:Remarks}

{pstd}
Useful for multiple-response survey data where codes are space-separated (e.g., "1 3 6").

It automates manual tasks:

{p 8 12 2}- Drops existing dummy variables.
{p 8 12 2}- Preserves and reapplies labels.
{p 8 12 2}- Detects new codes.
{p 8 12 2}- Generates all dummies, even if code has no responses.

Works with multiple spaces/tabs and both numeric and string codes.

{hline}
{title:Examples}

{pstd}
Split variable using default prefix:
{cmd:. multisplit g208}

Split variable with custom prefix:
{cmd:. multisplit g208, prefix(home)}

Update values and regenerate dummies:
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
