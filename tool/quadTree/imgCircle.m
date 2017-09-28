function [ r, c ] = imgCircle( d )

d = round(d);
if (round(d/2)*2==d)
    dh = ((d-1)/2);
    r = (-dh:dh)';
    r = r(:,ones(1,length(r)));
    r = r(:);
    c = (-dh:dh);
    c = c(ones(length(c),1),:);
    c = c(:);
    idx  = find( (r.*r+c.*c) <= (dh+0.5)^2);
    r = r(idx)+0.5;
    c = c(idx)+0.5;
else
    dh = (d-1)/2;
    r = (-dh:dh)';
    r = r(:,ones(1,length(r)));
    r = r(:);
    c = (-dh:dh);
    c = c(ones(length(c),1),:);
    c = c(:);
    idx  = find( (r.*r+c.*c) <= (dh)^2);
    r = r(idx);
    c = c(idx);
end
end

