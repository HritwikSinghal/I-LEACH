function [CH,Sensors]=SelectCH(Sensors,Model,rowx,circlex,circley)
%% Standard Leach Developed by Amin Nazari 
%   aminnazari91@gmail.com 
%   0918 546 2272
%% Improved Leach Developed by Hritwik Singhal and Nishita Agarwal 
    CH=[];
    countCHs=0;
    n=Model.n;
    numRx=Model.numRx;
    dr=Model.dr;
    
    CH_selected_arr=zeros(numRx, numRx);
    
    for i=1:1:n
        
        % these are the circle (x,y) for this node
        row_circle_of_node=-1;
        col_circle_of_node=-1;
        br=0;
        
        % checking in which circle this node lies
        for row=1:1:numRx
            for column=1:1:numRx
                if(sqrt((Sensors(i).xd - circlex(row,column))^2 + (Sensors(i).yd - circley(row,column))^2) <= dr/2)
                    row_circle_of_node=row;
                    col_circle_of_node=column;
                    
                    br=1;
                    break
                end
            end
            if(br==1)
                break
            end
        end
        
        
        % if this node is not in any circle then also skip
        if(br==0)
            continue
        end
        
        
        % if CH of this circle has already been chosen, then skip
        if(CH_selected_arr(row_circle_of_node, col_circle_of_node) == 1)
            continue
        end
        
        
        
        if(Sensors(i).E>0 && Sensors(i).G<=0)
            temp_rand=rand; 
            %Election of Cluster Heads
            if(temp_rand<= (Model.p/(1-Model.p*mod(rowx,round(1/Model.p)))))                    
                countCHs=countCHs+1; 

                TotalCH(countCHs).id=i; %#ok                
                Sensors(i).type='C';
                Sensors(i).G=round(1/Model.p)-1;

                % mark this cirle now that it has a CH
                CH_selected_arr(row_circle_of_node, col_circle_of_node) = 1;
                
            end
        end
    end 
     
    
    
end