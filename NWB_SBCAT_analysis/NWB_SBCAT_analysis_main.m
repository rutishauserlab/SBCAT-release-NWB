%% NWB_SBCAT_import_main
% Sample code to load/analyze the provided dataset for Daume et. al. 
% Calculates the following:
%   - Behavioral metrics
%   - Spike sorting metrics
%   - Category cell selectivity metrics
%   - Proportion of CAT cells per area
%   - Table of LFP/SUs recorded per area
%   - Sample cell plotting for Fig 3a in Daume et. al. 
%

clear; clc; close all
fs = filesep;
%% Parameters
% The first section of the script sets important parameters.
% The importRange is the range of files for the dataset. 
% For the current release, subject IDs have a range of 1:44. 
% The full range can also be specified by setting importRange=[]


% subject IDs for dataset.
importRange = []; % Full Range
% importRange = [1:3]; % Arbitrary example
% importRange = [6]; % SB-CAT Example Cat Cell (See Daume et. al. Fig 3a)
% importRange = [5]; % LFP PAC (See Daume et. al. Fig 2d)
% importRange = [32]; % PAC Cell Example


%% Initializing and pathing
% The script then defines the directory paths for the code, 
% the currently installed MatNWB package, and the dataset, 
% and then adds them to the MATLAB path. If figures are generated, 
% there is an additional option to add a custom save destination. 
% Please ensure that the defined paths in the script are correct for your 
% setup. This section also uses MatNWB's generateCore() function to 
% initialize the NWB API if it has not been initialized already.

paths.baseData = 'D:\DandiDownloads\000673'; % Dataset directory
paths.nwb_sb = paths.baseData; % Dandiset Directory
% This script should be in master directory
scriptPath = matlab.desktop.editor.getActiveFilename; scriptPathParse = split(scriptPath,fs); scriptPathParse = scriptPathParse(1:end-1);
paths.code = strjoin(scriptPathParse,filesep); 
paths.matnwb = 'C:\svnwork\matnwb-2.6.0.2';
paths.figOut = [strjoin(scriptPathParse(1:end-1),filesep) fs 'sbcat_figures'];
% Helpers
if(~isdeployed) 
  cd(fileparts(matlab.desktop.editor.getActiveFilename));
  addpath(genpath([pwd fs 'helpers'])) % Should be in same folder as active script. 
else
    error('Unexpected error.')
end

pathCell = struct2cell(paths);
for i = 1:length(pathCell)
    addpath(genpath(pathCell{i}))
end

% Initialize NWB Package
% generateCore() for first instantiation of matnwb API
fprintf('Checking generateCore() ... ')
if isfile([paths.matnwb fs '+types' fs '+core' fs 'NWBFile.m'])
     fprintf('generateCore() already initialized.\n') %only need to do once
else 
    cd(paths.matnwb)
    generateCore();
    fprintf('generateCore() initialized.\n')
end 

%% Importing Datasets From Folder
% The script will then import datasets from the given folder using the 
% NWB_importFromFolder function. Only files specified using importRange 
% will be loaded into the workspace.

tic % It is highly recommended to load nwb files from local drives for speed.
[nwbAll_sb, importLog_sb] = NWB_importFromFolder_SBCAT(paths.nwb_sb, importRange);
toc

%% Extracting Single Units
% Single unit information is extracted from the loaded NWB files for ease of 
% indexing, using the NWB_SB_extractUnits function. If spike waveforms are 
% not needed for analysis, the load_all_waveforms flag can be set to 0 to 
% only extract the mean waveform. All future plots will use this mean 
% waveform instead of a spike waveform pdf.

load_all_waveforms = 1; % Extracts all by default. Set to '0' to only extract the mean waveform. 
fprintf('Loading Sternberg CAT\n')
all_units_sbcat = NWB_SB_extractUnits(nwbAll_sb,load_all_waveforms);    


%% STERNBERG Params
paramsSB.doPlot = 0;  % if =1, plot significant cells. 
paramsSB.plotAlways = 0; % Plot regardless of selectivity (NOTE: generates a lot of figure windows unless exportFig=1)
paramsSB.exportFig = 0; 
paramsSB.exportType = 'png'; % File type for export. 'png' is the default. 
paramsSB.rateFilter =  []; % Rate filter in Hz. Removes cells from analysis that are below threshold. Setting to empty disables the filter. 
paramsSB.figOut = [paths.figOut fs 'stats_sternberg'];

%% Determine Category Cells
% This section selects for category neurons in all areas. It is preceded by
% a parameters section, which allows for the 
% control of various stages of the analysis and plotting process. 
% For example, one can choose to plot figures for significant cells by 
% setting paramsSC.doPlot = 1 or filter units being used for analysis by 
% specifying a minimum firing rate threshold paramsSC.rateFilter. To disable 
% analysis of all cells entirely, set paramsSC.calcSelective = 0.

paramsSB.calcSelective = 1;
if paramsSB.calcSelective
    [sig_cells_sb, areas_sb] = NWB_calcSelective_SB(nwbAll_sb,all_units_sbcat,paramsSB);
end
%% Category Cells Per-Area
% This section calculates the proportion of 
% category-selective cells across each area measured (compute the previous section first) 
% It is intended to use `importRange = 1:44`.

specify_selectivity = 1; % Set importRange to 1:44
if paramsSB.calcSelective && specify_selectivity
    % Getting selectivity
    sig_cells_total = logical(sig_cells_sb.cat_cells);
    unit_areas = cellfun(@(x) condenseAreas(x),areas_sb,'UniformOutput',false);
    % Areas of selective cells
    selective_areas = unit_areas(sig_cells_total);
    
    [unique_labels, ~, label_assignments] = unique(unit_areas);
    label_hist = histcounts(label_assignments);

    [unique_labels_selective, ~, label_assignments_selective] = unique(selective_areas);
    label_hist_selective = histcounts(label_assignments_selective);
    
    is_identical = strcmp(unique_labels,unique_labels_selective);
    if all(is_identical)
        selective_proportions = label_hist_selective./label_hist*100;
        for i = 1:length(unique_labels)
            fprintf('%s %.2f%% (%d/%d)\n',unique_labels{i}, selective_proportions(i),label_hist_selective(i),label_hist(i) )
        end
    else
        error('Labels not identical.')
    end
end

%% Sternberg CAT Example Params
paramsSB_ex.doPlot = 1;  % if =1, plot significant cells. 
paramsSB_ex.plotAlways = 0; % Plot regardless of selectivity (warning: generates a lot of figures unless exportFig=1)
paramsSB_ex.exportFig = 0; 
paramsSB_ex.exportType = 'png'; % File type for export. 'png' is the default. 
paramsSB_ex.rateFilter =  []; % Rate filter in Hz. Setting to empty disables the filter. 
paramsSB_ex.figOut = [paths.figOut fs 'stats_sternberg-cat_example'];
%% STERNBERG CAT Examples. Loops over Example Cells in Daume et al
% This section plots the example category-selective cell that can be 
% found in Fig 3a of Daume et al. 
% To decrease loading time, please set importRange = 6.

paramsSB_ex.processExamples = 1;
if paramsSB_ex.processExamples
    [sig_cells_sb_ex, areas_sb_ex] = NWB_SB_plotCell_Sternberg(nwbAll_sb,all_units_sbcat,paramsSB_ex);
end
%% PAC LFP Example
% This section recreates the example gamma amplitude distribution across 
% theta phase bins in addition to the comodulograms across load conditions 
% (Fig 2d, Daume et al). To decrease loading times, set importRange = 5. 

paramsSB_ex.processPAC_LFP = 1;
if paramsSB_ex.processPAC_LFP 
    LFP_PAC_figs = NWB_samplePAC_LFP(nwbAll_sb, paths);
end
%% PAC SU Example
% This section illustrates the binning and the model comparisons 
% used in PAC neuron selection for an example neuron. 
% To decrease loading times, set importRange = 32.

paramsSB_ex.processPAC_SU = 1;
if paramsSB_ex.processPAC_SU
    SU_PAC_figs = NWB_samplePAC_SU(nwbAll_sb, all_units_sbcat, paths);
end

%% State cells/lfps per area per Pt
% The script also calculates the number of LFP channels and cells by 
% area and saves the results into a .xlsx file. 
% This can be disabled by setting countAreas = 0.

countAreas = 1;
write2xlsx = 0; % Write proportions to an excel file
if countAreas
    AOIs = {'Hippo','Amy','preSMA','dACC','vmPFC'}; %#ok<*UNRCH>
    unitCountsAll = zeros(length(nwbAll_sb),length(AOIs));
    lfpCountsAll = zeros(length(nwbAll_sb),length(AOIs));
    for i = 1:length(nwbAll_sb)
        nwbSub = nwbAll_sb{i};
        fprintf('Counting ... (%d) %s\n',i, string(nwbSub.identifier))
        % Getting all electrode locations
        elecLocs = cellstr(nwbSub.general_extracellular_ephys_electrodes.vectordata.get('location').data.load());
        elecLocs = cellfun(@(x) condenseAreas(x),elecLocs, 'UniformOutput',false ); % Collapsing lateral distinction. 
        if ~isempty(nwbSub.units.id.data.load()) % If there are units
            % Units:
            % Getting electrode references
            unitElectrodes = nwbSub.units.electrodes.data.load() + 1; % Set to 1-indexing. 
            % Locations for each recording modality
            unitLocs = elecLocs(unitElectrodes);
            % area counts
            [unitLocs_unique, ~,temp] = unique(unitLocs);
            unitLocs_counts = histcounts(temp);
    
            for j = 1:length(unitLocs_unique)
                whichAreaIsThis = find(cellfun(@(x) strcmp(x,unitLocs_unique{j}),AOIs));
                unitCountsAll(i,whichAreaIsThis) = unitLocs_counts(j);
            end
    
        end
        if nwbSub.acquisition.isKey('LFPs') % If there are LFPs
            % LFP:
            % Getting electrode references
            lfpElectrodes = nwbSub.acquisition.get('LFPs').electrodes.data.load() + 1;% Set to 1-indexing. 
            % Locations for each recording modality
            lfpLocs = elecLocs(lfpElectrodes);
            % area counts
            [lfpLocs_unique, ~, temp] = unique(lfpLocs);
            lfpLocs_counts = histcounts(temp);
            for j = 1:length(lfpLocs_unique)
                whichAreaIsThis = find(cellfun(@(x) strcmp(x,lfpLocs_unique{j}),AOIs));
                lfpCountsAll(i,whichAreaIsThis) = lfpLocs_counts(j);
            end
        end
    end
    sfrmt_out = cell(size(unitCountsAll)); %output for csv
    for i = 1:size(unitCountsAll,1) % Outputting to terminal and saving results to csv
        fprintf('%s ',string(nwbAll_sb{i}.identifier))
        for j = 1:size(unitCountsAll,2)
            sfrmt_out{i,j} = sprintf('%d/%d',unitCountsAll(i,j),lfpCountsAll(i,j));
            fprintf('%s: %d/%d ',AOIs{j}, unitCountsAll(i,j),lfpCountsAll(i,j))
        end
        fprintf('\n')
    end
    fprintf('Total Units: %d \nTotal LFP Channels: %d \n',sum(unitCountsAll,'all'),sum(lfpCountsAll,'all'))
    fprintf('Areas: '); fprintf('%s ',AOIs{:}); fprintf('\n')
    fprintf('SU: %d %d %d %d %d\n',sum(unitCountsAll))
    fprintf('LFP: %d %d %d %d %d\n',sum(lfpCountsAll))
    sfrmt_out = vertcat(AOIs,sfrmt_out);
    subs = cell(length(nwbAll_sb)+1,1);for i=2:length(subs); subs{i} = char(nwbAll_sb{i-1}.identifier); end 
    sfrmt_out = horzcat(subs,sfrmt_out);
    xlsx_writePath = [paths.baseData fs 'areaCounts_temp.xlsx'];
    if write2xlsx 
        writecell(sfrmt_out, xlsx_writePath)
    end
end
%% Calculate Spike Sorting Metrics
% This section plots spike sorting metrics for single units recorded 
% in the Sternberg/screening tasks. These metrics include the percentage 
% of inter-spike intervals (ISIs) that were less than 3 ms, mean firing 
% rates for all units, coefficient of variation (CV2) values for all units, 
% signal-to-noise ratio (SNR) of the peak of the mean waveform, mean SNR for 
% all values in a unit’s mean waveform, pairwise projection distance between 
% each unit in which multiple units were found on the same electrode, 
% isolation distance (scaled to log 10 for ease of viewing) across all units 
% for which this metric was defined.

calcMetrics = 1; % Generate QA and behavioral metrics
if calcMetrics
    is_sternberg = true;
    QAfig_sb = NWB_QA_graphs(nwbAll_sb, all_units_sbcat, is_sternberg);
    QAfig_sb.set("Visible","on")
    % Moving to left screen
    QAfig_sb.WindowState = 'maximized';
    movegui(QAfig_sb,'west') 
    QAfig_sb.WindowState = 'maximized';
end

%% Simulate Noise Correlations
% Use main_popGeometry_noiseCorrs.m to simulate noise correlations between 
% two or more (as specified by Pdims) neurons. This script will determine 
% and plot the signal and the noise axes, their angle, as well as the 
% standard deviation of the values projected onto the signal axis before and 
% after noise correlations were removed among the simulated neurons. The 
% script allows to change the number of trials (NperGroup), the number of 
% neurons with category tuning (Pdims_withTuning), the method to extract the 
% noise axes (modeNoiseAxis), as well as the classifier (modeClassifier). 
% Parameters can be changed from within the script.

simNoiseCorr = 1;
if simNoiseCorr
    run('main_popGeometry_noiseCorrs.m')
end












