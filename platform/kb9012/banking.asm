; Copyright (C) 2017 Paul Kocialkowski <contact@paulk.fr>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

.area HOME (CODE)

__sdcc_banked_call::
	mov r7, a		; store acc value to r7
	push dpl		; store dpl value to stack
	push dph		; store dph value to stack
	mov dptr, #0xfea1	; load XBISEG3 to dptr
	movx a, @dptr		; load register value to acc
	pop dph			; restore dph value from stack
	pop dpl			; restore dpl value from stack
	push acc		; store acc (register value) to stack

;	In order to allow calling functions from the same switched segment
;	without going through this trampoline, a call to __sdcc_banked_ret
;	is added when returning from the switched segment, instead of declaring
;	functions as banked in the code.
	mov a, #__sdcc_banked_ret
	push acc
	mov a, #(__sdcc_banked_ret >> 8)
	push acc

;	The banked function address is pushed to stack for call.
	mov a, r0		; move r0 (physical address lsb) to acc
	push acc		; store acc (call lsb) to stack
	mov a, r1		; move r1 (physical address part) value to acc
	push acc		; store acc (call msb) to stack

;	The offset is the number of 16 kiB blocks to map the segment.
	mov a, r2		; move r2 (bank) value to acc
	add a, #0x03		; offset by 48 kiB (3 blocks of 16 kiB)
	orl a, #0x80		; enable SEG3 remapping
	push dpl		; store dpl value to stack
	push dph		; store dph value to stack
	mov dptr, #0xfea1	; load XBISEG3 to dptr
	movx @dptr, a		; store value in dptr
	pop dph			; restore dph value from stack
	pop dpl			; restore dpl value from stack
	mov a, r7		; restore acc value from r7
	ret			; call banked function

__sdcc_banked_ret::
	mov r7, a		; store acc value to r7
	pop acc			; restore register value from stack
	push dpl		; store dpl value to stack
	push dph		; store dph value to stack
	mov dptr, #0xfea1	; load XBISEG3 to dptr
	movx @dptr, a		; load acc value to register
	pop dph			; restore dph value from stack
	pop dpl			; restore dpl value from stack
	mov a, r7		; restore acc value from r7
	ret			; return to initial call
