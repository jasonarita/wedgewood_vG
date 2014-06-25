classdef stimLandoltCArray
    %STIMARRAY Summary of this function goes here
    %   stimArray(centerPt, targ_orientation, targBoxNum, exptVars)

    properties

        stims;
        centerLoc_pt;
        arrayRadius;
        
        distractor_orientations;
        jitter_px; 
        
        xyMatrix;
        colorMatrix;
    end % properties
    
    
    properties(Dependent = true)
        
        numStim;
        
    end


    methods
        
        function obj    = stimLandoltCArray(varargin)
            % obj = stimArray(centerPt, exptVars)
            % obj = stimArray(centerPt, TargetPresence, targetBoxNum, exptVars)
            numStim                         = 12;
            sizeScale                       = 1;
            uniqueLandoltCs                 = [];
            obj.xyMatrix                    = [];
            obj.colorMatrix                 = [];
            centerLoc_pt                    = [0,0];
            arrayRadius                     = 200;
            radius_shift                    = -pi/2;
            
            distractor_orientations         = {'left', 'right'};
            distractor_color                = 'black';
            
            
            switch nargin
                case 0
                    
                case 2
                    
                    numStim             = varargin{1};
                    arrayRadius         = varargin{2};
                    
                case 3
                    numStim             = varargin{1};
                    arrayRadius         = varargin{2};
                    
                    if(isstruct(varargin{3}))
                        uniqueLandoltCs = varargin{3};
                    elseif(isnumeric(varargin{3}))
                        sizeScale       = varargin{3};
                    end
                    
                case 4
                    numStim             = varargin{1};
                    arrayRadius         = varargin{2};
                    
                    if(isstruct(varargin{3}))
                        uniqueLandoltCs = varargin{3};
                    elseif(isnumeric(varargin{3}))
                        sizeScale       = varargin{3};
                    end
                    
                    radius_shift        = varargin{4}; % overrides radius shift
                    
                otherwise
                    error('Wrong number of input arguments');
            end







            %% ------------------
            % Create Stim:
            % -------------------
            
            obj.stims                   = cell(numStim, 1); % initial stimArray
            obj.centerLoc_pt            = centerLoc_pt;
            obj.arrayRadius             = arrayRadius;
            obj.distractor_orientations = distractor_orientations;
            obj.jitter_px               = 0;            
            obj.xyMatrix                = [];
                         
            
            for stimNum = 1:length(uniqueLandoltCs) % numStim
                
                % Compute distractor location
                X=1;    % array index for x-coordinate 
                Y=2;    % array index for y-coordinate
                obj_locPt   = radialCoordinate(stimNum, numStim, centerLoc_pt, arrayRadius, radius_shift);
                obj_locPt(X) = obj_locPt(X) + round(rand * (obj.jitter_px - -obj.jitter_px) + -obj.jitter_px);
                obj_locPt(Y) = obj_locPt(Y) + round(rand * (obj.jitter_px - -obj.jitter_px) + -obj.jitter_px);
                        
                % Compute distractor gap orientation 
                numDistractor_orientations  = length(distractor_orientations);
                landoltC_orientation        = distractor_orientations{round(rand*(numDistractor_orientations-1)+1)};
                landoltC_color              = distractor_color;
                
                if(~isempty(uniqueLandoltCs))  % 
                    uniqueLandoltC_index        = stimNum; % find([uniqueLandoltCs.location] == stimNum, 1);
                    if(~isempty(uniqueLandoltC_index))
                        
                        % Compute distractor location
                        obj_location_num    = uniqueLandoltCs(uniqueLandoltC_index).location;
                        obj_locPt           = radialCoordinate(obj_location_num, numStim, centerLoc_pt, arrayRadius, radius_shift);
                        obj_locPt(X)         = obj_locPt(X) + round(rand * (obj.jitter_px - -obj.jitter_px) + -obj.jitter_px);
                        obj_locPt(Y)         = obj_locPt(Y) + round(rand * (obj.jitter_px - -obj.jitter_px) + -obj.jitter_px);
                        
                        if(~isempty(uniqueLandoltCs(uniqueLandoltC_index).color))
                            landoltC_color          = uniqueLandoltCs(uniqueLandoltC_index).color;
                        else
                            landoltC_color          = distractor_color;
                        end
                        
                        % Set unique landolt-C ORIENTATION
                        if(~isempty(uniqueLandoltCs(uniqueLandoltC_index).orientation))
                            landoltC_orientation    = uniqueLandoltCs(uniqueLandoltC_index).orientation;
                        else
                            landoltC_orientation    = cell2mat(RandSample(distractor_orientations));
                        end
                        
                        
                    else
                        % do nothing
                    end
                end
                

                % create Landolt-C object
                obj.stims{stimNum}  = stimLandoltC(obj_locPt, landoltC_orientation, landoltC_color, sizeScale);


                obj.xyMatrix        = [obj.xyMatrix     obj.stims{stimNum}.xyMatrix];
                obj.colorMatrix     = [obj.colorMatrix  repmat(obj.stims{stimNum}.frameColor_rgb', [1 length(obj.stims{stimNum}.xyMatrix)])];

            end % stim loop
            
            
        end

        function value  = get.numStim(obj)
            
            value = length(obj.stims);
            
        end % get method
        
        function draw(obj, varargin)
                       
            switch nargin
                
                case 2 
                    winPtr = varargin{1};
            
                    Screen('DrawLines', winPtr, obj.xyMatrix, obj.stims{1}.frameWidth_px, obj.colorMatrix, obj.centerLoc_pt);
           
                case 3
                    
                    winPtr          = varargin{1};
                    new_location_pt = varargin{2};
                    Screen('DrawLines', winPtr, obj.xyMatrix, obj.stims{1}.frameWidth_px, obj.colorMatrix, new_location_pt);
                    
                otherwise
                    error('Wrong number of input arguments');
                    
            end
                    
        end % draw method

        function value  = show(obj)
            
            try
                bgColor = 'white';
                [winPtr winRect center_pt] = setupScreen(color2RGB(bgColor)); %#ok<ASGLU>
                Priority(MaxPriority(winPtr));

                % INSERT DRAW COMMANDS
                        
                
                keyIsDown = false;
                counter   = 1;
                
                while(~keyIsDown)
                
                tic;
                obj.draw(winPtr, center_pt);
                value(counter) = toc;
                
                % ----------------------
                
                Screen('Flip', winPtr);     % flip/draw buffer to display monitor
                
                keyIsDown   = KbCheck;
                counter     = counter + 1;
                end
                
                Screen('CloseAll');         % close psychtoolbox screen
                Priority(0);

                
            catch matlab_err
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                display(getReport(matlab_err));
            end
            
        end % method
        
    end % methods

    
end % class def


function outputLoc_pt = radialCoordinate(varargin)
%RADIALCOORDINATE
% returns cartesian coordinate position of a point on a circle defined by
% RADIUS pixels away from a center.
% 
%   outputLoc_pt = radialCoordinate(stimNum, numStim, radius)
%   outputLoc_pt = radialCoordinate(stimNum, numStim, centerLoc_pt, radius)

% Defaults
radius_shift        = -pi/2;

switch nargin
    
    case 3
        
        stimNum         = varargin{1};
        numStim         = varargin{2};
        radius          = varargin{3};
        centerLoc_pt    = [0,0];
        
    case 4
        
        stimNum 	   = varargin{1};
        numStim        = varargin{2};
        centerLoc_pt   = varargin{3};
        radius         = varargin{4};
        
    case 5
        
        stimNum 	   = varargin{1};
        numStim        = varargin{2};
        centerLoc_pt   = varargin{3};
        radius         = varargin{4};
        radius_shift   = varargin{5};   % overrides RADIUS_SHIFT
        
    otherwise
        error('Wrong number of input arguments');
end
X=1;    % array index for x-coordinate 
Y=2;    % array index for y-coordinate

% Calculate location
radIncr         = (2 * pi)/numStim;   % spacing between stimuli (in radians)

outputLoc_pt = ...
    [ round(centerLoc_pt(X) + cos((stimNum * radIncr) + radius_shift) * radius)     ... % x-coord
    , round(centerLoc_pt(Y) + sin((stimNum * radIncr) + radius_shift) * radius)     ... % y-coord
    ];

end
