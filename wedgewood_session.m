classdef wedgewood_session
    % Author:   Jason Arita
    % Version:  G --BLOCKED 3 set sizes: 4,8,12  (cluster sizes: 2,4,6 respectively)
    %
    
    properties
        
        block;                          % where all trial data is stored
        name;
        date;                           % current date (see help DATESTR)
        start_time;                     % current time
        end_time;
        
        is_practice;                    % from prompt
        subject_ID;                     % from prompt
        run_num;                        % from prompt
        cue_condition_num;              % from prompt
        save_filename;                  % from prompt
        condInfo;                       % from prompt
        cue_type_list;                  % from prompt
        cue_instructions;               % from prompt

        set_size_list;                  % from prompt
        
        
        save_directory              = 'data.raw';                 

        
        %------------------------
        % Stimulus settings
        %------------------------
        numStim                     = 8;                            % num of landolt-c to display
        bgColorWd                   = 'white';                      % (str)
        search_annulus_radius       = 200;                          % (px) dist. from center for landalt-c's
        trialMultiplier             = 4;                            % num times to repeat each trial permutation (~5 mins per set of unique trials)
        target_color_list           = { 'red'       , 'green'   , 'blue'    };
        target_hemifield_list       = { 'top'       , 'bottom'  , 'left'    , 'right'};
        target_presence_list        = { 'present'   };
        target_orientation_list     = { 'up'        , 'down'    };
        distractor_orientation_list = { 'left'      , 'right'   };
        
        
        %------------------------
        % Time Settings
        %------------------------
        % ~ 12 seconds max per trial
        ITI                         = { 1.000 1.400 };              % (sec) min dur for inter trial interval (ITI)
        pre_trial_duration          = 0.500;                        % (sec) dur to present fixation before search frame
        cue_frame_duration          = 0.100;                        % (sec) dur the cue stays on
        SOA_list                    = { 0.400 };                    % (sec) 1 SOA duration(s)
        responseDur                 = 5.000;                        % (sec) dur to wait for resp
        post_response_duration      = 0.500;                        % (sec) dur to wait after subj resp
        
        
        %------------------------
        % Font Settings
        %------------------------
        fontName                    = 'Helvetica';                  % font name for all instructions
        fontSize                    = 24;                           % font size for all instructions
        fontColorWd                 = 'black';                      % fonct color for all instructions
        
        
        % Timing %
        exptDuration;
        
        % Response %
        accResp;
        accRespNames;
               
        
    end % properties
    
     
    properties (Constant = true)
        DEBUG = false ;
    end % constant properties
    
    
    
    methods
        
        function obj    = wedgewood_session(varargin)
            
            obj.name                    = 'wedgewood_vG';
            obj.date                    = datestr(now, 'mm/dd/yyyy');  % current date (see help DATESTR)
            obj.start_time              = datestr(now, 'HH:MM:SS AM'); % current time

            
            % INPUT HANDLING:
            switch nargin
                
                case 0                                                              % Default settings
                    % -------------------------- %
                    % Prompt Experiment Run Info %
                    % -------------------------- %
                    
                    promptTitle                 = 'Experimental Setup Information';
                    prompt                      =   ...
                        { 'Enter subject number: '  ...
                        , 'Enter Run Number: '      ...
                        , 'Cue Condition Number:'   ...
                        , 'Practice?'               ...
                        };
                    promptNumAnsLines           = 1;
                    promptDefaultAns            =   ...
                        { 'F99'                     ...
                        , '99'                      ...
                        , '1'                       ...
                        , 'yes'                     ...
                        };
                    
                    
                    options.Resize              = 'on';
                    answer                      = inputdlg(prompt, promptTitle, promptNumAnsLines, promptDefaultAns, options);
                    obj.subject_ID              = answer{1};
                    obj.run_num                 = answer{2};
                    obj.cue_condition_num       = str2double(answer{3});
                    obj.is_practice             = answer{4};
                    
                case 4
                    obj.subject_ID              = varargin{1};
                    obj.run_num                 = varargin{2};
                    obj.cue_condition_num       = varargin{3};
                    obj.is_practice             = varargin{4};
                case 5
                    obj.subject_ID              = varargin{1};
                    obj.run_num                 = varargin{2};
                    obj.cue_condition_num       = varargin{3};
                    obj.set_size_list           = varargin{4};
                    obj.is_practice             = varargin{5};
                otherwise
                    error('Wrong number of input arguments');
            end
            
            
            obj.condInfo                = conditionInfo();
            obj.cue_type_list           = { obj.condInfo.cue_type(obj.cue_condition_num) };
            obj.cue_instructions        = obj.condInfo.instruction(obj.cue_condition_num);
            obj.accResp                 = obj.condInfo.button_nums(obj.cue_condition_num);
            obj.accRespNames            = obj.condInfo.button_names();
            
            % Practice Setup
            switch lower(obj.is_practice)
                case 'yes'
                    obj.is_practice          = true;
                otherwise
                    obj.is_practice          = false;
            end
            
            
            if(obj.DEBUG)
                obj.trialMultiplier             = 1;                   % num times to repeat each trial permutation
            end
            
            %------------------------
            % Set up trials
            %------------------------
            display('Generating Trial Permutations...');
            obj.block = wedgewood_block          ...
                ( obj.subject_ID                    ...
                , obj.run_num                       ...
                , obj.trialMultiplier               ...
                , obj.cue_type_list                 ...
                , obj.SOA_list                      ...
                , obj.set_size_list                  ...
                , obj.target_presence_list          ...
                , obj.target_hemifield_list          ...
                , obj.target_color_list             ...
                , obj.target_orientation_list       ...
                , obj.distractor_orientation_list   ...
                , obj.ITI                           ...
                , obj.search_annulus_radius         ...
                );
            display('Done');
            
            % -----------------------
            % Randomize Trials
            % -----------------------
            if(obj.DEBUG)
                % Don't randomize
            else
                obj.block.trials = obj.block.randomize();
            end
            
            % Save Dir setup
            if~(exist(obj.save_directory, 'dir')); mkdir(obj.save_directory); end            % if save dir doesn't exist create one
            
            % Save header to output file
            if(obj.is_practice)
                obj.save_filename   = [ './' obj.save_directory '/practice_' obj.name '_' obj.subject_ID '.txt'];
            else
                obj.save_filename   = [ './' obj.save_directory '/' obj.name '_' obj.subject_ID '.txt'];
            end
            
        end % constructor method
        
        function obj    = run(obj)
            
            try
                
                clc;
                HideCursor;
                progEnv.gamepadIndex   = Gamepad('GetGamepadIndicesFromNames', 'Logitech(R) Precision(TM) Gamepad');
                daqCard                = daqObj();                                                     % setup event codes
                [ winPtr winRect screenCenter_pt ]   = setupScreen(color2RGB(obj.bgColorWd));   %#ok<ASGLU> % setup screen
                background             = stimBackground(obj.bgColorWd);                                % setup background stim
                fixation               = stimFixationPt(screenCenter_pt);                              % setup fixation stim
                Screen('TextFont', winPtr, obj.fontName);                                       % setup text font
                Screen('TextSize', winPtr, obj.fontSize);                                       % setup text size
                font_wrap = 45;
                
                if(obj.is_practice)
                    numTrials       = 15;                                                       % use subset of all generated trials for practice
                else
                    numTrials       = length(obj.block.trials);                                 % use all generated trials
                end
                
%                 breakTrialNum   = ceil(numTrials / 3);                                          % Take a break every 1/3 of each session
                
                % --------------------
                % Execute Experiment
                % --------------------
                
                startTime    = GetSecs;                                                         % start timing experiment session
                
                % --------------------------
                % Present cue instructions
                % --------------------------
                background.draw(winPtr);
                DrawFormattedText(winPtr, obj.cue_instructions, 'center', 'center',color2RGB_2(obj.fontColorWd),font_wrap,0,0,2);
                Screen('Flip', winPtr);                                                         % flip/draw buffer to display monitor
                waitForButtonRelease(progEnv.gamepadIndex);
                waitForSubjPress(progEnv.gamepadIndex);
                
                
                % --------------------------
                % draw button instructions
                % --------------------------
                for respNum = 1:length(obj.accResp)
                    
                    buttonInstruction_txt = sprintf('Button %d is the %s.\n\nPress the target %s to continue... '             ...
                        , obj.accResp{respNum}        ...
                        , obj.accRespNames{respNum}   ...
                        , obj.accRespNames{respNum}   ...
                        );
                    
                    
                    DrawFormattedText(winPtr,buttonInstruction_txt,'center','center',color2RGB_2(obj.fontColorWd),font_wrap+10,false,false,2);
                    Screen('Flip', winPtr);            % flip/draw buffer to display monitor
                    
                    % wait for button confirmation
                    waitForButtonRelease(progEnv.gamepadIndex);
                    gamepadResponse(100,obj.accResp(respNum),{obj.accRespNames(respNum)}); % only accept correct response
                    
                end
                
                WaitSecs(.500); % give the subject a little time to get ready
                
                ITI_start_time = GetSecs;
                ITI_dur        = 0;
                for currTrialNum = 1:numTrials % Trial Start
                    
                    
                    % -------------------------
                    % Execute Single Trial
                    % -------------------------
                    obj.block.trials(currTrialNum).trial_order_num = currTrialNum;  % save trial order number to data object
                    stim_search             = obj.block.trials(currTrialNum).search_stim;
                    stim_cue                = obj.block.trials(currTrialNum).cue_stim;
                    SOA                     = obj.block.trials(currTrialNum).SOA;
                    
                    %                     target_eventCode        = obj.block.trials(currTrialNum).event_code;
                    if(daqCard.isPresent); daqCard.resetPorts(); end
                    
                    ITI_processing_time = (GetSecs-ITI_start_time);
                    leftover_ITI_dur = ITI_dur -ITI_processing_time;
                    WaitSecs(leftover_ITI_dur);
                    fprintf('Nominal ITI Duration:\t%-8.4f\tms\n'       , ITI_dur               *1000);
                    fprintf('Actual  ITI Duration:\t%-8.4f\tms\n'       , (GetSecs-ITI_start_time)*1000);
                    fprintf('=================================================\n');
                    fprintf('Current trial Num:\t%3d / %3d\t trials\n'  , currTrialNum, numTrials);
                    fprintf('\n');
                    
                    
                    % -------------------------
                    % Present: Pre-trial frame
                    % -------------------------
                    background.draw(winPtr);
                    fixation.draw(winPtr);
                    Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
                    WaitSecs(obj.pre_trial_duration);                                       % wait:
                    %                     fprintf('Pre-trial fixation dur: %1.4f\t\t ms\n' , (GetSecs-start)/1000);
                    
                    % ----------------------------------
                    % Present: Cue frame
                    % ----------------------------------
                    %                     start = GetSecs;
                    background.draw(winPtr);
                    stim_cue.draw(winPtr, screenCenter_pt);
                    Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
                    start = GetSecs;
                    WaitSecs(obj.cue_frame_duration);                                       % wait:
                    %                     fprintf('Cue frame dur: %1.4f\t\t ms\n' , (GetSecs-start)*1000);
                    
                    % ----------------------------------
                    % Present: Cue to search frame
                    % ----------------------------------
                    %                     start = GetSecs;
                    background.draw(winPtr);
                    fixation.draw(winPtr);
                    Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
                    WaitSecs(SOA-obj.cue_frame_duration);                                   % wait:
                    cue_to_search_SOA = GetSecs-start;
                    
                    % ----------------------------------
                    % Present: Search frame
                    % ----------------------------------
                    %                     start = GetSecs;
                    background.draw(winPtr);
                    fixation.draw(winPtr);
                    stim_search.draw(winPtr, screenCenter_pt);
                    Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
                    %                     daqCard.sendEventCode(target_eventCode);                                % send event code
                    %                     targDisplaySOA = GetSecs-start;
                    
                    
                    % ----------------------------------
                    % Subj Response
                    % ----------------------------------
                    %                     start = GetSecs;
                    subject_response = gamepadResponse(obj.responseDur, obj.accResp, obj.accRespNames, daqCard);
                    WaitSecs(obj.post_response_duration);
                    %                     targetDisplayDur = GetSecs-start;
                    
                    % ------------------------------
                    % Present: Post-response frame
                    % ------------------------------
                    
                    ITI_start_time = GetSecs;
                    background.draw(winPtr);
                    Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
                    
                    
                    % -------------------------
                    % Post-Trial Processing
                    % -------------------------
                    obj.block.trials(currTrialNum).saveResponse(subject_response);              % save the response to the expt class structure
                    obj.save_to_file(currTrialNum, false);
                    curr_mean_accuracy  = nanmean([ obj.block.trials.accuracy  ]) * 100;        % calculate current mean accuracy
                    curr_mean_RT        = nanmean([ obj.block.trials.RT ]) * 1000;              % calculate current mean response time
                    ITI_dur             = obj.block.trials(currTrialNum).ITI;                   % figure out the ITI duration at the end of the trial
                    
                    fprintf('Trial Accuracy:     \t%-8.4f\t%%\n'	, obj.block.trials(currTrialNum).accuracy   * 100 );
                    fprintf('Trial Response Time:\t%-8.4f\tms\n'	, obj.block.trials(currTrialNum).RT         * 1000);
                    fprintf('\n');
                    fprintf('Mean Accuracy:      \t%-8.4f\t%%\n'	, curr_mean_accuracy                        );
                    fprintf('Mean Response Time: \t%-8.4f\tms\n'	, curr_mean_RT                              );
                    fprintf('\n');
                    fprintf('Cue to Search SOA:  \t%1.4f\t ms\n'          , cue_to_search_SOA                         * 1000)
                    %                     fprintf('Target Display SOA:\t %1.4f\t ms\n'          , targDisplaySOA                            * 1000);
                    %                     fprintf('Target Display Duration: %1.4f\t ms\n\n'     , targetDisplayDur                          * 1000);
                    fprintf('-------------------------------------------------\n');
                    
                    
                    % -------------------------
                    % No subject break for WEDGEWOOD_VG
                    % -------------------------
                    %                     if((mod(currTrialNum, breakTrialNum) == 0)  ... %
                    %                             && not(currTrialNum == numTrials)   ... % No break on last trial
                    %                             && ~obj.is_practice)                     % No breaks during practice
                    %
                    %                         background.draw(winPtr);
                    %
                    %                         break_text = sprintf('Take a break\n\nAccuracy:\t %-1.2f \t%%\nResponse Time:\t %-1.2f\tmsecs\n\nPress button 10 button to continue', curr_mean_accuracy , curr_mean_RT);
                    %                         DrawFormattedText(winPtr, break_text, 'center', 'center',color2RGB_2(obj.fontColorWd),font_wrap,0,0,2);
                    %                         Screen('Flip', winPtr);            			% flip/draw buffer to display monitor
                    %                         waitForButtonRelease(progEnv.gamepadIndex);
                    %                         waitForSubjPress(progEnv.gamepadIndex);     % wait for button press (subj rest period)
                    %
                    %                         % --------------------------
                    %                         % Present cue instructions
                    %                         % --------------------------
                    %                         background.draw(winPtr);
                    %                         DrawFormattedText(winPtr, obj.cue_instructions, 'center', 'center',color2RGB_2(obj.fontColorWd),font_wrap,0,0,2);
                    %                         Screen('Flip', winPtr);                                                         % flip/draw buffer to display monitor
                    %                         waitForButtonRelease(progEnv.gamepadIndex);
                    %                         waitForSubjPress(progEnv.gamepadIndex);
                    %
                    %
                    %
                    %                         WaitSecs(.500);                                % give the subject a little time to get ready
                    %                     end
                    
                end % Trial End
                
                
                % -------------------------
                % Finish Expt
                % -------------------------
                
                
                
                % -------------------------
                % Present: Expt End Screen
                % -------------------------
                
                if(obj.is_practice)
                    end_instructions = sprintf('Practice Finished.\n\nAccuracy:\t %-1.2f \t%%\nResponse Time:\t %-1.2f\tmsecs\n\nPress button 10 to continue'  ...
                        , curr_mean_accuracy    ...
                        , curr_mean_RT          ...
                        );
                else
                    end_instructions = sprintf('Take a break.\n\nAccuracy:\t %-1.2f \t%%\nResponse Time:\t %-1.2f\tmsecs\n\nPress button 10 to continue'  ...
                        , curr_mean_accuracy    ...
                        , curr_mean_RT          ...
                        );
%                     soundsc(exptEndSndData, exptEndSndFreq);        % Play sound at expt run end
                end
                
                background.draw(winPtr);
                DrawFormattedText(winPtr, end_instructions, 'center', 'center',color2RGB_2(obj.fontColorWd),font_wrap);
                Screen('Flip', winPtr);                         % flip/draw buffer to display monitor
     
                
                waitForButtonRelease(progEnv.gamepadIndex);
                waitForSubjPress(progEnv.gamepadIndex);         % wait for button press
                    
%                     
%                 if(obj.is_practice)
%                     waitForButtonRelease(progEnv.gamepadIndex);
%                     waitForSubjPress(progEnv.gamepadIndex);         % wait for button press
%                 else
%                     KbWait;
%                 end
                
                % display experiment information @ run end
                obj.exptDuration = (GetSecs - startTime) / 60;  % (minutes)
                fprintf('Session Duration: %1.4f\t min\n\n'     , obj.exptDuration);
                
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                
            catch matlab_err
                
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                display(getReport(matlab_err));
                
            end
            
        end % run method
        
        function save_to_file(obj, trial_num, header, separator, excelYear, decimal)
            % Writes cell array content into a *.csv file.
            %
            % CELL2CSV(obj.save_filename, cellArray, separator, excelYear, decimal)
            %
            % obj.save_filename     = Name of the file to save. [ i.e. 'text.csv' ]
            % cellArray    = Name of the Cell Array where the data is in
            % separator    = sign separating the values (default = ';')
            % excelYear    = depending on the Excel version, the cells are put into
            %                quotes before they are written to the file. The separator
            %                is set to semicolon (;)
            % decimal      = defines the decimal separator (default = '.')
            %
            %         by Sylvain Fiedler, KA, 2004
            % updated by Sylvain Fiedler, Metz, 06
            % fixed the logical-bug, Kaiserslautern, 06/2008, S.Fiedler
            % added the choice of decimal separator, 11/2010, S.Fiedler
            
            %% Checking for optional Variables
            if ~exist('separator', 'var')
                separator = ',';
            end
            
            if ~exist('excelYear', 'var')
                excelYear = 1997;
            end
            
            if ~exist('decimal', 'var')
                decimal = '.';
            end
            
            %% Setting separator for newer excelYears
            if excelYear > 2000
                separator = ';';
            end
            
            %% Write file
            
            datei       = fopen(obj.save_filename, 'a+'); % open/create file; append data
            var_names   = transpose(fieldnames(obj.block.trials(trial_num)));
            
            for var_name = var_names
                
                if header
                    print_value = var_name{1};
                else
                    print_value = eval(['obj.block.trials(trial_num).' var_name{1}]);
                end
                
                % If zero, then empty cell
                if size(print_value, 1) == 0
                    print_value = '';
                end
                % If numeric -> String
                if isnumeric(print_value)
                    print_value = num2str(print_value);
                    % Conversion of decimal separator (4 Europe & South America)
                    % http://commons.wikimedia.org/wiki/File:DecimalSeparator.svg
                    if decimal ~= '.'
                        print_value = strrep(print_value, '.', decimal);
                    end
                end
                % If logical -> 'true' or 'false'
                if islogical(print_value)
                    if print_value == 1
                        print_value = 'TRUE';
                    else
                        print_value = 'FALSE';
                    end
                end
                % If newer version of Excel -> Quotes 4 Strings
                if excelYear > 2000
                    print_value = ['"' print_value '"']; %#ok<AGROW>
                end
                
                % OUTPUT value
                fprintf(datei, '%s', print_value);
                
                % OUTPUT separator
                %     if s ~= size(cellArray, 2)
                fprintf(datei, separator);
                %     end
                
            end
            
            fprintf(datei, '\n'); % print new line at end of every line
            
            % Closing file
            fclose(datei);
        end
        
    end % methods
    
    
end % classdef




%% Sub Functions %


function waitForSubjPress(gamepadIndex)
% Keep looping till keyPressName is pressed
BUTTON_10 = 10;
done = false;        % Initialize keyboard polling loop

waitForButtonRelease(gamepadIndex);   % Make sure to wait for key release AFTER start timing
%  . . . but why?
while not(done);   % keep polling keyboard for user response
    button10State = Gamepad('GetButton', gamepadIndex, BUTTON_10);
    
    if (button10State == true)
        done = true;
    end % button check
    
end % response loop

end


function waitForButtonRelease(gamepadIndex)
% Keeps looping till ONLY buttons 1-10 are all released

BUTTON_1 = 1;
BUTTON_2 = 2;
BUTTON_3 = 3;
BUTTON_4 = 4;
BUTTON_5 = 5;
BUTTON_6 = 6;
BUTTON_7 = 7;
BUTTON_8 = 8;
BUTTON_9 = 9;
BUTTON_10 = 10;

keyDown = true;
while(keyDown)
    
    buttonState = [ ...
        Gamepad('GetButton', gamepadIndex, BUTTON_1) ...
        Gamepad('GetButton', gamepadIndex, BUTTON_2) ...
        Gamepad('GetButton', gamepadIndex, BUTTON_3) ...
        Gamepad('GetButton', gamepadIndex, BUTTON_4) ...
        Gamepad('GetButton', gamepadIndex, BUTTON_5) ...
        Gamepad('GetButton', gamepadIndex, BUTTON_6) ...
        Gamepad('GetButton', gamepadIndex, BUTTON_7) ...
        Gamepad('GetButton', gamepadIndex, BUTTON_8) ...
        Gamepad('GetButton', gamepadIndex, BUTTON_9) ...
        Gamepad('GetButton', gamepadIndex, BUTTON_10) ...
        ];
    
    if(any(buttonState))
        keyDown = true;
    else
        keyDown = false;
    end
    
end

end



% END
