/*
 * Copyright (c) 2014-2019, ARM Limited and Contributors. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef PLATFORM_DEF_H
#define PLATFORM_DEF_H

#include <arch.h>
#include <lib/utils_def.h>
#include <common/interrupt_props.h>
#include <lib/xlat_tables/xlat_tables_defs.h>
#include <plat/arm/common/arm_def.h>
#include <plat/arm/common/arm_spm_def.h>
#include <plat/arm/common/smccc_def.h>
#include <plat/common/common_def.h>

#include <bl31_param.h>
#include <rk3399_def.h>

/*******************************************************************************
 * Platform binary types for linking
 ******************************************************************************/
#define PLATFORM_LINKER_FORMAT		"elf64-littleaarch64"
#define PLATFORM_LINKER_ARCH		aarch64

/*******************************************************************************
 * Generic platform constants
 ******************************************************************************/

/* Size of cacheable stacks */
#if defined(IMAGE_BL1)
#define PLATFORM_STACK_SIZE 0x440
#elif defined(IMAGE_BL2)
#define PLATFORM_STACK_SIZE 0x400
#elif defined(IMAGE_BL31)
#define PLATFORM_STACK_SIZE 0x800
#elif defined(IMAGE_BL32)
#define PLATFORM_STACK_SIZE 0x440
#endif

#define FIRMWARE_WELCOME_STR		"Booting Trusted Firmware\n"

#define PLATFORM_MAX_AFFLVL		MPIDR_AFFLVL2
#define PLATFORM_SYSTEM_COUNT		U(1)
#define PLATFORM_CLUSTER_COUNT		U(2)
#define PLATFORM_CLUSTER0_CORE_COUNT	U(4)
#define PLATFORM_CLUSTER1_CORE_COUNT	U(2)
#define PLATFORM_CORE_COUNT		(PLATFORM_CLUSTER1_CORE_COUNT +	\
					 PLATFORM_CLUSTER0_CORE_COUNT)
#define PLATFORM_MAX_CPUS_PER_CLUSTER	U(4)
#define PLATFORM_NUM_AFFS		(PLATFORM_SYSTEM_COUNT +	\
					 PLATFORM_CLUSTER_COUNT +	\
					 PLATFORM_CORE_COUNT)
#define PLAT_RK_CLST_TO_CPUID_SHIFT	6
#define PLAT_MAX_PWR_LVL		MPIDR_AFFLVL2

/*
 * This macro defines the deepest retention state possible. A higher state
 * id will represent an invalid or a power down state.
 * #define PLAT_MAX_RET_STATE		U(1)
 */

/*
 * This macro defines the deepest power down states possible. Any state ID
 * higher than this is invalid.
 * #define PLAT_MAX_OFF_STATE		U(2)
 */

/*******************************************************************************
 * Platform specific page table and MMU setup constants
 ******************************************************************************/
#define PLAT_VIRT_ADDR_SPACE_SIZE   (1ULL << 32)
#define PLAT_PHY_ADDR_SPACE_SIZE    (1ULL << 32)
#define MAX_XLAT_TABLES			20
#define PLAT_ARM_MMAP_ENTRIES		8
#define PLAT_ARM_MAX_BL31_SIZE		0x60000
#define PLAT_ARM_TRUSTED_SRAM_SIZE	0x00080000

#if TF_MBEDTLS_KEY_ALG_ID == TF_MBEDTLS_RSA_AND_ECDSA || PSA_CRYPTO
#define PLAT_ARM_MAX_BL1_RW_SIZE	UL(0xC000)
#else
#define PLAT_ARM_MAX_BL1_RW_SIZE	UL(0xB000)
#endif
/*******************************************************************************
 * Declarations and constants to access the mailboxes safely. Each mailbox is
 * aligned on the biggest cache line size in the platform. This is known only
 * to the platform as it might have a combination of integrated and external
 * caches. Such alignment ensures that two maiboxes do not sit on the same cache
 * line at any cache level. They could belong to different cpus/clusters &
 * get written while being protected by different locks causing corruption of
 * a valid mailbox address.
 ******************************************************************************/
#define CACHE_WRITEBACK_SHIFT	6

/*
 * Define GICD and GICC and GICR base
 */
#define PLAT_RK_GICD_BASE	BASE_GICD_BASE
#define PLAT_RK_GICR_BASE	BASE_GICR_BASE
#define PLAT_RK_GICC_BASE	0

#define PLAT_RK_UART_BASE		UART2_BASE
#define PLAT_RK_UART_CLOCK		RK3399_UART_CLOCK
#define PLAT_RK_UART_BAUDRATE		RK3399_BAUDRATE

#define PLAT_RK_CCI_BASE		CCI500_BASE

#define PLAT_RK_PRIMARY_CPU		0x0

#define PSRAM_DO_DDR_RESUME	1
#define PSRAM_CHECK_WAKEUP_CPU	0

#endif /* PLATFORM_DEF_H */
