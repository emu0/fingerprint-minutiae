function guardarMinucias(nombre, terminaciones, bifurcaciones)
name=strrep(nombre,' ','_');
date=datestr(now,29);
FileName=[name '_' date '.txt'];

Terminaciones=limpiarNaN(terminaciones);
Bifurcaciones=limpiarNaN(bifurcaciones);

file=fopen(FileName,'wt');

fprintf(file,'%s \n','-------------------------------------------------------------------');
fprintf(file,'%s \n',['Nombre: ' name]);
fprintf(file,'%s \n',['Fecha: ' date]);
fprintf(file,'%s','Numero de terminaciones: ');
fprintf(file,'%2.0f \n',size(Terminaciones,1));
fprintf(file,'%s','Numero de bifurcaciones: ');
fprintf(file,'%2.0f \n',size(Bifurcaciones,1));
fprintf(file,'%s \n','-------------------------------------------------------------------');
fprintf(file,'%s \n','-------------------------------------------------------------------');
fprintf(file,'%s \n','Terminaciones:');
fprintf(file,'%s \n','-------------------------------------------------------------------');
fprintf(file,'%s \n','X          Y     Angulo');
fprintf(file,'%3.0f \t %3.0f \t %3.2f \n',Terminaciones');
fprintf(file,'%s \n','-------------------------------------------------------------------');
fprintf(file,'%s \n','Bifurcaciones:');
fprintf(file,'%s \n','-------------------------------------------------------------------');
fprintf(file,'%s \n','X          Y     Angulo 1     Angulo 2    Angulo 3');
fprintf(file,'%3.0f \t %3.0f \t %3.2f \t \t %3.2f \t \t %3.2f \n',Bifurcaciones');
fclose(file);


