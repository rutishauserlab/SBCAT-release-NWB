# Sample code for: Control of working memory maintenance by theta-gamma phase amplitude coupling of human hippocampal neurons

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Generic badge](https://img.shields.io/badge/release-pending-green.svg)](https://rb.gy/otj7q)
[![Generic badge](https://img.shields.io/badge/DOI-pending-orange.svg)](https://rb.gy/otj7q)

## Introduction

This repository contains the code that accompanies Daume et. al. 'Control of working memory maintenance by theta-gamma phase amplitude coupling of human hippocampal neurons.' The purpose of the code in this repository is to provide examples of how to use the released data. This dataset is formatted in the [Neurodata Without Borders (NWB)](https://www.nwb.org/) format, which can easily be accessed from both MATLAB and Python as described [here](https://nwb-schema.readthedocs.io/en/latest/index.html). 

Abstract of the paper:
>Retaining information in working memory (WM) is a demanding process that relies on cognitive control to protect memoranda-specific persistent activity from interference. How cognitive control regulates WM storage, however, remains unknown. Here we show that interactions of frontal control and hippocampal persistent activity are coordinated by theta-gamma phase amplitude coupling (TG-PAC). We recorded single neurons in the human medial temporal and frontal lobe while patients maintained multiple items in WM. In the hippocampus, TG-PAC was indicative of WM load and quality. We identified cells that selectively spiked during nonlinear interactions of theta phase and gamma amplitude. The spike timing of these PAC neurons was coordinated with frontal theta activity when cognitive control demand was high. By introducing noise correlations with persistently active neurons in the hippocampus, PAC neurons shaped the geometry of the population code. This led to higher-fidelity representations of WM content that were associated with improved behavior. Our results support a multicomponent architecture of WM, with frontal control managing maintenance of WM content in storage-related areas3–5.Within this framework, hippocampal TG-PAC integrates cognitive control and WM storage across brain areas, thereby suggesting a potential mechanism for top-down control over sensory-driven processes.




<p align="center">
  <img width="500" height="400" src="https://github.com/rutishauserlab/SBCAT-release-NWB/blob/main/assets/Figure1.png">
</p>
<!--   <img width="400" height="500" src="https://placehold.co/400x500.png"> -->

## Installation (Code)

This repository can be downloaded by entering the following commands:

`cd $target_directory`

`git clone https://github.com/rutishauserlab/SBCAT-release-NWB.git`

## Installation (MatNWB)

Running the provided code and analyzing the dataset in MATLAB requires the download and initialization of MatNWB, a MATLAB interface for reading and writing NWB 2.x files. Instructions for how to [download and initialize MatNWB](https://github.com/NeurodataWithoutBorders/matnwb) have been listed on the project's public git repo. Further documentation for how to use MatNWB can be found [here](https://neurodatawithoutborders.github.io/matnwb/). MatNWB version 2.6.0.2 was used for the curation and analysis of this dataset.

## Installation (Data)

NOTE: The dataset will be made publicly available upon acceptance of the underlying paper. 

The dataset is available in NWB format from the DANDI Archive under [Placeholder](https://rb.gy/otj7q). This dataset is also available from the DABI Archive under [Placeholder](https://rb.gy/otj7q)

Dandi datasets are accessible through the Dandi command line interface (CLI). To install this Python client, use `pip install dandi` or `conda install -c conda-forge dandi`, depending on your Python environment setup. 

After installing the Dandi CLI, use `dandi download [insert dataset link]` to download the dataset. 

## File Validation (Python)

NWB Files can additionally be loaded and analyzed using the [PyNWB](https://github.com/NeurodataWithoutBorders/pynwb) python package. Further documentation can be found [here](https://pynwb.readthedocs.io/en/stable/). 


Validation of this dataset was performed using PyNWB (2.3.1) and PyNWB-dependent packages, such as nwbinspector (0.4.28) and dandi (0.55.1). The command lines used for each method are as follows:
* dandi: `dandi validate $target_directory`
* nwbinspector: `nwbinspector $target_directory`
* PyNWB: `$file_list = Get-ChildItem $target_directory -Filter *.nwb -Recurse | % { $_.FullName }; python -m pynwb.validate $file_list`

All validators returned no errors in data formatting & best-use practices across all uploaded files. 


## MATLAB Analysis

The main script in this repo, `NWB_SBCAT_import_main.m`, is designed to analyze the released dataset and to reproduce select figures & metrics noted in Daume et. al. [year]. It can calculate several metrics related to behavior (reaction time, accuracy), spike sorting, and single-unit (SU) activity during the task.

### Steps to Use the Script
* **Set Parameters:** The first section of the script sets important parameters. The `importRange` is the range of files for the dataset. For the current release, subject IDs have a range of `1:44`. The full range can also be specified by setting `importRange=[]`

* **Initialization and Pathing:** The script then defines the directory paths for the code, the currently installed MatNWB package, and the dataset, and then adds them to the MATLAB path. If figures are generated, there is an additional option to add a custom save destination. Please ensure that the defined paths in the script are correct for your setup. This section also uses MatNWB's generateCore() function to initialize the NWB API if it has not been initialized already.

* **Import Datasets From Folder:** The script will then import datasets from the given folder using the `NWB_importFromFolder` function. Only files specified using `importRange` will be loaded into the workspace. 

* **Extracting Single Units:** Single unit information is extracted from the loaded NWB files for ease of indexing, using the `NWB_SB_extractUnits` function. If spike waveforms are not needed for analysis, the `load_all_waveforms` flag can be set to `0` to only extract the mean waveform. All future plots will use this mean waveform instead of a spike waveform pdf. 

* **Single Unit Analysis:** This section is preceded by a parameters section, which allows for the control of various stages of the analysis and plotting process. For example, one can choose to plot figures for significant cells by setting `paramsSC.doPlot = 0` or filter units being used for analysis by specifying a minimum firing rate threshold `paramsSC.rateFilter`. To disable analysis of all cells entirely, set `paramsSC.calcSelective = 0`. 

* **Selectivity by Area:** This section calculates the proportion of category-selective cells across each area measured. 

* **Single Unit Analysis Example:** This section plots the example category-selective cell that can be found in Fig 3a of Daume et al. To decrease loading time, please set `importRange = 6`. 

* **LFP PAC Example Figure:** This section recreates the example gamma amplitude distribution across theta phase bins in addition to the comodulograms across load conditions (Fig 2d, Daume et al). To decrease loading times, set `importRange = 5`

* **SU PAC Example Figure:** This section illustrates the binning and the model comparisons used in PAC neuron selection for an example neuron. To decrease loading times, set `importRange = 32`

* **Recordings by Area:** The script also calculates the number of LFP channels and cells by area and saves the results into a .xlsx file. This can be disabled by setting `countAreas = 0`.
  
* **Spike Sorting Quality Metrics:** This section plots spike sorting metrics for single units recorded in the Sternberg/screening tasks. These metrics include the percentage of inter-spike intervals (ISIs) that were less than 3 ms, mean firing rates for all units, coefficient of variation (CV2) values for all units, signal-to-noise ratio (SNR) of the peak of the mean waveform, mean SNR for all values in a unit’s mean waveform, pairwise projection distance between each unit in which multiple units were found on the same electrode, isolation distance (scaled to log 10 for ease of viewing) across all units for which this metric was defined.

Please make sure to thoroughly read the comments in the code to understand the functionality of each part. If you encounter any problems, please report them as issues in the repository.


## Contributors
* [Michael Kyzar](mailto:kyzarnexus@gmail.com)
* [Jonathan Daume](mailto:Jonathan.Daume@cshs.org)
* [Ueli Rutishauser](mailto:Ueli.Rutishauser@cshs.org) (Principal Investigator)

>[[Citation Pending](https://rb.gy/otj7q)]


## Funding

Acquisition of this dataset has been supported by the National Institute of Health (U01NS117839-04).

## License 

"workingmem-release-NWB" Copyright (c) 2023, Rutishauser Lab. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
