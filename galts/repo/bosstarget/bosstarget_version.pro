;+
; NAME:
;   bosstarget_version
; PURPOSE:
;   Return the version name for the product bosstarget
; CALLING SEQUENCE:
;   vers = bosstarget_version()
; INPUTS:
; OUTPUTS:
;   vers       - Version name for the product bosstarget
; COMMENTS:
;   Depends on shell script in ../../bin
; BUGS:
; PROCEDURES CALLED:
; REVISION HISTORY:
;   2009-02-13  written - Padmanabhan
;-
;------------------------------------------------------------------------------
function bosstarget_version
   spawn, 'bosstarget_version', stdout, /noshell
   return, stdout[0]
end
;------------------------------------------------------------------------------
