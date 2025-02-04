function [all_units] =NWB_SB_extractUnits(nwbAll, load_all_waveforms)
%NWB_SB_extractUnits Takes a cell array of loaded nwb files and returns all
%   single unit information across all the files. 
%   nwbAll: cell array of loaded nwb files
%   importRange:  
%
%   mkyzar 4/27/2023
%   updated JD 01/2025 (correction of waveform_index_index)

all_units = {};
for i=1:length(nwbAll)
    unit_ids = num2cell(nwbAll{i}.units.id.data.load() + 1); % Convert to 1-based indexing
    session_count = num2cell(i.*ones(length(unit_ids),1));
    subject_id = cell(length(unit_ids),1); for j = 1:length(subject_id); subject_id{j} = nwbAll{i}.general_subject.subject_id; end
    session_id = cell(length(unit_ids),1); for j = 1:length(session_id); session_id{j} = nwbAll{i}.general_session_id; end
    identifier = cell(length(unit_ids),1); for j = 1:length(identifier); identifier{j} = nwbAll{i}.identifier; end
    electrodes_ind = num2cell(nwbAll{i}.units.electrodes.data.load() + 1); % Convert to 1-based indexing
    electrode_areas = cellstr(nwbAll{i}.general_extracellular_ephys_electrodes.vectordata.get('location').data.load());
    unit_areas = electrode_areas([electrodes_ind{:}]);
    
    fprintf('Loading SUs: Subject ID %s (%d/%d)...',string(subject_id{1}),i,length(nwbAll))
    

    % Organize spike times
    spike_times_session = nwbAll{i}.units.spike_times.data.load();
    spike_times_ind = nwbAll{i}.units.spike_times_index.data.load();
    
    spike_times_cells = cell(length(unit_ids),1);
    spike_times_cells{1} = spike_times_session(1:spike_times_ind(1));
    for j = 2:length(spike_times_cells)
        spike_times_cells{j} = spike_times_session(spike_times_ind(j-1)+1:spike_times_ind(j));
    end
    
    % Import Waveforms
    if load_all_waveforms % Imports all waveforms (memory intensive)
        wf_all = nwbAll{i}.units.waveforms.data.load();
        wf_ind = nwbAll{i}.units.waveforms_index.data.load();
        wf_ind_ind = nwbAll{i}.units.waveforms_index_index.data.load();
        % Compare num_waveforms to num_spikes
        if size(wf_all,2) ~= length(spike_times_session)
            error('Number of spikes does not equal number of waveforms')
        elseif size(wf_all,2) ~= max(wf_ind_ind)
            error('Waveform indices exceed the number of waveforms.')
        end
        % Performs double indexing
        wf_cells_all = cell(length(unit_ids),1);
        wf_cells_all{1} = wf_all(:,1:wf_ind_ind(wf_ind(1)))';
        for j = 2:length(wf_cells_all)
            wf_cells_all{j} = wf_all(:,wf_ind_ind(wf_ind(j)-1)+1:wf_ind_ind(wf_ind(j)))';
        end
        wf_cells = wf_cells_all;

    elseif ~load_all_waveforms && ~isfield(nwbAll{i}.units, 'waveform_mean')
        wf_all = nwbAll{i}.units.waveforms.data.load();
        wf_ind = nwbAll{i}.units.waveforms_index.data.load();
        wf_ind_ind = nwbAll{i}.units.waveforms_index_index.data.load();
        % Compare num_waveforms to num_spikes
        if size(wf_all,2) ~= length(spike_times_session)
            error('Number of spikes does not equal number of waveforms')
        elseif size(wf_all,2) ~= max(wf_ind)
            error('Waveform indices exceed the number of waveforms.')
        end
        % Performs double indexing
        wf_cells_all = cell(length(unit_ids),1);
        wf_cells_all{1} = wf_all(:,1:wf_ind_ind(wf_ind(1)))';
        for j = 2:length(wf_cells_all)
            wf_cells_all{j} = wf_all(:,wf_ind_ind(wf_ind(j)-1)+1:wf_ind_ind(wf_ind(j)))';
        end
        wf_cells_preMean = wf_cells_all;
        wf_cells = cellfun(@(x) mean(x), wf_cells_preMean, 'UniformOutput',false);

    else % Imports only mean waveforms. 
        wf_mean_all = nwbAll{i}.units.waveform_mean.data.load();
        % Assigning to cell array
        wf_cells_mean = cell(length(unit_ids),1);
        for j = 1:length(wf_cells_mean)
            wf_cells_mean{j} = wf_mean_all(:,j)';
        end
        wf_cells = wf_cells_mean;
    end


    session_units = horzcat(session_count,subject_id,session_id,identifier,unit_ids,electrodes_ind,unit_areas,spike_times_cells, wf_cells);
    all_units = vertcat(all_units,session_units); %#ok<AGROW>
    fprintf(' Loaded \n')
end
all_units = cell2struct(all_units,{'session_count','subject_id','session_id','identifier','unit_id','electrodes','unit_area','spike_times','waveforms'},2); % << Follows this column title format.
end