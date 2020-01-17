function y = gen_norm_power(x)
y= ( x - mean(x)) / std(x,1); % so that rms of output = 1
end