*** General Sets ***

  Sets
  T    "indices for times"       / 1 *  24 /
  N    "indices for nodes"       / 1 *   2 /
  G    "indices for generators"  / 1 *   8 /
  D(N) "indices for consumers"   / 1 *   2 /
  Z    "indices for zones"       / 1 *   2 /
  S_co2    "indices for scenarios"   /low_co2, high_co2/
  S_dloc    "indices for demand location scenarios" /north, south/
  S_dlev    "indices for demand level scenarios"    /low_dlev, medium_dlev, high_dlev/
  S_lcost   "indices for line investment cost scenarios"    /low_lcost, high_lcost/
  B    "indices for backup"      / 1 *   2 /
  ;

  Alias (n,nn) ;

  Scalars
  M              bigM                                  / 10000    /
  epsilon        elacticity of demand                  /    -0.10 /
  Year           Hours per year                        /  8760    /
  buFixInv       Annuity per 1 MW backup capacity      / 32000    /
  DSM            Load Shedding costs                   /  3000    /  
  L_step         Capacity steps for lines              /   0.1 /
  ;
  
  Parameters
  
*** Line Parameters ***
  lineIsNew(L)   "candidate line"
  lineGamma(L)   "susceptance"
  lineUB(L)      "thermal capacity"
  lineStart(L)   "start node"
  lineEnd(L)     "end node"
  lineFixInv(L,S_lcost)  "line investment cost (candidate lines)"
  lineInter(L) "line is interzone link"
  L_cost(S_lcost)   "Cost for 0.01 line capacity"           / low_lcost 300, high_lcost 300/   

$ifthen '%mode%' == deterministic
*** Probability Parameters ***  
  prob_co2(S_co2)  "probability for CO2 scenario"      /low_co2 0, high_co2 1/
  prob_dloc(S_dloc) "probability for demand location scenario"  /north 0, south 1/
  prob_dlev(S_dlev) "probability for demand level scenario"     /low_dlev 0, medium_dlev 0, high_dlev 1/
  prob_lcost(S_lcost)   "probability for line investment cost scenario" /low_lcost 0, high_lcost 1/
$else
*** Probability Parameters ***
Parameters
  prob_co2(S_co2)  "probability for CO2 scenario"      /low_co2 0.5, high_co2 0.5/
  prob_dloc(S_dloc) "probability for demand location scenario"  /north 0.5, south 0.5/
  prob_dlev(S_dlev) "probability for demand level scenario"     /low_dlev 0.4, medium_dlev 0.2, high_dlev 0.4/
  prob_lcost(S_lcost)   "probability for line investment cost scenario" /low_lcost 0.5, high_lcost 0.5/
$endif  

Parameters
*** Generator Parameters ***
  genIsRES(G)    "renewable generator"                   / 7 1, 8 1 /
  genAtNode(G)   "location (node)"                       / 1 1, 2 1, 3 1, 4 2, 5 2, 6 2, 7 1, 8 2 /
  buVarInv(S_co2)       "Variable cost per MWh for backup"      /low_co2 79, high_co2 85/
  genFixInv(G)   "investment cost"                       / 1 93000, 2 58000, 3 28000, 4 93000, 5 58000, 6 28000, 7 78000, 8 93000 /
  buAtNode(B)    "location (node) of backup"             / 1 1, 2 2 /
  avail(T,G)     "availability of generators";

  Table
  genVarInv(G,S_co2)   "variable cost"               low_co2   high_co2
                                                1       35      51
                                                2       43      50
                                                3       68      79
                                                4       38      54
                                                5       43      50
                                                6       68      79
                                                7       0       0
                                                8       0       0
 ;
 
 Parameters
 
*** Demand Parameters ***
  consAtNode(D)   "location (node)"                      / 1 1, 2 2 /
  consObjB(D,T,S_dloc,S_dlev)   "slope demand function"
  consObjA(D,T,S_dloc,S_dlev)   "intercept demand function"
  periodScale(T)  "occurence of scenarios"
  dRef(T,S_dlev)         "reference demand per season"
  pRef(T)         "reference price"
  ;
  Table
  qPeak(D,S_dloc)    "peak consumption at consumer D in scenario s_dloc" north  south
                                                                     1   0.9    0.1
                                                                     2   0.1    0.9;                                                                
  lineIsNew(L)     = 1 ;
  lineGamma(L)     = 1 ;
  lineUB(L)        = ( L.Val - 1 ) * L_step ;
  lineStart(L)     = 1 ;
  lineEnd(L)       = 2 ;
  lineFixInv(L,S_lcost)    = L_cost(S_lcost) * L_step / 0.01 * ( L.Val - 1 ) ;  

*** Zonal Configuration Parameters ***
$ifthen '%no_of_zones%' == one
  lineInter(L) = 0
  Parameters
  ConsInZone(D) "consumer in zone" /1 1, 2 1/
  GenInZone(G) "generation in zone"  /1 1, 2 1, 3 1, 4 1, 5 1, 6 1, 7 1, 8 1/
  NodeInZone(N) /1 1, 2 1/
$else
  lineInter(L) = 1
  Parameters
  ConsInZone(D) "consumer in zone" /1 1, 2 2/
  GenInZone(G) "generation in zone"  /1 1, 2 1, 3 1, 4 2, 5 2, 6 2, 7 1, 8 2/
  NodeInZone(N) /1 1, 2 2/
$endif                          
  ;

*** Risk Aversion Parameters ***
  Parameters
  weight_sp     "weight assigned to the worst-case spot market outcome for risk averse market participants (0 being the risk-neutral case and 1 being strictly robust)"
  weight_rd     "weight assigned to the worst-case redispacth outcome for risk averse market participants (0 being the risk-neutral case and 1 being strictly robust)"
  percentile    "lower percentile of welfare function that is considered to be the worst case"                /0.5/
  ;



*** Read.csv Input Data

$call csv2gdx Data/Input_avail.txt id=avail Index=1 Value='(2..9)' UseHeader=Y StoreZero=Y FieldSep=Tab Output=input.gdx
$gdxin input.gdx
$load avail
$gdxin

$call csv2gdx Data/Input_hourly.txt id=periodScale Index=1 Value=2 UseHeader=Y StoreZero=Y FieldSep=Tab Output=input.gdx
$gdxin input.gdx
$load periodScale
$gdxin

$call csv2gdx Data/Input_hourly.txt id=dRef Index=1 Value='(4..6)' UseHeader=Y StoreZero=Y FieldSep=Tab Output=input.gdx
$gdxin input.gdx
$load dRef
$gdxin

$call csv2gdx Data/Input_hourly.txt id=pRef Index=1 Value=3 UseHeader=Y StoreZero=Y FieldSep=Tab Output=input.gdx
$gdxin input.gdx
$load pRef
$gdxin

*** Demand Curves ***

  consObjB(D,T,S_dloc,S_dlev) = (-1) * pRef(T) / ( dRef(T,S_dlev) * qPeak(D,S_dloc) * epsilon )      ;
  consObjA(D,T,S_dloc,S_dlev) =  pRef(T) + consObjB(D,T,S_dloc,S_dlev) * dRef(T,S_dlev) * qPeak(D,S_dloc)          ;
