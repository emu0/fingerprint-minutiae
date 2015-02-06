%% Proyecto PDI: Obtención de minucias de una huella dactilar.

%%
% La comparación de huellas dactilares se basa en minucias o puntos
% singulares de una huella formados por los surcos y valles de la piel.
% Hay bastantes estudios e investigaciones al respecto del reconocimiento,
% procesamiento e identificación de una huella dactilar. Identificatemos 
% dos tipos de minucias, terminaciones (final de una cresta) y
% bifurcaciones (uniones de dos crestas).
% Al final del proceso obtendremos un vector de minucias formado por la 
% posición y orientación de las mismas.

clear all;
close all;

%% PASO 1: Preparación de la imagen.
% El primer paso es preparar la imagen para una obtención de minucias
% satisfactoria.

% Cargamos la imagen:
nombre='koala';
I=imread([nombre '.bmp']);

% Mostramos la imagen original
imshow(I);

% Binarizamos la imagen con cierto umbral consiguiendo que las crestas de 
% las huellas sean de color negro y los valles blanco.
J=I(:,:,1)>180;

% La imagen tras binarizar queda
imshow(J);

% Aplicamos una función de erosionado para conseguir que las creas tengan
% el grosor de un pixel. Para conseguir esto indicamos en la función 'inf'
% que aplica el erosionado hasta que ya no se produzca ningún cambio.
% Para un posterior análisis es necesario que las crestas sean de color
% blanco, por eso le pasamos la imagen negada.
K=bwmorph(~J,'thin','inf');

% Y tras la función, queda
imshow(K);

%% PASO 2: Obtención de minucias.
% A esta imagen erosionada le pasamos un filtro que analiza fragmentos de
% 3x3 píxeles para calcular el número de 1 lógicos que haya, el objetivo de
% este filtro es obtener si cada ventana de 3x3 se coresponde con una 
% terminación o una bifurcacción.
% Este filtro es la función 'filtro.m' que se adjunta con el código y que
% la realizamos con 'nlfilter'para que pueda aplicarla en pequeñas ventanas
% durante toda la imagen.
% Esta función aplica el siguiente criterio:
%  - 0: El punto central no tiene ningún pixel, por tanto no es de interés.
%  - 1: El punto central tiene un pixel vecino, por lo tanto es una
%  terminación.
%  - 3: El punto central tiene 3 píxeles vecinos, por tanto es una
%  bifurcación.
%  - Otro: Cualquier otro valor no se considera un punto atractivo.
L = nlfilter(K, [3 3], @filtro);

% Analizamos los casos de terminación y bifurcación para marcarlos en la
% imagen.

% Llamaremos LTerm a todos los puntos que se consideran terminación.
LTerm=(L==1);
% Podemos ver la nube de de terminaciones
imshow(LTerm);
% Obtenemos el centroide de las terminaciones para poder situarlas
% correctamentes
propTerm=regionprops(LTerm, 'Centroid');
centroideTerminacion=round(cat(1, propTerm(:).Centroid));
imshow(~K);
hold on;
% Marcamos de color rojo los puntos indicados como terminaciones
plot(centroideTerminacion(:,1),centroideTerminacion(:,2),'ro');

% Llamaremos LBif a todos los puntos que se consideran bifurcación.
LBif=(L==3);
% Como anteriormente calculamos las posiciones de las bifurcaciones.
propBif=regionprops(LBif,'Centroid','Image');
centroideBifurcacion=round(cat(1,propBif(:).Centroid));
% Esta vez las marcamos de amarillo.
plot(centroideBifurcacion(:,1),centroideBifurcacion(:,2),'yo');

%% PASO 3: Criba de minucias.
% Una vez detectadas todas las minucias, tendremos que realizar una
% criba de ellas, quedándonos con una serie de puntos relevantes.
% Esto también nos ayudará a eliminar aquellos minucias detectadas por
% error. Nos basaremos en la distancia euclídea entre dos minucias para
% realizar la criba.

% Seleccionamos un umbral de distancia.
D=6;

% Este paso tiene tres criterios:
% 1: Si la distancia entre una terminación y una bifurcación es menos que el
%  umbral de distancia se elimina esa minucia.
distancia=calcularDistanciaEuclidea(centroideBifurcacion,centroideTerminacion);
% Creamos una matriz binaria con aquellas minucias que no pasen el criterio
minuciaCriba=distancia<D;
[i,j]=find(minuciaCriba);
% Eliminamos esas minucias falsas
centroideBifurcacion(i,:)=[];
centroideTerminacion(j,:)=[];

% 2: Si la distancia entre 2 bifurcaciones es menor que la distancia umbral
% entonces se elimina la minucia.
distancia=calcularDistanciaEuclidea(centroideBifurcacion);
minuciaCriba=distancia<D;
[i,~]=find(minuciaCriba);
centroideBifurcacion(i,:)=[];

% 3: Si la distancia entre 2 terminaciones es menor que la distancia umbral
% entonces se elimina la minucia.
distancia=calcularDistanciaEuclidea(centroideTerminacion);
minuciaCriba=distancia<D;
[i,j]=find(minuciaCriba);
centroideTerminacion(i,:)=[];

% Mostramos las minucias que han superado la criba
hold off
imshow(~K)
hold on
plot(centroideTerminacion(:,1),centroideTerminacion(:,2),'ro')
plot(centroideBifurcacion(:,1),centroideBifurcacion(:,2),'yo')
hold off

%% PASO 4: Región de interés de la imagen. ROI.
% No toda la imagen contiene minucias que sean significativas. Por ejemplo,
% los bordes son propensos a estar repleto de minucias no reales (una
% terminación puede ser tal, o que el lector ha dejado de realizar la
% lectura en ese punto). Por eso, debemos delimitar una región de interés
% de la imagen (ROI en inglés).
% Para la creación de la ROI seguimos los siguientes pasos:
% -Cerrado Morfológico: Esto une las crestas de la huella en un cuerpo
% mayor. Nosotros lo realizamos con un elemento cuadrado de lado 7
KcerradoM=imclose(K,strel('square',7));

% -Relleno de huecos que queden aislados:
KcerradoLimpio= imfill(KcerradoM,'holes');
 
% -Eliminación de pequeños elementos: Para eliminar del todo aquellos 
% elementos que no tengan un tamaño mínimo volvemos a hacer una limpieza 
% de aquellos elementos menores de 5 píxeles.
KcerradoLimpio=bwareaopen(KcerradoLimpio,5);

% -Erosión: la ROI será finalmente la máscara anterior pero erosionada con
% un disco de tamaño 10 para suavizarla.
ROI=imerode(KcerradoLimpio,strel('disk',10));

% Por último, para evitar que la ROI llegue hasta los bordes de la imagen
% se recortará a cada lado un total de 3 pixeles
ROI(1:5, 1:end)=0;
ROI(end-5:end, 1:end)=0;

% Podemos ver la evolución del proceso:
subplot(2, 2, 1); imshow(K); title('Original');
subplot(2, 2, 2); imshow(KcerradoM); title('Cerrado Morfologico');
subplot(2, 2, 3); imshow(KcerradoLimpio); title('Relleno de huecos y filtrado');
subplot(2, 2, 4); imshow(ROI); title('Erosion. ROI definitiva');

% Vemos como vamos al final de este paso:
% Superponemos la ROI y la imagen con las minucias.
figure, imshowpair(I, ROI, 'blend');
hold on
plot(centroideTerminacion(:,1),centroideTerminacion(:,2),'ro')
plot(centroideBifurcacion(:,1),centroideBifurcacion(:,2),'yo')
hold off

% Al haber delimitado una ROI, todas las minucias que queden fuera de la
% misma ya no son necesarias.
% Creamos una matriz para las terminaciones y otra para bifurcaciones
[m,n]=size(I(:,:,1));
Terminaciones=sub2ind([m,n],centroideTerminacion(:,2),centroideTerminacion(:,1));
Bifurcaciones=sub2ind([m,n],centroideBifurcacion(:,2),centroideBifurcacion(:,1));

% Creamos una matriz auxiliar que junto a la ROI nos ayudará a crear una
% matriz con las posiciones de las terminaciones y las bifurcaciones.
Z=zeros(m,n);
Z(Terminaciones)=1;
posTerminaciones=Z.*ROI;

Z=zeros(m,n);
Z(Bifurcaciones)=1;
posBifurcaciones=Z.*ROI;

% Las posiciones de las terminaciones y las bifurcaciones son
[TerminacionY, TerminacionX]=find(posTerminaciones);
[BifurcacionY, BifurcacionX]=find(posBifurcaciones);

%Finalmente tenemos la huella con todas las minucias que se han elegido
figure;
imshow(I);
hold on;
plot(TerminacionX, TerminacionY,'ro','linewidth',2);
plot(BifurcacionX, BifurcacionY,'yo','linewidth',2);
hold off;

%% PASO 5: Orientación de las minucias.
% Para terminar de determinar las minucias de la huella se deben orientar.
% Esta orientación se llevará a cabo a traves de una tabla de ángulos donde
% se asignará aquel valor donde mejor encajen.

TablaAngulos=[3*pi/4, 2*pi/3, pi/2, pi/3, pi/4; ... 
              5*pi/6,   0,     0,    0,   pi/6; ...
                pi,     0,     0,    0,     0;  ...
             -5*pi/6,   0,     0,    0,  -pi/6; ...
             -3*pi/4,-2*pi/3,-pi/2,-pi/3,-pi/4];
         
% Obtenemos la orientación de las terminaciones
% La idea para obtener el ángulo es la siguiente:
% Tras la manipulación de la imagen, podemos asegurar que en la matrix
% 5x5 tendremos una línea de unos lógicos que simulará la terminación,
% donde el pixel central será la terminación y desde alguna posición de
% la ventana 5x5 continuará la línea hasta el borde de la ventana. 
% Si aislamos el uno lógico que esté en el borde, podremos obtener
% desde donde viene la cresta de la huella y posteriormente asignarle
% un ángulo a la terminación   
OrientacionTerminaciones=zeros(length(TerminacionX), 1);
for n=1:length(TerminacionX)
    % Creamos la ventana 5x5 con la información de la terminación y sus
    % pixeles aledaños. 
    Klocal=K(TerminacionY(n)-2:TerminacionY(n)+2, TerminacionX(n)-2:TerminacionX(n)+2);
    % Eliminamos el punto central y sus alrededores para asilar el borde
    Klocal(2:end-1,2:end-1)=0;
    % Obtenemos la posición de donde viene la terminación
    [i,j]=find(Klocal);
    % Es posible que tras el proceso haya más de un uno lógico en el borde
    % o no haya ninguno por haber detectado un pixel aislado como
    % terminación, por lo tanto, tenemos que asegurarnos de que todo es
    % correcto.
    if (length(i)==1)
        OrientacionTerminaciones(n,1)=TablaAngulos(i,j);
    % En el caso de detectar una terminación incorrecta, eliminamos la
    % información del vector.
    else 
        TerminacionY(n)=NaN;
        TerminacionX(n)=NaN;
        OrientacionTerminaciones(n, 1)=0;
    end
end

% Para poder mostrar en la imagen el ángulo de la terminación calculamos
% los puntos correspondientes a una hipotética recta de longitud 7
anguloXTerminaciones=sin(OrientacionTerminaciones)*7;
anguloYTerminaciones=cos(OrientacionTerminaciones)*7;

% Mostramos la imagen
figure;
imshow(K);
hold on;

% Mostramos los ángulos de las terminaciones
plot(TerminacionX,TerminacionY,'ro','linewidth',2);
plot([TerminacionX TerminacionX+anguloYTerminaciones]',...
    [TerminacionY TerminacionY-anguloXTerminaciones]','r','linewidth',2);

% De forma análoga calculamos la orientación de las bifurcaciones. Como en
% este caso tendremos tres líneas, tenemos que repetir el proceso 3 veces.
OrientacionBifurcaciones=zeros(length(BifurcacionX), 3);
for n=1:length(BifurcacionX)
    % Creamos la ventana 5x5
    Klocal=K(BifurcacionY(n)-2:BifurcacionY(n)+2,BifurcacionX(n)-2:BifurcacionX(n)+2);
    Klocal(2:end-1,2:end-1)=0;
    [i,j]=find(Klocal);
    % Si la información obtenida es la correcta tendremos que apuntar los 3
    % ángulos de la bifurcación
    if (length(i)==3)
        for k=1:3
            OrientacionBifurcaciones(n, k)=TablaAngulos(i(k),j(k));
        end
    % Si es incorrecto volvemos a usar el NaN
    else
        BifurcacionY(n)=NaN;
        BifurcacionX(n)=NaN;
        OrientacionBifurcaciones(n)=NaN;
    end
end

% Igualmente, necesitamos añadir puntos para la representación en pantalla
% de los ángulos
anguloXBifurcacion=sin(OrientacionBifurcaciones)*5;
anguloYBifurcacion=cos(OrientacionBifurcaciones)*5;

% Y mostramos los ángulos de las bifurcaciones
plot(BifurcacionX,BifurcacionY,'yo','linewidth',2);
OrientacionEjeX=[BifurcacionX BifurcacionX+anguloYBifurcacion(:,1);BifurcacionX BifurcacionX+anguloYBifurcacion(:,2);BifurcacionX BifurcacionX+anguloYBifurcacion(:,3)]';
OrientacionEjeY=[BifurcacionY BifurcacionY-anguloXBifurcacion(:,1);BifurcacionY BifurcacionY-anguloXBifurcacion(:,2);BifurcacionY BifurcacionY-anguloXBifurcacion(:,3)]';
plot(OrientacionEjeX,OrientacionEjeY,'y','linewidth',2);

%% PASO 6: Volcado de la información de las minucias
% Para el posterior análisis de la huella, mandamos las minucias a un txt
% para que quien lo desee, pueda usas la información de la huella.
terminacionesGuardar=[TerminacionX, TerminacionY, OrientacionTerminaciones];
bifurcacionesGuardar=[BifurcacionX, BifurcacionY, OrientacionBifurcaciones];
guardarMinucias(nombre ,terminacionesGuardar, bifurcacionesGuardar);