% Based on https://www.nature.com/articles/nmeth.1618

function out_color= get_cbf_color(col_name)

switch lower(col_name)

    case{'k', 'black'}
        out_color= [0, 0, 0]/255;

    case {'o', 'orange'}
        out_color= [230, 159, 0]/255;

    case {'sky','sky_blue', 'sb', 'lightblue', 'lb'}
        out_color= [86, 180, 233]/255;

    case {'blue_green', 'dg', 'darkgreen'}
        out_color= [0, 158, 115]/255;

    case {'yellow', 'y'}
        out_color= [240, 228, 66]/255;

    case {'blue', 'b'}
        out_color= [0, 114, 178]/255;

    case {'vermillion', 'v', 'r', 'red'}
        out_color= [213,94,0]/255;

    case {'purple', 'red_purple'}
        out_color= [204, 121, 167]/255;

end

end