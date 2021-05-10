proc import 
	out = work.stroke
	datafile='/home/u44958032/Stroke/stroke-data-sas.csv'
	dbms = csv replace;
	getnames=yes;
run;

proc stdize data=stroke out=stroke reponly method=median;
run;


data stroke;
	set stroke;
	if gender='Other' then delete;
run;