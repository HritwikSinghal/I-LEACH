function Receiver=findReceiver(Sensors,Model,Sender,SenderRR)
%% Developed by Amin Nazari 
% 	aminnazari91@gmail.com 
%	0918 546 2272   
    Receiver=[];
    %% Calculate Distance All Sensor With Sender 
    n=Model.n;
    D=zeros(1,n);
    
    for i=1:n
             
        D(i)=sqrt((Sensors(i).xd-Sensors(Sender).xd)^2+ ...
            (Sensors(i).yd-Sensors(Sender).yd)^2);
                      
    end 
    
    %% 
    for i=1:n
             
        if (D(i) <= SenderRR & Sender~=Sensors(i).id)
            Receiver=[Receiver,Sensors(i).id]; %#ok
        end
                      
    end 
    
end
