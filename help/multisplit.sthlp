*-------------------------------------------------------
* multisplit.sthlp
* Help file for multisplit.ado
*-------------------------------------------------------

TITLE
    multisplit — Split multiple-response variables into dummies

SYNOPSIS
    multisplit varname [repeatnum]

DESCRIPTION
    multisplit creates dummy variables for multiple-response variables.
    It handles numeric or string responses and supports repeat groups.
    Existing dummies and labels are preserved.

    Optionally, a repeat number can be provided to indicate
    repeated variables in a survey.

EXAMPLES
    * Simple multiple-response split
    . multisplit hhr_occu_1

    * With repeat group
    . multisplit hhr_occu_2 2

FEATURES
    - Automatically splits space/tab-delimited multiple responses
    - Preserves existing dummy variables and labels
    - Updates dummies when main variable changes
    - Supports repeat group variables
    - Automatically orders variables: existing dummies first, new dummies next
    - Generates informative variable labels

AUTHOR
    Ashiqur Rahman Rony
    Email: ashiqurrahman.stat@gmail.com

VERSION
    1.6.2

NOTES
    Ensure the main variable is correctly cleaned (trim spaces or tabs).
    Dummies are numeric (0/1).
