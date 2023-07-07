% darkgreen and purple go together
function out_color= get_color(col_name)

if ~exist('col_name', 'var')
    co= get(gca, 'colororder');
    col_num= get(gca, 'ColorOrderIndex');
    out_color= co(col_num+1, :);
    
elseif ischar(col_name)
    switch col_name
           
        case {'r', 'red'}
            out_color= [215 48 39]/255;
            
        case {'g', 'green'}
            out_color= [119, 172, 48]/255;
            
        case {'b', 'blue'}
            out_color= [69 117 180]/255;

        case {'lr', 'lightred'}
            out_color= [252 141 89]/255;

        case {'lg', 'lgreen', 'lightgreen'}
            out_color= [171 240 160]/255;
            
        case {'lb', 'lightblue'}
            out_color= [145 191 219]/255;            
            
        case {'dr', 'darkred'}
            out_color= [136, 8, 8]/255;
            
        case {'dg', 'darkgreen'}
            out_color= [0 136 55]/255;
            
        case {'db', 'darkblue'}
            out_color= [0, 0, 139]/255;
            
        case {'prp', 'purple'}
            out_color= [123 50 148]/255;
            
        case {'light_prp', 'lprp', 'light_purple'}
            out_color= [177, 156, 217]/255;
            
        case {'gray'}
            out_color= [100 100 100]/255;

        case {'lgray','lightgray'}
            out_color= [150 150 150]/255;

        case {'wg'} % white-gray
            out_color= [200 200 200]/255;
            
        case {'black', 'k'}
            out_color= [0 0 0]/255;
        
        case {'orange'}
            out_color= [255, 102, 0]/255;
            
        case {'brown', 'br'}
            out_color= [162 20 47]/255;
            
        case {'w', 'white'}
            out_color= [255 255 255]/255;
            
        case{'c', 'cyan'}
            out_color= [0 255 255]/255;

        case{'dm', 'darkmagenta'}
            out_color= [153 0 153]/255;            
       
        case{'m', 'magenta'}
            out_color= [255 0 255]/255;
            
        case{'lm', 'lightmagenta'}
            out_color= [255 153 255]/255;
            
        case{'lbrown', 'lightbrown'}
            out_color= [181 101 29]/255;
            
        case{'bronze'}
            out_color= [204 128 51]/255;
            
        case {'pink'}
            out_color= [255 192 203]/255;

        case {'lavender'}
            out_color= [244,187,255]/255;
    end
    
elseif isnumeric(col_name)
    co= get(gca, 'colororder');
    out_color= co(col_name+1, :);
    
end