% function [ run_01 run_02 run_03 run_04 run_05 run_06 run_07 run_08 run_09 practice_run_01 practice_run_02 practice_run_03 ] = start_wedgewood( input_args ) %#ok<INUSD,*STOUT>
% start_wedgewood Create all 4 runs (3 + 3 practices) for experiment wedgewood
%
% Version F: Three set sizes -- { 4, 8, 12 } ( cluster sizes 2, 4, 6 respectively)
%
%   Example:
%           [ run_01 run_02 run_03 run_04 run_05 run_06 run_07 run_08 run_09 practice_run_01 practice_run_02 practice_run_03 ] = start_wedgewood();
%


% switch nargin
%     
%     case 0                                                              % Default settings
        % -------------------------- %
        % Prompt Experiment Run Info %
        % -------------------------- %
        clc;
        clear all;
        promptTitle                 = 'Experimental Setup Information';
        prompt                      =   ...
            { 'Enter subject number: '  ...
            };
        promptNumAnsLines           = 1;
        promptDefaultAns            =   ...
            { 'pilot_F01'                ...
            };
        
        
        options.Resize              = 'on';
        answer                      = inputdlg(prompt, promptTitle, promptNumAnsLines, promptDefaultAns, options);
        subj_num                    = answer{1};
        condition_order_num         = mod(str2double(subj_num(end-1:end)), 6);
        
%     otherwise
%         error('Wrong number of input arguments');
% end





% Figure out the condition order
switch condition_order_num
    case 1
        condition_list = [ 1 2 3 ];
    case 2
        condition_list = [ 1 3 2 ];
    case 3
        condition_list = [ 2 1 3 ];
    case 4
        condition_list = [ 2 3 1 ];
    case 5
        condition_list = [ 3 1 2 ];
    case {6,0}
        condition_list = [ 3 2 1 ];
    otherwise
        error('Wrong condition number')
end




display(condition_list);

% Create all runs and practice-runs
practice_run_num=1;
run_num=1;
for condition_num = condition_list
    
    set_size_list = Shuffle([ 4 8 12 ]);
    
    % create practice runs
    is_practice         = 'yes';
    practice_set_size   = set_size_list(1);
    run_command     = sprintf('practice_run_0%d = wedgewood_session(''%s'' ,%d ,%d ,{%d} ,''%s'');' , practice_run_num, subj_num, practice_run_num, condition_num, practice_set_size, is_practice);
    eval(run_command);
    practice_run_num=practice_run_num+1;
    
    for set_size = set_size_list
        
        % create experiment runs
        is_practice         = 'no';
        run_command     = sprintf('run_0%d = wedgewood_session(''%s'' ,%d ,%d ,{%d} ,''%s''); '      , run_num ,subj_num , run_num, condition_num, set_size, is_practice);
        eval(run_command);
        
        
        % Create output file & write headers
        if(run_num == 1)
            practice_run_01.save_to_file(1,true);
            run_01.save_to_file(1,true);
        end
        
        run_num = run_num+1;
    end
end




% end

