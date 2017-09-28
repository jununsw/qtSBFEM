figure; 
c=contour(seg,1,'r')
hold on
ib=1
nend=size(c,2)
while ib<nend
    n=c(2,ib)
    x=c(1,ib+1:ib+n)'
    y=c(2,ib+1:ib+n)'
    plot(x,y,'b')
    ib=ib+n+1
end