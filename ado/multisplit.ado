*! version 1.6.2
*! multisplit.ado
*! Author: Ashiqur Rahman Rony
*! Description: Robust multiple-response split into dummies with repeat groups,
*!              preserving existing dummies and automatic ordering
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
    * ----------------------------
    local varlabels
    local othlist ""
    unab allvars : *
    foreach v of local allvars {
        if "`repeatnum'" == "" {
            if regexm("`v'", "^`prefix'_[0-9]+$") {
                local lbl : var label `v'
                local suffix : subinstr local v "`prefix'_" "", all
                local varlabels `varlabels' "`suffix'`=char(1)'`lbl'"
            }
            else if regexm("`v'", "^`prefix'oth.*") {
                local othlist "`othlist' `v'"
            }
        }
        else {
            if regexm("`v'", "^`prefix'_[0-9]+_`repeatnum'$") {
                local lbl : var label `v'
                local suffix : subinstr local v "`prefix'_" "", all
                local suffix : subinstr local suffix "_`repeatnum'" "", all
                local varlabels `varlabels' "`suffix'`=char(1)'`lbl'"
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
            if regexm("`v'", "^`prefix'_[0-9]+$") | regexm("`v'", "^`prefix'oth.*") local existdummies "`existdummies' `v'"
        }
        else {
            if regexm("`v'", "^`prefix'_[0-9]+_`repeatnum'$") | regexm("`v'", "^`prefix'oth.*_`repeatnum'$") local existdummies "`existdummies' `v'"
        }
    }

    * ----------------------------
    * Generate unique numeric codes
    * ----------------------------
    tempvar temp

    * --- FIX for numeric mainvar ---
    capture confirm string variable `mainvar'
    if _rc {
        gen strL `temp' = string(`mainvar')
    } 
    else {
        gen strL `temp' = `mainvar'
    }
    replace `temp' = trim(`temp')
    replace `temp' = subinstr(`temp', char(9), " ", .)

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
        if "`repeatnum'" == "" {
            local varname `prefix'_`code'
        }
        else {
            local varname `prefix'_`code'_`repeatnum'
        }

        capture confirm variable `varname'
        if _rc {
            gen byte `varname' = 0
        }
        replace `varname' = 1 if regexm(" " + `mainvar' + " ", "( |^)`code'( |$)")
        local newdummies "`newdummies' `varname'"

        * Apply saved label
        local foundlbl ""
        foreach lblpair of local varlabels {
            local thiscode = substr("`lblpair'", 1, strpos("`lblpair'", char(1)) - 1)
            local thislbl  = substr("`lblpair'", strpos("`lblpair'", char(1)) + 1, .)
            if "`thiscode'" == "`code'" local foundlbl "`thislbl'"
        }

        if "`foundlbl'" != "" {
            label var `varname' "`foundlbl'"
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
			local code = subinstr("`v'", "`prefix'_","",.)
			if "`repeatnum'" != "" local code = subinstr("`code'", "_`repeatnum'","",.)
			capture confirm numeric variable `v'
			if !_rc {
				replace `v' = 0
				replace `v' = 1 if regexm(" " + `mainvar' + " ", "( |^)`code'( |$)")
			}
			else {
				replace `v' = "0"
				replace `v' = "1" if regexm(" " + `mainvar' + " ", "( |^)`code'( |$)")
			}
		}
	}

    * ----------------------------
    * Order: existing dummies first, then new, after main variable
    * ----------------------------
    local allorder "`existdummies' `newdummies'"
    order `allorder', after(`mainvar')

    * Drop temp variable
    drop `temp'

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
