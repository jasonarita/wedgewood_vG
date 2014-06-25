classdef stimBoxFrame
%STIMBOXFRAME Summary of this class goes here
%   Detailed explanation goes here

   properties
       
       shape;
       
       color_wd;
       boxSize_px;
       frameSize_px;
       
   end

   methods
       
       function obj     = stimBoxFrame(varargin)
           
           switch nargin
               
               case 0
                   obj.frameSize_px = 10;
                   obj.color_wd     = 'black';
                   obj.boxSize_px   = 100;
                   

                   
                   % Calculate Shape %
                   basePixelSize  = obj.boxSize_px;
                   frameOffset_px = obj.frameSize_px/2;
                   top_ln      = ln(pt(-basePixelSize,  -basePixelSize+frameOffset_px) , pt( basePixelSize, -basePixelSize+frameOffset_px));
                   btm_ln      = ln(pt(-basePixelSize,   basePixelSize-frameOffset_px) , pt( basePixelSize,  basePixelSize-frameOffset_px));
                   
                   
                   right_ln    = ln(pt( basePixelSize-frameOffset_px, basePixelSize) , pt( basePixelSize-frameOffset_px, -basePixelSize));
                   left_ln     = ln(pt(-basePixelSize+frameOffset_px, basePixelSize) , pt(-basePixelSize+frameOffset_px, -basePixelSize));
                   
                   obj.shape = [top_ln.matrix btm_ln.matrix right_ln.matrix left_ln.matrix];
                   
               otherwise
                   error('Wrong number of input arguments');
           end % switch
           
       end % constructor method
       
       
       
       function draw(obj, varargin)
           
           switch nargin
               
               case 2
                   winPtr    = varargin{1};
                   center_pt = pt(0, 0);
               case 3
                   winPtr    = varargin{1};
                   center_pt = varargin{2};
               otherwise
                   error('Wrong number of input arguments');
           end % switch
           

           xyMatrix = obj.shape;
           width    = obj.frameSize_px;
           color    = color2RGB(obj.color_wd);
           center   = center_pt.array;
           
           Screen('DrawLines', winPtr, xyMatrix, width, color, center);
       
       end % draw method
       
       function show(obj)
            try

                [winPtr, winRect, centerPt] = setupScreen(color2RGB('white'));
                Priority(MaxPriority(winPtr));

                tic;
                obj.draw(winPtr, centerPt);
                toc;
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
            
       end % show function
       
   end
end


      
      
