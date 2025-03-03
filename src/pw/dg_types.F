!--------------------------------------------------------------------------------------------------!
!   CP2K: A general program to perform molecular dynamics simulations                              !
!   Copyright 2000-2022 CP2K developers group <https://cp2k.org>                                   !
!                                                                                                  !
!   SPDX-License-Identifier: GPL-2.0-or-later                                                      !
!--------------------------------------------------------------------------------------------------!

! **************************************************************************************************
!> \par History
!>      none
! **************************************************************************************************
MODULE dg_types

   USE dg_rho0_types,                   ONLY: dg_rho0_create,&
                                              dg_rho0_release,&
                                              dg_rho0_retain,&
                                              dg_rho0_type
#include "../base/base_uses.f90"

   IMPLICIT NONE

! Information on the assignment function for Ewald
! **************************************************************************************************
   TYPE dg_type
      PRIVATE
      INTEGER :: ref_count, id_nr
      INTEGER :: grid_index
      TYPE(dg_rho0_type), POINTER :: dg_rho0
   END TYPE dg_type

! **************************************************************************************************
   TYPE dg_p_type
      TYPE(dg_type), POINTER :: dg
   END TYPE dg_p_type

   CHARACTER(len=*), PARAMETER, PRIVATE :: moduleN = 'dg_types'
   INTEGER, SAVE, PRIVATE :: last_dg_id = 0

   PRIVATE
   PUBLIC :: dg_type, dg_get, &
             dg_set, dg_retain, dg_release, &
             dg_create

CONTAINS

! **************************************************************************************************
!> \brief   Get the dg_type
!> \param dg ...
!> \param id_nr ...
!> \param grid_index ...
!> \param dg_rho0 ...
!> \version 1.0
! **************************************************************************************************
   SUBROUTINE dg_get(dg, id_nr, grid_index, dg_rho0)
      TYPE(dg_type), POINTER                             :: dg
      INTEGER, OPTIONAL                                  :: id_nr, grid_index
      TYPE(dg_rho0_type), OPTIONAL, POINTER              :: dg_rho0

      IF (PRESENT(id_nr)) id_nr = dg%id_nr
      IF (PRESENT(grid_index)) grid_index = dg%grid_index
      IF (PRESENT(dg_rho0)) dg_rho0 => dg%dg_rho0

   END SUBROUTINE dg_get

! **************************************************************************************************
!> \brief   create the dg structure
!> \param dg ...
!> \version 1.0
! **************************************************************************************************
   SUBROUTINE dg_create(dg)
      TYPE(dg_type), POINTER                             :: dg

      TYPE(dg_rho0_type), POINTER                        :: dg_rho0

      ALLOCATE (dg)
      NULLIFY (dg_rho0)
      CALL dg_rho0_create(dg_rho0)
      dg%dg_rho0 => dg_rho0
      last_dg_id = last_dg_id + 1
      dg%id_nr = last_dg_id
      dg%ref_count = 1

   END SUBROUTINE dg_create

! **************************************************************************************************
!> \brief retains the given dg_type
!> \param dg the dg_type to retain
!> \par History
!>      04.2003 created [fawzi]
!> \author fawzi
!> \note
!>      see doc/ReferenceCounting.html
! **************************************************************************************************
   SUBROUTINE dg_retain(dg)
      TYPE(dg_type), POINTER                             :: dg

      CPASSERT(ASSOCIATED(dg))
      CPASSERT(dg%ref_count > 0)
      dg%ref_count = dg%ref_count + 1
   END SUBROUTINE dg_retain

! **************************************************************************************************
!> \brief releases the given dg_type
!> \param dg the dg_type to release
!> \par History
!>      04.2003 created [fawzi]
!> \author fawzi
!> \note
!>      see doc/ReferenceCounting.html
! **************************************************************************************************
   SUBROUTINE dg_release(dg)
      TYPE(dg_type), POINTER                             :: dg

      IF (ASSOCIATED(dg)) THEN
         CPASSERT(dg%ref_count > 0)
         dg%ref_count = dg%ref_count - 1
         IF (dg%ref_count == 0) THEN
            CALL dg_rho0_release(dg%dg_rho0)
            DEALLOCATE (dg)
         END IF
      END IF
      NULLIFY (dg)
   END SUBROUTINE dg_release

! **************************************************************************************************
!> \brief   Set the double grid environment
!> \param dg ...
!> \param dg_rho0 ...
!> \param grid_index ...
!> \version 1.0
! **************************************************************************************************
   SUBROUTINE dg_set(dg, dg_rho0, grid_index)
      TYPE(dg_type), POINTER                             :: dg
      TYPE(dg_rho0_type), OPTIONAL, POINTER              :: dg_rho0
      INTEGER, OPTIONAL                                  :: grid_index

      IF (PRESENT(dg_rho0)) THEN
         CALL dg_rho0_retain(dg_rho0)
         CALL dg_rho0_release(dg%dg_rho0)
         dg%dg_rho0 => dg_rho0
      END IF
      IF (PRESENT(grid_index)) dg%grid_index = grid_index
   END SUBROUTINE dg_set

END MODULE dg_types
