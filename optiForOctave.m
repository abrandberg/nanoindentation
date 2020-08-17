function [uld_p,fval,exitflag,output] = optiForOctave(unloadFitMinFun,unloadFitConstraintFun,Fmax)
opts = optimset('Algorithm','interior-point','MaxIter',1000,'TolFun',1e-5);


[uld_p,fval,exitflag,output] =  fmincon(unloadFitMinFun,        ... % Minimization function
                                        [1, 1, 1, 1]',          ... % Starting guess
                                        [],[],[],[],[],[],      ... % Linear equality and inequality constraints
                                        @ (p) {unloadFitConstraintFun(p),[]}{:},opts);%, ... %  Non-linear inequality an equality constraints OBS OBS OBS OBS OBS OBS
                                        %);                  ... % Solver options