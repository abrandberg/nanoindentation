function xy = IBWtoTXT(filename)

	[vector, ~, ~, ~, ~] = ReadIBW(filename);

	lv = length(vector)/3;
	
	y = vector(lv+1:2*lv);
	x = vector(2*lv+1:3*lv);

	xy = [x,y];

	lfm = length(filename)-3;

% % 	savename = [filename(1:lfm), "txt"];
%         savename = horzcat(filename(1:lfm),'txt');
% 	save('-ascii', savename, 'xy');
end
