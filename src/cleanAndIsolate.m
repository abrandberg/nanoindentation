function xyOut = cleanAndIsolate(xy0)
% Step 1: We want to isolate the part of the curve related to the main loading, which
% goes to 20 um.

xyOut = xy0((10.0*2000):round(60*2000),:);




































