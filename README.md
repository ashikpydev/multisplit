# multisplit.ado

**Author:** Ashiqur Rahman Rony
**Email:** ashiqurrahman.stat@gmail.com
**Version:** 1.6.2  
**Description:** Stata program to split multiple-response variables into dummy variables (0/1), with support for repeat groups.

---

## Install
```stata
net install multisplit, from("https://raw.githubusercontent.com/ashikpydev/multisplit/main/") replace
*For help
help multisplit
```
## Features

- Splits multiple-response variables automatically
- Works with numeric or string variables
- Preserves existing dummies and labels
- Updates dummy variables if values are removed from main variable
- Handles repeat groups (`repeatnum`)
- Orders existing dummies first, then new dummies
- Cleans tabs/spaces automatically in main variable
- Labels new dummies with code information

---

## Installation

Copy `multisplit.ado` into your Stata ADO directory.

---

## Usage

```stata
* Basic usage
. multisplit varname

* With repeat number
. multisplit varname repeatnum

Example

```stata
* Split household occupation codes
. multisplit hhr_occu_1

* Split repeat group 2 of household occupation
. multisplit hhr_occu_2 2
---

Notes

- Ensure the main variable is clean (no extra tabs or leading/trailing spaces).
- Dummies are numeric (0/1).
- Existing dummies are preserved and automatically updated.
- Combined codes like "6 99" are correctly split into individual dummy variables.

