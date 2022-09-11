function xy = IBWtoTXT(filename)
	[vector, ~, ~, ~, ~] = ReadIBW(filename);
	lv = length(vector)/3;
	y = vector(lv+1:2*lv);
	x = vector(2*lv+1:3*lv);
	xy = [x,y];
end
