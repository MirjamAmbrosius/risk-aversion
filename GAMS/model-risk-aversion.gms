***--------------------------------------------------------------------------***
***                           DEFINITION of VARIABLES                        ***
***--------------------------------------------------------------------------***

  Variables
* objective values
  welfareSpot            "welfare in spot market"
  costRedispatch         "cost at redispatch level"

* Spot Market
  f_sp(S,L,T)            "trade flow in spot market"
  VAR_sp                "value at risk spot market"
* Redispatch
  f_rd(S,L,T)            "transmission flows redispatch"
  angle(S,N,T)           "phase angle in redispatch model"
  VAR_rd                "value at risk redispatch"
  CVAR                   "conditional value at risk"
  ;

  Positive Variables
* Spot Market
  d_sp(S,D,T)            "demand spot market"
  g_sp(S,G,T)            "generation amount spot market"
  ig_sp(G)               "installed capacity of generators in spot market"
* Risk Aversion
  eta_sp(S)              "auxiliary variable to model CVAR in spot market stage"


* Redispatch
  d_rd(S,D,T)            "demand redispatcht"
  g_rd(S,G,T)            "generation amount redispatch"
  gb_rd(S,B,T)           "generation backup capacity redispatch"
  ib_rd(B)               "investment in backup capacity redispatch"
  g_n_rd(S,G,T)          "negative generation redispatch"
  g_p_rd(S,G,T)          "positive generation redispatch"
  ls_rd(S,D,T)           "load shedding redispatch"
* Risk Aversion
  eta_rd(S)              "auxiliary variable to model CVAR in redispatch stage"
  ;

*  Binary Variable
*  lineB(L)               "line is built?"
*  ;

***--------------------------------------------------------------------------***
***                          SPOT MARKET MODEL                               ***
***--------------------------------------------------------------------------***

*** Objective function
  Equation welfSpot;
  welfSpot..         welfareSpot =e= (1-weight_sp)*sum(S$probability(S), probability(S)
                                      * ( sum((D,T), periodScale(T)*( consObjA(D,T) * d_sp(S,D,T)
                                      - 0.5 * consObjB(D,T) * d_sp(S,D,T) * d_sp(S,D,T) ) )
                                      - sum((G,T), genVarInv(G) * g_sp(S,G,T) * periodScale(T) ) ) ) * Year
                                      - sum(G, genFixInv(G) * ig_sp(G) )
                                      + weight_sp*(VAR_sp - (1/(1-percentile)*sum(S$probability(S), probability(S) * eta_sp(S)))) ;

*** Conditional Value at Risk Restrictions ***
  Equation CVARSpot;
  CVARSpot(S)$probability(S)..
        VAR_sp - (( sum((D,T), periodScale(T)*( consObjA(D,T) * d_sp(S,D,T)
                - 0.5 * consObjB(D,T) * d_sp(S,D,T) * d_sp(S,D,T) ) )
                - sum((G,T), genVarInv(G) * g_sp(S,G,T) * periodScale(T) ) )  * Year
                - sum(G, genFixInv(G) * ig_sp(G))) =l=eta_sp(S)

*** Zonal First Kirchhoffs Law

  Equation ZFKL;
  ZFKL(S,Z,T)$probability(S)..

         sum(D$(consInZone(D,S) = Z.val), d_sp(S,D,T)) =e=
                     sum(G$(sum(N$(genAtNode(G) = N.val), NodeInZone(N,S)) = Z.val), g_sp(S,G,T) )
                   - sum(L$(sum(N$(lineStart(L) = N.val), NodeInZone(N,S)) = Z.val and lineInter(S,L) = 1), f_sp(S,L,T))
                   + sum(L$(sum(N$(lineEnd(L) = N.val),   NodeInZone(N,S)) = Z.val and lineInter(S,L) = 1), f_sp(S,L,T)) ;

*** Market Coupling Flow Restrictions

  Equation MCF1;
  MCF1(S,L,T)$(lineInter(S,L) = 1 and lineIsNew(L) = 0)..   f_sp(S,L,T) =l= lineUB(L);
  Equation MCF2;
  MCF2(S,L,T)$(lineInter(S,L) = 1 and lineIsNew(L) = 0).. - lineUB(L)=l= f_sp(S,L,T);
  Equation MCF3;
  MCF3(S,L,T)$(lineInter(S,L) = 1 and lineIsNew(L) = 1)..   f_sp(S,L,T) =l= lineB(L) * lineUB(L);
  Equation MCF4;
  MCF4(S,L,T)$(lineInter(S,L) = 1 and lineIsNew(L) = 1).. - lineB(L) * lineUB(L) =l= f_sp(S,L,T);

***Generation Capacity Limits

  Equation GCLSpot ;
  GCLSpot(S,G,T)..  g_sp(S,G,T) =l= avail(T,G) * ig_sp(G) ;


***--------------------------------------------------------------------------***
***                     NETWORK- and REDISPATCH LEVEL                        ***
***--------------------------------------------------------------------------***

  Equation costRed ;
  costRed..         costRedispatch =e= (1-weight_rd)*(sum(S$probability(S), probability(S)
                                         * ( sum((G,T), genVarInv(G) * ( g_rd(S,G,T) - SP_GEN_G(S,G,T) ) * periodScale(T) ) * YEAR
                                           + sum((B,T), buVarInv * gb_rd(S,B,T) * periodScale(T) ) * YEAR )))
                                           + sum(B, buFixInv * ib_rd(B) )
                                           + sum(L$(lineIsNew(L) = 1), lineFixInv(L) * lineB(L))
                                           + weight_rd*CVAR
                                           ;

*** Conditional Value at Risk Restrictions ***

  Equation CVARRed1;
  CVARRed1..
         (VAR_rd + (1/(1-percentile)*sum(S$probability(S), probability(S) * eta_rd(S)))) =l= CVAR
  
  Equation CVARRed2;
  CVARRed2(S)$probability(S)..
         (sum((G,T), genVarInv(G) * ( g_rd(S,G,T) - SP_GEN_G(S,G,T) ) * periodScale(T) ) * YEAR
                                           + sum((B,T), buVarInv * gb_rd(S,B,T) * periodScale(T) ) * YEAR ) 
                                           + sum(B, buFixInv * ib_rd(B) )
                                           + sum(L$(lineIsNew(L) = 1), lineFixInv(L) * lineB(L) ) - VAR_rd =l=eta_rd(S)

***First Kirchhoffs Law

  Equation FKL;
  FKL(S,N,T)$probability(S)..   sum(D$(consAtNode(D) = N.val), SP_DEM(S,D,T)) =e=
                 sum(G$(genAtNode(G)   = N.val), g_rd(S,G,T))
                 + sum(B$(buAtNode(B)  = N.val), gb_rd(S,B,T))
                 + sum(L$(lineEnd(L)   = N.val), f_rd(S,L,T))
                 - sum(L$(lineStart(L) = N.val), f_rd(S,L,T)) ;

***Second Kirchhoffs Law

  Equation SKL1;
  SKL1(S,L,T)$(lineIsNew(L) = 0).. f_rd(S,L,T) + lineGamma(L) * (sum(N$(lineStart(L) = N.val), angle(S,N,T)) - sum(N$(lineEnd(L) = N.val), angle(S,N,T))) =e= 0;
  Equation SKL2;
  SKL2(S,L,T)$(lineIsNew(L) = 1).. - M * (1 - lineB(L)) =l=  f_rd(S,L,T) + lineGamma(L) * (sum(N$(lineStart(L) = N.val), angle(S,N,T)) - sum(N$(lineEnd(L) = N.val), angle(S,N,T)));
  Equation SKL3;
  SKL3(S,L,T)$(lineIsNew(L) = 1).. f_rd(S,L,T) + lineGamma(L) * (sum(N$(N.val = lineStart(L)), angle(S,N,T)) - sum(N$(N.val = lineEnd(L)), angle(S,N,T))) =l= M * (1 - lineB(L));

***Voltage Phase Angle

  Equation VPA;
  VPA(S,N,T)$(N.val = 1).. angle(S,N,T) =e= 0;

***Trasmission Flow Limits

  Equation TFL1;
  TFL1(S,L,T)$(lineIsNew(L) = 0)..   f_rd(S,L,T) =l= lineUB(L);
  Equation TFL2;
  TFL2(S,L,T)$(lineIsNew(L) = 0).. - lineUB(L) =l= f_rd(S,L,T);
  Equation TFL3;
  TFL3(S,L,T)$(lineIsNew(L) = 1)..   f_rd(S,L,T) =l= lineB(L) * lineUB(L);
  Equation TFL4;
  TFL4(S,L,T)$(lineIsNew(L) = 1).. - lineB(L) * lineUB(L) =l= f_rd(S,L,T);

***Generation Capacity Limits (Redispatch Level)

  Equation GCLRed;
  GCLRed(S,G,T)$probability(S).. g_rd(S,G,T) =l= avail(T,G) * SP_CAP_G(G) ;

  Equation GCLBu;
  GCLBu(S,B,T)$probability(S)..  gb_rd(S,B,T) =l= ib_rd(B) ;

*** Fix Spot Market and Redispatch Quantities

  Equation fixDem;
  fixDem(S,D,T)$probability(S).. d_rd(S,D,T) =e= SP_DEM(S,D,T)
*- ls_rd(S,D,T)
  ;

  Equation fixGen;
  fixGen(S,G,T)$probability(S).. g_rd(S,G,T) =e= SP_GEN_G(S,G,T) + g_p_rd(S,G,T) - g_n_rd(S,G,T);

***--------------------------------------------------------------------------***
***                           DEFINITION MODELS                              ***
***--------------------------------------------------------------------------***

  Model Spotmarket
  / welfspot,
    CVARSpot,
    ZFKL,
    MCF1,
    MCF2,
    MCF3,
    MCF4,
    GCLSpot /;

  Model Redispatch
  / costRed,
    CVARRed1,
    CVARRed2,
    FKL,
    SKL1,
    SKL2,
    SKL3,
    VPA,
    TFL1,
    TFL2,
    TFL3,
    TFL4,
    GCLRed,
    GCLBu,
    fixDem,
    fixGen /;

***--------------------------------------------------------------------------***
***                           END MODEL SECTION                              ***
***--------------------------------------------------------------------------***
