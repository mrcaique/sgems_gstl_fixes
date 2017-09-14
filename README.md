# SGeMS and GsTL fixes #

This repository contains the source files fixed for compiling [SGeMS](http://sgems.sourceforge.net/) in the recent versions of GCC (GNU C Compiler).
To get the source code of SGeMS, the SVN repository can be seen [here](https://svn.code.sf.net/p/sgems/svn/trunk/) and the source code
of GsTL (it is a dependacy of SGeMS) can be seen [here](http://gstl.sourceforge.net/).

**NOTE**: Both SGeMS and GsTL are legacy projects!

Here are the original path for the files in the respective repository.

**GsTL files:**

* `GsTL/GsTL/cdf_estimator/soft_indicator_cdf_estimator.h`

* `GsTL/GsTL/matrix_library/gstl_tnt/gstl_gauss_solver.h`

* `GsTL/GsTL/utils/smartptr.cc`

* `GsTL/GsTL/univariate_stats/build_cdf.h`

**SGeMS files:**

* `sgems/GsTLAppli/geostat/kriging_mean.cpp`

* `sgems/GsTLAppli/geostat/utilities.h`

## Important notes ##
* This repository contains the script to compile SGeMS in recent versions of GCC. It was tested in two versions of Ubuntu Linux OS: 14.04 LTS "Thrusty Tahr" and 16.04 LTS "Xenial Xerus";
* The script was tested with following versions of GCC: 4.8.2 (in Ubuntu 14.04 LTS), 4.8.4 (in the Ubuntu 14.04 LTS) and 5.4.0 (in the Ubuntu 16.04 LTS).
* **For Ubuntu 14.04 LTS, use 'libcoin80' package instead of 'libcoin80v5'**;
* Sudo access is needed to run the script. For two reasons: install dependencies and set ldconfig;
* Default localization of the sources is in `~/.sgems_source`;
* **To run SGeMS is necessary to set `GSTLAPPLIHOME` variable**. After compilation, a file `env.sh`, generated in `~/.sgems_source`, can be used to set the environment.