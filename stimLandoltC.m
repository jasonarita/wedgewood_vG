classdef stimLandoltC
    %STIMLANDOLTCSummary of this function goes here
    %   Detailed explanation goes here
    % stimLandoltC(location_pt, orientation_wd, inColor)
    % draw(winPtr)
    % draw(winPtr, gapLoc)
    % draw(winPtr, gapLoc, location)



    properties
        location_pt;
        orientation_wd;

        gapSize_px;
        size_px;
        frameWidth_px;
        frameColor_wd;
        

        xyMatrix;

    end % properties

    properties(Dependent = true)
        
        frameColor_rgb;
        
    end % dependent properties
    

    methods

        function obj = stimLandoltC(varargin)
            % constructor function for STIMLANDOLTC

            % DEFAULTS
            location_pt         = pt(0,0);
            orientation_wd      = 'right';
            gapSize_px          = 5;
            size_px             = 30;
            frameWidth_px       = 6;
            frameColor_wd       = 'black';
            
            switch nargin
                
                case 0 
                    % use defaults
                case 2
                    
                    location_pt         = varargin{1};
                    orientation_wd      = varargin{2};

                case 3
                    
                    location_pt         = varargin{1};
                    orientation_wd      = varargin{2};
                    frameColor_wd       = varargin{3};
                    
                case 4
                    
                    location_pt         = varargin{1};
                    orientation_wd      = varargin{2};
                    frameColor_wd       = varargin{3};
                    
                    % Cortical Scaling
                    sizeScale           = varargin{4};
                    size_px             = size_px       * sizeScale;
                    gapSize_px          = gapSize_px    * sizeScale;
                    frameWidth_px       = frameWidth_px * sizeScale;
                otherwise
                    error('Wrong number of input arguments');
            end
            
            sizeC       = size_px;
            sizeD       = size_px - frameWidth_px;
            gapsizeC    = gapSize_px;
            gapLocation = orientation_wd;
                        
            
            %Make the Landolt-C shape         

            
            switch gapLocation %boxes are always made top line(s), right line(s), bottom line(s), then left line(s)
                case 'up'
                    xyMatrix=[-.5*sizeC, -.5*gapsizeC,  .5*gapsizeC,  .5*sizeC,     .5*sizeD, .5*sizeD,    -.5*sizeC, .5*sizeC,    -.5*sizeD, -.5*sizeD;... % x line-pts
                              -.5*sizeD, -.5*sizeD,    -.5*sizeD,    -.5*sizeD,    -.5*sizeC, .5*sizeC,     .5*sizeD, .5*sizeD,    -.5*sizeC,  .5*sizeC];  % y line-pts
                case 'right'
                    xyMatrix=[-.5*sizeC,  .5*sizeC,    .5*sizeD, .5*sizeD,   .5*sizeD,   .5*sizeD,    -.5*sizeC, .5*sizeC,     -.5*sizeD, -.5*sizeD;...
                              -.5*sizeD, -.5*sizeD,   -.5*sizeC,-.5*gapsizeC,.5*gapsizeC,.5*sizeC,     .5*sizeD, .5*sizeD,     -.5*sizeC,  .5*sizeC];
                case 'down'
                    xyMatrix=[-.5*sizeC,  .5*sizeC,    .5*sizeD, .5*sizeD,   -.5*sizeC, -.5*gapsizeC,.5*gapsizeC, .5*sizeC,     -.5*sizeD, -.5*sizeD;...
                              -.5*sizeD, -.5*sizeD,   -.5*sizeC, .5*sizeC,    .5*sizeD,  .5*sizeD,   .5*sizeD,    .5*sizeD,     -.5*sizeC,  .5*sizeC];
                case 'left'
                    xyMatrix=[-.5*sizeC, .5*sizeC,     .5*sizeD,.5*sizeD,    -.5*sizeC,.5*sizeC,    -.5*sizeD,-.5*sizeD,  -.5*sizeD,  -.5*sizeD;...
                              -.5*sizeD,-.5*sizeD,    -.5*sizeC,.5*sizeC,     .5*sizeD,.5*sizeD,    -.5*sizeC,-.5*gapsizeC,.5*gapsizeC,.5*sizeC];
                otherwise
                    error('Input ErrorWrong stimulus gap location number');
            end

            %Create the position correction positions for the stimuli, based on the position matrix input
            X=1;    % array index for x-coordinate
            Y=2;    % array index for y-coordinate
            numLinePts      = size(xyMatrix,2);
            positionMatrix  = [ repmat(location_pt(X), [1 numLinePts]) ;  % x line-points
                                repmat(location_pt(Y), [1 numLinePts])];  % y line-points
                            

                            
            % Set Obj Properties
                            
            obj.location_pt     = location_pt;
            obj.orientation_wd  = orientation_wd;
            obj.gapSize_px      = gapSize_px;
            obj.size_px         = size_px;
            obj.frameWidth_px   = frameWidth_px;
            obj.frameColor_wd   = frameColor_wd;
            
            
            
            obj.xyMatrix        = round(xyMatrix+positionMatrix);                                % set landolt-c matrix in final position            


        end % constructor method
        
        function obj    = set.frameWidth_px(obj, width_px)
            if(~mod(width_px, 2))
                obj.frameWidth_px = width_px;
            else
                error('FRAMEWIDTH_PX: frame width must be even number of pixels');              
            end
        end % set method
        
        function value  = get.frameColor_rgb(obj)
            
            value = color2RGB_2(obj.frameColor_wd);
            
        end % get method
            
        function draw(obj, winPtr, location_pt)           
            
            Screen('DrawLines', winPtr, obj.xyMatrix, obj.frameWidth_px, color2RGB_2(obj.frameColor_wd), location_pt.array);

        end % draw method
        
        function show(obj)
            
            try

                bgColor = 'white';
                [winPtr winRect centerPt] = setupScreen(color2RGB_2(bgColor));
                Priority(MaxPriority(winPtr));

                % ---- INSERT DRAW COMMANDS ---- %
                                              
                obj.draw(winPtr, centerPt);
               
                
                % ------------------------------ %
                
                Screen('Flip', winPtr);     % flip/draw buffer to display monitor
                KbWait;
                Screen('CloseAll');         % close psychtoolbox screen
                Priority(0);
                
            catch matlab_err
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                display(getReport(matlab_err));
                
            end % try-catch
            
        end % method
        
    end % methods

end % class def

