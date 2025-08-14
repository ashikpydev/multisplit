capture program drop multisplit
program define multisplit
    version 17.0

    * Parse main variable, optional prefix
    syntax varname [if] [in], [PREFIX(string)]

    local mainvar "`varlist'"

    * Use variable name as prefix if PREFIX not provided
    if "`prefix'" == "" local prefix "`mainvar'"

    * Step 1: Save labels & existing codes from current dummies
    local varlabels
    local codes
    unab allvars : *
    foreach v of local allvars {
        if substr("`v'", 1, length("`prefix'_")) == "`prefix'_" {
            local lbl : var label `v'
            local code = substr("`v'", length("`prefix'_") + 1, .)
            local varlabels `varlabels' "`code'`=char(1)'`lbl'"
            if strpos(" `codes' ", " `code' ") == 0 {
                local codes "`codes' `code'"
            }
        }
    }

    * Step 2: Drop old dummy variables
    foreach v of local allvars {
        if substr("`v'", 1, length("`prefix'_")) == "`prefix'_" {
            drop `v'
        }
    }

    * Step 3: Collect unique codes from main variable
    tempvar temp
    gen `temp' = trim(`mainvar')
    levelsof `temp', local(rows)
    foreach row of local rows {
        tokenize "`row'"
        while "`1'" != "" {
            if strpos(" `codes' ", " `1' ") == 0 {
                local codes "`codes' `1'"
            }
            macro shift
        }
    }

    * Step 4: Create dummy variables with . first, then replace 1/0
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

end
