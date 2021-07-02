# readMEDYANtraj
**MATLAB(R)** code to parse trajectories generated in MEDYAN.

# Output
Generates a **.mat** file with trajectory data and a PDB file that has the trajectory snapshots saved similar to NMR models.

# Execution 

The following code block outlines usage to parse example trajectory

```matlab
N=1;
ouptutfile = 'test';
outputdir ='./';
x = '0';
varargin={'filereadpath','./example/'}
readMEDYANtraj(N, outputfile outputdir, x, varargin);
```

# Requisites

All input variables are of character array datatype to ensure easy execution in case the Matlab needs to be precompiled.

Current version assumes the trajectories are stored in folders with the string **run** followed by numerals (example **run1**, **run2**, etc.)

# Additional options

Additional options are passed as a cell array in varargin as a **key**, **value** pair. 

| varargin entry                             | feature                                                      |
| ------------------------------------------ | ------------------------------------------------------------ |
| 'filereadpath', 'path/to/file'             | Allows user to specify path to trajectory files              |
| 'stringtag', 'tag-string'                  | stringtag option helps user to parse trajectories in folders with custom tags such as **run1_single** **run1_test** etc |
| 'tastkstringtag', 'stringtag'              | **taskstringtag** allows user to parse a subset of the trajectory data. Options are<br />**SMP** - parse snapshot, monomer, and plusend **.traj** files<br />**GCC** - parse graph, chemistry, and concentration **.traj** files<br />**PDB** - write the PDB file <br />**Note** To generate the PDB file alone to visualize trajectory in **VMD**, taskstringtag value should be **SMP-PDB** <br />default **SMP-GCC-PDB** |
| 'runarray', 'true'  OR 'runarray', 'false' | default **false** .<br />if **true** all the trajectory data is stored in a single **.mat** file example: **outputfile.mat** <br />if **false** trajectory data are written into different **.mat** files example: **outputfile_1.mat** <br /> |

# Output files

| filetype  | data stored                                                  |
| --------- | ------------------------------------------------------------ |
| ***.mat** | Depending on the taskstringtag value and runarray value, different sets of output are generated.<br />**outputfilename_tasktag_runnunmber.mat**<br />example: test_S1.mat, test_MS1.mat, test.GC1.mat will have snapshot.traj, monomers.traj and plusends.traj, graph.traj, concentrations.traj, and chemistry.traj respectively corresponding to trajectory **run1** |
| ***.pdb** | Visualizable trajectory in PDB format with each snapshot rendered as an NMR model (**MODEL1, MODEL2,etc**) PDB file contains each filament as a Calpha atom of an amino acid. If multiple trajectories are parsed, the visualization file is only generated for the first trajectory. |

# Accessing data ***.mat** file

Trajectory data is stored as an object of matlab class. 

``` matlab
X=r(1).s(10).f.coord_cell;
```

Above command will store the filament coordinates  corresponding to run 1 and snapshot 10 as a 1d cell array in variable X.

Similar options are available for other trajectory files as well.

# Visualizing trjectory

Please refer to the MEDYAN usage guide to see the steps to visualize the PDB file in VMD.
