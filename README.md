# Setting up EnergyPlus on Legion

How to run stuff on the Legion server at UCL
--------------

####1. First you need to make sure the correct compilers are loaded. For EnergyPlus you will need:

	module load cmake/2.8.10.2
	module load compilers/gnu/4.9.2

####2. To get the EnergyPlus source code off GitHub you will need to:

	export GIT_SSL_NO_VERIFY=true
	#make a software directory where your software will be stored
	mkdir Software
	cd Software
	git clone https://github.com/NREL/EnergyPlus
	cd EnergyPlus
	
####3. Checkout the version of EnergyPlus you need e.g.:

	git checkout tags/v8.2.0-Update-1.2
	#You can do: git tag -l to show what versions are available
	
####4. You will need to create the directory where the code is built:

	mkdir ../EnergyPlus_82_Build
	cd ../EnergyPlus_82_Build    
  
  - where you can replace "82" with a different *Version* if desired

####5. Confure the cmake compiler in the build directory:

	ccmake ../EnergyPlus
 
  - Press *c* to configure
  - Turn on BUILD_FORTRAN
  - Turn on BUILD_PACKAGE
  - Change Build Type -> *Release*
  - Change path -> *build path* created in step 4
  - Press *c* to re-configure
  - An extra option should appear EPLUS_BUILDSUPPORT_REPO (leave this as it is)
  - Press *c* to re-configure
  - Press *g* to generate the makefile

####6. Compile the code:

	make -j N   

  - where *N* is the number of cores to use e.g. 8
  - Wait ~15 mins

####7. You will now need some files to the bin folder

	mkdir bin
	cp Products/* bin
	cp Energy+.idd bin
	cp scripts/runenergyplus bin
	
	#Copy over any other .idds you need e.g.
	cp ../EnergyPlus/idd/SlabGHT.idd bin
	
	#and add some weather files:
	
	mkdir EnergyPlus-8-2-0 
	mkdir EnergyPlus-8-2-0/WeatherData
	cp ../EnergyPlus/weather/* EnergyPlus-8-2-0/WeatherData
	
	
####8. In order to run the *runenergyplus* command you will need to make it an executable and add the path to the bin directory to the $PATH variable:
	
	chmod u+x bin/runenergyplus
	export PATH 
	PATH=$PATH:<path_to_bin_directory>

  - the above two lines should also be added to your .bash_profile file so that you don't have to do this each time you log in

####9. You can then try some test runs using .idf file from EnergyPlus/test
	
	cd
	mkdir Simulations
	mkdir Simulations/test
	cd Simulations/test
	cp ~/Software/EnergyPlus/test/1ZoneUncontrolled.idf ./
	runenergyplus 1ZoneUncontrolled.idf USA_AZ_Phoenix_TMY2
	
####10. Or, if you have lots of idfs that need running you can put them all in the same directory and run one of the scripts in the scripts directory (currently only series script):
  - series_script.sh : for running energyplus on all the files in a folder in series
  - to run you will have to edit it so that it points to the right directory working directory (WORK_DIR):
  	
	qsub series_script.sh  	
 
