function [ ydata ] = getydata( x, y, img)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for i = 1:5
    ydata(i) = img(x, y ,i);
end

end

