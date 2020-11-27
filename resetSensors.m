function Sensors=resetSensors(Sensors,Model)
   %% Developed by Amin Nazari 
% 	aminnazari91@gmail.com 
%	0918 546 2272 
    n=Model.n;
    for i=1:n
        Sensors(i).MCH=n+1;
        Sensors(i).type='N';
        Sensors(i).dis2ch=inf;
    end
    
end