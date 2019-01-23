.text
.global run_serial_tests
# Pass 1 as the argument to test the second serial port
run_serial_tests:
    
    subui $sp, $sp, 5
    sw $ra, 2($sp)
    sw $2, 3($sp)
    sw $3, 4($sp)

test_which:
    lw $2, active_serial($0)
    sw $2, original_serial($0)
    
    lw $2, 5($sp)
    # Switch to the correct serial port
    multui $2, $2, 0x1000
    lhi $3, 0x7         # $3 is now 0x70000
    addu $2, $2, $3     # $2 is now the base address of the serial port to use
    sw $2, active_serial($0)
    
    la $2, welcome_msg
    sw $2, 0($sp)
    jal puts

    la $2, paste_msg
    sw $2, 0($sp)
    jal puts
    la $2, text_chunk
    sw $2, 0($sp)
    jal puts
    
    jal get_paste
    
    # Check if the paste is what it should be
    la $2, paste_gets_buf
    sw $2, 0($sp)
    la $2, text_chunk
    sw $2, 1($sp)
    jal strcmp
    
    beqz $1, paste_success

    la $2, paste_fail_msg
    sw $2, 0($sp)
    addui $2, $0, 0x1
    sw $2, found_error($0)
    jal puts

paste_success:
    la $2, newline
    sw $2, 0($sp)
    jal puts
    
    la $2, control_codes_msg
    sw $2, 0($sp)
    jal puts

    la $2, cow_string
    sw $2, 0($sp)
    jal puts

exit:
    lw $2, original_serial($0)
    sw $2, active_serial($0)
    lw $ra, 2($sp)
    lw $2, 3($sp)
    lw $3, 4($sp)
    addui $sp, $sp, 5
    
    lw $1, found_error($0)
    jr $ra

get_paste:
    subui $sp, $sp, 3
    sw $ra, 1($sp)
    sw $2, 2($sp)
    
    la $2, paste_gets_buf
    sw $2, 0($sp)
    jal gets
    sw $1, 0($sp)
    jal gets
    sw $1, 0($sp)
    jal gets
    
    sw $2, 0($sp)
    jal puts
    
    lw $ra, 1($sp)
    lw $2, 2($sp)
    addui $sp, $sp, 3
    jr $ra

.bss
paste_gets_buf:
    .space 300

original_serial:
    .word

.data
found_error:
    .word 0

welcome_msg:
    .ascii "Running serial tests" # This will get the newline too since it's unterminated
newline:
    .asciiz "\r\n"

paste_msg:
    .ascii "Please highlight the following section of text, and paste it back here.\r\n"
    .asciiz "Middle-click on some Linux distributions will paste highlighted text.\r\n\r\n"

paste_fail_msg:
    .ascii "What you pasted was not the same as what was sent. If you think you did\r\n"
    .ascii "not paste the correct string, please run this program again when it\r\n"
    .asciiz "completes. Otherwise, the serial port is communicating incorrectly.\r\n"

text_chunk:
    .ascii "the exodus of jazzy pigeons is craved by squeamish walkers\r\n"
    .ascii "BOTH FICKLE DWARVES JINX MY PIG QUIZ\r\n"
    .asciiz "`1234567890-=~!@#$%^&*()_+[]\\{}|;':\",./<>?\r\n"

control_codes_msg:
    .ascii "A friendly cow should appear below. If it looks strange, remote might not\r\n"
    .ascii "understand the commands used to move the cursor's position.\r\n"
    .ascii "This works best if the console window is currently 80x24."
    .asciiz "\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n" #make some room for the cow


cow_string:

#"\033[yy;xxH" will move the cursor to (xx,yy)

.ascii  "\033[15;05H"
.ascii  "________________________________________\033[16;04H"
.ascii  "/ Hi there, WRAMP user! Thanks for using \\\033[17;04H"
.ascii  "\\ this test suite.\033[17;45H/\033[18;05H"
.ascii  "----------------------------------------\033[19;12H"
.ascii  "\\   ^__^\033[20;13H"
.ascii  "\\  (^^)\\_______\033[21;16H"
.ascii  "(__)\\       )\\/\\\033[22;20H"
.ascii  "||----w |\033[23;20H"
.asciiz "||     ||\r\n\r\n"


# This is what it should look like. Made with `cowsay`.
# ________________________________________
#/ Hi there, WRAMP user! Thanks for using \
#\ this test suite.                       /
# ----------------------------------------
#        \   ^__^
#         \  (^^)\_______
#            (__)\       )\/\
#                ||----w |
#                ||     ||

