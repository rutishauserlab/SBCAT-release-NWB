%% NWB_SBCAT_import_main

 
clear; clc; close all
fs = filesep;
%% Parameters

% subject IDs for dataset.
% importRange = 6:7;% :43; % Dataset: Daume et al 
% importRange = 43; % faulty JHU export. (Due to it only storing one neuron)
importRange = [];

%% Initializing and pathing
paths.baseData = 'D:\DandiDownloads\000673'; % Dataset directory
paths.nwb_sb = paths.baseData; % Dandiset Directory
% This script should be in master directory
scriptPath = matlab.desktop.editor.getActiveFilename; scriptPathParse = split(scriptPath,fs); scriptPathParse = scriptPathParse(1:end-1);
paths.code = strjoin(scriptPathParse,filesep); 
paths.matnwb = 'C:\svnwork\matnwb-2.6.0.2';
paths.figOut = [paths.code fs 'figures'];
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
%generateCore() for first instantiation of matnwb API
fprintf('Checking generateCore() ... ')
if isfile([paths.matnwb fs '+types' fs '+core' fs 'NWBFile.m'])
     fprintf('generateCore() already initialized.\n') %only need to do once
else 
    cd(paths.matnwb)
    generateCore();
    fprintf('generateCore() initialized.\n')
end 

%% Importing Datasets From Folder
tic % It is recommended to load nwb files from local files for speed. Otherwise, the load takes ages. 
[nwbAll_sb, importLog_sb] = NWB_importFromFolder_SBCAT(paths.nwb_sb, importRange);
toc

%% Extracting Single Units
load_all_waveforms = 1; % Extracts all by default. Set to '0' to only extract the mean waveform. 
fprintf('Loading Sternberg CAT\n')
all_units_sbcat = NWB_SB_extractUnits(nwbAll_sb,load_all_waveforms);    


%% STERNBERG Params
paramsSB.doPlot = 0;  % if =1, plot significant cells. 
paramsSB.plotAlways = 0; % Plot regardless of selectivity (warning: generates a lot of figures unless exportFig=1)
paramsSB.plotMode = 1; % Which cell type to plot (1: Concept, 2: Maint, 3: Probe, 4: All)
paramsSB.exportFig = 0; 
paramsSB.exportType = 'png'; % File type for export. 'png' is the default. 
paramsSB.rateFilter =  0; % Rate filter in Hz. Setting to zero disables the filter. 
paramsSB.figOut = [paths.figOut fs 'stats_sternberg'];

%% Calculate Category Cells
paramsSB.calcSelective = 1;
if paramsSB.calcSelective
    [sig_cells_sb, areas_sb] = NWB_calcSelective_SB(nwbAll_sb,all_units_sbcat,paramsSB);
end

%% State cells/lfps per area per Pt
countAreas = 0;
if countAreas
    AOIs = {'Hippo','Amy','preSMA','dACC','vmPFC'}; %#ok<*UNRCH>
    unitCountsAll = zeros(length(nwbAll_sb),length(AOIs));
    lfpCountsAll = zeros(length(nwbAll_sb),length(AOIs));
    for i = 1:length(nwbAll_sb)
        nwbSub = nwbAll_sb{i};
        fprintf('Counting ... (%d) %s\n',i, nwbSub.identifier)
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
        fprintf('%s ',nwbAll_sb{i}.identifier)
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
    % paths.baseData = 'Z:\LabUsers\kyzarm\data\NWB_SBCAT\data_NWB';
    subs = cell(length(nwbAll_sb)+1,1);for i=2:length(subs); subs{i} = nwbAll_sb{i-1}.identifier; end 
    sfrmt_out = horzcat(subs,sfrmt_out);
    xlsx_writePath = [paths.baseData fs 'areaCounts_temp.xlsx'];
    
    writeFlag = 0;
    if writeFlag 
        writecell(sfrmt_out, xlsx_writePath)
    end
end
%% Calculate Spike Sorting Metrics (Sternberg only)
calcMetrics = 1;
if calcMetrics
    is_sternberg = true;
    QAfig_sb = NWB_QA_graphs(nwbAll_sb, all_units_sbcat, is_sternberg);
    QAfig_sb.set("Visible","on")
    % Moving to left screen
    QAfig_sb.WindowState = 'maximized';
    movegui(QAfig_sb,'west') 
    QAfig_sb.WindowState = 'maximized';
end

