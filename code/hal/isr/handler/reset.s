/**
 * @file       reset.s
 * @brief      Processor startup and memory initialization routines.
 * @details    This file contains the assembly routines executed when the processor
 *             starts after a reset event. These routines perform the minimal required
 *             initialization, including setting up the stack pointer, initializing
 *             the .data section, zeroing the .bss section, and then transferring
 *             control to the application's `main` function.
 *
 * @copyright  (C) 2025, Manoel Augusto de Souza Serafim
 *             All rights reserved.
 *
 * @author     Manoel Serafim
 * @email      manoel.serafim@proton.me
 * @github     https://github.com/manoel-serafim
*/
.syntax unified
.cpu cortex-m4
.thumb

#include "hal/stm32f411xe.h"
#include "hooks/blink.h"

.global reset_
/**
 * @brief  This is the code that gets called when the processor first
 *         starts execution following a reset event. Only the absolutely
 *         necessary set is performed, after which the application
 *         supplied main() routine is called.
 * @param None
 * @return None
*/ 
  .section .text.reset_
  .type reset_, %function
reset_:
  ldr   r0, =_estack
  mov   sp, r0

/**
 */
/*bl  rcc_init (Init Cache, PLL , etc)*/  
/**
 * @brief Setup clock control registers and system clock
 * @details This assembly routine initializes the .data section in SRAM by copying
 *          its values from the corresponding region in FLASH. The .data section holds
 *          initialized global and static variables that must persist with specific
 *          initial values at runtime.
 *  @note If there is no use of initiallized global values, this may break the initialization code. 
 *        Still, no unreallistic overhead is added considering that the application established here will use it
 */


/**
 * @brief Copy initialized .data section from FLASH to SRAM.
 * @details This assembly routine initializes the .data section in SRAM by copying
 *          its values from the corresponding region in FLASH. The .data section holds
 *          initialized global and static variables that must persist with specific
 *          initial values at runtime.
 *  @note If there is no use of initiallized global values, this may break the initialization code. 
 *        Still, no unreallistic overhead is added considering that the application established here will use it
 */
  ldr r0, =_sdata       
  ldr r1, =_edata       
  ldr r2, =_sidata
  sub r3, r1, r0

copy_flash__reset_:
  sub r3, r3, #4
  ldr r4, [r2, r3]  
  str r4, [r0, r3]
  
  bne copy_flash__reset_     


/**
 * @brief Zero fills the .bss section in SRAM.
 * @details This routine initializes the .bss section in SRAM by setting all its contents to 0. 
 *          The .bss section is used to store uninitialized global and static variables, which are 
 *          automatically initialized to zero during program startup. This ensures that all uninitialized 
 *          variables in the .bss section are properly set to zero before the program begins execution.
 * @note Variables to be initiallized with zero go here
 */
  ldr r0, =_sbss
  ldr r1, =_ebss
  movs r2, #0
  sub r3, r1, r0

zero_bss__reset_:
  sub r3, r3, #4
  str  r2, [r0, r3]
  
  bne zero_bss__reset_


  bl rdx_init
  .size reset_, .-reset_
