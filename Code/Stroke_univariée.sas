proc import 
	out = work.stroke
	datafile='/home/u44958032/Stroke/stroke-data.csv'
	dbms = csv replace;
	getnames=yes;
run;

proc print data=work.stroke(obs=10);
run;


/* On remplace les "N/A" par des valeurs manquantes */
data _null_;
	infile '/home/u44958032/Stroke/stroke-data.csv' obs=1;
	input;
	call symputx('ncol',countw(_infile_,',','q'));
run;

data _null_;
	infile '/home/u44958032/Stroke/stroke-data.csv' dsd truncover;
	file '/home/u44958032/Stroke/stroke-data-sas.csv' dsd;
	length word $200;
	do i=1 to 12;
		input word @;
		if word='N/A' then word= ' ';
		put word @;
	end;
	put;
run;
	
proc import 
	out = work.stroke
	datafile='/home/u44958032/Stroke/stroke-data-sas.csv'
	dbms = csv replace;
	getnames=yes;
run;	

proc means data=stroke n nmiss min q1 mean q3 max;
	var age avg_glucose_level bmi;
run;

proc stdize data=stroke out=stroke reponly method=median;
run;

proc print data=stroke obs=10;run;
	

/* Variables quanti */

proc means data=stroke n nmiss min q1 mean q3 max;
	var age avg_glucose_level bmi;
run;

proc sgplot data=stroke;
	histogram age/showbins;
run;

proc sgplot data=stroke;
	histogram avg_glucose_level/showbins;
run;

proc sgplot data=stroke;
	histogram bmi/showbins;
run;

/* Variables quali */

proc freq data=stroke;
	tables gender hypertension heart_disease ever_married work_type
			Residence_type smoking_status;
run;

proc freq data=stroke;
	tables gender;
run;

data stroke;
	set stroke;
	if gender='Other' then delete;
run;

proc freq data=stroke;
	tables gender;
run;

proc sgplot data=stroke;
	vbar gender/stat=percent;
run;

proc freq data=stroke;
	tables hypertension;
run;

proc sgplot data=stroke;
	vbar hypertension/stat=percent;
run;

proc freq data=stroke;
	tables heart_disease;
run;

proc sgplot data=stroke;
	vbar heart_disease/stat=percent;
run;

proc freq data=stroke;
	tables ever_married;
run;

proc sgplot data=stroke;
	vbar ever_married/stat=percent;
run;

proc freq data=stroke;
	tables work_type;
run;

proc sgplot data=stroke;
	vbar work_type/stat=percent;
run;

proc freq data=stroke;
	tables Residence_type;
run;

proc sgplot data=stroke;
	vbar Residence_type/stat=percent;
run;

proc freq data=stroke;
	tables smoking_status;
run;

proc sgplot data=stroke;
	vbar smoking_status/stat=percent;
run;

/* Variable cible */

proc freq data=stroke;
	tables stroke;
run;

proc sgplot data=stroke;
	vbar stroke/stat=percent;
run;

