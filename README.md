# Setting up EnergyPlus on UCL's MYRIAD (HPC)

How to run stuff on the MYRIAD server at UCL
--------------

Installing a pre-built Linux version of Energplus
--------------

#### 1. Once logged onto MYRIAD (see https://www.rc.ucl.ac.uk/docs/Clusters/Grace/) move to a suitable directory, e.g:
	
	cd Software/
	mkdir EnergyPlus_v9.4
	cd EnergyPlus_v9.4
	
#### 2. Get the required version from the E+ website (https://energyplus.net/downloads), e.g for version 9.4:

	wget https://github.com/NREL/EnergyPlus/releases/download/v9.4.0/EnergyPlus-9.4.0-998c4b761e-Linux-Ubuntu18.04-x86_64.sh

#### 3. You can then follow the Linux istallation instructions (https://energyplus.net/installation-linux), but without admistrator privileges:

	chmod +x EnergyPlus-9.4.0-998c4b761e-Linux-Ubuntu18.04-x86_64.sh
	./EnergyPlus-9.4.0-998c4b761e-Linux-Ubuntu18.04-x86_64.sh
	
#### 4. When asked (enter 'y'): 
	
	Do you accept the license? [y/\033[1;31mN\033[0m]: 
	y
	
#### 5. Choose a suitible directories when asked,:
	
	EnergyPlus install directory [/usr/local/EnergyPlus-9-4-0]:
	EnergyPlus-940
	
	Symbolic link location (enter \033[1;31m"n"\033[0m for no links) [/usr/local/bin]:
	EnergyPlus-940

#### 6. Then just set the path to the installation folder to the director in the PATH variable (also add this line to your ~/.bash_profile file):
	
	export PATH
	PATH=$PATH:/home/<your_login_name>/<path_to_where_you installed EnergyPlus>/bin/

--------------

Running EnergPlus Simulations on MYRIAD in parrallel
--------------

#### 1. Copy your idf files from a local directory onto MYRIAD into a suitable folder (more info: https://www.rc.ucl.ac.uk/docs/howto/#how-do-i-transfer-data-onto-the-system):
	
	scp <local_data_file> <remote_user_id>@<remote_hostname>:<remote_path>
	
#### 2. Set up your job submission script

	- Series and parrallel scripts are included in the 'scripts' folder of this repository
	- You will need to modify the WORK_DIR
	- Specify the weather file you want to use
	- Modify the number of files you want to run
	- Change the runenergyplus command to suit your needs
	- Contact p.symonds@ucl.ac.uk for more help with this
	
#### 3. Submit the job
  	
	qsub series_script.sh  	
	
#### 4. Check that the script is running (lots more detail/commands here: https://www.rc.ucl.ac.uk/docs/howto/): 
  	
	qstat series_script.sh  	
	
-----------------------------------------------------------------------

Compiling EnergyPlus from source (Not trivial & not updated since 2016)
-----------------------------------------------------------------------

#### 1. First you need to make sure the correct compilers are loaded. For EnergyPlus you will need:

	module unload compilers
 	module unload gcc-libs
   	module load compilers/gnu/7.3.0
    	module load gcc-libs/7.3.0
     	module load cmake/3.27.3

We have found that for EnergyPlus v9.4, the gnu compilers version 7.3.0 works, but versions 4.9.2 and 10.2.0 do not.  

#### 2. To get the EnergyPlus source code off GitHub you will need to:

	export GIT_SSL_NO_VERIFY=true
	#make a software directory where your software will be stored
	mkdir Software
	cd Software
	git clone https://github.com/NREL/EnergyPlus
	cd EnergyPlus
	
#### 3. Checkout the version of EnergyPlus you need e.g.:

	git checkout tags/v8.2.0-Update-1.2
	#You can do: git tag -l to show what versions are available
	
#### 4. You will need to create the directory where the code is built:

	mkdir ../EnergyPlus_82_Build
	cd ../EnergyPlus_82_Build    
  
  - where you can replace "82" with a different *Version* if desired

#### 5. Confure the cmake compiler in the build directory:

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

#### 6. Compile the code:

	make -j N   

  - where *N* is the number of cores to use e.g. 8
  - Wait ~15 mins

#### 7. You will now need some files to the bin folder

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

