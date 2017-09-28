function [ImgOrg] = ScatteredEllipse(ImgOrg, n, dmax, dmin, dmid, ncir, dratioMin)

ImgOrg = zeros(n,'uint8'); 
cnt = round(random('Uniform',1, n, [2,ncir]));
%dfct  = random('Uniform',1/200, 1, [ncir,1]);
dfct = (dmin+(dmax-dmin)*random('Uniform',0, 1, [ncir,1]));
dratioMax = 1;
%a = dratioMin+(dratioMax-dratioMin)*rand([ncir,1])
a = random('Uniform',dratioMin, dratioMax, [ncir,1]);
dratio = ones(ncir,2);
dratio((1:ncir)'+(randi(2,[ncir,1])-1)*ncir) = a;
a = dfct>dmid;
dfct = dfct(:, [1 1]);
dfct(a,:) = dfct(a,:).*dratio(a,:);
dCirMax = dmax * dratioMax;
dfct = dfct/dCirMax;
[r,c]=imgCircle(dCirMax); 
for ii = 1:ncir; 
    ind = cnt(1,ii)+round(r*dfct(ii,1))+(cnt(2,ii)+round(c*dfct(ii,2))-1)*n;
    ind = ind(ind>0&ind<n*n); ind = unique(ind);
    ImgOrg(ind) = 150; 
end
end