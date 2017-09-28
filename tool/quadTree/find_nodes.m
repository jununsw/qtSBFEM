function[point]= find_nodes(coord,x_coord,y_coord)
        
        distance_2=(coord(:,1)-x_coord).^2+(coord(:,2)-y_coord).^2;
        distance=distance_2.^(0.5);
        min_dis=min(distance);
        point=find(distance==min_dis);
        point=point(1);
       
end