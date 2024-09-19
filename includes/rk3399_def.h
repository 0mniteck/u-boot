/*
 * Copyright (c) 2014-2016, ARM Limited and Contributors. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef RK3399_DEF_H
#define RK3399_DEF_H

#include <addressmap.h>

#define RK3399_PRIMARY_CPU		0x0

/* Special value used to verify platform parameters from BL2 to BL3-1 */
#define RK_BL31_PLAT_PARAM_VAL		0x0f1e2d3c4b5a6978ULL

/**************************************************************************
 * UART related constants
 **************************************************************************/
#define RK3399_BAUDRATE			115200
#define RK3399_UART_CLOCK		24000000

/******************************************************************************
 * System counter frequency related constants
 ******************************************************************************/
#define SYS_COUNTER_FREQ_IN_TICKS	24000000

/* Base rockchip_platform compatible GIC memory map */
#define BASE_GICD_BASE			(GIC500_BASE)
#define BASE_GICR_BASE			(GIC500_BASE + SIZE_M(1))

/*****************************************************************************
 * CCI-400 related constants
 ******************************************************************************/
#define PLAT_RK_CCI_CLUSTER0_SL_IFACE_IX	0
#define PLAT_RK_CCI_CLUSTER1_SL_IFACE_IX	1

/******************************************************************************
 * sgi, ppi
 ******************************************************************************/
#define ARM_IRQ_SEC_PHY_TIMER		29

#define ARM_IRQ_SEC_SGI_0		8
#define ARM_IRQ_SEC_SGI_1		9
#define ARM_IRQ_SEC_SGI_2		10
#define ARM_IRQ_SEC_SGI_3		11
#define ARM_IRQ_SEC_SGI_4		12
#define ARM_IRQ_SEC_SGI_5		13
#define ARM_IRQ_SEC_SGI_6		14
#define ARM_IRQ_SEC_SGI_7		15

/*
 * Define a list of Group 1 Secure and Group 0 interrupts as per GICv3
 * terminology. On a GICv2 system or mode, the lists will be merged and treated
 * as Group 0 interrupts.
 */
#define PLAT_RK_GICV3_G1S_IRQS						\
	INTR_PROP_DESC(ARM_IRQ_SEC_PHY_TIMER, GIC_HIGHEST_SEC_PRIORITY,	\
		       INTR_GROUP1S, GIC_INTR_CFG_LEVEL)

#define PLAT_RK_GICV3_G0_IRQS						\
	INTR_PROP_DESC(ARM_IRQ_SEC_SGI_6, GIC_HIGHEST_SEC_PRIORITY,	\
		       INTR_GROUP0, GIC_INTR_CFG_LEVEL)

#define DEVICE0_BASE			0x20000000
#define DEVICE0_SIZE			0x0c200000

#define DEVICE1_BASE			0x2e000000
#define DEVICE1_SIZE			0x1A00000

# if defined(IMAGE_BL31)
#  if SPM_MM
#define PLAT_PRI_BITS			3
#define PLAT_SP_IMAGE_MMAP_REGIONS	7
#define PLAT_SP_IMAGE_MAX_XLAT_TABLES	10
#define PLAT_SP_PRI			0x20
#  endif
# endif

#endif /* RK3399_DEF_H */
