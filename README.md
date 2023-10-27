# Sample code for: Control of working memory maintenance by theta-gamma phase amplitude coupling of human hippocampal neurons

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Generic badge](https://img.shields.io/badge/unpublished_version-green.svg)](https://rb.gy/otj7q)
[![Generic badge](https://img.shields.io/badge/DOI_placeholder-orange.svg)](https://rb.gy/otj7q)

## Introduction


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

## Installation & File Validation (Python)

NWB Files can additionally be loaded and analyzed using the [PyNWB](https://github.com/NeurodataWithoutBorders/pynwb) python package. Further documentation can be found [here](https://pynwb.readthedocs.io/en/stable/). 


Validation of this dataset was performed using PyNWB (2.3.1) and PyNWB-dependent packages, such as nwbinspector (0.4.28) and dandi (0.55.1). The command lines used for each method are as follows:
* dandi: `dandi validate $target_directory`
* nwbinspector: `nwbinspector $target_directory`
* PyNWB: `$file_list = Get-ChildItem $target_directory -Filter *.nwb -Recurse | % { $_.FullName }; python -m pynwb.validate $file_list`

All validators returned no errors in data formatting & best-use practices across all uploaded files. 


## MATLAB Analysis
* NOTE: To be added































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
