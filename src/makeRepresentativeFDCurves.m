function makeRepresentativeFDCurves(indentationSet,ctrl,hyperParameters,resultFile)

% Preprocessing
xy = dataPreProcessing(horzcat(indentationSet.targetDir,resultFile));

[xy,~,~,~,~] = offsetAndDriftCompensation(xy);

xy(:,1) = xy(:,1)-xy(:,2);                                      % Subtract deflection from distance to get indentation.
xy(:,2) = 1e-3*xy(:,2)*indentationSet.springConstant;           % [10^-9*m]*[N/m] = nN Multiply deflection with spring constant to get the force.

xy(xy(:,1)<-25,:) = [];


f1 = gramm('x',xy(:,1),'y',xy(:,2));
f1.geom_line();
f1.set_names('x','Indentation $h$ [nm]','y','Indentation force $F$ [$\mu$N]');
f1.set_text_options('interpreter','latex','base_size',11,'font','Arial');
f1.axe_property('xlim',[-25 350],'ylim',[-0.5 21]);
f1.set_color_options('map',[0 0 0 ]);
figure;
f1.draw;


f1.export('export_path','cleanFDCurves','file_name',resultFile(1:end-4),'file_type','png','width',8,'height',8,'units','cm');
