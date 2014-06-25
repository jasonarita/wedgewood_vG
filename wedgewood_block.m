classdef wedgewood_block < handle
    %  obj = wedgewood_block(cueColorList, targColorList, target_presence_list)
    %
    % gonna need:
    %     exptVars.cue2targDur;
    %     exptVars.possibleColors
    %     orientationList {'up', 'down'}
    %     exptVars.validPercent
    %     exptVars.num_trial_copies
    
    
    properties
        
        subject_ID;
        run_order_num;
        trials;                     % array for SINGLETRIAL objs
        numTrials;
        
        % INPUT:
        ITI_list;
        num_trial_copies;
        
        % Factors
        cue_type_list                % { positive, neutral, negative cue }
        set_size_list;               % { 2,4,6,8 }
        SOA_list;
        
        % Non-factors
        target_presence_list;       % { present, absent }
        color_list;                 % { red, green, blue }
        target_hemifield_list;       % { 1-4 }
        target_orientation_list;
        distractor_orientation_list;
        
        vertJitter  = 5;
        horizJitter = 5;
        
    end % properties
    
    
    
    
    
    methods
        
        function obj = wedgewood_block(varargin)
            % constructor method for TRIALBLOCK obj
            %  obj = wedgewood_block(cueColorList, targColorList, target_presence_list)
            
            % INPUT HANDLING:
            switch nargin
                
% FOR DEBUGGING PURPOSES ONLY                
%                 case 0                                                              % Default settings
%                     obj.subject_ID                  = 'Z99';
%                     obj.run_order_num               = '99';
%                     obj.trials                      = wedgewood_trial.empty;                        %
%                     obj.num_trial_copies            = 1;                                            %
%                     
%                     obj.cue_type_list               = {'positive'};                                 % blocked
%                     obj.SOA_list                    = { 0.400 };                                    % duration between cue display & search display
%                     obj.set_size_list               = { 4, 8, 12 };                                        %
%                     obj.target_presence_list        = { 'present' };                                % Target always present
%                     obj.target_hemifield_list        = {'top'    , 'bottom'  , 'left'    , 'right'}; %
%                     obj.color_list                  = { 'red'   ,'green'    ,'blue'     };          %
%                     obj.target_orientation_list     = { 'up'    , 'down'    };                      %
%                     obj.distractor_orientation_list = {'left'   ,'right'    };
%                     
%                     obj.ITI_list                    = {1000 1400};                                  %
%                     search_annulus_radius           = 200;
%                     
                    
                case 13
                    obj.trials                      = wedgewood_trial.empty;          % cell array for SINGLETRIAL objs
                    
                    obj.subject_ID                  = varargin{1};
                    obj.run_order_num               = varargin{2};
                    obj.num_trial_copies            = varargin{3};                  % 1
                    obj.cue_type_list               = varargin{4};                  % blocked
                    obj.SOA_list                    = varargin{5};                  % duration between cue display & search display
                    obj.set_size_list               = varargin{6};                  % { 4 }
                    obj.target_presence_list        = varargin{7};                  % { present }
                    obj.target_hemifield_list        = varargin{8};                  % { 1-4 }
                    obj.color_list                  = varargin{9};                  % { red, green }
                    obj.target_orientation_list     = varargin{10};                  %
                    obj.distractor_orientation_list = varargin{11};                 % { left, right }
                    
                    obj.ITI_list                    = varargin{12};                 % { 1000, 1400 }
                    search_annulus_radius           = varargin{13};                 % 200
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
            
            
            % --------------------------------------------------------- %
            % NOTE:                                                     %
            %   if trial multiplier is zero (default) then doesn't      %
            %   generate a trial array                                  %
            % --------------------------------------------------------- %
            
            trialNum                        = 1;                    % reset trial count
            for num_trial_copiesIndex = 1:obj.num_trial_copies
                unique_ID                   = 11;                   % reset the unique trial ID number (for ERPSS event codes)
                
                % -------------------- %
                % Generate Base Trials %
                % -------------------- %
                for cue_type = obj.cue_type_list
                    for SOA = obj.SOA_list
                        for set_size = obj.set_size_list
                            for target_presence = obj.target_presence_list
                                for target_hemifield = obj.target_hemifield_list;
                                    for target_orientation = obj.target_orientation_list
                                        for cue_color = obj.color_list
                                            
                                            % Counterbalanced variables:
                                            %                 cue_type
                                            %                 SOA
                                            %                 set_size
                                            %                 target_presence
                                            %                 target_orientation
                                            %                 cue_color
                                            
                                            
                                            
                                            % create new single trial
                                            obj.trials(trialNum) = wedgewood_trial  ...
                                                ( obj.subject_ID                    ...
                                                , obj.run_order_num                 ...
                                                , unique_ID                         ...
                                                , cell2mat(cue_type)                ...
                                                , cell2mat(SOA)                     ...
                                                , cell2mat(set_size)                ...
                                                , cell2mat(target_presence)         ...
                                                , cell2mat(target_hemifield)        ...
                                                , cell2mat(cue_color)               ...
                                                , obj.color_list                    ...
                                                , target_orientation                ...
                                                , obj.distractor_orientation_list   ...
                                                , obj.ITI_list                      ...
                                                , search_annulus_radius             ...
                                                );
                                            
                                            
                                            %
                                            trialNum                 = trialNum+1;                          % increment trial num
                                            unique_ID                = unique_ID+1;                         % increment unique trial ID
                                            if(mod(trialNum, 10) == 0); fprintf('%d...', trialNum); end;    % display current status
                                            
                                        end % target color loop
                                    end % target orientation loop
                                end % target hemifield loop
                            end % target presence loop
                        end % set size loop
                    end % SOA loop
                end % cue type loop
                
            end % trial multiplier loop
            
            
            obj.numTrials   = length(obj.trials);
            fprintf('...done.\n')        % end status display
            
        end % function
        
        function value = randomize(obj)
            % returns randomized trials
            %
            % NOTE:
            % Does not mutate obj itself. Need to run command:
            %
            %       exptBlockName.trials = exptBlockName.randomize();
            %
            % to do actual randomization
            
            value = Shuffle(obj.trials);
            
        end % method
        
        function displayTrials(obj, varargin)
            
            switch nargin
                case 1
                    saveFilename_wd = false;
                case 2
                    saveFilename_wd = varargin{1};
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
            
            for trialIndex = 1:length(obj.trials)
                
                if(saveFilename_wd)
                    obj.trials(trialIndex).displayTrial(saveFilename_wd);
                else
                    obj.trials(trialIndex).displayTrial();
                end
                
            end % trial loop
            
            
            
        end % method
        
        
        
    end % methods
    
    
end % class def
