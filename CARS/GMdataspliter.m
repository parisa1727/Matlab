%This code is to split custom targeting data from adclicks on globe and
%mail on November 12 2014 by Parisa Lak.

filename = 'autoadclicks.xls'
autoclick = xlsread(filename);
x = autoclick(:,8);% read all custom targetings
x = CustomTargeting;
custtarg = zeros(4427,50);
for i = 1:2
    custtarg2 =strsplit( x , ';');
end