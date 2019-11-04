***--------------------------------------------------------------------------***
***                           DEFINITION of VARIABLES                        ***
***--------------------------------------------------------------------------***

  Variables
* Objective Values
  welfareSpot                            "welfare in spot market"
  welfareSpot_rn                         "welfare in spot market with risk-neutral post-run model"
  costRedispatch                         "cost at redispatch level"
  welfareRedispatch                      "welfare at redispatch level"
* Spot Market
  f_sp(L,T,S_co2,S_dloc,S_dlev,S_lcost)  "trade flow in spot market"
* Redispatch
  f_rd(L,T,S_co2,S_dloc,S_dlev,S_lcost)  "transmission flows redispatch"
  angle(N,T,S_co2,S_dloc,S_dlev,S_lcost) "phase angle in redispatch model"
* Risk Aversion
  VAR_sp                                 "value at risk spot market"
  VAR_rd                                 "value at risk redispatch"
  CVAR                                   "conditional value at risk"
  ;

  Positive Variables
* Spot Market
  d_sp(D,T,S_co2,S_dloc,S_dlev,S_lcost)  "demand spot market"
  g_sp(G,T,S_co2,S_dloc,S_dlev,S_lcost)  "generation amount spot market"
  ig_sp(G)                               "installed capacity of generators in spot market"

* Redispatch
  d_rd(D,T,S_co2,S_dloc,S_dlev,S_lcost)  "demand redispatcht"
  g_rd(G,T,S_co2, S_dloc,S_dlev,S_lcost) "generation amount redispatch"
  gb_rd(B,T,S_co2, S_dloc,S_dlev,S_lcost)"generation backup capacity redispatch"
  ib_rd(B)                               "investment in backup capacity redispatch"
  g_n_rd(G,T,S_co2,S_dloc,S_dlev,S_lcost)"negative generation redispatch"
  g_p_rd(G,T,S_co2,S_dloc,S_dlev,S_lcost)"positive generation redispatch"
  ls_rd(D,T,S_co2,S_dloc,S_dlev,S_lcost) "load shedding redispatch"

* Risk Aversion
  eta_sp(S_co2,S_dloc,S_dlev,S_lcost)    "auxiliary variable to model CVAR in spot market stage"
  eta_rd(S_co2,S_dloc,S_dlev,S_lcost)    "auxiliary variable to model CVAR in redispatch stage"
  ;

***--------------------------------------------------------------------------***
***                          SPOT MARKET MODEL                               ***
***--------------------------------------------------------------------------***

*** Objective function
  Equation welfSpot;
  welfSpot..         welfareSpot =e=   (1-weight_sp)*(
                                        sum((S_co2,S_dloc,S_dlev,S_lcost), prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
                                        *((sum((D,T), periodScale(T)*(consObjA(D,T,S_dloc,S_dlev) * d_sp(D,T,S_co2,S_dloc,S_dlev,S_lcost)
                                        - 0.5 * consObjB(D,T,S_dloc,S_dlev) * d_sp(D,T,S_co2,S_dloc,S_dlev,S_lcost) * d_sp(D,T,s_co2,S_dloc,S_dlev,S_lcost) ))
                                        - sum((G,T), genVarInv(G,S_co2) * g_sp(G,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T) ) )) * Year)
                                        - sum(G, genFixInv(G) * ig_sp(G) )
                                        )
                                        + weight_sp
                                        *(VAR_sp - (1/(1-percentile)
                                        *sum((S_co2,S_dloc,S_dlev,S_lcost), prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
                                        *eta_sp(S_co2,S_dloc,S_dlev,S_lcost))))
                                        ;

*** CVAR Restrictions
  Equation CVARSpot;
  CVARSpot(S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost)..
                                        VAR_sp
                                        - ((sum((D,T), periodScale(T)*(consObjA(D,T,S_dloc,S_dlev) * d_sp(D,T,S_co2,S_dloc,S_dlev,S_lcost)
                                        - 0.5 * consObjB(D,T,S_dloc,S_dlev) * d_sp(D,T,S_co2,S_dloc,S_dlev,S_lcost) * d_sp(D,T,s_co2,S_dloc,S_dlev,S_lcost)))
                                        - sum((G,T), genVarInv(G,S_co2) * g_sp(G,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T)) )* Year
                                        - sum(G, genFixInv(G) * ig_sp(G))) =l= eta_sp(S_co2,S_dloc,S_dlev,S_lcost)
                                        ;


*** Zonal First Kirchhoffs Law
  Equation ZFKL;
  ZFKL(Z,T,S_co2,S_dloc,S_dlev,S_lcost)$ prob_scen(S_co2,S_dloc,S_dlev,S_lcost)..
         sum(D$(ConsInZone(D) = Z.val), d_sp(D,T,S_co2,S_dloc,S_dlev,S_lcost)) =e=
                     sum(G$(sum(N$(genAtNode(G) = N.val), NodeInZone(N)) = Z.val), g_sp(G,T,S_co2,S_dloc,S_dlev,S_lcost))
                   - sum(L$(sum(N$(lineStart(L) = N.val), NodeInZone(N)) = Z.val and lineInter(L) = 1), f_sp(L,T,S_co2,S_dloc,S_dlev,S_lcost))
                   + sum(L$(sum(N$(lineEnd(L) = N.val),   NodeInZone(N)) = Z.val and lineInter(L) = 1), f_sp(L,T,S_co2,S_dloc,S_dlev,S_lcost)) ;

*** Market Coupling Flow Restrictions

  Equation MCF1;
  MCF1(L,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (lineInter(L) = 1 and lineIsNew(L) = 0))..

                                 f_sp(L,T,S_co2,S_dloc,S_dlev,S_lcost) =l= lineUB(L);
  Equation MCF2;
  MCF2(L,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (lineInter(L) = 1 and lineIsNew(L) = 0))..

                                 - lineUB(L)=l= f_sp(L,T,S_co2,S_dloc,S_dlev,S_lcost);
  Equation MCF3;
  MCF3(L,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (lineInter(L) = 1 and lineIsNew(L) = 1))..

                                  f_sp(L,T,S_co2,S_dloc,S_dlev,S_lcost) =l= lineB(L) * lineUB(L);
  Equation MCF4;
  MCF4(L,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (lineInter(L) = 1 and lineIsNew(L) = 1))..

                                 - lineB(L) * lineUB(L) =l= f_sp(L,T,S_co2,S_dloc,S_dlev,S_lcost);

***Generation Capacity Limits
  Equation GCLSpot ;
  GCLSpot(G,T,S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost)..  g_sp(G,T,S_co2,S_dloc,S_dlev,S_lcost) =l= avail(T,G) * ig_sp(G) ;



*** Objective function (RISKNEUTRAL)
  Equation welfSpot_rn;
  welfSpot_rn..         welfareSpot_rn =e=   sum((S_co2,S_dloc,S_dlev,S_lcost), prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
                                        *((sum((D,T), periodScale(T)*(consObjA(D,T,S_dloc,S_dlev) * d_sp(D,T,S_co2,S_dloc,S_dlev,S_lcost)
                                        - 0.5 * consObjB(D,T,S_dloc,S_dlev) * d_sp(D,T,S_co2,S_dloc,S_dlev,S_lcost) * d_sp(D,T,s_co2,S_dloc,S_dlev,S_lcost) ))
                                        - sum((G,T), genVarInv(G,S_co2) * g_sp(G,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T) ) )) * Year)
                                        - sum(G, genFixInv(G) * SP_CAP_G(G) )
                                        ;


***Generation Capacity Limits (RISKNEUTRAL)
  Equation GCLSpot_rn ;
  GCLSpot_rn(G,T,S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost)..  g_sp(G,T,S_co2,S_dloc,S_dlev,S_lcost) =l= avail(T,G) * SP_CAP_G(G)  ;


***--------------------------------------------------------------------------***
***                     NETWORK- and REDISPATCH LEVEL                        ***
***--------------------------------------------------------------------------***

  Equation welfRed;
  welfRed..    welfareRedispatch =e= (1-weight_rd)
            * (sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
            * (( sum((D,T),(consObjA(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)
            - 0.5 * consObjB(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)) * periodScale(T))
            - sum((G,T), genVarInv(G,S_co2) * g_rd(G,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))
            - sum((B,T), buVarInv(S_co2) * gb_rd(B,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))) * Year
            - sum(L$(lineIsNew(L) = 1), lineFixInv(L,S_lcost) * lineB(L))))
            - sum(G,genFixInv(G)* SP_CAP_G(G))
            - sum(B,buFixInv * ib_rd(B)))
            + weight_rd
            * (VAR_rd - (1/(1-percentile)
            * sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
            * eta_rd(S_co2,S_dloc,S_dlev,S_lcost))))
            ;


  Equation costRed ;
  costRed..         costRedispatch =e= (1-weight_rd)*(
                                           sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
                                           *(sum((G,T), GenVarInv(G,S_co2) * ( g_rd(G,T,S_co2,S_dloc,S_dlev,S_lcost) - SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost)) * periodScale(T) ) * YEAR
                                           + sum((B,T), buVarInv(S_co2) * gb_rd(B,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T) ) * YEAR
                                           + sum(L$(lineIsNew(L) = 1), lineFixInv(L,S_lcost) * lineB(L))))
                                           + sum(B, buFixInv * ib_rd(B)))
                                           + weight_rd*CVAR
                                           ;

*** CVAR Restrictions

  Equation CVARRed;
  CVARRed(S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost)..
            VAR_rd-
             ((sum((D,T),(consObjA(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)
            - 0.5 * consObjB(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)) * periodScale(T))
            - sum((G,T), genVarInv(G,S_co2) * g_rd(G,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))
            - sum((B,T), buVarInv(S_co2) * gb_rd(B,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))) * Year
            - sum(L$(lineIsNew(L) = 1), lineFixInv(L,S_lcost) * lineB(L))
            - sum(G,genFixInv(G)* SP_CAP_G(G))
            - sum(B,buFixInv * ib_rd(B))) =l= eta_rd(S_co2,S_dloc,S_dlev,S_lcost)


  Equation CVARRed1;
  CVARRed1..
         (VAR_rd + (1/(1-percentile)
         *sum((S_co2,S_dloc,S_dlev,S_lcost),prob_scen(S_co2,S_dloc,S_dlev,S_lcost)
         * eta_rd(S_co2,S_dloc,S_dlev,S_lcost)))) =l= CVAR

  Equation CVARRed2;
  CVARRed2(S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost)..
         (sum((G,T), genVarInv(G,S_co2) * ( g_rd(G,T,S_co2,S_dloc,S_dlev,S_lcost) - SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) )
                                           * periodScale(T)) * YEAR
                                           + sum((B,T), buVarInv(S_co2) * gb_rd(B,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))*YEAR )
                                           + sum(B, buFixInv * ib_rd(B))
                                           + sum(L$(lineIsNew(L) = 1), lineFixInv(L,S_lcost) * lineB(L) ) - VAR_rd
                                           =l= eta_rd(S_co2,S_dloc,S_dlev,S_lcost)


***First Kirchhoffs Law

  Equation FKL;
  FKL(N,T,S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost)..
                 sum(D$(consAtNode(D) = N.val), SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)) =e=
                         sum(G$(genAtNode(G)   = N.val), g_rd(G,T,S_co2,S_dloc,S_dlev,S_lcost))
                         + sum(B$(buAtNode(B)  = N.val), gb_rd(B,T,S_co2,S_dloc,S_dlev,S_lcost))
                         + sum(L$(lineEnd(L)   = N.val), f_rd(L,T,S_co2,S_dloc,S_dlev,S_lcost))
                         - sum(L$(lineStart(L) = N.val), f_rd(L,T,S_co2,S_dloc,S_dlev,S_lcost)) ;

***Second Kirchhoffs Law

  Equation SKL1;
  SKL1(L,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (lineIsNew(L) = 0))..

                         f_rd(L,T,S_co2,S_dloc,S_dlev,S_lcost) + lineGamma(L) * (sum(N$(lineStart(L) = N.val), angle(N,T,S_co2,S_dloc,S_dlev,S_lcost)) - sum(N$(lineEnd(L) = N.val), angle(N,T,S_co2,S_dloc,S_dlev,S_lcost))) =e= 0;
  Equation SKL2;
  SKL2(L,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (lineIsNew(L) = 1))..

                         - M * (1 - lineB(L)) =l=  f_rd(L,T,S_co2,S_dloc,S_dlev,S_lcost) + lineGamma(L) * (sum(N$(lineStart(L) = N.val), angle(N,T,S_co2,S_dloc,S_dlev,S_lcost)) - sum(N$(lineEnd(L) = N.val), angle(N,T,S_co2,S_dloc,S_dlev,S_lcost)));
  Equation SKL3;
  SKL3(L,T,S_co2,S_dloc,S_dlev,S_lcost,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (lineIsNew(L) = 1))..

                         f_rd(L,T,S_co2,S_dloc,S_dlev,S_lcost) + lineGamma(L) * (sum(N$(N.val = lineStart(L)), angle(N,T,S_co2,S_dloc,S_dlev,S_lcost)) - sum(N$(N.val = lineEnd(L)), angle(N,T,S_co2,S_dloc,S_dlev,S_lcost))) =l= M * (1 - lineB(L));

***Voltage Phase Angle

  Equation VPA;
  VPA(N,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (N.val = 1)).. angle(N,T,S_co2,S_dloc,S_dlev,S_lcost) =e= 0;

***Trasmission Flow Limits

  Equation TFL1;
  TFL1(L,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (lineIsNew(L) = 0))..   f_rd(L,T,S_co2,S_dloc,S_dlev,S_lcost) =l= lineUB(L);
  Equation TFL2;
  TFL2(L,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (lineIsNew(L) = 0)).. - lineUB(L) =l= f_rd(L,T,S_co2,S_dloc,S_dlev,S_lcost);
  Equation TFL3;
  TFL3(L,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (lineIsNew(L) = 1))..   f_rd(L,T,S_co2,S_dloc,S_dlev,S_lcost) =l= lineB(L) * lineUB(L);
  Equation TFL4;
  TFL4(L,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_scen(S_co2,S_dloc,S_dlev,S_lcost) and (lineIsNew(L) = 1)).. - lineB(L) * lineUB(L) =l= f_rd(L,T,S_co2,S_dloc,S_dlev,S_lcost);

***Generation Capacity Limits (Redispatch Level)

  Equation GCLRed;
  GCLRed(G,T,S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost).. g_rd(G,T,S_co2,S_dloc,S_dlev,S_lcost) =l= avail(T,G) * SP_CAP_G(G) ;

  Equation GCLBu;
  GCLBu(B,T,S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost)..  gb_rd(B,T,S_co2,S_dloc,S_dlev,S_lcost) =l= ib_rd(B) ;

*** Fix Spot Market and Redispatch Quantities

  Equation fixDem;
  fixDem(D,T,S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost).. d_rd(D,T,S_co2,S_dloc,S_dlev,S_lcost) =e= SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)
  ;

  Equation fixGen;
  fixGen(G,T,S_co2,S_dloc,S_dlev,S_lcost)$prob_scen(S_co2,S_dloc,S_dlev,S_lcost).. g_rd(G,T,S_co2,S_dloc,S_dlev,S_lcost) =e= SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) + g_p_rd(G,T,S_co2,S_dloc,S_dlev,S_lcost) - g_n_rd(G,T,S_co2,S_dloc,S_dlev,S_lcost);

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

  Model Spotmarket_Riskneutral
  / welfspot_rn,
    ZFKL,
    MCF1,
    MCF2,
    MCF3,
    MCF4,
    GCLSpot_rn /;

  Model Redispatch
  / welfRed,
    CVARRed,
*   costRed,
*    CVARRed1,
*    CVARRed2,
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
