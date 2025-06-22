/*******************************************************************************
 * @file       default.s
 * @brief      Default interrupt handler implementation for ARM Cortex-M processors.
 * @details    This file defines the default interrupt handler that gets invoked 
 *             when an unexpected interrupt occurs. The handler enters an infinite 
 *             loop, preserving the system state for debugging purposes.
 *
 *
 * @note       This implementation ensures that unhandled interrupts do not result 
 *             in undefined behavior. Applications should define handlers for all 
 *             required interrupts to avoid relying on this default implementation.
 *
 * @copyright  (C) 2025, Manoel Augusto de Souza Serafim
 *             All rights reserved.
 * 
 * @author     Manoel Serafim
 * @email      manoel.serafim@proton.me
 * @date       2025-01-15
 * @github     https://github.com/manoel-serafim
 ******************************************************************************/
.syntax unified
.cpu cortex-m4
.thumb

.global default_
/**
 * @brief  This is the code that gets called when the processor receives an
 *         unexpected interrupt. This simply enters an infinite loop, preserving
 *         the system state for examination by a debugger.
 *
 * @param  None
 * @return None
 */
  .section .text.default_,"ax",%progbits
default_:
loop__default_:
  b loop__default_
  .size default_, .-default_