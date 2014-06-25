classdef wedgewood_trial < handle
    %
    % Experimentor Defined Variables:
    %
    
    properties
        
        % Experimentor Defined Variables
        subject_ID;
        trial_order_num;
        run_order_num;
        cue_type;
        SOA;
        set_size;
        cluster_size;
        num_clusters        = 2;
        target_presence;
        target_hemifield;
        target_obj_location
        cue_color;
        target_color;
        distractor_color;
        target_orientation;
        ITI;
        
        accuracy        = NaN;          % subject's single trial accuracy {1 == correct || 0 == incorrect}
        resp_keyname    = 'No_Press';   % response key name
        resp_keycode;                   % response gamepad key number
        RT;                             % subject's single trial response time
        
    end % properties
    
    properties (Hidden = true)
        event_code;
        cue_stim;                       % Cue    stimulus to draw
        search_stim;                    % Search stimulus to draw
        
        search_annulus_radius;
        
    end
    
    events
        calculateAccuracy
    end
    
    methods
        
        function obj   = wedgewood_trial(varargin)
            
            switch nargin
                case 0
                    
% For debugging purposes only:
%                     obj.subject_ID                  = 'Z99';
%                     obj.trial_order_num             = 21;
%                     obj.run_order_num               = '99';
%                     obj.event_code                  = 99;
%                     obj.cue_type                    = 'positive';
%                     obj.SOA                         = { 400 };
%                     obj.set_size                    = 8;                                % { 4, 8, 12 }
%                     obj.target_presence             = 'present';
%                     obj.target_hemifield             = 'top'; % search_location_list            = {'top', 'bottom', 'left', 'right'};
%                     obj.cue_color                   = 'blue';
%                     color_list                      = {'red', 'green', 'blue'};
%                     target_orientation_list         = {'up','down'};
%                     distractor_orientation_list     = {'left','right'};
%                     ITI_list                        = {1000, 1400};                  
%                     obj.search_annulus_radius       = 200;
                    
                case 14
                    
                    obj.subject_ID                  = varargin{1};
                    obj.run_order_num               = varargin{2};
                    obj.event_code                  = varargin{3};
                    obj.cue_type                    = varargin{4};
                    obj.SOA                         = varargin{5};
                    obj.set_size                    = varargin{6};
                    
                    obj.target_presence             = varargin{7};
                    obj.target_hemifield            = varargin{8};
                    obj.cue_color                   = varargin{9};
                    color_list                      = varargin{10};
                    target_orientation_list         = varargin{11};
                    distractor_orientation_list     = varargin{12};
                    ITI_list                        = varargin{13};
                    obj.search_annulus_radius       = varargin{14};
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
            obj.cluster_size                = obj.set_size/obj.num_clusters;        % varies
            obj.cue_stim                    = stimBox.empty;
            obj.search_stim                 = stimLandoltCArray.empty;
            
            
            % Calculate inter-trial interval
            ITI_min  = ITI_list{1};
            ITI_max  = ITI_list{2};  % create random preCue ISI based min & max
            obj.ITI  = rand * (ITI_max-ITI_min) + ITI_min;
            
            
            % Calculate search object LOCATIONS
            switch(obj.target_hemifield)
                case{'top'}
                    target_cluster_start_loc      = 10;
                    distractor_cluster_start_loc  = 4;
                case{'bottom'}
                    target_cluster_start_loc      = 4;
                    distractor_cluster_start_loc  = 10;
                case{'left'}
                    target_cluster_start_loc      = 7;
                    distractor_cluster_start_loc  = 1;
                case{'right'}
                    target_cluster_start_loc      = 1;
                    distractor_cluster_start_loc  = 7;
            end
            
            num_obj_locs_total = 12;
            num_obj_locs_per_cluster    = num_obj_locs_total/obj.num_clusters;
            
            target_cluster_start_locs       = mod(target_cluster_start_loc:target_cluster_start_loc+(num_obj_locs_per_cluster-obj.cluster_size), num_obj_locs_total);
            target_start_loc                = RandSample(target_cluster_start_locs);
            target_obj_locs                 = mod(target_start_loc:target_start_loc+obj.cluster_size-1, num_obj_locs_total);
            
            distractor_cluster_start_locs   = mod(distractor_cluster_start_loc:distractor_cluster_start_loc+(num_obj_locs_per_cluster-obj.cluster_size), num_obj_locs_total);
            distractor_start_loc            = RandSample(distractor_cluster_start_locs);
            distractor_obj_locs             = mod(distractor_start_loc:distractor_start_loc+obj.cluster_size-1, num_obj_locs_total);
            
            location = [target_obj_locs, distractor_obj_locs];

            
            
            % Calculate search object COLORS
            non_cue_colors = setdiff(color_list, obj.cue_color);
            
            switch(obj.cue_type)
                case {'positive'}
                    obj.target_color     = obj.cue_color;
                    obj.distractor_color = cell2mat(RandSample(non_cue_colors));
                case {'neutral'}
                    obj.target_color     = cell2mat(RandSample(non_cue_colors));
                    obj.distractor_color = cell2mat(RandSample(setdiff(non_cue_colors,obj.target_color)));
                case {'negative'}
                    obj.target_color     = cell2mat(RandSample(non_cue_colors));
                    obj.distractor_color = obj.cue_color;
            end
            
            color = cell(1,obj.set_size);
            for obj_index = 1:obj.set_size
                color{obj_index}    = obj.target_color;
            end
            
            for obj_index = obj.cluster_size+1:obj.set_size
                color{obj_index} = obj.distractor_color;
            end        
            
            
            % Calculate search object ORIENTATIONS
            switch(obj.target_presence)
                case {'present'}
                    obj.target_orientation = cell2mat(RandSample(target_orientation_list));
                case {'absent'}
                    obj.target_orientation = cell2mat(RandSample(distractor_orientation_list));
            end
            
            orientation = cell(1,obj.set_size);
            
            for obj_index = 1:obj.set_size
                orientation{obj_index} = cell2mat(RandSample(distractor_orientation_list));
            end
            
            target_cell_location                = RandSample(1:obj.cluster_size);
            orientation{target_cell_location}   = obj.target_orientation;
            obj.target_obj_location             = location(target_cell_location);

            
            % Create search landolt-c array for STIMLANDOLTCARRAY.M
            search_landoltCs = struct('orientation',[],'color',[],'location',[]);
            for search_stim_index = 1:obj.set_size
                search_landoltCs(search_stim_index).orientation  = orientation{ search_stim_index};
                search_landoltCs(search_stim_index).color        = color{       search_stim_index};
                search_landoltCs(search_stim_index).location     = location(    search_stim_index);
            end
            
            % Set up stimulus objects
            obj.cue_stim    = stimBox(30,30,0,obj.cue_color, pt(0,0), obj.cue_color);
            obj.search_stim = stimLandoltCArray(num_obj_locs_total, obj.search_annulus_radius, search_landoltCs, -7*pi/num_obj_locs_total);
            
            wedgewood_trial_manager.addTrial(obj);
            
        end % constructor method
        
        function trial_obj = saveResponse(trial_obj, subject_response)
            
            trial_obj.resp_keyname    = subject_response.keyname;               % response key name
            trial_obj.resp_keycode    = subject_response.keycode;               % response gamepad key number
            trial_obj.RT       = subject_response.time;                  % subject's single trial response time
            notify(trial_obj, 'calculateAccuracy');
            
        end       % method
        
    end % methods
    
end % classdef
