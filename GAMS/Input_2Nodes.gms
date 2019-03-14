*** General Sets ***

  Sets
  T    "indices for times"       / 1 *  400 /
  N    "indices for nodes"       / 1 *   2 /
  G    "indices for generators"  / 1 *   8 /
  D(N) "indices for consumers"   / 1 *   2 /
  Z    "indices for zones"       / 1 *   2 /
  B    "indices for backup"      / 1 *   2 /
  trans "indices for transmission cost scenarios" /low_trans, high_trans/
  S_co2 "indices for CO2 cost scenarios"    /low_co2, high_co2/
  S_dloc "indices for demand locational distribution scenarios"  /south, north/
  S_dlev    "indices for demand level scenarios"    /low_dlev, medium_dlev, high_dlev/
  S(S_trans,S_co2,S_dloc,S_dlev)    "indices for all scenarios"   /#S_trans.#S_co2.#S_dloc.#S_dlev/
  ;
  Alias (n,nn) ;

  Scalars
  M              bigM                                  / 10000    /
  epsilon        elacticity of demand                  / -0.10 /
  Year           Hours per year                        /  8760    /
  buFixInv       Annuity per 1 MW backup capacity      / 32000    /
  DSM            Load Shedding costs                   /  3000    /
*DSM: do we use / need that?
  buVarInv       Variable cost per MWh for backup      /    79    /
  L_step         Capacity steps for lines              /     0.01 /
  ;

*** Line Parameters ***

  Parameters
  lineIsNew(L)   "candidate line"
  lineGamma(L)   "susceptance"
  lineUB(L)      "thermal capacity"
  lineStart(L)   "start node"
  lineEnd(L)     "end node"
  lineFixInv(L, S_trans)  "line investment cost (candidate lines)"
  lineInter(L) "line is interzone link"
  L_cost(S_trans)   "Cost for 0.01 line capacity"           / 1 250, 2 350 /

*** Generator Parameters ***

  genIsRES(G)    "renewable generator"                   / 7 1, 8 1 /
  genAtNode(G)   "location (node)"                       / 1 1, 2 1, 3 1, 4 2, 5 2, 6 2, 7 1, 8 2 /;
  Table
  genVarInv(G,S_co2)   "variable cost"               1   2
                                                1   35  51  
                                                2   43  50
                                                3   68  79
                                                4   38  54
                                                5   43  50
                                                6   68  79
  ;

  Parameters
  genFixInv(G)   "investment cost"                       / 1 93000, 2 58000, 3 32000, 4 93000, 5 58000, 6 32000, 7 78000, 8 93000 /
  buAtNode(B)    "location (node) of backup"             / 1 1, 2 2 /
  probability(S) "probability for scenario S"
  avail(T,G)     "availability of generators"

*** Demand Parameters ***
  consAtNode(D)   "location (node)"                      / 1 1, 2 2 /;
  Table
  qPeak(D, S_dloc) "peak consumption at consumer D"         1   2
                                                        south   0.3 0.7
                                                        north   0.7 0.3
  ;
  Parameters
  consObjB(D,T,S_dlev,S_dloc)   "slope demand function"
  consObjA(D,T,S_dlev,S_dloc)   "intercept demand function"
  periodScale(T)  "occurence of scenarios"
  dRef(T, S_dlev)         "reference demand per season"
  pRef(T)         "reference price"

*** Risk Aversion Parameters ***
  weight_sp     "weight assigned to the worst-case spot market outcome for risk averse market participants (0 bein the risk-neutral case and 1 being strictly robust)"   /0.4/
  weight_rd     "weight assigned to the worst-case redispacth outcome for risk averse market participants (0 bein the risk-neutral case and 1 being strictly robust)"    /0.4/
  percentile      "lower percentile of welfare function that is considered to be the worst case"                /0.2/
  ;

  lineIsNew(L)     = 1 ;
  lineGamma(L)     = 1 ;
  lineUB(L)        = ( L.Val - 1 ) * L_step ;
  lineStart(L)     = 1 ;
  lineEnd(L)       = 2 ;
  lineFixInv(L, S_trans)    = L_cost(S_trans) * L_step / 0.01 * ( L.Val - 1 ) ;
  lineInter("2",L) = 1 ;


  Table
  ConsInZone(D,S) "consumer in zone" 1     2
                                 1   1     1
                                 2   1     2
  ;


  Table
  GenInZone(G,S) "generation in zone"  1   2
                                   1   1   1
                                   2   1   1
                                   3   1   1
                                   4   1   2
                                   5   1   2
                                   6   1   2
                                   7   1   1
                                   8   1   2

  ;

  Table
  NodeInZone(N,S) "node in zone" 1     2
                             1   1     1
                             2   1     2
  ;


*** Read.csv Input Data

$call csv2gdx Data/InputRES.txt id=avail Index=1 Value='(2..9)' UseHeader=Y StoreZero=Y FieldSep=Tab Output=input.gdx
$gdxin input.gdx
$load avail
$gdxin

$call csv2gdx Data/Input_HourlyValues.txt id=periodScale Index=1 Value=2 UseHeader=Y StoreZero=Y FieldSep=Tab Output=input.gdx
$gdxin input.gdx
$load periodScale
$gdxin

$call csv2gdx Data/Input_HourlyValues.txt id=dRef Index=1 Value='(4..6)' UseHeader=Y StoreZero=Y FieldSep=Tab Output=input.gdx
$gdxin input.gdx
$load dRef
$gdxin

$call csv2gdx Data/Input_HourlyValues.txt id=pRef Index=1 Value=4 UseHeader=Y StoreZero=Y FieldSep=Tab Output=input.gdx
$gdxin input.gdx
$load pRef
$gdxin

*** Demand Curves ***

  consObjB(D,T,S_dlev,S_dloc) = (-1) * pRef(T) / ( dRef(T, S_dlev) * qPeak(D, S_dloc) * epsilon )      ;
  consObjA(D,T,S_dlev,S_dloc) =  pRef(T) + consObjB(D,T,S_dlev,S_dloc) * dRef(T, S_dlev) * qPeak(D, S_dloc)          ;
