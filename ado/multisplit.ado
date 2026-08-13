*! version 1.6.5
*! multisplit.ado
*! Author: Ashiqur Rahman Rony
*! Description: Robust multiple-response split into dummies with repeat groups,
*!              preserving existing dummies and automatic ordering.
*!              v1.6.4: fixed crash when a response code is negative (e.g. -888),
*!              since Stata variable names cannot contain "-". Negative codes are
*!              mapped to a double-underscore suffix for variable naming only
*!              (e.g. -888 -> hhr_occu_1__888); matching, labels, and summaries
*!              still use the real code (-888).
*!              v1.6.5: fixed a label-preservation bug where packing all existing
*!              dummy labels into one macro (space list + char(1) delimiter) could
*!              truncate a label at its first space. Labels are now stored in
*!              individually-indexed locals (no packing/parsing), so full label
*!              text is always preserved exactly.
capture program drop multisplit
program define multisplit
    version 17.0

    * ----------------------------
    * Parse arguments
    * ----------------------------
    args mainvar repeatnum

    * Determine prefix
    if "`repeatnum'" == "" {
        local prefix "`mainvar'"
    }
    else {
        local prefix = subinstr("`mainvar'", "_`repeatnum'", "", .)
    }

    * ----------------------------
    * Save existing dummy labels
    * (stored as individually-indexed locals, not packed into one macro,
    *  so label text with spaces/punctuation can never be truncated)
    * ----------------------------
    local nlab = 0
    local othlist ""
    unab allvars : *
    foreach v of local allvars {
        if "`repeatnum'" == "" {
            if regexm("`v'", "^`prefix'__?[0-9]+$") {
                local lbl : var label `v'
                local suffix : subinstr local v "`prefix'_" "", all
                * translate double-underscore suffix back to actual code (_888 -> -888)
                if substr("`suffix'",1,1) == "_" {
                    local suffix = "-" + substr("`suffix'", 2, .)
                }
                local nlab = `nlab' + 1
                local labcode`nlab' "`suffix'"
                local lablabel`nlab' `"`lbl'"'
            }
            else if regexm("`v'", "^`prefix'oth.*") {
                local othlist "`othlist' `v'"
            }
        }
        else {
            if regexm("`v'", "^`prefix'__?[0-9]+_`repeatnum'$") {
                local lbl : var label `v'
                local suffix : subinstr local v "`prefix'_" "", all
                local suffix : subinstr local suffix "_`repeatnum'" "", all
                * translate double-underscore suffix back to actual code (_888 -> -888)
                if substr("`suffix'",1,1) == "_" {
                    local suffix = "-" + substr("`suffix'", 2, .)
                }
                local nlab = `nlab' + 1
                local labcode`nlab' "`suffix'"
                local lablabel`nlab' `"`lbl'"'
            }
            else if regexm("`v'", "^`prefix'oth.*_`repeatnum'$") {
                local othlist "`othlist' `v'"
            }
        }
    }

    * ----------------------------
    * Preserve existing dummies
    * ----------------------------
    local existdummies ""
    foreach v of local allvars {
        if "`repeatnum'" == "" {
            if regexm("`v'", "^`prefix'__?[0-9]+$") | regexm("`v'", "^`prefix'oth.*") local existdummies "`existdummies' `v'"
        }
        else {
            if regexm("`v'", "^`prefix'__?[0-9]+_`repeatnum'$") | regexm("`v'", "^`prefix'oth.*_`repeatnum'$") local existdummies "`existdummies' `v'"
        }
    }

    * ----------------------------
    * Generate unique numeric codes
    * ----------------------------
    tempvar temp isblank

    * --- FIX for numeric mainvar ---
    capture confirm string variable `mainvar'
    if _rc {
        gen strL `temp' = string(`mainvar')
        gen byte `isblank' = missing(`mainvar')          // numeric missing -> blank
    } 
    else {
        gen strL `temp' = `mainvar'
        replace `temp' = subinstr(`temp', char(9),   " ", .)   // tabs -> space
        replace `temp' = subinstr(`temp', char(160), " ", .)   // NBSP -> space
        replace `temp' = trim(`temp')
        gen byte `isblank' = `temp' == ""                     // empty after cleaning
    }

    levelsof `temp', local(rows)
    local codes ""
    foreach row of local rows {
        tokenize "`row'"
        while "`1'" != "" {
            capture confirm number `1'
            if !_rc {
                if strpos(" `codes' ", " `1' ") == 0 {
                    local codes "`codes' `1'"
                }
            }
            macro shift
        }
    }
    local codes : list sort codes

    * ----------------------------
    * Generate/update dummy variables
    * ----------------------------
    local newdummies ""
    foreach code of local codes {

        * Build a Stata-safe suffix for the variable name.
        * Stata variable names cannot contain "-", so a leading "-" is
        * replaced with "_" (e.g. code -888 -> suffix _888, giving
        * varname prefix__888). The real `code' (e.g. -888) is still used
        * for matching against `mainvar' and for labeling.
        if substr("`code'", 1, 1) == "-" {
            local safecode = "_" + substr("`code'", 2, .)
        }
        else {
            local safecode "`code'"
        }

        if "`repeatnum'" == "" {
            local varname `prefix'_`safecode'
        }
        else {
            local varname `prefix'_`safecode'_`repeatnum'
        }

        capture confirm variable `varname'
        if _rc {
            gen byte `varname' = 0
        }
        replace `varname' = 1 if regexm(" " + `mainvar' + " ", "( |^)`code'( |$)")
        replace `varname' = . if `isblank'                        // ensure blank -> .
        local newdummies "`newdummies' `varname'"

        * Apply saved label (look up by code among the indexed locals)
        local foundlbl ""
        forvalues i = 1/`nlab' {
            if "`labcode`i''" == "`code'" {
                local foundlbl `"`lablabel`i''"'
            }
        }

        if `"`foundlbl'"' != "" {
            label var `varname' `"`foundlbl'"'
        }
        else {
            if "`repeatnum'" == "" {
                label var `varname' "`prefix' : Code `code'"
            }
            else {
                label var `varname' "`prefix' : Code `code' (Repeat `repeatnum')"
            }
        }
    }

    * ----------------------------
    * Reset/update all old dummies according to current mainvar
    * ----------------------------
    foreach v of local existdummies {
        capture confirm variable `v'
        if !_rc {
            * check storage type
            capture confirm numeric variable `v'
            if !_rc {
                local code = subinstr("`v'", "`prefix'_","",.)
                if "`repeatnum'" != "" local code = subinstr("`code'", "_`repeatnum'","",.)

                * translate double-underscore code back to actual code (_888 -> -888)
                * before matching against `mainvar'
                if substr("`code'", 1, 1) == "_" {
                    local code = "-" + substr("`code'", 2, .)
                }

                replace `v' = 0
                replace `v' = 1 if regexm(" " + `mainvar' + " ", "( |^)`code'( |$)")
                replace `v' = . if `isblank'                    // ensure blank -> .
            }
            else {
                * if string → skip (don't overwrite string vars like g208_oths)
                continue
            }
        }
    }

    * ----------------------------
    * Order: existing dummies first, then new, after main variable
    * ----------------------------
    local allorder "`existdummies' `newdummies'"
    order `allorder', after(`mainvar')

    * Drop temp variable(s)
    drop `temp' `isblank'

    * ----------------------------
    * Summary of changes
    * ----------------------------
    di "-------------------------------"
    di "Multisplit completed for variable: `mainvar'"
    di "Existing dummies preserved: `existdummies'"
    di "New dummies created: `newdummies'"
    local totaldummies : word count `allorder'
    di "-------------------------------"

end
