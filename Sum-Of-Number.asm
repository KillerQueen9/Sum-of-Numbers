#######################################################################################################################################################
#   Liwen Cui
#######################################################################################################################################################            
               
            .data 
Prompt:     .asciiz                          "\n please input value for N: "
result:     .asciiz                          "\n The sum of integers from 1 to N is: "
FP_Num:     .asciiz                          "\n You entered a Floating Point number. It has been truncated and we will be using:  "
Bye:        .asciiz                          "\n Adios Amigos ... Have a good day"
            .globl                           main
            .text

main: 

             li                              $v0, 4                                   # syscall Print string
             la                              $a0, Prompt                              # Load address of Prompt to $a0
             syscall
             li                              $v0, 6                                   # read N into $f0
             syscall 
             li                              $t0, 0                                   # Initialize $t0 to 0
# Copy the FP number from floating point register $f0 into an integer register, NO conversion             
             mfc1  $t1, $f0
             blez  $t1, End  # Branch to End if N is less than or equal to 0
             srl   $t2, $t1, 23  # shift right logical to remove the significant
# Substract 127 from the biased exponent to get the exponent
             addi  $s3, $t2, -127 # This is the exponent


# check if there is fraction
             sll   $t4, $t1, 9  # "shift left logical" shift out the exponent and sign bit
             srl   $t5, $t4, 9  # "shift right logical" shift back to the original position, this will make all previous bits 0
             addi  $t6, $t5, 8388608 # add the implied bit to bit number 8 ( 2^23)
             addi  $t7, $s3, 9 # add 9 to the exponent
             sllv  $s4, $t6, $t7 # By shifting to the left 9 + exponent. If this number Not Equal to 0, then there is a fraction


# Get the integer
             rol   $t8, $t6, $t7 # Rotate the bits to left,
             li    $t9, 32          # initialize $t9 to 32 and
             sub   $t3, $t9, $t7    # use $t3 to determine how many bits the fraction part has:  32 total bits - (exponent + 1 sign bit + 8 biased exponent bits), exponent is how many times we moved the decimal point
             sllv  $t8, $t8, $t3 # Shift left to remove the fraction part
             srlv  $t8, $t8, $t3 # Shift back, then we left with only the integer part
             move  $v0, $t8  # copy the number in $t8 and move it to $v0 for further computation
             beqz  $s4, Loop # branch to loop if there is no fraction part


Float_Print:  
             # this part will be skipped if N is an integer 
             li                               $v0,4                                    # system call code for Print String
             la                               $a0,FP_Num                               # load address of message into $a0
             syscall                                                                   # print the string
 
             li                               $v0,1                                    # system call code for print integer
             move                             $a0, $t8                                 # move value to be printed to $a0
             syscall
             move                             $v0, $t8                                 # copy the number in $t8 and move it to $v0 for further computation
Loop:
             add                              $t0,$t0,$v0                              # sum of integers in register $t0
             addi                             $v0,$v0,-1                               # suming integers in reverse order
             bnez                             $v0,Loop                                 # branch to loop if $v0 is !=0
             
             li                               $v0,4                                    # system call code for Print String
             la                               $a0,result                               # load address of message into $a0
             syscall                                                                   # print the string
 
             li                               $v0,1                                    # system call code for print integer
             move                             $a0, $t0                                 # move value to be printed to $a0
             syscall                                                                   # print sum of integers
             b                                main                                     # branch to main
End:
 
             li                               $v0,4                                    # system call code for Print String
             la                               $a0, Bye                                 # load address of msg. into $a0
             syscall                                                                   # print the string
             li                               $v0, 10                                  # terminate program run and
             syscall                                                                   # return control to system
             
