function [ErMean,ErStd,ErNumel,ErCI,HMean,HStd,HNumel,HCI] = summaryStatisticsOfResults(results)

selIdx = true(numel(results),1)';
ErMean = mean([results(selIdx).Er]);
ErStd = std([results(selIdx).Er]);
ErNumel = sum(selIdx);
ErCI = 1.96*ErStd/sqrt(ErNumel);

HMean = mean([results(selIdx).H]);
HStd = std([results(selIdx).H]);
HNumel = sum(selIdx);
HCI = 1.96*HStd/sqrt(HNumel);