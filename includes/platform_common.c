/*
 * Copyright (c) 2013-2023, ARM Limited and Contributors. All rights reserved.
 * Copyright (c) 2024, Shant Tchatalbachian
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <string.h>

#include <platform_def.h>

#include <arch_helpers.h>
#include <common/bl_common.h>
#include <common/debug.h>
#include <drivers/arm/cci.h>
#include <lib/utils.h>
#include <lib/xlat_tables/xlat_tables_compat.h>
#if SPM_MM
#include <services/spm_mm_partition.h>
#endif

#include <plat_private.h>

#ifdef PLAT_RK_CCI_BASE
static const int cci_map[] = {
	PLAT_RK_CCI_CLUSTER0_SL_IFACE_IX,
	PLAT_RK_CCI_CLUSTER1_SL_IFACE_IX
};
#endif

#if defined(IMAGE_BL31) && SPM_MM
const mmap_region_t plat_arm_secure_partition_mmap[] = {
    MAP_REGION_FLAT(0x20000000,
                    0x0c200000,
                    MT_DEVICE | MT_RW | MT_SECURE),
    MAP_REGION_FLAT(0x80000000,
                    0x00010000,
                    MT_MEMORY | MT_RW | MT_SECURE),
    MAP_REGION_FLAT(0x8000D000,
                    0x00001000,
                    MT_MEMORY | MT_RW | MT_NON_SECURE),
    MAP_REGION_FLAT(0x8000E000,
                    0x00002000,
                    MT_MEMORY | MT_RW | MT_SECURE),
    MAP_REGION_FLAT(0x8000C000,
                    0x00001000,
                    MT_MEMORY | MT_RW | MT_SECURE),
    {0}
};
#endif

#define PLAT_SP_IMAGE_MMAP_REGIONS	\
    {					\
        {				\
            .base = 0x80000000,		\
            .size = 0x1000000,		\
            .attr = MT_MEMORY | MT_RW | MT_SECURE,	\
        },				\
        {				\
            .base = 0x0,		\
            .size = 0x40000000,		\
            .attr = MT_MEMORY | MT_RW | MT_SECURE,	\
        },				\
    }

#define PLAT_SP_IMAGE_MAX_XLAT_TABLES 4

#if defined(IMAGE_BL31) && SPM_MM
static spm_mm_mp_info_t sp_mp_info[] = {
	[0] = {0x80000000, 0},
	[1] = {0x80000001, 0},
	[2] = {0x80000002, 0},
	[3] = {0x80000003, 0},
	[4] = {0x80000100, 0},
	[5] = {0x80000101, 0},
	[6] = {0x80000102, 0},
	[7] = {0x80000103, 0},
};

const spm_mm_boot_info_t plat_arm_secure_partition_boot_info = {
    .h.type              = PARAM_SP_IMAGE_BOOT_INFO,
    .h.version           = 0x01,
    .h.size              = sizeof(spm_mm_boot_info_t),
    .h.attr              = 0,
    .sp_mem_base         = 0x80000000,
    .sp_mem_limit        = 0x80010000,
    .sp_image_base       = 0x80000000,
    .sp_stack_base       = 0x8000F000,
    .sp_heap_base        = 0x8000E000,
    .sp_ns_comm_buf_base = 0x8000D000,
    .sp_shared_buf_base  = 0x8000C000,
    .sp_image_size       = 0x00010000,
    .sp_pcpu_stack_size  = 0x00002000,
    .sp_heap_size        = 0x00002000,
    .sp_ns_comm_buf_size = 0x00001000,
    .sp_shared_buf_size  = 0x00001000,
    .num_sp_mem_regions  = ARRAY_SIZE(sp_mp_info),
    .num_cpus            = PLATFORM_CORE_COUNT,
    .mp_info             = &sp_mp_info[0],
};

const struct mmap_region *plat_get_secure_partition_mmap(void *cookie)
{
	return plat_arm_secure_partition_mmap;
}

const struct spm_mm_boot_info *plat_get_secure_partition_boot_info(void *cookie)
{
	return &plat_arm_secure_partition_boot_info;
}
#endif
/******************************************************************************
 * Macro generating the code for the function setting up the pagetables as per
 * the platform memory map & initialize the mmu, for the given exception level
 ******************************************************************************/
#define DEFINE_CONFIGURE_MMU_EL(_el)					\
	void plat_configure_mmu_el ## _el(unsigned long total_base,	\
					  unsigned long total_size,	\
					  unsigned long ro_start,	\
					  unsigned long ro_limit,	\
					  unsigned long coh_start,	\
					  unsigned long coh_limit)	\
	{								\
		mmap_add_region(total_base, total_base,			\
				total_size,				\
				MT_MEMORY | MT_RW | MT_SECURE);		\
		mmap_add_region(ro_start, ro_start,			\
				ro_limit - ro_start,			\
				MT_MEMORY | MT_RO | MT_SECURE);		\
		if ((coh_limit - coh_start) != 0)			\
			mmap_add_region(coh_start, coh_start,		\
					coh_limit - coh_start,		\
					MT_DEVICE | MT_RW | MT_SECURE);	\
		mmap_add(plat_rk_mmap);					\
		rockchip_plat_mmu_el##_el();				\
		init_xlat_tables();					\
									\
		enable_mmu_el ## _el(0);				\
	}

/* Define EL3 variants of the function initialising the MMU */
DEFINE_CONFIGURE_MMU_EL(3)

unsigned int plat_get_syscnt_freq2(void)
{
	return SYS_COUNTER_FREQ_IN_TICKS;
}

void plat_cci_init(void)
{
#ifdef PLAT_RK_CCI_BASE
	/* Initialize CCI driver */
	cci_init(PLAT_RK_CCI_BASE, cci_map, ARRAY_SIZE(cci_map));
#endif
}

void plat_cci_enable(void)
{
	/*
	 * Enable CCI coherency for this cluster.
	 * No need for locks as no other cpu is active at the moment.
	 */
#ifdef PLAT_RK_CCI_BASE
	cci_enable_snoop_dvm_reqs(MPIDR_AFFLVL1_VAL(read_mpidr()));
#endif
}

void plat_cci_disable(void)
{
#ifdef PLAT_RK_CCI_BASE
	cci_disable_snoop_dvm_reqs(MPIDR_AFFLVL1_VAL(read_mpidr()));
#endif
}
