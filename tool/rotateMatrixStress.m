function T2 = rotateMatrixStress(angle)
%rotate matrix for stress, the rotate angle is in counter-clock direction
%3x3 [T2] is used as [T2].{sigma} to calculate stress in rotated coordinate
m = cos(angle); n = sin(angle);
T2 = zeros(3,3);
T2(1,1) = m*m;       T2(1,2) = n*n;        T2(1,3) = 2*m*n;
T2(2,1) = T2(1,2);   T2(2,2) = T2(1,1);    T2(2,3) = -T2(1,3);
T2(3,1) = -m*n;      T2(3,2) = m*n;        T2(3,3) = (m+n)*(m-n);

end