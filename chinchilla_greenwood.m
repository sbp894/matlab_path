function outVar= chinchilla_greenwood(inVar, inType)



switch lower(inType)
    case {'f', 'freq'}
        freq= inVar;
        outVar= (1/2.1) *  log10(.85 + freq/163.5);
    case {'l', 'd', 'len', 'dist'} %
        coch_dist= inVar;
        outVar= 163.5*( 10 .^ (2.1*coch_dist) - 0.85 );
end