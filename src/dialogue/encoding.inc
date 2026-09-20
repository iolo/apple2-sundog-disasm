; Custom dialogue script encoding; see docs/dialogue-scripts.md.
.macro d_begin arg0, arg1, arg2, arg3
    .byte ((arg0 << 4) | (arg1 << 2) | arg2), arg3
.endmacro

.macro d_entry arg0
    .byte arg0
.endmacro

.macro d_say arg0
    .byte arg0
.endmacro

.macro d_value arg0
    .byte arg0
.endmacro

.macro d_condition arg0
    .byte arg0
.endmacro

.macro d_test arg0, arg1
    .byte arg0, arg1
.endmacro

.macro d_default arg0
    .byte arg0
.endmacro

.macro d_next arg0
    .byte arg0
.endmacro

.macro d_reply arg0, arg1
    .byte arg0, arg1
.endmacro

.macro d_no_override
    .byte 0
.endmacro

.macro d_override arg0, arg1
    .byte arg0, arg1
.endmacro

.macro d_text_random arg0
    .byte arg0
.endmacro

.macro d_text_conditional arg0
    .byte 10+arg0
.endmacro

.macro d_text_mood20
    .byte 20
.endmacro

.macro d_text_mood21
    .byte 21
.endmacro

.macro d_text_mood22
    .byte 22
.endmacro

.macro d_text_mood23
    .byte 23
.endmacro

.macro d_state_random arg0
    .byte arg0
.endmacro

.macro d_state_conditional arg0
    .byte 10+arg0
.endmacro

.macro d_state_mood20
    .byte 20
.endmacro

.macro d_state_mood21
    .byte 21
.endmacro

.macro d_state_mood22
    .byte 22
.endmacro

.macro d_state_mood23
    .byte 23
.endmacro

.macro d_action0
    .byte 0
.endmacro

.macro d_action1 arg0
    .byte 1, arg0
.endmacro

.macro d_action2 arg0, arg1
    .byte 2, arg0, arg1
.endmacro

.macro d_action3 arg0, arg1, arg2, arg3
    .byte 3, arg0, arg1, arg2, arg3
.endmacro

.macro d_action4
    .byte 4
.endmacro

.macro d_action5 arg0
    .byte 5, arg0
.endmacro

.macro d_action6 arg0
    .byte 6, arg0
.endmacro

.macro d_action7 arg0
    .byte 7, arg0
.endmacro
