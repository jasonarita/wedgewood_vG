function rgbVal = color2RGB_2(colorName)
%
% Given a string indicating the color (e.g. 'red', 'green', 'magenta', etc)
% return that color's corresponding RGB value in a three element vector.
%
% For example:
%   colorName2RGB('red') => [200 0 0]

% global RED GREEN BLUE MAGENTA

% Color-word RGB Values
RED     = [200 000 000];
GREEN   = [000 150 000];
BLUE    = [030 030 255];
MAGENTA = [200 000 200];
YELLOW  = [255 255 000];
GRAY    = [075 075 075];
WHITE   = [255 255 255];
BLACK   = [000 000 000];

if nargin~=1
    error('ERROR: COLOR2RGB(colorName) only takes one input variable')
end

switch lower(colorName)
    case 'red'
        rgbVal = RED;
    case 'green'
        rgbVal = GREEN;
    case 'blue'
        rgbVal = BLUE;
    case 'magenta'
        rgbVal = MAGENTA;
    case 'yellow'
        rgbVal = YELLOW;
    case 'white'
        rgbVal = WHITE;
    case 'gray'
        rgbVal = GRAY;
    case 'black'
        rgbVal = BLACK;
    otherwise
        error('ERROR: unrecognized input color for COLOR2RGB')
end

end