function directioncallback( obj, ~, ~, q)
string = q.String;
% check the allowable direction ... 
switch lower( string )
    case 'east'
        obj.direction = 'east';
    case 'north'
        obj.direction = 'north';
    case 'south'
        obj.direction = 'south';
    case 'west'
        obj.direction = 'west';
    case 'northeast'
        obj.direction = 'northeast';
    case 'northwest'
        obj.direction = 'northwest';
    case 'southeast'
        obj.direction = 'southeast';
    case 'southwest'
        obj.direction = 'southwest';
    otherwise
        warning('invalid ''direction'' string, ''east'' assumed!');
        obj.direction = 'east';
end