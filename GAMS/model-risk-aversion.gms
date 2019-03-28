***--------------------------------------------------------------------------***
***                           DEFINITION of VARIABLES                        ***
***--------------------------------------------------------------------------***

  Variables
* objective values
  welfareSpot            "welfare in spot market"
  costRedispatch         "cost at redispatch level"
* Spot Market
  f_sp(S_trans,S_co2,S_dloc,S_dlev,L,T) "trade flow in spot market"
  VAR_sp                 "value at risk spot market"
* Redispatch
  f_rd(S_trans,S_co2,S_dloc,S_dlev,L,T)            "transmission flows redispatch"
  angle(S_trans,S_co2,S_dloc,S_dlev,N,T)           "phase angle in redispatch model"
  VAR_rd                "value at risk redispatch"
  CVAR                   "conditional value at risk"
  ;

  Positive Variables
* Spot Market
  d_sp(S_trans,S_co2,S_dloc,S_dlev,D,T)            "demand spot market"
  g_sp(S_trans,S_co2,S_dloc,S_dlev,G,T)            "generation amount spot market"
  ig_sp(G)                                         "installed capacity of generators in spot market"
* Risk Aversion
  eta_sp(S_trans,S_co2,S_dloc,S_dlev)              "auxiliary variable to model CVAR in spot market stage"

* Redispatch
  d_rd(S_trans,S_co2,S_dloc,S_dlev,D,T)            "demand redispatcht"
  g_rd(S_trans,S_co2,S_dloc,S_dlev,G,T)            "generation amount redispatch"
  gb_rd(S_trans,S_co2,S_dloc,S_dlev,B,T)           "generation backup capacity redispatch"
  ib_rd(B)                                         "investment in backup capacity redispatch"
  g_n_rd(S_trans,S_co2,S_dloc,S_dlev,G,T)          "negative generation redispatch"
  g_p_rd(S_trans,S_co2,S_dloc,S_dlev,G,T)          "positive generation redispatch"
  ls_rd(S_trans,S_co2,S_dloc,S_dlev,D,T)           "load shedding redispatch"
* Risk Aversion
  eta_rd(S_trans,S_co2,S_dloc,S_dlev)              "auxiliary variable to model CVAR in redispatch stage"
  ;

*  Binary Variable
*  lineB(L)               "line is built?"
*  ;

***--------------------------------------------------------------------------***
***                          SPOT MARKET MODEL                               ***
***--------------------------------------------------------------------------***

*** Objective function
  Equation welfSpot;
  welfSpot..         welfareSpot =e=
  (1-weight_sp)*
                                        sum((S_trans,S_co2,S_dloc,S_dlev), prob_trans(S_trans)*prob_co2(S_co2)*prob_dloc(S_dloc)*prob_dlev(S_dlev)
                                      * ( sum((D,T), periodScale(T)*( consObjA(D,T,S_dlev,S_dloc) * d_sp(S_trans,S_co2,S_dloc,S_dlev,D,T)
                                      - 0.5 * consObjB(D,T,S_dlev,S_dloc) * d_sp(S_trans,S_co2,S_dloc,S_dlev,D,T) * d_sp(S_trans,S_co2,S_dloc,S_dlev,D,T) ) )
                                      - sum((G,T), genVarInv(G,S_co2) * g_sp(S_trans,S_co2,S_dloc,S_dlev,G,T) * periodScale(T) ) ) ) * Year
                                      - sum(G, genFixInv(G) * ig_sp(G) )
                                      + weight_sp*(VAR_sp - (1/(1-percentile)
                                      *sum((S_trans,S_co2,S_dloc,S_dlev), prob_trans(S_trans)*prob_co2(S_co2)*prob_dloc(S_dloc)*prob_dlev(S_dlev)
                                      * eta_sp(S_trans,S_co2,S_dloc,S_dlev))))
;                                     

*** Conditional Value at Risk Restrictions ***
  Equation CVARSpot;
  CVARSpot(S_trans,S_co2,S_dloc,S_dlev)..
        VAR_sp - (( sum((D,T), periodScale(T)*( consObjA(D,T,S_dlev,S_dloc) * d_sp(S_trans,S_co2,S_dloc,S_dlev,D,T)
                - 0.5 * consObjB(D,T,S_dlev,S_dloc) * d_sp(S_trans,S_co2,S_dloc,S_dlev,D,T) * d_sp(S_trans,S_co2,S_dloc,S_dlev,D,T) ) )
                - sum((G,T), genVarInv(G,S_co2) * g_sp(S_trans,S_co2,S_dloc,S_dlev,G,T) * periodScale(T) ) )  * Year
                - sum(G, genFixInv(G) * ig_sp(G))) =l=eta_sp(S_trans,S_co2,S_dloc,S_dlev)
                ;


*** Zonal First Kirchhoffs Law

  Equation ZFKL;
  ZFKL(S_trans,S_co2,S_dloc,S_dlev,Z,T)..
         sum(D$(consInZone(D) = Z.val), d_sp(S_trans,S_co2,S_dloc,S_dlev,D,T)) =e=
                     sum(G$(sum(N$(genAtNode(G) = N.val), NodeInZone(N)) = Z.val), g_sp(S_trans,S_co2,S_dloc,S_dlev,G,T) )
                   - sum(L$(sum(N$(lineStart(L) = N.val), NodeInZone(N)) = Z.val and lineInter(L) = 1), f_sp(S_trans,S_co2,S_dloc,S_dlev,L,T))
                   + sum(L$(sum(N$(lineEnd(L) = N.val),   NodeInZone(N)) = Z.val and lineInter(L) = 1), f_sp(S_trans,S_co2,S_dloc,S_dlev,L,T)) ;


*** Market Coupling Flow Restrictions

  Equation MCF1;
  MCF1(S_trans,S_co2,S_dloc,S_dlev,L,T)$(lineInter(L) = 1 and lineIsNew(L) = 0)..   f_sp(S_trans,S_co2,S_dloc,S_dlev,L,T) =l= lineUB(L);
  Equation MCF2;
  MCF2(S_trans,S_co2,S_dloc,S_dlev,L,T)$(lineInter(L) = 1 and lineIsNew(L) = 0).. - lineUB(L)=l= f_sp(S_trans,S_co2,S_dloc,S_dlev,L,T);
  Equation MCF3;
  MCF3(S_trans,S_co2,S_dloc,S_dlev,L,T)$(lineInter(L) = 1 and lineIsNew(L) = 1)..   f_sp(S_trans,S_co2,S_dloc,S_dlev,L,T) =l= lineB(L) * lineUB(L);
  Equation MCF4;
  MCF4(S_trans,S_co2,S_dloc,S_dlev,L,T)$(lineInter(L) = 1 and lineIsNew(L) = 1).. - lineB(L) * lineUB(L) =l= f_sp(S_trans,S_co2,S_dloc,S_dlev,L,T);



***Generation Capacity Limits

  Equation GCLSpot ;
  GCLSpot(S_trans,S_co2,S_dloc,S_dlev,G,T)..  g_sp(S_trans,S_co2,S_dloc,S_dlev,G,T) =l= avail(T,G) * ig_sp(G) ;


***--------------------------------------------------------------------------***
***                     NETWORK- and REDISPATCH LEVEL                        ***
***--------------------------------------------------------------------------***

  Equation costRed ;
  costRed..         costRedispatch =e= (1-weight_rd)
                                           *sum((S_trans,S_co2,S_dloc,S_dlev), prob_trans(S_trans)*prob_co2(S_co2)*prob_dloc(S_dloc)*prob_dlev(S_dlev)
                                           * ( sum((G,T), genVarInv(G,S_co2) * ( g_rd(S_trans,S_co2,S_dloc,S_dlev,G,T) - SP_GEN_G(S_trans,S_co2,S_dloc,S_dlev,G,T) )
                                           * periodScale(T) ) * YEAR
                                           + sum((B,T), buVarInv(S_co2) * gb_rd(S_trans,S_co2,S_dloc,S_dlev,B,T) * periodScale(T) ) * YEAR )
                                           + sum(L$(lineIsNew(L) = 1), lineFixInv(L,S_trans) * lineB(L)))
                                           + sum(B, buFixInv * ib_rd(B) )
                                           + weight_rd*CVAR
                                           ;
                                          

*** Conditional Value at Risk Restrictions ***

  Equation CVARRed1;
  CVARRed1..
         (VAR_rd + (1/(1-percentile)
         *sum((S_trans,S_co2,S_dloc,S_dlev), prob_trans(S_trans)*prob_co2(S_co2)*prob_dloc(S_dloc)*prob_dlev(S_dlev)
         * eta_rd(S_trans,S_co2,S_dloc,S_dlev)))) =l= CVAR
  
  Equation CVARRed2;
  CVARRed2(S_trans,S_co2,S_dloc,S_dlev)..
         (sum((G,T), genVarInv(G,S_co2) * ( g_rd(S_trans,S_co2,S_dloc,S_dlev,G,T) - SP_GEN_G(S_trans,S_co2,S_dloc,S_dlev,G,T) )
                                           * periodScale(T) ) * YEAR
                                           + sum((B,T), buVarInv(S_co2) * gb_rd(S_trans,S_co2,S_dloc,S_dlev,B,T) * periodScale(T) ) * YEAR ) 
                                           + sum(B, buFixInv * ib_rd(B) )
                                           + sum(L$(lineIsNew(L) = 1), lineFixInv(L,S_trans) * lineB(L) ) - VAR_rd
                                           =l=eta_rd(S_trans,S_co2,S_dloc,S_dlev)
***First Kirchhoffs Law

  Equation FKL;
  FKL(S_trans,S_co2,S_dloc,S_dlev,N,T)..   sum(D$(consAtNode(D) = N.val), SP_DEM(S_trans,S_co2,S_dloc,S_dlev,D,T)) =e=
                 sum(G$(genAtNode(G)   = N.val), g_rd(S_trans,S_co2,S_dloc,S_dlev,G,T))
                 + sum(B$(buAtNode(B)  = N.val), gb_rd(S_trans,S_co2,S_dloc,S_dlev,B,T))
                 + sum(L$(lineEnd(L)   = N.val), f_rd(S_trans,S_co2,S_dloc,S_dlev,L,T))
                 - sum(L$(lineStart(L) = N.val), f_rd(S_trans,S_co2,S_dloc,S_dlev,L,T)) ;
 
***Second Kirchhoffs Law

  Equation SKL1;
  SKL1(S_trans,S_co2,S_dloc,S_dlev,L,T)$(lineIsNew(L) = 0)..
            f_rd(S_trans,S_co2,S_dloc,S_dlev,L,T) + lineGamma(L) * (sum(N$(lineStart(L) = N.val), angle(S_trans,S_co2,S_dloc,S_dlev,N,T))
            - sum(N$(lineEnd(L) = N.val), angle(S_trans,S_co2,S_dloc,S_dlev,N,T))) =e= 0;
  Equation SKL2;
  SKL2(S_trans,S_co2,S_dloc,S_dlev,L,T)$(lineIsNew(L) = 1)..
            - M * (1 - lineB(L)) =l=  f_rd(S_trans,S_co2,S_dloc,S_dlev,L,T)
            + lineGamma(L) * (sum(N$(lineStart(L) = N.val), angle(S_trans,S_co2,S_dloc,S_dlev,N,T))
            - sum(N$(lineEnd(L) = N.val), angle(S_trans,S_co2,S_dloc,S_dlev,N,T)));
  Equation SKL3;
  SKL3(S_trans,S_co2,S_dloc,S_dlev,L,T)$(lineIsNew(L) = 1)..
            f_rd(S_trans,S_co2,S_dloc,S_dlev,L,T)
            + lineGamma(L) * (sum(N$(N.val = lineStart(L)), angle(S_trans,S_co2,S_dloc,S_dlev,N,T))
            - sum(N$(N.val= lineEnd(L)), angle(S_trans,S_co2,S_dloc,S_dlev,N,T))) =l= M * (1 - lineB(L));

***Voltage Phase Angle

  Equation VPA;
  VPA(S_trans,S_co2,S_dloc,S_dlev,N,T)$(N.val = 1).. angle(S_trans,S_co2,S_dloc,S_dlev,N,T) =e= 0;

***Trasmission Flow Limits

  Equation TFL1;
  TFL1(S_trans,S_co2,S_dloc,S_dlev,L,T)$(lineIsNew(L) = 0)..   f_rd(S_trans,S_co2,S_dloc,S_dlev,L,T) =l= lineUB(L);
  Equation TFL2;
  TFL2(S_trans,S_co2,S_dloc,S_dlev,L,T)$(lineIsNew(L) = 0).. - lineUB(L) =l= f_rd(S_trans,S_co2,S_dloc,S_dlev,L,T);
  Equation TFL3;
  TFL3(S_trans,S_co2,S_dloc,S_dlev,L,T)$(lineIsNew(L) = 1)..   f_rd(S_trans,S_co2,S_dloc,S_dlev,L,T) =l= lineB(L) * lineUB(L);
  Equation TFL4;
  TFL4(S_trans,S_co2,S_dloc,S_dlev,L,T)$(lineIsNew(L) = 1).. - lineB(L) * lineUB(L) =l= f_rd(S_trans,S_co2,S_dloc,S_dlev,L,T);

***Generation Capacity Limits (Redispatch Level)

  Equation GCLRed;
  GCLRed(S_trans,S_co2,S_dloc,S_dlev,G,T).. g_rd(S_trans,S_co2,S_dloc,S_dlev,G,T) =l= avail(T,G) * SP_CAP_G(G) ;

  Equation GCLBu;
  GCLBu(S_trans,S_co2,S_dloc,S_dlev,B,T)..  gb_rd(S_trans,S_co2,S_dloc,S_dlev,B,T) =l= ib_rd(B) ;

*** Fix Spot Market and Redispatch Quantities

  Equation fixDem;
  fixDem(S_trans,S_co2,S_dloc,S_dlev,D,T).. d_rd(S_trans,S_co2,S_dloc,S_dlev,D,T) =e= SP_DEM(S_trans,S_co2,S_dloc,S_dlev,D,T)
*- ls_rd(S,D,T)
  ;

  Equation fixGen;
  fixGen(S_trans,S_co2,S_dloc,S_dlev,G,T)..
                g_rd(S_trans,S_co2,S_dloc,S_dlev,G,T) =e= SP_GEN_G(S_trans,S_co2,S_dloc,S_dlev,G,T)
                + g_p_rd(S_trans,S_co2,S_dloc,S_dlev,G,T) - g_n_rd(S_trans,S_co2,S_dloc,S_dlev,G,T);

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
    GCLSpot
/;

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
