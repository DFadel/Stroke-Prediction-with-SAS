data temp1 temp0;
	set work.stroke;
	n=ranuni(20);
	if stroke=0 then output temp0;
	else output temp1;
run;

data train0 test0;
	set temp0 nobs=nobs;
	if _n_ <=0.7*nobs then output train0;
	else output test0;
run;

data train1 test1;
	set temp1 nobs=nobs;
	if _n_ <=0.7*nobs then output train1;
	else output test1;
run;

data train;
	set train0 train1;
	drop n;
	file '/home/u44958032/Stroke/stroke-train.csv' dsd;
run;

data test;
	set test0 test1;
	drop n;
	file '/home/u44958032/Stroke/stroke-test.csv' dsd;
run;

proc sgplot data=train;
	vbar stroke/ stat=percent;
run;

proc sgplot data=test;
	vbar stroke/ stat=percent;
run;

/*Regression logistique */

ods graphics on;
proc logistic data=train descending plots=all outmodel=work.strokelogit;
	class gender hypertension heart_disease ever_married work_type
			Residence_type smoking_status
		/param=ref;
	model stroke(event='1') = age avg_glucose_level bmi
					gender hypertension heart_disease ever_married 
					work_type Residence_type smoking_status
		/selection=stepwise lackfit;
	score out=Score1 ;
run;

proc logistics inmodel=work.strokelogit;
	score data=test out=Score2 fitstat;
run;

proc freq data=Score2;
	tables F_stroke*I_stroke / nocol nocum nopercent senspec;
run;

proc freq data=Score1;
	tables F_stroke*I_stroke / nocol nocum nopercent senspec;
run;

/* Arbre de décision */

ods graphics on;
proc hpsplit data=train cvmodelfit seed=123 plots=wholetree;
	class stroke gender hypertension heart_disease ever_married work_type
			Residence_type smoking_status;
	model stroke(event='1') = age avg_glucose_level bmi
					gender hypertension heart_disease ever_married 
					work_type Residence_type smoking_status;
	grow gini;
	prune costcomplexity;
	output out=ScoredTrain;
	code file = '/home/u44958032/Stroke/Stroketree.sas';
run;

data strokepred;
	set test;
	%include '/home/u44958032/Stroke/Stroketree.sas';
	Actual = stroke;
	Predicted = (P_stroke1 >= 0.5);
	file '/home/u44958032/Stroke/strokepred.csv' dsd;
run;

proc freq data=strokepred;
	tables Actual*Predicted / nocol nocum nopercent senspec;
run;


/* Stratégie de suréchantillonnage */

data train_rare train_not_rare;
	set work.train;
	if stroke=1 then output train_rare;
	else output train_not_rare;
run;

data indexes (drop=i);
	call streaminit(1);
	do i = 1 to 2500;
		p= ceil(249*ranuni(123));
		output;
	end;
run;

data train_oversampled (drop=i);
	set indexes;
	do i=1 to 2500;
		set work.train_rare point=p;
	end;
run;

data train_oversampled;
	set train_oversampled train_not_rare;
	file '/home/u44958032/Stroke/stroke-train_oversampled.csv' dsd;
run;

proc freq data=train_oversampled;
	table stroke;
run;

/*Regression logistique */

ods graphics on;
proc logistic data=train_oversampled descending plots=all 
	outmodel=work.strokelogit_oversampled;
	class gender hypertension heart_disease ever_married work_type
			Residence_type smoking_status
		/param=ref;
	model stroke(event='1') = age avg_glucose_level bmi
					gender hypertension heart_disease ever_married 
					work_type Residence_type smoking_status
		/selection=stepwise lackfit ;
	score out=Score1_oversampled;
run;

proc logistics inmodel=work.strokelogit_oversampled;
	score data=test out=Score2_oversampled fitstat;
run;

proc freq data=Score2_oversampled;
	tables F_stroke*I_stroke / nocol nocum nopercent senspec;
run;

proc freq data=Score1_oversampled;
	tables F_stroke*I_stroke / nocol nocum nopercent senspec;
run;

/* Arbre de décision */

ods graphics on;
proc hpsplit data=train cvmodelfit seed=123 plots=wholetree;
	class stroke gender hypertension heart_disease ever_married work_type
			Residence_type smoking_status;
	model stroke(event='1') = age avg_glucose_level bmi
					gender hypertension heart_disease ever_married 
					work_type Residence_type smoking_status;
	grow gini;
	prune C45;
	output out=ScoredTrain_oversampled;
	code file = '/home/u44958032/Stroke/Stroketree_oversampled.sas';
run;

data strokepred_oversampled;
	set test;
	%include '/home/u44958032/Stroke/Stroketree_oversampled.sas';
	Actual = stroke;
	Predicted = (P_stroke1 >= 0.5);
	file '/home/u44958032/Stroke/strokepred_oversampled.csv' dsd;
run;

proc freq data=strokepred_oversampled;
	tables Actual*Predicted / nocol nocum nopercent senspec;
run;


/* Stratégie de sous-échantillonnage */

data train_undersampled;
	set work.train;
	if stroke=1 then output;
	if stroke=0 then do;
		if ranuni(123)<0.1 then output;
	end;
	file '/home/u44958032/Stroke/stroke-train_undersampled.csv' dsd;
run;

proc freq data=train_undersampled;
	tables stroke;
run;

/*Regression logistique */

ods graphics on;
proc logistic data=train_undersampled descending plots=all 
	outmodel=work.strokelogit_undersampled;
	class gender hypertension heart_disease ever_married work_type
			Residence_type smoking_status
		/param=ref;
	model stroke(event='1') = age avg_glucose_level bmi
					gender hypertension heart_disease ever_married 
					work_type Residence_type smoking_status
		/selection=stepwise lackfit ;
	score out=Score1_undersampled;
run;

proc logistics inmodel=work.strokelogit_undersampled;
	score data=test out=Score2_undersampled fitstat;
run;

proc freq data=Score2_undersampled;
	tables F_stroke*I_stroke / nocol nocum nopercent senspec;
run;

proc freq data=Score1_undersampled;
	tables F_stroke*I_stroke / nocol nocum nopercent senspec;
run;

/* Arbre de décision */

ods graphics on;
proc hpsplit data=train_undersampled cvmodelfit seed=123 plots=wholetree;
	class stroke gender hypertension heart_disease ever_married work_type
			Residence_type smoking_status;
	model stroke(event='1') = age avg_glucose_level bmi
					gender hypertension heart_disease ever_married 
					work_type Residence_type smoking_status;
	grow gini;
	prune C45;
	output out=ScoredTrain_oversampled;
	code file = '/home/u44958032/Stroke/Stroketree_undersampled.sas';
run;

data strokepred_undersampled;
	set test;
	%include '/home/u44958032/Stroke/Stroketree_undersampled.sas';
	Actual = stroke;
	Predicted = (P_stroke1 >= 0.5);
	file '/home/u44958032/Stroke/strokepred_undersampled.csv' dsd;
run;

proc freq data=strokepred_undersampled;
	tables Actual*Predicted / nocol nocum nopercent senspec;
run;


/* tous les résultats pour comparer */

title "Régression logistique";

proc logistics inmodel=work.strokelogit;
	score data=test out=Score2 fitstat;
run;

title "Régression logistique suréchantillonnage";

proc logistics inmodel=work.strokelogit_oversampled;
	score data=test out=Score2_oversampled fitstat;
run;


title "Régression logistique sous-échantillonnage";

proc logistics inmodel=work.strokelogit_undersampled;
	score data=test out=Score2_undersampled fitstat;
run;


title "Matrice de confusion régression logsitique";

proc freq data=Score2;
	tables F_stroke*I_stroke / nocol nocum nopercent;
run;


title "Matrice de confusion régression logistique suréchantillonage";

proc freq data=Score2_oversampled;
	tables F_stroke*I_stroke / nocol nocum nopercent;
run;

title "Matrice de confusion régression logistique sous-échantillonage";

proc freq data=Score2_undersampled;
	tables F_stroke*I_stroke / nocol nocum nopercent;
run;


title "Matrice de confusion arbre de décision";

proc freq data=strokepred;
	tables Actual*Predicted / nocol nocum nopercent;
run;

title "Matrice de confusion arbre de décision suréchantillonnage";

proc freq data=strokepred_oversampled;
	tables Actual*Predicted / nocol nocum nopercent;
run;

title "Matrice de confusion arbre de décision sous-échantillonnage";

proc freq data=strokepred_undersampled;
	tables Actual*Predicted / nocol nocum nopercent;
run;
