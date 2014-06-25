classdef stimBox
    %STIMBOX Summary of this function goes here
    %  obj = stimBox(width, height, frameWidth, frameColor, centerPt, inColor)


    properties

        width;
        height;
        frameWidth;
        frameColor;
        centerPt;
        inColor;
        
        
        outerStimRect;
        innerStimRect;
    end % properties


    
    
    methods

        function obj    = stimBox(varargin)
        
            switch(nargin)
                
                case 0
                    obj.centerPt   = pt(500,500);
                    obj.width      = 50;
                    obj.height     = 50;
                    obj.frameWidth = 6;
                    obj.frameColor = 'green';
                    obj.inColor    = 'green';
                    
                case 1
                    
                    obj.centerPt   = varargin{1};
                    obj.width      = 50;
                    obj.height     = 50;
                    obj.frameWidth = 6;
                    obj.frameColor = 'black';
                    obj.inColor    = 'white';
                    
                case 2
                    
                    obj.centerPt   = varargin{1};
                    obj.width      = 50;
                    obj.height     = 50;
                    obj.frameWidth = 6;
                    obj.frameColor = 'black';
                    obj.inColor    = varargin{2};                    
                    
                case 6
                    obj.width       = varargin{1};
                    obj.height      = varargin{2};
                    obj.frameWidth  = varargin{3};
                    obj.frameColor  = varargin{4};
                    obj.centerPt    = varargin{5};
                    obj.inColor     = varargin{6};
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
            obj.outerStimRect = [0 0 obj.height obj.width];
            obj.outerStimRect = CenterRectOnPoint(obj.outerStimRect, obj.centerPt.x, obj.centerPt.y);
            obj.innerStimRect = [0 0 obj.height-obj.frameWidth  obj.width-obj.frameWidth];
            obj.innerStimRect = CenterRectOnPoint(obj.innerStimRect, obj.centerPt.x, obj.centerPt.y);
            
            
            
        end % constructor method
                    
        
        function draw(obj, varargin)

            X=1;
            Y=2;
            
            switch nargin
                case 2
                    winPtr = varargin{1};
                    Screen('FillRect', winPtr, color2RGB_2(obj.frameColor), obj.outerStimRect);
                    Screen('FillRect', winPtr, color2RGB_2(obj.inColor),    obj.innerStimRect);
                case 3
                    winPtr          = varargin{1};
                    new_location_pt = varargin{2};
                    
                    outter_rect  = CenterRectOnPoint(obj.outerStimRect, new_location_pt(X), new_location_pt(Y));
                    inner_rect   = CenterRectOnPoint(obj.innerStimRect, new_location_pt(X), new_location_pt(Y));
                    
                    Screen('FillRect', winPtr, color2RGB_2(obj.frameColor), outter_rect);
                    Screen('FillRect', winPtr, color2RGB_2(obj.inColor),    inner_rect);
                otherwise
                    error('Wrong number in input arguments');
            end
            
        end % method
        
        
        function show(obj)
            
            try

                [winPtr, winRect, centerPt] = setupScreen(color2RGB_2('white')); %#ok<ASGLU>
                Priority(MaxPriority(winPtr));

                tic;
                obj.draw(winPtr, centerPt);
                toc;
                Screen('Flip', winPtr);     % flip/draw buffer to display monitor


                KbWait;
                Screen('CloseAll');         % close psychtoolbox screen
                Priority(0);

            catch matlab_err
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                display(getReport(matlab_err));
            end
            
        end % method
        

    end % methods

end
