*! version 1.1.0
*! multisplit.ado
*! Author: Ashiqur Rahman Rony
*! Description: Split multiple response variable into dummies

capture program drop multisplit
program define multisplit
    version 17.0

    * Parse main variable, optional prefix
    syntax varname [if] [in], [PREFIX(string)]

    local mainvar "`varlist'"

    * Use variable name as prefix if PREFIX not provided
    if "`prefix'" == "" local prefix "`mainvar'"

    * --- Step 1: Save labels & existing codes from current dummies ---
    local varlabels
    local codes
    unab allvars : *
    foreach v of local allvars {
        if substr("`v'", 1, length("`prefix'_")) == "`prefix'_" {
            local suffix = substr("`v'", length("`prefix'_") + 1, .)

            * only keep numeric suffixes (avoid _oth, _rank, etc.)
            capture confirm number `suffix'
            if !_rc {
                local lbl : var label `v'
                local varlabels `varlabels' "`suffix'`=char(1)'`lbl'"
                if strpos(" `codes' ", " `suffix' ") == 0 {
                    local codes "`codes' `suffix'"
                }
            }
        }
    }

    * --- Step 2: Drop only old dummy variables with numeric suffix ---
    foreach v of local allvars {
        if substr("`v'", 1, length("`prefix'_")) == "`prefix'_" {
            local suffix = substr("`v'", length("`prefix'_") + 1, .)
            capture confirm number `suffix'
            if !_rc {
                drop `v'
            }
        }
    }

    * --- Step 3: Collect unique codes from main variable ---
    tempvar temp
    gen `temp' = trim(`mainvar')
    levelsof `temp', local(rows)
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

    * Sort codes numerically
    local codes : list sort codes

    * --- Step 4: Create dummy variables with . first, then replace 1/0 ---
    foreach code of local codes {
        gen byte `prefix'_`code' = .
        replace `prefix'_`code' = 1 if strpos(" " + `mainvar' + " ", " `code' ") > 0
        replace `prefix'_`code' = 0 if strpos(" " + `mainvar' + " ", " `code' ") == 0 & !missing(`mainvar')

        * Apply saved label if exists
        local foundlbl ""
        foreach lblpair of local varlabels {
            local thiscode = substr("`lblpair'", 1, strpos("`lblpair'", char(1)) - 1)
            local thislbl  = substr("`lblpair'", strpos("`lblpair'", char(1)) + 1, .)
            if "`thiscode'" == "`code'" {
                local foundlbl "`thislbl'"
            }
        }

        if "`foundlbl'" != "" {
            label var `prefix'_`code' "`foundlbl'"
        }
        else {
            label var `prefix'_`code' "`prefix' : Code `code'"
        }
    }

    * --- Step 5: Order dummies right after main variable ---
    order `prefix'_*, after(`mainvar')

end
