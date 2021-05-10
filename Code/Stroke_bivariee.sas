
/*Cible vs quanti */

proc sgplot data=stroke;
	vbox age/category=stroke;
run;

proc sgplot data=stroke;
	vbox avg_glucose_level/category=stroke;
run;

proc sgplot data=stroke;
	vbox bmi/category=stroke;
run;

proc means data=stroke min q1 mean median q3 max;
	class stroke;
	var age avg_glucose_level bmi;
run;

/* Cible vs quali */

proc sgplot data=stroke;
	vbar stroke/group=gender;
run;

proc sgplot data=stroke;
	vbar stroke/group=hypertension;
run;

proc sgplot data=stroke;
	vbar stroke/group=heart_disease ;
run;

proc sgplot data=stroke;
	vbar stroke/group=ever_married ;
run;

proc sgplot data=stroke;
	vbar stroke/group=work_type ;
run;

proc sgplot data=stroke;
	vbar stroke/group=Residence_type ;
run;

proc sgplot data=stroke;
	vbar stroke/group=smoking_status ;
run;

proc freq data=stroke;
	table stroke*gender /nopercent norow;
run;

proc freq data=stroke;
	table stroke*hypertension /nopercent norow;
run;

proc freq data=stroke;
	table stroke*heart_disease /nopercent norow;
run;

proc freq data=stroke;
	table stroke*ever_married /nopercent norow;
run;

proc freq data=stroke;
	table stroke*work_type /nopercent norow;
run;

proc freq data=stroke;
	table stroke*Residence_type /nopercent norow;
run;

proc freq data=stroke;
	table stroke*smoking_status /nopercent norow;
run;