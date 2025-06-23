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

.extern hook
#include "hal/cmsis/registers.h"

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
 * @brief Configures the Reset and Clock Control (RCC) to run the system at 100 MHz.
 * @details This routine enables the High-Speed External oscillator (HSE) and waits until it becomes stable. It then configures the PLL with parameters PLLM=25, PLLN=200, and PLLP=2 to generate a 100 MHz system clock from the 25 MHz HSE source. After enabling the PLL, the code waits until the PLL locks and becomes ready. The flash latency is set to 2 wait states to ensure proper operation at the increased clock frequency. Next, the AHB, APB1, and APB2 prescalers are configured to safe values, specifically AHB at division factor 1, APB1 at division factor 2, and APB2 at division factor 1. Finally, the system clock source is switched to the PLL output, and the routine waits until the clock switch is confirmed by checking the appropriate status flags.
 *          The code operates on several key registers: RCC_CR at offset 0x00 is used to enable both the HSE and PLL and to monitor their readiness flags. RCC_PLLCFGR at offset 0x04 holds the PLL configuration parameters. RCC_CFGR at offset 0x08 controls the prescaler settings and system clock source selection. The flash latency register, FLASH_ACR (address held in register r2), is also set during this process. The routine includes polling loops labeled `hse_not_ready__reset_`, `pll_not_ready__reset_`, and `wait_sysclk_switch` that wait for the HSE oscillator, the PLL, and the system clock switch to become ready, respectively.
 */

  ldr r0, =F411_RCC_BASE
  ldr r1, [r0]
  orr r1, r1, #0x010000
  str r1, [r0] 

hse_not_ready__reset_:
  ldr r1, [r0, #0x00]
  tst r1, #0x20000
  beq hse_not_ready__reset_

  ldr r1, =(25 | (200 << 6) | (0 << 16) | (1 << 22))
  str r1, [r0, #0x04]

  ldr r1, [r0, #0x00]
  orr r1, r1, #(1 << 24)
  str r1, [r0, #0x00]

pll_not_ready__reset_:
  ldr r1, [r0, #0x00]
  tst r1, #(1 << 25)
  beq pll_not_ready__reset_

  
  ldr r1, =0x00000002
  str r1, [r2, #0x00]

  ldr r1, [r0, #0x08]
  bic r1, r1, #(0xF << 4)
  bic r1, r1, #(0x7 << 10)
  bic r1, r1, #(0x7 << 13)
  orr r1, r1, #(0x4 << 10)
  str r1, [r0, #0x08]

  ldr r1, [r0, #0x08]
  bic r1, r1, #0x3
  orr r1, r1, #0x2            
  str r1, [r0, #0x08]

sysclk_switch_not_ready__reset_:
    ldr r1, [r0, #0x08]
    and r1, r1, #0xC
    cmp r1, #0x8
    bne sysclk_switch_not_ready__reset_

/**
 * @brief Copy initialized .data section from FLASH to SRAM.
 * @details This assembly routine initializes the .data section in SRAM by copying
 *          its values from the corresponding region in FLASH. The .data section holds
 *          initialized global and static variables that must persist with specific
 *          initial values at runtime.
 * @note If there is no use of initiallized global values, this may break the initialization code. 
 *        Still, no unreallistic overhead is added considering that the application established here will use it
 * @pre Linker symbols `_sdata`, `_edata`, and `_sidata` must be properly defined
 *      by the linker script. The memory region between `_sdata` and `_edata` in SRAM
 *      will be overwritten with the contents from `_sidata` in FLASH.
 */

  ldr r0, =_sdata       
  ldr r1, =_edata       
  ldr r2, =_sidata
  subs r3, r1, r0

copy_flash__reset_:
  subs r3, #4
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
  subs r3, r1, r0

zero_bss__reset_:
  subs r3, #4
  str  r2, [r0, r3]
  
  bne zero_bss__reset_


/**
 * @brief Call the global initialization hook.
 * @details This routine branches and links to an initialization function (typically responsible for
 *          setting up global runtime state). It is often used to perform startup tasks such as 
 *          zero-initializing the .bss section, configuring the environment, or invoking user-defined
 *          initialization code before entering the main program loop.
 * @see hook()
 */

  bl hook
  b .

  .size reset_, .-reset_
