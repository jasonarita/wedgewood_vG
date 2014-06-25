classdef conditionInfo
    % CONDITIONINFO Summary of this class goes here
    %   Detailed explanation goes here


    properties
        
    end

    properties(Constant = true)

        button_columns      = 2:3;
        cue_column          = 1;
        instruction_column  = 4;
        conditionTable  = {...
            'cue type'  , 'gap UP button'   , 'gap DOWN button' , 'instructions'                                                             ; ...
            'positive'  ,  1                        ,  2                        , 'The color of the cue tells you what the TARGET color will be.\nPress start to continue...'                                       ; ...
            'negative'  ,  1                        ,  2                        , 'The color of the cue tells you what the DISTRACTOR color will be.\nPress start to continue...'                                  ; ...
            'neutral'   ,  1                        ,  2                          'The cue doesn''t indicate anything about the target or distractor colors.\nPress start to continue...' ; ...
            };


    end

    
    
    methods
        
        function obj        = conditionInfo(varargin)
            
            switch(nargin)
                
                case 0
                    
                otherwise
                    error('Wrong number of input arguments');
                    
            end
            
            
            
            
        end
        
        function buttons        = button_nums(obj, cond_num)
            buttons = obj.conditionTable(cond_num+1, obj.button_columns);
        end
        
        function names          = button_names(obj)
            names = obj.conditionTable(1, obj.button_columns);
        end
        
        function cue_type       = cue_type(obj, cond_num)
            cue_type = obj.conditionTable{cond_num+1, obj.cue_column};
        end
        
        function instruction_string   = instruction(obj, cond_num)
            instruction_string = obj.conditionTable{cond_num+1, obj.instruction_column};
        end            
        
    end
end
