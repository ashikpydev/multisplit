capture program drop multisplit
program define multisplit
    version 17.0

    * Make prefix optional
    syntax varname, Prefix(string optional)

    * Use variable name as prefix if not provided
    local mainvar "`varlist'"
    if "`prefix'" == "" local prefix "`mainvar'"

    // Step 1: Save labels & code list from existing dummies
    local varlabels
    local codes
    unab allvars : *
    foreach v of local allvars {
        if substr("`v'", 1, length("`prefix'_")) == "`prefix'_" {
            local lbl : var label `v'
            local code = substr("`v'", length("`prefix'_") + 1, .)
            local varlabels `varlabels' "`code'`=char(1)'`lbl'"
            if strpos("`codes'", " `code' ") == 0 {
                local codes "`codes' `code' "
            }
        }
    }

    // Step 2: Drop old dummies
    foreach v of local allvars {
        if substr("`v'", 1, length("`prefix'_")) == "`prefix'_" {
            drop `v'
        }
    }

    // Step 3: Gather codes from main variable
    tempvar temp
    gen `temp' = trim(itrim(`mainvar'))
    levelsof `temp', local(rows)
    foreach row of local rows {
        local row = itrim("`row'")
        tokenize "`row'"
        while "`1'" != "" {
            if strpos("`codes'", " `1' ") == 0 {
                local codes "`codes' `1' "
            }
            macro shift
        }
    }

    // Step 4: Create dummy vars for all codes (even if no matches)
    foreach code of local codes {
        gen byte `prefix'_`code' = strpos(" " + `mainvar' + " ", " `code' ") > 0

        * Find label from saved list
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
