classdef wedgewood_trial_manager
    %WESTEND_TRIAL_MANAGER
    %   Manager class for WESTEND_TRIAL handle class
    %   Handles calculating accuracy

    methods (Static)
        
        function assignAccuracy(obj)
            
            if(strcmp(obj.resp_keyname, 'No_Press')) % if no response return NaN
                
                obj.accuracy = false;                % count 'no responses' as an response error
                
            elseif( (strcmp(obj.target_presence, 'present') && strcmp(obj.target_orientation, 'up')   && strcmp(obj.resp_keyname, 'gap UP button'    )) || ...
                    (strcmp(obj.target_presence, 'present') && strcmp(obj.target_orientation, 'down') && strcmp(obj.resp_keyname, 'gap DOWN button'  )) || ...
                    (strcmp(obj.target_presence, 'absent')  && strcmp(obj.resp_keyname, 'absent button')) )

                obj.accuracy = true;

            else
                obj.accuracy = false;
                
            end
        end
        
        function addTrial(trial_obj)
            % Add a listener for calculating accuracy
            addlistener(trial_obj, 'calculateAccuracy', ...
                @(src, evnt)wedgewood_trial_manager.assignAccuracy(src));
        end
        
    end
    
end



