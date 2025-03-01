!--------------------------------------------------------------------------------------------------!
!   CP2K: A general program to perform molecular dynamics simulations                              !
!   Copyright 2000-2022 CP2K developers group <https://cp2k.org>                                   !
!                                                                                                  !
!   SPDX-License-Identifier: GPL-2.0-or-later                                                      !
!--------------------------------------------------------------------------------------------------!

! **************************************************************************************************
!> \brief Definition of the DFTB parameter types.
!> \author JGH (24.02.2007)
! **************************************************************************************************
MODULE qs_dftb_types

   USE kinds,                           ONLY: default_string_length,&
                                              dp
#include "./base/base_uses.f90"

   IMPLICIT NONE

   PRIVATE

! *** Global parameters ***

   CHARACTER(len=*), PARAMETER, PRIVATE :: moduleN = 'qs_dftb_types'

! **************************************************************************************************
   TYPE qs_dftb_atom_type
      ! PRIVATE
      CHARACTER(LEN=default_string_length)   :: typ
      CHARACTER(LEN=default_string_length)   :: name
      LOGICAL                                :: defined
      INTEGER                                :: z !atomic number
      REAL(KIND=dp)                          :: zeff !effective core charge
      INTEGER                                :: natorb !number of orbitals
      INTEGER                                :: lmax !max angular momentum
      REAL(KIND=dp), DIMENSION(0:3)          :: skself !orbital energy
      REAL(KIND=dp), DIMENSION(0:3)          :: occupation !free atom occupation
      REAL(KIND=dp), DIMENSION(0:3)          :: eta !orbital hardness
      REAL(KIND=dp)                          :: energy !free atom energy
      REAL(KIND=dp)                          :: cutoff !cutoff radius for f matrix
      REAL(KIND=dp)                          :: xi, di !London parameter
      REAL(KIND=dp)                          :: rcdisp !cutoff radius for vdW
      REAL(KIND=dp)                          :: dudq !DFTB3 hardness derivative
   END TYPE qs_dftb_atom_type

! **************************************************************************************************
   TYPE qs_dftb_pairpot_type
      REAL(KIND=dp)                          :: dgrd ! grid spacing
      INTEGER                                :: ngrd ! number of grid points
      INTEGER                                :: ngrdcut ! grid cutoff
      INTEGER                                :: llm ! number of interactions (l,l,m)
      INTEGER                                :: n_urpoly ! order of polynomial
      REAL(KIND=dp)                          :: urep_cut ! cutoff for repulsive pot.
      REAL(KIND=dp), DIMENSION(10)           :: urep ! coefficients for repulsive
      ! potential in polynomial form
      INTEGER                                :: spdim ! number of points for
      ! spline representation
      REAL(KIND=dp)                          :: s_cut ! left-hand cutoff
      REAL(KIND=dp), DIMENSION(3)            :: srep ! coefficients for extrapolation
      REAL(KIND=dp), DIMENSION(:, :), POINTER :: spxr ! spline points
      REAL(KIND=dp), DIMENSION(:, :), POINTER :: scoeff ! spline coefficients
      REAL(KIND=dp), DIMENSION(2)            :: surr ! coefficients for last point
      REAL(KIND=dp), DIMENSION(:, :), POINTER :: fmat ! Slater-Koster table (Hamiltonian)
      REAL(KIND=dp), DIMENSION(:, :), POINTER :: smat ! Slater-Koster table (overlap)
      ! van der Waals parameter
      REAL(KIND=dp)                          :: xij, dij ! standard LJ parameters
      REAL(KIND=dp)                          :: x0ij ! Evdw(x0) = 0
      REAL(KIND=dp)                          :: a, b, c ! Short range polynomial coeffs
   END TYPE qs_dftb_pairpot_type

! *** Public data types ***

   PUBLIC :: qs_dftb_atom_type, qs_dftb_pairpot_type, &
             qs_dftb_pairpot_init, qs_dftb_pairpot_create, qs_dftb_pairpot_release

CONTAINS

! **************************************************************************************************
!> \brief ...
!> \param pairpot ...
! **************************************************************************************************
   SUBROUTINE qs_dftb_pairpot_init(pairpot)
      TYPE(qs_dftb_pairpot_type), DIMENSION(:, :), &
         POINTER                                         :: pairpot

      INTEGER                                            :: i, j

      IF (ASSOCIATED(pairpot)) THEN
         DO i = 1, SIZE(pairpot, 1)
            DO j = 1, SIZE(pairpot, 2)
               NULLIFY (pairpot(i, j)%spxr, pairpot(i, j)%scoeff, &
                        pairpot(i, j)%smat, pairpot(i, j)%fmat)
            END DO
         END DO
      END IF

   END SUBROUTINE qs_dftb_pairpot_init

! **************************************************************************************************
!> \brief ...
!> \param pairpot ...
!> \param ngrd ...
!> \param llm ...
!> \param spdim ...
! **************************************************************************************************
   SUBROUTINE qs_dftb_pairpot_create(pairpot, ngrd, llm, spdim)
      TYPE(qs_dftb_pairpot_type)                         :: pairpot
      INTEGER, INTENT(IN)                                :: ngrd, llm, spdim

      pairpot%ngrd = ngrd
      pairpot%spdim = spdim
      pairpot%llm = llm

      IF (spdim > 0) THEN
         ALLOCATE (pairpot%spxr(spdim, 2))

         ALLOCATE (pairpot%scoeff(spdim, 4))
      END IF

      ALLOCATE (pairpot%fmat(ngrd, llm))

      ALLOCATE (pairpot%smat(ngrd, llm))

   END SUBROUTINE qs_dftb_pairpot_create

! **************************************************************************************************
!> \brief ...
!> \param pairpot ...
! **************************************************************************************************
   SUBROUTINE qs_dftb_pairpot_release(pairpot)
      TYPE(qs_dftb_pairpot_type), DIMENSION(:, :), &
         POINTER                                         :: pairpot

      INTEGER                                            :: i, j, n1, n2

      IF (ASSOCIATED(pairpot)) THEN
         n1 = SIZE(pairpot, 1)
         n2 = SIZE(pairpot, 2)
         DO i = 1, n1
            DO j = 1, n2
               IF (ASSOCIATED(pairpot(i, j)%spxr)) THEN
                  DEALLOCATE (pairpot(i, j)%spxr)
               END IF
               IF (ASSOCIATED(pairpot(i, j)%scoeff)) THEN
                  DEALLOCATE (pairpot(i, j)%scoeff)
               END IF
               IF (ASSOCIATED(pairpot(i, j)%smat)) THEN
                  DEALLOCATE (pairpot(i, j)%smat)
               END IF
               IF (ASSOCIATED(pairpot(i, j)%fmat)) THEN
                  DEALLOCATE (pairpot(i, j)%fmat)
               END IF
            END DO
         END DO
         DEALLOCATE (pairpot)
      END IF

   END SUBROUTINE qs_dftb_pairpot_release

END MODULE qs_dftb_types

