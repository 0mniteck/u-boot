/*
 * Copyright (c) 2013-2016, ARM Limited and Contributors. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <string.h>

#include <platform_def.h>

#include <bl31/ehf.h>
#include <arch_helpers.h>
#include <common/bl_common.h>
#include <common/debug.h>
#include <drivers/arm/cci.h>
#include <lib/utils.h>
#include <lib/smccc.h>
#include <lib/xlat_tables/xlat_tables_v2.h>
#if SPM_MM
#include <services/spm_mm_partition.h>
#endif

#include <plat_private.h>

#define MAP_DEVICE0	MAP_REGION_FLAT(DEVICE0_BASE,			\
					DEVICE0_SIZE,			\
					MT_DEVICE | MT_RW | MT_SECURE)

#define MAP_DEVICE1	MAP_REGION_FLAT(DEVICE1_BASE,			\
					DEVICE1_SIZE,			\
					MT_DEVICE | MT_RW | MT_SECURE)

#if TRANSFER_LIST
#ifdef FW_NS_HANDOFF_BASE
#define MAP_FW_NS_HANDOFF MAP_REGION_FLAT(FW_NS_HANDOFF_BASE, \
					  FW_HANDOFF_SIZE,    \
					  MT_MEMORY | MT_RW | MT_NS)
#endif
#endif

#ifdef PLAT_RK_CCI_BASE
static const int cci_map[] = {
	PLAT_RK_CCI_CLUSTER0_SL_IFACE_IX,
	PLAT_RK_CCI_CLUSTER1_SL_IFACE_IX
};
#endif

#ifdef IMAGE_BL31
const mmap_region_t plat_arm_mmap[] = {
	ARM_MAP_SHARED_RAM,
	ARM_MAP_EL3_TZC_DRAM,
	MAP_DEVICE0,
	MAP_DEVICE1,
#if SPM_MM
	ARM_SPM_BUF_EL3_MMAP,
#endif
#if ENABLE_RME
	ARM_MAP_GPT_L1_DRAM,
	ARM_MAP_EL3_RMM_SHARED_MEM,
#endif
#ifdef MAP_FW_NS_HANDOFF
	MAP_FW_NS_HANDOFF,
#endif
	{0}
};

#if defined(IMAGE_BL31) && SPM_MM
const mmap_region_t plat_arm_secure_partition_mmap[] = {
	MAP_REGION_FLAT(DEVICE0_BASE,
			DEVICE0_SIZE,
			MT_DEVICE | MT_RO | MT_SECURE | MT_USER),
	ARM_SP_IMAGE_MMAP,
	ARM_SP_IMAGE_NS_BUF_MMAP,
	ARM_SP_IMAGE_RW_MMAP,
	ARM_SPM_BUF_EL0_MMAP,
	{0}
};

static spm_mm_mp_info_t sp_mp_info[PLATFORM_CORE_COUNT];

const spm_mm_boot_info_t plat_arm_secure_partition_boot_info = {
	.h.type              = PARAM_SP_IMAGE_BOOT_INFO,
	.h.version           = VERSION_1,
	.h.size              = sizeof(spm_mm_boot_info_t),
	.h.attr              = 0,
	.sp_mem_base         = BL32_BASE,
	.sp_mem_limit        = BL32_LIMIT,
	.sp_image_base       = BL32_BASE,
	.sp_stack_base       = PLAT_SP_IMAGE_STACK_BASE,
	.sp_heap_base        = ARM_SP_IMAGE_HEAP_BASE,
	.sp_ns_comm_buf_base = PLAT_SP_IMAGE_NS_BUF_BASE,
	.sp_shared_buf_base  = PLAT_SPM_BUF_BASE,
	.sp_image_size       = ARM_SP_IMAGE_SIZE,
	.sp_pcpu_stack_size  = PLAT_SP_IMAGE_STACK_PCPU_SIZE,
	.sp_heap_size        = ARM_SP_IMAGE_HEAP_SIZE,
	.sp_ns_comm_buf_size = PLAT_SP_IMAGE_NS_BUF_SIZE,
	.sp_shared_buf_size  = PLAT_SPM_BUF_SIZE,
	.num_sp_mem_regions  = ARM_SP_IMAGE_NUM_MEM_REGIONS,
	.num_cpus            = PLATFORM_CORE_COUNT,
	.mp_info             = sp_mp_info,
};

static ehf_pri_desc_t arm_exceptions[] = {
	EHF_PRI_DESC(PLAT_PRI_BITS, PLAT_SP_PRI),
};

static void arm_initialize_mp_info(spm_mm_mp_info_t *mp_info)
{
	unsigned int i, j;
	spm_mm_mp_info_t *tmp = mp_info;

	for (i = 0; i < PLATFORM_CLUSTER_COUNT; i++) {
		for (j = 0; j < PLATFORM_MAX_CPUS_PER_CLUSTER; j++) {
			tmp->mpidr = (0x80000000 | (i << MPIDR_AFF1_SHIFT)) + j;
			/*
			 * Linear indices and flags will be filled
			 * in the spm_mm service.
			 */
			tmp->linear_id = 0;
			tmp->flags = 0;
			tmp++;
		}
	}
}

const struct mmap_region *plat_get_secure_partition_mmap(void *cookie)
{
	return plat_arm_secure_partition_mmap;
}

const spm_mm_boot_info_t *
const struct spm_mm_boot_info *plat_get_secure_partition_boot_info(void *cookie)
{
	arm_initialize_mp_info(sp_mp_info);
	return &plat_arm_secure_partition_boot_info;
}

EHF_REGISTER_PRIORITIES(arm_exceptions, ARRAY_SIZE(arm_exceptions), PLAT_PRI_BITS);
#endif
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
		mmap_add_region(coh_start, coh_start,			\
				coh_limit - coh_start,			\
				MT_DEVICE | MT_RW | MT_SECURE);		\
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
