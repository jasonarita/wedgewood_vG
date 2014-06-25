classdef stimBoxArray
    %STIMBOXARRAY Summary of this function goes here
    %   stimBoxArray(centerLoc_pt, targOrientation, targBoxNum, exptVars)

    properties
        
        boxes;
        centerLoc_pt;
        distFromCenter;
        
        numStim;
        box2ColorWd;
        box4ColorWd;
        box8ColorWd;
        box10ColorWd;
        defaultBoxColor_wd;
        
    end % properties  
    
    
    methods



        function obj  = stimBoxArray(varargin)
            % obj = stimArray(centerLoc_pt, exptVars)
            % obj = stimArray(centerLoc_pt, targetOrientation, targetBoxNum, exptVars)

            switch nargin

                
                case 0
                    obj.numStim            = 12;
                    obj.centerLoc_pt       = pt(400,800);
                    obj.distFromCenter	   = 200;
                    obj.defaultBoxColor_wd = 'white';
                    obj.box2ColorWd        = 'gray';
                    obj.box4ColorWd        = 'gray';
                    obj.box8ColorWd        = 'gray';
                    obj.box10ColorWd       = 'gray';
                    obj.boxes              = stimBox.empty;
                      
                    
                case 1
                   
                    obj                    = stimBoxArray();
                    obj.centerLoc_pt       = varargin{1};
                    
                case 5
                    obj                    = stimBoxArray();
                    obj.centerLoc_pt       = varargin{1};
                    obj.box2ColorWd        = varargin{2};
                    obj.box4ColorWd        = varargin{3};
                    obj.box8ColorWd        = varargin{4};
                    obj.box10ColorWd       = varargin{5};
                    
                otherwise
                    error('Wrong number of input arguments');
            end

            obj = obj.update();
            

        end % constructor method

        function draw(obj, winPtr)

            for stimNum = 1:obj.numStim

                obj.boxes(stimNum).draw(winPtr);

            end % stim loop

        end % draw method
        
        function obj     = update(obj)
            
               
            % ------------------ %
            % Create Stim: Boxes %
            % ------------------ %
            boxes               = stimBox.empty; % initial stimArray
            
            numStim             = obj.numStim
            centerLoc_pt        = obj.centerLoc_pt;
            distFromCenter      = obj.distFromCenter;
            box2ColorWd         = obj.box2ColorWd;
            box4ColorWd         = obj.box4ColorWd;
            box8ColorWd         = obj.box8ColorWd;
            box10ColorWd        = obj.box10ColorWd;
            defaultBoxColor_wd  = obj.defaultBoxColor_wd;
            
            for stimNum = 1:numStim
                
                boxCenterLoc_pt = radialCoordinate(stimNum, numStim, centerLoc_pt, distFromCenter);

                % Set RGB value for box: converted from experimentor input
                switch stimNum
                    case 2
                        boxInColor = box2ColorWd;  % RGB value converted from experimentor input
                    case 4
                        boxInColor = box4ColorWd;  % RGB value converted from experimentor input
                    case 8
                        boxInColor = box8ColorWd;  % RGB value converted from experimentor input
                    case 10
                        boxInColor = box10ColorWd; % RGB value converted from experimentor input
                    otherwise % Non-cued box
                        boxInColor = defaultBoxColor_wd;    % uncolored box => use background color (transparent box)
                end
                
                boxes(stimNum) = stimBox(boxCenterLoc_pt, boxInColor);

            end % stim loop
            
            
            obj.boxes = boxes;
            
        end % method

        function boxNum  = boxColor2BoxNum(obj, boxColor)

%             if(strcmp(boxColor, obj.box2ColorWd))
%                 boxNum = 2;
%             elseif (strcmp(boxColor, obj.box4ColorWd))
%                 boxNum = 4;
%             elseif (strcmp(boxColor, obj.box08ColorWd))
%                 boxNum = 8;
%             elseif (strcmp(boxColor, obj.box10ColorWd))
%                 boxNum = 10;
%             else
%                 boxNum = NaN;
%             end
            
            boxNum = NaN;
            
            for stimNum = 1:obj.numStim
                if(strcmp(boxColor, obj.boxes(stimNum).inColor))
                    boxNum = stimNum;
                end
            end
                    
                    
                
            

        end

        function show(obj)

            try

                bgColor = 'white';
                [winPtr, winRect, centerPt] = setupScreen(color2RGB(bgColor));
                Priority(MaxPriority(winPtr));

                % ---- INSERT DRAW COMMANDS ---- %

                
%                 display(centerPt);
%                 obj = stimBoxArray(centerPt);
tic;
                obj.draw(winPtr);
toc;

                % ------------------------------ %

                Screen('Flip', winPtr);     % flip/draw buffer to display monitor
                KbWait;
                Screen('CloseAll');         % close psychtoolbox screen
                Priority(0);

            catch
                Screen('CloseAll');         % close psychtoolbox screen
                Priority(0);
                uhoh = lasterror;
                for stackNum = 1:length(uhoh.stack)
                    disp(uhoh.stack(stackNum));
                end
                rethrow(uhoh);         % display error to comman window

            end % try-catch

        end % method

        function display(obj)
            % DISPLAY displays info for STIMARRAY obj

            
            for x = 1:obj.numStim
                
                eval(sprintf('box%d = obj.boxes(x)', x))
                disp(' ');
            end
            
            disp(' ');
            disp(obj)
            disp(' ');
            disp(sprintf('%s is a %s object', inputname(1), class(obj)))
            
        end % function

    end % methods

end % class def








%         function value   = get.numStim(obj)
%             
%             value = length(obj.boxes);
%             
%         end % get method
