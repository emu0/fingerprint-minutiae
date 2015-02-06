function [y] = filtro(x)
% Función del filtro para contabilizar la cantidad de 1 lógicos vecinos 
% que existe alrededor de un punto central de la imagen.

i=ceil(size(x)/2);
% Si el valor central vale cero se devuelve dicho valor
if x(i,i)==0;
    y=0;
% Si el valor central no vale cero, entonces se manda la suma de ellos
else
    y=sum(x(:)) - 1;
end