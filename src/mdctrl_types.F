!--------------------------------------------------------------------------------------------------!
!   CP2K: A general program to perform molecular dynamics simulations                              !
!   Copyright 2000-2022 CP2K developers group <https://cp2k.org>                                   !
!                                                                                                  !
!   SPDX-License-Identifier: GPL-2.0-or-later                                                      !
!--------------------------------------------------------------------------------------------------!

! **************************************************************************************************
!> \brief A common interface for passing a callback into the md_run loop.
!> \par History
!> \author Ole
! **************************************************************************************************
MODULE mdctrl_types

   USE kinds,                           ONLY: dp
#include "./base/base_uses.f90"

   IMPLICIT NONE
   PRIVATE

   TYPE glbopt_mdctrl_data_type
      INTEGER                                    :: md_bump_counter
      REAL(KIND=dp), DIMENSION(:), ALLOCATABLE   :: epot_history
      INTEGER                                    :: output_unit
      INTEGER                                    :: itimes
      INTEGER                                    :: bump_steps_upwards
      INTEGER                                    :: bump_steps_downwards
      INTEGER                                    :: md_bumps_max
   END TYPE glbopt_mdctrl_data_type

   TYPE mdctrl_type
      TYPE(glbopt_mdctrl_data_type), POINTER                 :: glbopt => Null()
      !... and possible more in the future
   END TYPE mdctrl_type

   PUBLIC :: mdctrl_type, glbopt_mdctrl_data_type

   CHARACTER(len=*), PARAMETER, PRIVATE :: moduleN = 'mdctrl_types'

END MODULE mdctrl_types

