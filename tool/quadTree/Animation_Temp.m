function [handle]=Animation_Temp(coord,ele,eleTrue,Sol,cntrl,colormap,timestep,eleMat,matNum)
   %close all
   
   
   figure('Renderer','zbuffer')
   set(gcf,'position',get(0,'screensize'))
    length(Sol)
   count=1;

   for it=1:timestep:length(Sol)
       U_i=Sol(it).Temp;
       
       PlotElement_Duc(coord,ele,eleTrue,U_i,colormap,eleMat,matNum);
       F(count) = getframe;
       [X(:,:,:,count)] = frame2im(F(count));
       count=count+1;
   end
       %close Figure 3
        %movie(F,2,10)
        mov=immovie(X);
        implay(mov);
        
        % resize figure based on frame's w x h, and place at (150, 150)
        
        % Place frames at bottom left
        
   
   
   

end