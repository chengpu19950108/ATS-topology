# ATS-topology
Codes and necessary FE model for ATS topology optimization method.

  The ATS-topology is used for the optimization of connection joints, the two parts of the joints 
are numbered as 1 and 2. The codes illustrated here can only be used for this example here. When
applicated in other examples, the FE model and some parameters here should be corrected according
to the theory.

  Attention: in this example, two completely overlapping grids are used to construct parts 1 and 2, 
which is to facilitate the updating of design variables, and ensure the reasonable grid consecutiveness
and edge conditions.

Software needed:
Matlab
Ls-dyna (installed in  'F:\ls-dyna\program\ls-dyna_smp_s_R700_winx64_ifort101.exe' in this example)
