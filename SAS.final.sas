libname data "C:\Users\hamed.ghaseminezhad\Desktop\project.sas";

proc sort data=data.travel_expense;
by employee_id;
run;


data data.All;
merge data.Employees data.Travel_expense;
by employee_id;
run;

proc sort data=data.All;
by Employee_ID;
run;


data data.All1;
set data.All;
if Exp1 or Exp2 or Exp3 or Exp4 or Exp5 ne . then output;
run;


data data.t1;
set data.All1;
   
  drop i term_date marital_status dependents street_number street_name city state postal_code country
manager_id department ;

  /* Job_Title and Department of each employee, separated by a blank space */
JOB_DEP=CATX(" ",job_title,department);

  /* GENDER_CD: is equal to 0 for males and 1 for females */
if gender="M" then GENDER_CD=0;
 else if gender="F" then GENDER_CD=1;

  /* HIRE_AGE: the difference between HIRE_DATE and BIRTH_DATE and divide it by 365.25. */
Hire_age=INT((Hire_date-Birth_Date)/365.25);

 /* Using an array, create a character variable for each expense */
array a[*] $20 EXP1-EXP5;
array b[*] $20 EXP_C1-EXP_C5; 
do i=1 to dim(a);
if  a[i]=. then b[i]="No expense"; 
else if a[i]<100 then b[i]="very low expense";
else if a[i]>=100 and a[i]<300 then b[i]="low expense";
else if a[i]>=300 and a[i]<500 then b[i]="high expense";
else if a[i]>=500 then b[i]="very high expense";
end;
format birth_date hire_date date9. salary DOLLAR10. ; 
run;

 /* Create a report excluding variables EXP1-EXP5. Consider all employees except the ones with Job_Title ending with “II”. */
data data.all2;
set data.t1;
if SUBSTR(Job_Title,length(Job_Title)-2,3)=" II" then delete;
run;

/*Create a table that summarizes the mean, min, max, sd, and n related to the HIRE_AGE grouped by SEX. */
proc means data=data.t1;
var Hire_age;
class gender;
output out=data.mean mean=medium_Hire_age
                     std=std_Hire_age
                     min=minimum_Hire_age
					 max=maximum_Hire_age;
run;


data data.t5;
	set data.t1;
	keep employee_id EXP1-EXP5;
run;

data data.LOCF;
  set data.t5;
	array a[*] EXP1-EXP5;
	array b[*] locf_exp1-locf_exp5;
	drop i;
	if a[1] ne . then do;
	  b[1]=a[1];
	  do i=2 to dim(a);
		if a[i] ne . then b[i]=a[i];
		else b[i]=b[i-1];
	  end;
	end; 
run;
data data.TOTAL;
set data.LOCF;
where locf_exp1 ne .;
total_expenses=locf_exp1+locf_exp2+locf_exp3+locf_exp4+locf_exp5;
run;

data data.total_1;
set data.total;
array a[*] locf_exp1-locf_exp5;
array b[*] perc1-perc5;
do i = 1 to dim(a);
b[i] = round((a[i] / total_expenses) * 100, .01);
end;
drop i;
run;


proc format ;
value $gender "F"="Females"
              "M"="Males";
run;

ods html close;
ods rtf file="C:\Users\hamed.ghaseminezhad\Desktop\project.sas\project2.rtf";
options nodate nonumber;
proc report data=data.t1 
style(report)=[rules=groups frame=void]
style(header)=[background=yellow font_face=calibri font_size=8pt font_weight=bold]
style(column)=[background=lightblue font_face=calibri font_size=7pt ];
 column gender employee_id name job_title salary birth_date hire_date trip_id 
  ("Expense" exp1 exp2 exp3 exp4 exp5) job_dep gender_cd hire_age ("character version of the expense" exp_c1 exp_c2 exp_c3 exp_c4 exp_c5);

  define gender / order noprint;
  define employee_id / display "Employee_ID" style(column)=[just=center];
  define name / display "Name";
  define job_title / display "Job_Title" ;
  define salary / display "Salary" style(column)=[just=left];
  define birth_date / display "Birth_Date";
  define hire_date / display "Hire_Date";
  define trip_id / display "Trip_ID";
  define exp1 / display "EXP1" style(column)=[just=left] ;
  define exp2 / display "EXP2" style(column)=[just=left];
  define exp3 / display "EXP3" style(column)=[just=left];
  define exp4 / display "EXP4" style(column)=[just=left];
  define exp5 / display "EXP5" style(column)=[just=left];
  define job_dep / display "Job_Dep";
  define gender_cd / order "Gender_CD" style(column)=[just=center];
  define hire_age / display "Hire_Age" style(column)=[just=left];
  define exp_c1 / display "EXP_C1" ;
  define exp_c2 / display "EXP_C2" ;
  define exp_c3 / display "EXP_C3" ;
  define exp_c4 / display "EXP_C4" ;
  define exp_c5 / display "EXP_C5" ;

  compute before gender / style=[font_face=calibri font_size=7pt font_weight=bold just=left];
   line "";
   line "Employee Gender: " gender $gender.;
   endcomp;

  compute before _page_ / style=[font_face=calibri font_size=12pt font_weight=bold];
   line "Employee's Travel Expense Information";
   line"";
   endcomp;
 
  compute after _page_ / style=[font_face=calibri font_size=7pt font_style=italic];
   line"";
   line "report sorted by gender and gender_cd";
   endcomp;
run;
ods rtf close;
ods html;





