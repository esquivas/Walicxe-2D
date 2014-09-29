#---------------------------------------------------
# WALICXE-2D
#---------------------------------------------------
#   Name of the executable
PROGRAM=WALICXE-2D
#
#   Choice of compiler: ifort and gfortran are tested
#   if MPI enabled, do not use mpif90, but rather the base compiler
#   of the mpi build (see 'mpif90 --version')
#COMPILER= gfortran
COMPILER= ifort
#
#   Compiler flags, make sure they are compatible with 
#   the previous selection
#  -g -traceback
FLAGS= -O3 -cpp -i_dynamic -vec-report0
#
#---------------------------------------------------
#   compilation time parameters (Y=on, N=off)
#   watch out all of the following is case sensitive
#---------------------------------------------------
#   MPI paralalelization
MPIP = Y
#   Double Precision (Default is single)
DOUBLEP= Y
#   Riemann Solver for the fluxes (available: HLL, HLL_HLLC, HLLC)
FLUXES = HLLC
#   Type of output (BIN are raw unformatted, VTK are binary)
OUTBIN = Y
OUTVTK = N
#   additional equations (i.e. passive scalars)?
PASSIVES = Y
#   cylindrical geometry source terms (axisymmetric)
CYLINDRICAL = Y
#   adiabatic or type of cooling (choose only one)
#   options are ADIABATIC, H, BBC, CORONAL
#   ADIABATIC: of course turns off the cooling
#   H: single parametrized cooling function
#   BBC: cooling function of Benjamin, Benson and Cox (2003)
#   DMC: Coronal eq. (tabulated) from Dalgarno & Mc Cray (1972)
COOLING   = H
#   boundary conditions
#   options are OUTFLOW, REFLECTIVE, PERIODIC , INFLOW, OTHERB
#   INFLOW refers to the outer grid boundary  (e.g. to
#   impose a plane parallel side wind)
#   OTHER is used to add sink/sources at any point in the
#   computational domain, calls 'otherbounds.pro'
LEFTX   = REFLECTIVE
RIGHTX  = OUTFLOW
BOTTOMY = REFLECTIVE
TOPY    = OUTFLOW
OTHERB  = Y
#   choice of slope limiter, available limiters are:
#   limiter =-1: no average, 0 : no limiter, 1: Minmod,
#   2: Van Leer, 3: Van Albada,4: UMIST, 5: Woodward
#   6: Superbee
LIMITER=  2
#####################################################
# There should be no need to modify below this line #
#####################################################
#   list of objects to compile
OBJECTS =\
./src/parameters.o		\
./src/globals.o			\
./src/dmc_module.o		\
./src/sn.o				\
./src/jet.o 			\
./src/user_mod.o 		\
./src/main.o			\
./src/initmain.o		\
./src/basegrid.o		\
./src/refine.o        	\
./src/updatelpup.o		\
./src/calcprim.o 		\
./src/uprim.o 			\
./src/loadbalance.o   	\
./src/output.o			\
./src/timestep.o		\
./src/sound.o 			\
./src/tstep.o			\
./src/hllcfluxes.o		\
./src/hllfluxes.o		\
./src/hll_hllcfluxes.o	\
./src/swapy.o			\
./src/step.o			\
./src/limiter.o 		\
./src/primf.o 			\
./src/primu.o 			\
./src/locatebounds.o	\
./src/viscosity.o		\
./src/boundaryI.o		\
./src/boundaryII.o		\
./src/coolingh.o		\
./src/coolingdmc.o		\
./src/criteria.o		\
./src/markref.o			\
./src/critneighup.o 	\
./src/critneighdown.o	\
./src/admesh.o			\
./src/coarse.o			\
./src/updatelpdown.o
#---------------------------------------------------
ifeq ($(DOUBLEP),Y)
FLAGS += -DDOUBLEP
ifeq ($(COMPILER),ifort)
FLAGS += -r8
endif
ifeq ($(COMPILER),gfortran)
FLAGS += -fdefault-real-8
endif
endif
ifeq ($(MPIP),Y)
FLAGS += -DMPIP
COMPILER = mpif90
endif
ifeq ($(FLUXES),HLLC)
FLAGS += -DHLLC
endif
ifeq ($(FLUXES),HLL)
FLAGS += -DHLL
endif
ifeq ($(FLUXES),HLL_HLLC)
FLAGS += -DHLL_HLLC
endif
ifeq ($(OUTBIN),Y)
FLAGS += -DOUTBIN
endif
ifeq ($(OUTVTK),Y)
FLAGS += -DOUTVTK
endif
ifeq ($(PASSIVES),Y)
FLAGS += -DPASSIVES
endif
ifeq ($(CYLINDRICAL),Y)
FLAGS += -DCYLINDRICAL
endif
ifeq ($(COOLING),ADIABATIC)
FLAGS += -DADIABATIC
endif
ifeq ($(COOLING),H)
FLAGS += -DCOOLINGH
endif
ifeq ($(COOLING),BBC)
FLAGS += -DCOOLINGBBC
endif
ifeq ($(COOLING),DMC)
FLAGS += -DCOOLINGDMC
endif
ifeq ($(LEFTX),PERIODIC)
FLAGS += -DPERIODX
endif
ifeq ($(BOTTOMY),PERIODIC)
FLAGS += -DPERIODY
endif
ifeq ($(LEFTX),REFLECTIVE)
FLAGS += -DREFXL
endif
ifeq ($(RIGHTX),REFLECTIVE)
FLAGS += -DREFXR
endif
ifeq ($(BOTTOMY),REFLECTIVE)
FLAGS += -DREFYB
endif
ifeq ($(TOPY),REFLECTIVE)
FLAGS += -DREFYT
endif
ifeq ($(LEFTX),OUTFLOW)
FLAGS += -DOUTFXL
endif
ifeq ($(RIGHTX),OUTFLOW)
FLAGS += -DOUTFXR
endif
ifeq ($(TOPY),OUTFLOW)
FLAGS += -DOUTFYT
endif
ifeq ($(BOTTOMY),OUTFLOW)
FLAGS += -DOUTFYB
endif
ifeq ($(LEFTX),INFLOW)
FLAGS += -DINFXL
endif
ifeq ($(RIGHTX),INFLOW)
FLAGS += -DINFXR
endif
ifeq ($(TOPY),INFLOW)
FLAGS += -DINFYT
endif
ifeq ($(BOTTOMY),INFLOW)
FLAGS += -DINFYB
endif
ifeq ($(OTHERB),Y)
FLAGS += -DOTHERB
endif
FLAGS += -DLIMITER=$(LIMITER)
#---------------------------------------------------
$(PROGRAM)  : ${OBJECTS}
	$(COMPILER) $(FLAGS) -o $@ $(OBJECTS)

%.o:%.f90
	$(COMPILER) $(FLAGS) -c $^ -o $@

.PHONY : clean
clean :
	rm -f *.o *.mod src/*.o src/*.mod
	rm -f $(PROGRAM)
#---------------------------------------------------
