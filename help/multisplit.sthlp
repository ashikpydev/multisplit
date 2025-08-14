{smcl}
{* *! version 1.0.0 14aug2025 Ashikur Rahman}
{cmd:help multisplit}
{hline}

{title:Title}

{cmd:multisplit} — Split a multiple-response variable into dummy variables (with label preservation)

{hline}
{title:Syntax}

{p 8 15 2}
{cmd:multisplit} {it:varname}, {cmd:prefix(}{it:string}{cmd:)}

{hline}
{title:Description}

{pstd}
{cmd:multisplit} takes a multiple-response variable (e.g., survey question with codes separated by spaces)
and creates a set of dummy (0/1) variables, one for each unique code in the variable.

{pstd}
If dummy variables from a previous run exist, they are dropped and regenerated.
Variable labels from existing dummies are preserved, so your descriptive labels
(e.g., "Home", "School") remain intact. Any old codes will still be regenerated
even if they no longer appear in the current data (with 0 values).

{hline}
{title:Options}

{dlgtab:prefix(string)}
{pstd}
Specifies the prefix for the dummy variables.
Usually, this will be the same as the name of the main variable.
For example, if your main variable is {cmd:g208}, you would use {cmd:prefix(g208)},
producing variables {cmd:g208_1}, {cmd:g208_2}, etc.

{hline}
{title:Remarks}

{pstd}
This command is useful when working with multiple-response survey data where codes
are stored as space-separated values (e.g., "1 3 6") and you need individual
dummy variables for analysis.

{pstd}
It automates repetitive manual work:
{p 8 12 2}- Drops all existing dummy variables for the main variable.{p_end}
{p 8 12 2}- Preserves and re-applies labels from previous dummies.{p_end}
{p 8 12 2}- Detects any new codes in the updated main variable.{p_end}
{p 8 12 2}- Generates all dummies, even for codes with no current responses.{p_end}

{pstd}
The program works even if there are multiple spaces or tabs between codes.
It handles codes as strings, so both numeric and text codes are supported.

{hline}
{title:Examples}

{pstd}Example 1: Split a multiple-response variable into dummies{p_end}
{cmd:. multisplit g208, prefix(g208)}

{pstd}Example 2: After updating {cmd:g208}, regenerate dummies with preserved labels{p_end}
{cmd:. replace g208 = "1 3" if id == 5}
{cmd:. multisplit g208, prefix(g208)}

{hline}
{title:Stored results}

{pstd}None.

{hline}
{title:Author}

{pstd}
Ashikur Rahman  
Email: ashiqurrahman.stat@gmail.com  
License: Apache License 2.0

{hline}
