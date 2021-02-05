%% Developed by Amin Nazari 
% 	aminnazari91@gmail.com 
%	0918 546 2272

clc;
clear;
close all;
warning off all;
tic;

%% Create sensor nodes, Set Parameters and Create Energy Model 
%%%%%%%%%%%%%%%%%%%%%%%%% Initial Parameters %%%%%%%%%%%%%%%%%%%%%%%
n=200;                                  %Number of Nodes in the field
[Area,Model]=setParameters(n);     		%Set Parameters Sensors and Network

%%%%%%%%%%%%%%%%%%%%%%%%% configuration Sensors %%%%%%%%%%%%%%%%%%%%
CreateRandomSen(Model,Area);            %Create a random scenario
load Locations                          %Load sensor Location
Sensors=ConfigureSensors(Model,n,X,Y);
ploter(Sensors,Model);                  %Plot sensors

%%%%%%%%%%%%%%%%%%%%%%%%%% Parameters initialization %%%%%%%%%%%%%%%%
countCHs=0;         %counter for CHs
flag_first_dead=0;  %flag_first_dead
deadNum=0;          %Number of dead nodes

initEnergy=0;       %Initial Energy
for i=1:n
      initEnergy=Sensors(i).E+initEnergy;
end

SRP=zeros(1,Model.rmax);    %number of sent routing packets
RRP=zeros(1,Model.rmax);    %number of receive routing packets
SDP=zeros(1,Model.rmax);    %number of sent data packets 
RDP=zeros(1,Model.rmax);    %number of receive data packets 

Sum_DEAD=zeros(1,Model.rmax);
CLUSTERHS=zeros(1,Model.rmax);
AllSensorEnergy=zeros(1,Model.rmax);

%%%%%%%%%%%%%%%%%%%%%%%%% Start Simulation %%%%%%%%%%%%%%%%%%%%%%%%%
global srp rrp sdp rdp
srp=0;          %counter number of sent routing packets
rrp=0;          %counter number of receive routing packets
sdp=0;          %counter number of sent data packets 
rdp=0;          %counter number of receive data packets 

%Sink broadcast start message to all nodes
Sender=n+1;     %Sink
Receiver=1:n;   %All nodes
Sensors=SendReceivePackets(Sensors,Model,Sender,'Hello',Receiver);

% All sensor send location information to Sink .
 Sensors=disToSink(Sensors,Model);
% Sender=1:n;     %All nodes
% Receiver=n+1;   %Sink
% Sensors=SendReceivePackets(Sensors,Model,Sender,'Hello',Receiver);

%Save metrics
SRP(1)=srp;
RRP(1)=rrp;  
SDP(1)=sdp;
RDP(1)=rdp;

x=0;
%% Main loop program
for r=1:1:Model.rmax

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%
    %This section Operate for each epoch   
    member=[];              %Member of each cluster in per period
    countCHs=0;             %Number of CH in per period
    %counter for bit transmitted to Bases Station and Cluster Heads
    srp=0;          %counter number of sent routing packets
    rrp=0;          %counter number of receive routing packets
    sdp=0;          %counter number of sent data packets to sink
    rdp=0;          %counter number of receive data packets by sink
    %initialization per round
    SRP(r+1)=srp;
    RRP(r+1)=rrp;  
    SDP(r+1)=sdp;
    RDP(r+1)=rdp;   
    pause(0.001)    %pause simulation
    hold off;       %clear figure
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Sensors=resetSensors(Sensors,Model);
    %allow to sensor to become cluster-head. LEACH Algorithm  
    AroundClear=10;
    if(mod(r,AroundClear)==0) 
        for i=1:1:n
            Sensors(i).G=0;
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot sensors %%%%%%%%%%%%%%%%%%%%%%%
    deadNum=ploter(Sensors,Model);
    
    %Save r'th period When the first node dies
    if (deadNum>=1)      
        if(flag_first_dead==0)
            first_dead=r;
            flag_first_dead=1;
        end  
    end
    
%%%%%%%%%%%%%%%%%%%%%%% cluster head election %%%%%%%%%%%%%%%%%%%
    %Selection Candidate Cluster Head Based on LEACH Set-up Phase
    [TotalCH,Sensors]=SelectCH(Sensors,Model,r); 
    
    %Broadcasting CHs to All Sensor that are in Radio Rage CH.
    for i=1:length(TotalCH)
        
        Sender=TotalCH(i).id;
        SenderRR=Model.RR;
        Receiver=findReceiver(Sensors,Model,Sender,SenderRR);   
        Sensors=SendReceivePackets(Sensors,Model,Sender,'Hello',Receiver);
            
    end 
    
    %Sensors join to nearest CH 
    Sensors=JoinToNearestCH(Sensors,Model,TotalCH);
    
%%%%%%%%%%%%%%%%%%%%%%% end of cluster head election phase %%%%%%

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% steady-state phase %%%%%%%%%%%%%%%%%
    NumPacket=Model.NumPacket;
    for i=1:1:1%NumPacket 
        
        %Plotter     
        deadNum=ploter(Sensors,Model);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% All sensor send data packet to  CH 
        for j=1:length(TotalCH)
            
            Receiver=TotalCH(j).id;
            Sender=findSender(Sensors,Model,Receiver); 
            Sensors=SendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
            
        end
        
    end
    
    
%%%%%%%%%%%% send Data packet from CH to Sink after Data aggregation
    for i=1:length(TotalCH)
            
        Receiver=n+1;               %Sink
        Sender=TotalCH(i).id;       %CH 
        Sensors=SendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
            
    end
%%% send data packet directly from other nodes(that aren't in each cluster) to Sink
    for i=1:n
        if(Sensors(i).MCH==Sensors(n+1).id)
            Receiver=n+1;               %Sink
            Sender=Sensors(i).id;       %Other Nodes 
            Sensors=SendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
        end
    end
 
   
%% STATISTICS
     
    Sum_DEAD(r+1)=deadNum;
    
    SRP(r+1)=srp;
    RRP(r+1)=rrp;  
    SDP(r+1)=sdp;
    RDP(r+1)=rdp;
    
    CLUSTERHS(r+1)=countCHs;
    
    alive=0;
    SensorEnergy=0;
    for i=1:n
        if Sensors(i).E>0
            alive=alive+1;
            SensorEnergy=SensorEnergy+Sensors(i).E;
        end
    end
    AliveSensors(r)=alive; %#ok
    
    SumEnergyAllSensor(r+1)=SensorEnergy; %#ok
    
    AvgEnergyAllSensor(r+1)=SensorEnergy/alive; %#ok
    
    ConsumEnergy(r+1)=(initEnergy-SumEnergyAllSensor(r+1))/n; %#ok
    
    En=0;
    for i=1:n
        if Sensors(i).E>0
            En=En+(Sensors(i).E-AvgEnergyAllSensor(r+1))^2;
        end
    end
    
    Enheraf(r+1)=En/alive; %#ok
    
    title(sprintf('Round=%d,Dead nodes=%d', r+1, deadNum)) 
    
   %dead
   if(n==deadNum)
       
       lastPeriod=r;  
       break;
       
   end
STATISTICS.Alive(r+1)=n-deadNum;
STATISTICS.Energy(r+1)=SumEnergyAllSensor(r+1);
x=r+1;
end % for r=0:1:rmax
r=1:x-1;
figure(2)
plot(r,STATISTICS.Alive(r+1));
xlabel 'Rounds';
ylabel 'No of live sensor Nodes';
title('Life time of Sensor Nodes')




figure(3)
plot(r,STATISTICS.Energy(r+1));
xlabel 'Rounds';
ylabel 'Energy(in j)';
title('Average Residual energy ');

disp('End of Simulation');
toc;
disp('Create Report...')

filename=sprintf('leach%d.mat',n);

%% Save Report
save(filename);
