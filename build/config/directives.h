/**
 * @file compiler_flags.h
 * @brief Documentation of compiler definition flags used in the project.
 *
 * This file contains all relevant preprocessor macros that control
 * compilation options, with detailed explanations.
 */

/**
 * @def RDX_NO_GLOBAL_VARIABLES
 * @brief Disable initialization of the .data section.
 *
 * When defined, this flag disables the copying of the initialized
 * .data section from FLASH to SRAM during startup.
 *
 * Use this when the application does not use any initialized
 * global or static variables to reduce startup overhead.
 */
#define RDX_NO_GLOBAL_VARIABLES

/**
 * @def RDX_NO_BSS_ZERO
 * @brief Disable zero initialization of the .bss section.
 *
 * When defined, this flag disables zeroing of the .bss section during
 * startup.
 *
 * Use this when the application guarantees .bss is already zero or
 * does not use uninitialized globals.
 */
#define RDX_NO_BSS_ZERO

