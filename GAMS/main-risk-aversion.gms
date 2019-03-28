
***--------------------------------------------------------------------------***
***                             GENERAL OPTIONS                              ***
***--------------------------------------------------------------------------***

option  optcr = 0.0001
        limrow = 0,
*equations listed per block */
        limcol = 0
*variables listed per block */
        solprint = off,
*solver's solution output printed */
        sysout = off,
*define standard solver
        QCP = Gurobi,
        LP = Gurobi
;

***--------------------------------------------------------------------------***
***            OPTIONS FOR DIFFERENT SCENARIOS & LINE INVESTMENT             ***
***--------------------------------------------------------------------------***

*** Choose number of zones (one, two)
$set no_of_zones one

Sets
         L "indices for power lines"     / 1 * 3 /
         LineInvest                      / 1 * 3 /
 ;

***--------------------------------------------------------------------------***
***             LOAD DATA AND SETUP FOR LOOP WITH PROBABILITIES              ***
***--------------------------------------------------------------------------***

  
$include input-risk-aversion.gms
$include parameters-risk-aversion.gms
$include model-risk-aversion.gms

*** read gurobi.opt
*  Spotmarket.OptFile = 1 ;
*  RedispatchWelfare.OptFile = 1 ;

*** time after which the solver terminates:
 Spotmarket.reslim = 10000;
 Redispatch.reslim = 36000;

 Alias(LineInvest,LineInvest2) ;

***--------------------------------------------------------------------------***
***           START MODEL LOOP FOR PROBABILITIES AND LINE INVEST             ***
***--------------------------------------------------------------------------***

Loop(LineInvest,

   lineB(L) = 1$(LineInvest.val=L.val);

***--------------------------------------------------------------------------***
***                        SOLVE SPOT MARKET MODEL                           ***
***--------------------------------------------------------------------------***

  option clear= welfareSpot ;
  option clear= d_sp        ;
  option clear= g_sp        ;
  option clear= ig_sp       ;
  option clear= f_sp        ;

  SOLVE Spotmarket USING QCP MAXIMIZE welfareSpot ;

  SP_DEM(S_trans,S_co2,S_dloc,S_dlev,D,T)   =  d_sp.l(S_trans,S_co2,S_dloc,S_dlev,D,T);
  SP_GEN_G(S_trans,S_co2,S_dloc,S_dlev,G,T) = g_sp.l(S_trans,S_co2,S_dloc,S_dlev,G,T)          ;
  SP_CAP_G(G)     = ig_sp.l(G)                                                                 ;
  SP_FLOW(S_trans,S_co2,S_dloc,S_dlev,L,T)  = f_sp.l(S_trans,S_co2,S_dloc,S_dlev,L,T)          ;
  SP_CAP_L(L)     = lineB(L) * lineUB(L)   ;


***--------------------------------------------------------------------------***
***                         SOLVE REDISPATCH MODEL                           ***
***--------------------------------------------------------------------------***


  option clear = costRedispatch ;
  option clear = f_rd   ;
  option clear = angle  ;
  option clear = d_rd   ;
  option clear = g_rd   ;
  option clear = gb_rd  ;
  option clear = ib_rd  ;
  option clear = g_n_rd ;
  option clear = g_p_rd ;

  SOLVE Redispatch USING LP MINIMIZE costRedispatch ;

  RD_GEN_G(S_trans,S_co2,S_dloc,S_dlev,G,T) = g_rd.l(S_trans,S_co2,S_dloc,S_dlev,G,T)  ;
  RD_CAP_B(B)     = ib_rd.l(B)     ;
  RD_GEN_B(S_trans,S_co2,S_dloc,S_dlev,B,T) = gb_rd.l(S_trans,S_co2,S_dloc,S_dlev,B,T) ;

***--------------------------------------------------------------------------***
***                       CALCULATION OF RESULTS                             ***
***--------------------------------------------------------------------------***

  

*Welfare after redispatch and investment costs in scenario S
  wf_sc_all(S_trans,S_co2,S_dloc,S_dlev)  = (sum((D,T), (consObjA(D,T,S_dlev,S_dloc) * SP_dem(S_trans,S_co2,S_dloc,S_dlev,D,T)
                                   - 0.5 * consObjB(D,T,S_dlev,S_dloc) * SP_dem(S_trans,S_co2,S_dloc,S_dlev,D,T) * SP_dem(S_trans,S_co2,S_dloc,S_dlev,D,T) ) * periodScale(T) )
                                   - sum((G,T), genVarInv(G,S_co2) * RD_GEN_G(S_trans,S_co2,S_dloc,S_dlev,G,T) * periodScale(T) )
                                   - sum((B,T), buVarInv(S_co2) * RD_GEN_B(S_trans,S_co2,S_dloc,S_dlev,B,T) * periodScale(T) ) ) * Year
                                   - sum(G, genFixInv(G)  * SP_CAP_G(G) )
                                   - sum(B, buFixInv      * RD_CAP_B(B) )
                                   - sum(L$SP_CAP_L(L), lineFixInv(L,S_trans) ) ;
 
*Welfare after redispatch for both scenarios
  wf_all                         = sum((S_trans,S_co2,S_dloc,S_dlev), prob_trans(S_trans)*prob_co2(S_co2)*prob_dloc(S_dloc)*prob_dlev(S_dlev)
                                    * wf_sc_all(S_trans,S_co2,S_dloc,S_dlev) ) ;

  Loop_welfare_all(LineInvest)         = wf_all        ;
  Loop_welfare_all_sc(LineInvest,S_trans,S_co2,S_dloc,S_dlev)     = wf_sc_all(S_trans,S_co2,S_dloc,S_dlev)  ;
  Loop_genInv(LineInvest, G)           = SP_CAP_G(G)   ;
  Loop_lineInv(LineInvest)             = sum(L, SP_CAP_L(L) ) ;

)  

***--------------------------------------------------------------------------***
***                       RESULTS to LOOP-PARAMETER                          ***
***--------------------------------------------------------------------------***

  Parameter
  maxWelfare
  Results_welfare_all_sc(S_trans,S_co2,S_dloc,S_dlev)
  Results_welfare_all
  Results_genInv(G)
  Results_lineInv;
 


  Loop(LineInvest,

    maxWelfare$(Loop_welfare_all(LineInvest)=smax(LineInvest2, Loop_welfare_all(LineInvest2) )) = LineInvest.val             ;

  );

  Results_welfare_all_sc(S_trans,S_co2,S_dloc,S_dlev)    = sum(LineInvest$(ord(LineInvest)=maxWelfare), Loop_welfare_all_sc(LineInvest,S_trans,S_co2,S_dloc,S_dlev) )   ;
  Results_welfare_all  = sum(LineInvest$(ord(LineInvest)=maxWelfare), Loop_welfare_all(LineInvest) )        ;
  Results_genInv(G)    = sum(LineInvest$(ord(LineInvest)=maxWelfare), Loop_genInv(LineInvest, G) )         ;
  Results_lineInv      = sum(LineInvest$(ord(LineInvest)=maxWelfare), Loop_lineInv(LineInvest) )           ;

