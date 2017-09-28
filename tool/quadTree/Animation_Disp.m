function [F]=Animation_Disp(coord,ele,eleTrue,Sol,cntrl,colormap,timestep)
   %close all
   set(gcf,'position',get(0,'screensize'))
   figure('Renderer','zbuffer')
   set(gcf,'position',get(0,'screensize'))
    length(Sol)
   count=1;

   maxU = max([Sol.disp]);
   maxU = max(maxU);
   maxD = max(max(coord)-min(coord));
   
   for it=1:timestep:length(Sol)
       U_i=0.06*maxD/maxU*Sol(it).disp(1,:);
       PlotElement_Disp(coord,ele(eleTrue),U_i,colormap);
       F(count) = getframe;
       [X(:,:,:,count)] = frame2im(F(count));
       count=count+1;
   end
        
        
        mov=immovie(X);
        implay(mov);
        %movie2avi(mov, 'myMovie.avi', 'compression', 'None');
        % resize figure based on frame's w x h, and place at (150, 150)
        
        % Place frames at bottom left
        
   
   
   

end