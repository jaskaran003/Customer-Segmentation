libname S '/folders/myfolders/K-means';

proc contents data=s.telco_SAS;
run;

ods html file='/folders/myfolders/K-means/desc.xls';

/*Calculating means and STD to identify outliers*/

proc means data=s.telco_SAS min max mean std var;
var longmon
tollmon
equipmon
cardmon
wiremon
multline
voice
pager
internet
callid
callwait
forward
confer
ebill;
run;
ods html close;


/*Creating 'validobs' to filter outliers (mean + 2STD)*/

data cluster;
set s.telco_SAS;

valid_obs_2=1;
 if longmon>32.45007269 or
 tollmon>47.0782442  or
 equipmon>52.3568776 or
 cardmon>41.9499926  or
 wiremon>51.0227512
then valid_obs_2=0;

/*Creating 'validobs' to filter outliers (mean + 3STD)*/

valid_obs_3=1;
 if longmon>42.8135589 or
 tollmon>63.9803663 or
 equipmon>71.4254164 or
 cardmon>56.0344889 or
 wiremon>70.7421768
then valid_obs_3=0;

run;

/* Calucating the % of data points in 'validobs' variables */

proc freq data=cluster;
table valid_obs_2 valid_obs_3;
run;

/*Standardizing segmentation variable and selecting valid_obs*/

data cluster;
set cluster;

Z_longmon       =       longmon ;
Z_tollmon       =       tollmon ;
Z_equipmon      =       equipmon        ;
Z_cardmon       =       cardmon ;
Z_wiremon       =       wiremon ;
Z_multline      =       multline        ;
Z_voice         =       voice   ;
Z_pager         =       pager   ;
Z_internet      =       internet        ;
Z_callid        =       callid  ;
Z_callwait      =       callwait        ;
Z_forward       =       forward ;
Z_confer        =       confer  ;
Z_ebill         =       ebill   ;

where valid_obs_3=1;

run;

proc standard data=cluster mean=0 std=1 out=cluster;

var Z_longmon
Z_tollmon
Z_equipmon
Z_cardmon
Z_wiremon
Z_multline
Z_voice
Z_pager
Z_internet
Z_callid
Z_callwait
Z_forward
Z_confer
Z_ebill;

run;

/*Doing K-means segmentation from 3 to 6 cluster*/

proc fastclus data=cluster out=Cluster maxclusters=3 cluster=clus_3 maxiter=100 ;

var Z_longmon
Z_tollmon
Z_equipmon
Z_cardmon
Z_wiremon
Z_multline
Z_voice
Z_pager
Z_internet
Z_callid
Z_callwait
Z_forward
Z_confer
Z_ebill;

run;

proc fastclus data=cluster out=Cluster maxclusters=4 cluster=clus_4 maxiter=100 ;
var Z_longmon
Z_tollmon
Z_equipmon
Z_cardmon
Z_wiremon
Z_multline
Z_voice
Z_pager
Z_internet
Z_callid
Z_callwait
Z_forward
Z_confer
Z_ebill;
run;

proc fastclus data=cluster out=Cluster maxclusters=5 cluster=clus_5 maxiter=100 ;
var Z_longmon
Z_tollmon
Z_equipmon
Z_cardmon
Z_wiremon
Z_multline
Z_voice
Z_pager
Z_internet
Z_callid
Z_callwait
Z_forward
Z_confer
Z_ebill;
run;

proc fastclus data=cluster out=Cluster maxclusters=6 cluster=clus_6 maxiter=100 ;
var Z_longmon
Z_tollmon
Z_equipmon
Z_cardmon
Z_wiremon
Z_multline
Z_voice
Z_pager
Z_internet
Z_callid
Z_callwait
Z_forward
Z_confer
Z_ebill;
run;

/*Checking segment size*/

proc freq data=cluster;
table clus_3 clus_4 clus_5 clus_6;
run;

ods html file='/folders/myfolders/K-means/profiling.xls';

proc tabulate data=Cluster;
var longmon
tollmon
equipmon
cardmon
wiremon
multline
voice
pager
internet
callid
callwait
forward
confer
ebill;
class  clus_3 clus_4 clus_5 clus_6;
table (longmon
tollmon
equipmon
cardmon
wiremon
multline
voice
pager
internet
callid
callwait
forward
confer
ebill)*mean, clus_3 clus_4 clus_5 clus_6 All;
run;
ods html close;
