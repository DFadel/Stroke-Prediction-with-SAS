
/* Forêt aléatoire */


proc hpforest data=train_oversampled maxtrees=1000 maxdepth=5;
	input gender hypertension heart_disease ever_married Residence_type/level=binary;
	input work_type smoking_status/level=nominal;
	input age/level=ordinal;
	input avg_glucose_level bmi/level=interval;
	target stroke/level=binary;
	ods output FitStatistics=fitstats;
	save file='/home/u44958032/Stroke/outforest_oversampled.sas';
quit;

proc hp4score data=test;
	score file='/home/u44958032/Stroke/outforest_oversampled.sas' out=scoreforest;
run;

data score;
	set scoreforest;
	if stroke ne I_stroke then misclass=1;
	else misclass=0;
run;

proc means data=score;
	var misclass;
run;

data forestpred_oversampled;
	set scoreforest;
	Actual = stroke;
	Predicted = (P_stroke1 >= 0.5);
run;

proc freq data=forestpred_oversampled;
	tables Actual*Predicted / nocol nocum nopercent;
run;

proc sgplot data=fitstats;
	series x=Ntrees y=MiscAll;
	series x=Ntrees y=Miscoob/lineattrs=(pattern=shortdash thickness=2);
run;

/* Undersampling */


/* Forêt aléatoire */


proc hpforest data=train_undersampled maxtrees=1000 maxdepth=5;
	input gender hypertension heart_disease ever_married Residence_type/level=binary;
	input work_type smoking_status/level=nominal;
	input age/level=ordinal;
	input avg_glucose_level bmi/level=interval;
	target stroke/level=binary;
	ods output FitStatistics=fitstats;
	save file='/home/u44958032/Stroke/outforest_undersampled.sas';
quit;

proc hp4score data=test;
	score file='/home/u44958032/Stroke/outforest_undersampled.sas' out=scoreforest;
run;

data score;
	set scoreforest;
	if stroke ne I_stroke then misclass=1;
	else misclass=0;
run;

proc means data=score;
	var misclass;
run;

data forestpred_undersampled;
	set scoreforest;
	Actual = stroke;
	Predicted = (P_stroke1 >= 0.5);
run;

proc freq data=forestpred_undersampled;
	tables Actual*Predicted / nocol nocum nopercent;
run;

proc sgplot data=fitstats;
	series x=Ntrees y=MiscAll;
	series x=Ntrees y=Miscoob/lineattrs=(pattern=shortdash thickness=2);
run;

title "Matrice de Confusion forêt suréchantillonnage";

proc freq data=forestpred_oversampled;
	tables Actual*Predicted / nocol nocum nopercent;
run;

title "Matrice de Confusion forêt sous-échantillonnage";

proc freq data=forestpred_undersampled;
	tables Actual*Predicted / nocol nocum nopercent;
run;
