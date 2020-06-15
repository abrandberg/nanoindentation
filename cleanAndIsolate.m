function xyOut = cleanAndIsolate(xy0)
% Step 1: We want to isolate the part of the curve related to the main loading, which
% goes to 20 um.

% figure;
% plot(xy0(:,1),xy0(:,2))

% plot(xy0(:,1))

% plot([1:length(xy0(:,2))]/2000,xy0(:,2))

xyOut = xy0((10.3*2000):round(60*2000),:);
% plot(xyOut(:,1),xyOut(:,2))



































