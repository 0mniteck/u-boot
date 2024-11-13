# U-Boot RockChip rk3399 with StandaloneMM Support (W.I.P.)
Status:
* [x] Build SPM StandaloneMM from EDK2 with GCC5 (Reproducable)
* [x] Build Optee with StandaloneMM support (Reproducable)
* [ ] Build TF-A with StandaloneMM support (DEBUG)
  * [x] Transition to xlat_v2 to add dynamic translation table support (Builds)
  * [x] Configure sm_mem_map regions
    * [ ] Unhandled Exception in EL3
* [ ] Test Optee MM Communicate
* [ ] Add support for ARM FFA MM
* [ ] Test vTPM
