function deadNum=LEACH_plotter(Sensors,Model)
    %% Developed by Amin Nazari 
% 	aminnazari91@gmail.com 
%	0918 546 2272
    deadNum=0;
    n=Model.n;
    for i=1:n
        %check dead node
        if (Sensors(i).E>0)
            
            if(Sensors(i).type=='N' )      
                plot(Sensors(i).xd,Sensors(i).yd,'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
               % text(Sensors(i).xd+1,Sensors(i).yd-1,num2str(i));
            else %Sensors.type=='C'       
                plot(Sensors(i).xd,Sensors(i).yd,'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
              %  text(Sensors(i).xd+1,Sensors(i).yd-1,num2str(i));
            end
            
        else
            deadNum=deadNum+1;
            plot(Sensors(i).xd,Sensors(i).yd,'ko', 'MarkerSize',5, 'MarkerFaceColor', 'w');
           % text(Sensors(i).xd+1,Sensors(i).yd-1,num2str(i));
        end
        
        hold on;
        
    end 
    plot(Sensors(n+1).xd,Sensors(n+1).yd,'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    text(Sensors(n+1).xd+1,Sensors(n+1).yd-1,'Sink');
    axis square

end