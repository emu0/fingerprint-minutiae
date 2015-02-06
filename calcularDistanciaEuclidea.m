function [D] = calcularDistanciaEuclidea(conjuntoDatos1,conjuntoDatos2)
% Función para calcular la distancia euclídea entre dos conjuntos de datos.
% Solo acepta uno o dos conjunto de datos. Discriminamos con la función
% nargin

switch nargin
    % Un conjunto de datos
    case 1
        [m1, ~]=size(conjuntoDatos1);
        m2=m1;
        D=zeros(m1,m2);
        for i=1:m1
            for j=1:m2
                if i==j
                    % Para evitar posibles errores futuros, si ambos
                    % índices son los mismos, lo identificamos sin valor
                    % númerico.
                    D(i,j)=NaN;
                else
                    % Aplicamos la distancia euclídea.
                    D(i,j)=sqrt((conjuntoDatos1(i,1)-conjuntoDatos1(j,1))^2+(conjuntoDatos1(i,2)-conjuntoDatos1(j,2))^2);
                end
            end
        end
    % Dos conjuntos de datos
    case 2
        [m1, ~]=size(conjuntoDatos1);
        [m2, ~]=size(conjuntoDatos2);
        D=zeros(m1,m2);
        for i=1:m1
            for j=1:m2
                % Aplicamos la distancia euclídea.
                D(i,j)=sqrt((conjuntoDatos1(i,1)-conjuntoDatos2(j,1))^2+(conjuntoDatos1(i,2)-conjuntoDatos2(j,2))^2);
            end
        end
    otherwise
        error('Solo se admiten uno o dos conjuntos de datos')
end