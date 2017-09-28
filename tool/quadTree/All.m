function [ele,eleMat,eleQT,eleSize] = All(ele, coord, eleMat, eleEdge, edge2Ele, eleQT, eleSize, corner)
Nele = length(ele);
ele = [ele;cell(Nele,1)];
eleMat = [eleMat;zeros(Nele,1)];
eleQT = [eleQT;zeros(Nele,2)];
k = [3 2 3 4; 4 3 4 1; 1 4 1 2; 2 1 2 3];
eleSize = [eleSize;zeros(Nele,1)];
% Eele = zeros(Nele,1); % Modulus of the element
% Newele = cell(Nele,1);
addele = 0;
e{4} = {[1 2 3];[3 4 1];[2 3 4];[4 1 2]};
e{5} = {[1 2 3 4];[4 5 1];[3 4 5];[5 1 2 3]};
e{6}.a = {[1 2 3 4];[4 5 6 1];[3 4 5 6];[6 1 2 3]};
e{6}.b = {[1 2 3 4 5];[5 6 1];[3 4 5 6];[6 1 2 3]};
e{7} = {[1 2 3 4 5];[5 6 7 1];[3 4 5 6 7];[7 1 2 3]};
e{8} = {[1 2 3 4 5];[5 6 7 8 1];[3 4 5 6 7];[7 8 1 2 3]};
for i = 1:Nele
    if any(corner == i) == 1
        continue
    end
% 	if eleMat(i) == 2
        elenodes = length(ele{i});
		edge = NaN(elenodes,1);
        c = 1;
		for ii = 1:elenodes
			edge(ii) = eleEdge{i}(ii);
		end
		neieleno = zeros(length(edge),1);
		for ii = 1: length(edge)
			if length(edge2Ele{edge(ii)}) == 2
				for iii = 1:2
					if edge2Ele{edge(ii)}(iii) ~= i
						neieleno(ii) = edge2Ele{edge(ii)}(iii);
					end
				end
			else
				if edge2Ele{edge(ii)} ~= i
					neieleno(ii) = edge2Ele{edge(ii)};
                else
                    neieleno(ii) = i;
				end
			end
		end
		b = zeros(length(neieleno),2);
		for ii = 1:length(neieleno)
			if neieleno(ii) ~= i
                if eleMat(neieleno(ii)) ~= eleMat(i)
					b(ii,1) = ii;      % edge no. in neighbour element has different modulus around the target element
                end
            elseif neieleno(ii) == i
                b(ii,2) = ii;
			end
		end
		switch elenodes
			case 4
				d = find(b(:,1) > 0); f = find(b(:,2) > 0);
				if length(d) == 2 || length(f) == 2 % f means the no. of white neighbour elements is 2
                    if length(d) ~= 2
                        d = f;c = 2;
                    end
					split = 0;  % 1 if element needs to be splited
                    white = 0;  % 1 if two adjacent neighbour eelements of the element are in white color
                    if d(1) == 1 && d(2) == 2
                        if neieleno(1) == neieleno(2) && neieleno(1) == i
                            white = 1;
                        end
						add = e{elenodes}{1}; change = e{elenodes}{2}; split = 1;
						eleQT(i,1) = 7; eleQT(addele+Nele+1,1) = 7;
						eleQT(addele+Nele+1,2) = eleQT(i,2);
						eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                        if neieleno(3) == neieleno(4)
                            if neieleno(3) == i
                                eleMat(i,1) = 3;
                            end
                        end
					elseif d(1) == 2 && d(2) == 3;
                        if neieleno(2) == neieleno(3) && neieleno(2) == i
                            white = 1;
                        end
						add = e{elenodes}{3}; change = e{elenodes}{4}; split = 1;
						eleQT(i,1) = 7; eleQT(addele+Nele+1,1) = 7;
						eleQT(addele+Nele+1,2) = k(eleQT(i,2),2);
						eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                        if neieleno(1) == neieleno(4)
                            if neieleno(1) == i
                                eleMat(i,1) = 3;
                            end
                        end
					elseif d(1) == 3 && d(2) == 4;
                        if neieleno(3) == neieleno(4) && neieleno(3) == i
                            white = 1;
                        end
						add = e{elenodes}{2}; change = e{elenodes}{1}; split = 1;
						eleQT(i,1) = 7; eleQT(addele+Nele+1,1) = 7;
						eleQT(addele+Nele+1,2) = k(eleQT(i,2),3);
						eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                        if neieleno(1) == neieleno(2)
                            if neieleno(1) == i
                                eleMat(i,1) = 3;
                            end
                        end
					elseif d(1) == 1 && d(2) == 4
                        if neieleno(1) == neieleno(4) && neieleno(1) == i
                            white = 1;
                        end
						add = e{elenodes}{4}; change = e{elenodes}{3}; split = 1;
						eleQT(i,1) = 7; eleQT(addele+Nele+1,1) = 7;
						eleQT(addele+Nele+1,2) = k(eleQT(i,2),4);
						eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                        if neieleno(2) == neieleno(3)
                            if neieleno(2) == i
                                eleMat(i,1) = 3;
                            end
                        end
                    end
                    if split == 1
						addele = addele + 1;
						ele{addele+Nele,1} = ele{i,1}(add);
						ele{i,1} = ele{i,1}(change);
                        if white == 0
                            eleMat(addele+Nele,1) = eleMat(neieleno(b(d(1),c)));
                        elseif white ==1
                            eleMat(addele+Nele,1) = 3;
                        end
						eleSize(addele+Nele,1) = eleSize(i,1);
                    end
                elseif length(d) == 3 || length(f) == 3 % f means the no. of white neighbour elements is 3
                    if length(d) ~= 3
                        d = f;
                    end
                    if eleMat(neieleno(d(1))) == eleMat(neieleno(d(2))) || eleMat(neieleno(d(2))) == eleMat(neieleno(d(3)))
                        if neieleno(d(1)) == i
                            eleMat(i) = 3;
                        else
                            eleMat(i) = eleMat(neieleno(d(1)));
                        end
                    end
				end
			case 5
				if eleMat(neieleno(1)) == eleMat(neieleno(2))
					b(2,:) = 0;
					d = find(b(:,1) > 0); f = find(b(:,2) > 0);
                    if length(d) == 2 || length(f) == 2
                        if length(d) ~= 2
                            d = f; c = 2;
                        end
                        split = 0; white = 0;
                        if d(1) == 1 && d(2) == 3
                            if neieleno(1) == neieleno(3) && neieleno(1) == i
                                white = 1;
                            end
							add = e{elenodes}{1}; change = e{elenodes}{2}; split = 1;
							eleQT(i,1) = 7; eleQT(addele+Nele+1,1) = 8;
							eleQT(addele+Nele+1,2) = eleQT(i,2);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(4) == neieleno(5)
                                if neieleno(4) == i
                                    eleMat(i,1) = 3;
                                end
                            end
						elseif d(1) == 3 && d(2) == 4;
                            if neieleno(3) == neieleno(4) && neieleno(3) == i
                                white = 1;
                            end
							add = e{elenodes}{3}; change = e{elenodes}{4}; split = 1;
							eleQT(i,1) = 9; eleQT(addele+Nele+1,1) = 7;
							eleQT(addele+Nele+1,2) = k(eleQT(i,2),2);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(1) == neieleno(5)
                                if neieleno(1) == i
                                    eleMat(i,1) = 3;
                                end
                            end
						elseif d(1) == 4 && d(2) == 5;
                            if neieleno(4) == neieleno(5) && neieleno(4) == i
                                white = 1;
                            end
							add = e{elenodes}{2}; change = e{elenodes}{1}; split = 1;
							eleQT(i,1) = 8; eleQT(addele+Nele+1,1) = 7;
							eleQT(addele+Nele+1,2) = k(eleQT(i,2),3);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(1) == neieleno(3)
                                if neieleno(1) == i
                                    eleMat(i,1) = 3;
                                end
                            end
						elseif d(1) == 1 && d(2) == 5
                            if neieleno(1) == neieleno(5) && neieleno(1) == i
                                white = 1;
                            end
							add = e{elenodes}{4}; change = e{elenodes}{3}; split = 1;
							eleQT(i,1) = 7; eleQT(addele+Nele+1,1) = 9;
							eleQT(addele+Nele+1,2) = k(eleQT(i,2),4);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(3) == neieleno(4)
                                if neieleno(3) == i
                                    eleMat(i,1) = 3;
                                end
                            end
                        end
                        if split == 1
							addele = addele + 1;
							ele{addele+Nele,1} = ele{i,1}(add);
							ele{i,1} = ele{i,1}(change);
                            if white == 0
                                eleMat(addele+Nele,1) = eleMat(neieleno(b(d(1),c)));
                            elseif white ==1
                                eleMat(addele+Nele,1) = 3;
                            end
							eleSize(addele+Nele,1) = eleSize(i,1);
                        end
                    elseif length(d) == 3 || length(f) == 3 % f means the no. of white neighbour elements is 3
                        if length(d) ~= 3
                            d = f;
                        end
                        if eleMat(neieleno(d(1))) == eleMat(neieleno(d(2))) || eleMat(neieleno(d(2))) == eleMat(neieleno(d(3)))
                            if neieleno(d(1)) == i
                                eleMat(i) = 3;
                            else
                                eleMat(i) = eleMat(neieleno(d(1)));
                            end
                        end
                    end
				end
			case 6
				coord_2 = coord(ele{i}(2),:); coord_5 = coord(ele{i}(5),:);
				if coord_2(1) == coord_5(1)|| coord_2(2) == coord_5(2) % 6-node with oppositing mid-nodes
					if eleMat(neieleno(1)) == eleMat(neieleno(2)) && ...
							eleMat(neieleno(4)) == eleMat(neieleno(5))
						b(2,:) = 0; b(5,:) = 0;
						d = find(b(:,1) > 0); f = find(b(:,2) > 0);
						if length(d) == 2 || length(f) == 2
                            if length(d) ~= 2
                                d = f; c = 2;
                            end
							split = 0; white = 0;
                            if d(1) == 1 && d(2) == 3
                                if neieleno(1) == neieleno(3) && neieleno(1) == i
                                    white = 1;
                                end
								add = e{elenodes}.a{1}; change = e{elenodes}.a{2}; split = 1;
								eleQT(i,1) = 8; eleQT(addele+Nele+1,1) = 8;
								eleQT(addele+Nele+1,2) = eleQT(i,2);
								eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                                if neieleno(4) == neieleno(6)
                                    if neieleno(4) == i
                                        eleMat(i,1) = 3;
                                    end
                                end
							elseif d(1) == 3 && d(2) == 4;
                                if neieleno(3) == neieleno(4) && neieleno(3) == i
                                    white = 1;
                                end
								add = e{elenodes}.a{3}; change = e{elenodes}.a{4}; split = 1;
								eleQT(i,1) = 9; eleQT(addele+Nele+1,1) = 9; 
								eleQT(addele+Nele+1,2) = k(eleQT(i,2),2);
								eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                                if neieleno(1) == neieleno(6)
                                    if neieleno(1) == i
                                        eleMat(i,1) = 3;
                                    end
                                end
							elseif d(1) == 4 && d(2) == 6;
                                if neieleno(4) == neieleno(6) && neieleno(4) == i
                                    white = 1;
                                end
								add = e{elenodes}.a{2}; change = e{elenodes}.a{1}; split = 1;
								eleQT(i,1) = 8; eleQT(addele+Nele+1,1) = 8; 
								eleQT(addele+Nele+1,2) = k(eleQT(i,2),3);
								eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                                if neieleno(1) == neieleno(3)
                                    if neieleno(1) == i
                                        eleMat(i,1) = 3;
                                    end
                                end
							elseif d(1) == 1 && d(2) == 6
                                if neieleno(1) == neieleno(6) && neieleno(1) == i
                                    white = 1;
                                end
								add = e{elenodes}.a{4}; change = e{elenodes}.a{3}; split = 1;
								eleQT(i,1) = 9; eleQT(addele+Nele+1,1) = 9; 
								eleQT(addele+Nele+1,2) = k(eleQT(i,2),4);
								eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                                if neieleno(3) == neieleno(4)
                                    if neieleno(3) == i
                                        eleMat(i,1) = 3;
                                    end
                                end
                            end
                            if split == 1
								addele = addele + 1;
								ele{addele+Nele,1} = ele{i,1}(add);
								ele{i,1} = ele{i,1}(change);
                                if white == 0
                                    eleMat(addele+Nele,1) = eleMat(neieleno(b(d(1),c)));
                                elseif white ==1
                                    eleMat(addele+Nele,1) = 3;
                                end
								eleSize(addele+Nele,1) = eleSize(i,1);
                            end
                        elseif length(d) == 3 || length(f) == 3 % f means the no. of white neighbour elements is 3
                            if length(d) ~= 3
                                d = f;
                            end
                            if eleMat(neieleno(d(1))) == eleMat(neieleno(d(2))) || eleMat(neieleno(d(2))) == eleMat(neieleno(d(3)))
                                if neieleno(d(1)) == i
                                    eleMat(i) = 3;
                                else
                                    eleMat(i) = eleMat(neieleno(d(1)));
                                end
                            end
						end
					end
				else    % 6-node with adjacent mid-nodes
					if eleMat(neieleno(1)) == eleMat(neieleno(2)) && ...
							eleMat(neieleno(3)) == eleMat(neieleno(4))
						b(2,:) = 0; b(4,:) = 0;
						d = find(b(:,1) > 0); f = find(b(:,2) > 0);
						if length(d) == 2 || length(f) == 2
                            if length(d) ~= 2
                                d = f; c = 2;
                            end
							split = 0; white = 0;
                            if d(1) == 1 && d(2) == 3
                                if neieleno(1) == neieleno(3) && neieleno(1) == i
                                    white = 1;
                                end
								add = e{elenodes}.b{1}; change = e{elenodes}.b{2}; split = 1;
								eleQT(i,1) = 7; eleQT(addele+Nele+1,1) = 10; 
								eleQT(addele+Nele+1,2) = eleQT(i,2);
								eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                                if neieleno(5) == neieleno(6)
                                    if neieleno(5) == i
                                        eleMat(i,1) = 3;
                                    end
                                end
							elseif d(1) == 3 && d(2) == 5;
                                if neieleno(3) == neieleno(5) && neieleno(3) == i
                                    white = 1;
                                end
								add = e{elenodes}.b{3}; change = e{elenodes}.b{4}; split = 1;
								eleQT(i,1) = 9; eleQT(addele+Nele+1,1) = 8; 
								eleQT(addele+Nele+1,2) = k(eleQT(i,2),2);
								eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                                if neieleno(1) == neieleno(6)
                                    if neieleno(1) == i
                                        eleMat(i,1) = 3;
                                    end
                                end
							elseif d(1) == 5 && d(2) == 6;
                                if neieleno(5) == neieleno(6) && neieleno(5) == i
                                    white = 1;
                                end
								add = e{elenodes}.b{2}; change = e{elenodes}.b{1}; split = 1;
								eleQT(i,1) = 10; eleQT(addele+Nele+1,1) = 7; 
								eleQT(addele+Nele+1,2) = k(eleQT(i,2),3);
								eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                                if neieleno(1) == neieleno(3)
                                    if neieleno(1) == i
                                        eleMat(i,1) = 3;
                                    end
                                end
							elseif d(1) == 1 && d(2) == 6
                                if neieleno(1) == neieleno(6) && neieleno(1) == i
                                    white = 1;
                                end
								add = e{elenodes}.b{4}; change = e{elenodes}.b{3}; split = 1;
								eleQT(i,1) = 8; eleQT(addele+Nele+1,1) = 9; 
								eleQT(addele+Nele+1,2) = k(eleQT(i,2),4);
								eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                                if neieleno(3) == neieleno(5)
                                    if neieleno(3) == i
                                        eleMat(i,1) = 3;
                                    end
                                end
                            end
                            if split == 1
								addele = addele + 1;
								ele{addele+Nele,1} = ele{i,1}(add);
								ele{i,1} = ele{i,1}(change);
                                if white == 0
                                    eleMat(addele+Nele,1) = eleMat(neieleno(b(d(1),c)));
                                elseif white ==1
                                    eleMat(addele+Nele,1) = 3;
                                end
								eleSize(addele+Nele,1) = eleSize(i,1);
                            end
                        elseif length(d) == 3 || length(f) == 3 % f means the no. of white neighbour elements is 3
                            if length(d) ~= 3
                                d = f;
                            end
                            if eleMat(neieleno(d(1))) == eleMat(neieleno(d(2))) || eleMat(neieleno(d(2))) == eleMat(neieleno(d(3)))
                                if neieleno(d(1)) == i
                                    eleMat(i) = 3;
                                else
                                    eleMat(i) = eleMat(neieleno(d(1)));
                                end
                            end
						end
					end
				end
				
			case 7
				if eleMat(neieleno(1)) == eleMat(neieleno(2)) && ...
						eleMat(neieleno(3)) == eleMat(neieleno(4)) &&...
						eleMat(neieleno(5)) == eleMat(neieleno(6))
					b(2,:) = 0; b(4,:) = 0; b(6,:) = 0;
					d = find(b(:,1) > 0); f = find(b(:,2) > 0);
					if length(d) == 2 || length(f) == 2
                        if length(d) ~= 2
                            d = f; c = 2;
                        end
						split = 0; white = 0;
                        if d(1) == 1 && d(2) == 3
                            if neieleno(1) == neieleno(3) && neieleno(1) == i
                                white = 1;
                            end
							add = e{elenodes}{1}; change = e{elenodes}{2}; split = 1;
							eleQT(i,1) = 8; eleQT(addele+Nele+1,1) = 10; 
							eleQT(addele+Nele+1,2) = eleQT(i,2);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(5) == neieleno(7)
                                if neieleno(5) == i
                                    eleMat(i,1) = 3;
                                end
                            end
						elseif d(1) == 3 && d(2) == 5;
                            if neieleno(3) == neieleno(5) && neieleno(3) == i
                                white = 1;
                            end
							add = e{elenodes}{3}; change = e{elenodes}{4}; split = 1;
							eleQT(i,1) = 9; eleQT(addele+Nele+1,1) = 10; 
							eleQT(addele+Nele+1,2) = k(eleQT(i,2),2);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(1) == neieleno(7)
                                if neieleno(1) == i
                                    eleMat(i,1) = 3;
                                end
                            end
						elseif d(1) == 5 && d(2) == 7;
                            if neieleno(5) == neieleno(7) && neieleno(5) == i
                                white = 1;
                            end
							add = e{elenodes}{2}; change = e{elenodes}{1}; split = 1;
							eleQT(i,1) = 10; eleQT(addele+Nele+1,1) = 8; 
							eleQT(addele+Nele+1,2) = k(eleQT(i,2),3);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(1) == neieleno(3)
                                if neieleno(1) == i
                                    eleMat(i,1) = 3;
                                end
                            end
						elseif d(1) == 1 && d(2) == 7
                            if neieleno(1) == neieleno(7) && neieleno(1) == i
                                white = 1;
                            end
							add = e{elenodes}{4}; change = e{elenodes}{3}; split = 1;
							eleQT(i,1) = 10; eleQT(addele+Nele+1,1) = 9; 
							eleQT(addele+Nele+1,2) = k(eleQT(i,2),4);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(3) == neieleno(5)
                                if neieleno(3) == i
                                    eleMat(i,1) = 3;
                                end
                            end
                        end
                        if split == 1
							addele = addele + 1;
							ele{addele+Nele,1} = ele{i,1}(add);
							ele{i,1} = ele{i,1}(change);
                            if white == 0
                                eleMat(addele+Nele,1) = eleMat(neieleno(b(d(1),c)));
                            elseif white ==1
                                eleMat(addele+Nele,1) = 3;
                            end
							eleSize(addele+Nele,1) = eleSize(i,1);
                        end
                    elseif length(d) == 3 || length(f) == 3 % f means the no. of white neighbour elements is 3
                        if length(d) ~= 3
                            d = f;
                        end
                        if eleMat(neieleno(d(1))) == eleMat(neieleno(d(2))) || eleMat(neieleno(d(2))) == eleMat(neieleno(d(3)))
                            if neieleno(d(1)) == i
                                eleMat(i) = 3;
                            else
                                eleMat(i) = eleMat(neieleno(d(1)));
                            end
                        end
					end
				end
			case 8
				if eleMat(neieleno(1)) == eleMat(neieleno(2)) && ...
						eleMat(neieleno(3)) == eleMat(neieleno(4)) && ...
						eleMat(neieleno(5)) == eleMat(neieleno(6)) && ...
						eleMat(neieleno(7)) == eleMat(neieleno(8))
					b(2,:) = 0; b(4,:) = 0; b(6,:) = 0; b(8,:) = 0;
					d = find(b(:,1) > 0); f = find(b(:,2) > 0);
					if length(d) == 2 || length(f) == 2
                        if length(d) ~= 2
                            d = f; c = 2;
                        end
						split = 0; white = 0;
                        if d(1) == 1 && d(2) == 3
                            if neieleno(1) == neieleno(3) && neieleno(1) == i
                                white = 1;
                            end
							add = e{elenodes}{1}; change = e{elenodes}{2}; split = 1;
							eleQT(i,1) = 10; eleQT(addele+Nele+1,1) = 10;
							eleQT(addele+Nele+1,2) = eleQT(i,2);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(5) == neieleno(7)
                                if neieleno(5) == i
                                    eleMat(i,1) = 3;
                                end
                            end
						elseif d(1) == 3 && d(2) == 5;
                            if neieleno(3) == neieleno(5) && neieleno(3) == i
                                white = 1;
                            end
							add = e{elenodes}{3}; change = e{elenodes}{4}; split = 1;
							eleQT(i,1) = 10; eleQT(addele+Nele+1,1) = 10;
							eleQT(addele+Nele+1,2) = k(eleQT(i,2),2);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(1) == neieleno(7)
                                if neieleno(1) == i
                                    eleMat(i,1) = 3;
                                end
                            end
						elseif d(1) == 5 && d(2) == 7;
                            if neieleno(5) == neieleno(7) && neieleno(5) == i
                                white = 1;
                            end
							add = e{elenodes}{2}; change = e{elenodes}{1}; split = 1;
							eleQT(i,1) = 10; eleQT(addele+Nele+1,1) = 10;
							eleQT(addele+Nele+1,2) = k(eleQT(i,2),3);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(1) == neieleno(3)
                                if neieleno(1) == i
                                    eleMat(i,1) = 3;
                                end
                            end
						elseif d(1) == 1 && d(2) == 7
                            if neieleno(1) == neieleno(7) && neieleno(1) == i
                                white = 1;
                            end
							add = e{elenodes}{4}; change = e{elenodes}{3}; split = 1;
							eleQT(i,1) = 10; eleQT(addele+Nele+1,1) = 10;
							eleQT(addele+Nele+1,2) = k(eleQT(i,2),4);
							eleQT(i,2) = k(eleQT(addele+Nele+1,2),1);
                            if neieleno(3) == neieleno(5)
                                if neieleno(3) == i
                                    eleMat(i,1) = 3;
                                end
                            end
                        end
                        if split == 1
							addele = addele + 1;
							ele{addele+Nele,1} = ele{i,1}(add);
							ele{i,1} = ele{i,1}(change);
                            if white == 0
                                eleMat(addele+Nele,1) = eleMat(neieleno(b(d(1),c)));
                            elseif white ==1
                                eleMat(addele+Nele,1) = 3;
                            end
							eleSize(addele+Nele,1) = eleSize(i,1);
                        end
                    elseif length(d) == 3 || length(f) == 3 % f means the no. of white neighbour elements is 3
                        if length(d) ~= 3
                            d = f;
                        end
                        if eleMat(neieleno(d(1))) == eleMat(neieleno(d(2))) || eleMat(neieleno(d(2))) == eleMat(neieleno(d(3)))
                            if neieleno(d(1)) == i
                                eleMat(i) = 3;
                            else
                                eleMat(i) = eleMat(neieleno(d(1)));
                            end
                        end
					end
				end
		end
% 	end
end
ele = ele(~cellfun('isempty',ele)); % Delete empty cell in ele.
eleMat = eleMat(eleMat ~= 0);
eleQT(any(eleQT(:,1)==0,2),:)= [];
eleSize = eleSize(eleSize ~= 0);
end