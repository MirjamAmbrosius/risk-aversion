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
$set no_of_zones two
*** Choose deterministic or uncertain model (deterministic, uncertain)
$set mode deterministic
*uncertain

Sets
         Weight                          / 1 * 2 /
         L "indices for power lines"     / 1 * 2 /
         LineInvest                      / 1 * 6 /
;

***--------------------------------------------------------------------------***
***             LOAD DATA AND SETUP FOR LOOP WITH PROBABILITIES              ***
***--------------------------------------------------------------------------***

$include input_ra.gms
$include parameters_ra.gms
$include model_ra.gms

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

 Loop(Weight,

  weight_sp = (Weight.val-1)*0.2;
  weight_rd = (Weight.val-1)*0.2;

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

  SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)   = d_sp.l(D,T,S_co2,S_dloc,S_dlev,S_lcost)          ;
  SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) = g_sp.l(G,T,S_co2,S_dloc,S_dlev,S_lcost)          ;
  SP_CAP_G(G)     = ig_sp.l(G)             ;
  SP_FLOW(L,T,S_co2,S_dloc,S_dlev,S_lcost)  = f_sp.l(L,T,S_co2,S_dloc,S_dlev,S_lcost)          ;
  SP_CAP_L(L)     = lineB(L) * lineUB(L)   ;


$ontext
  option clear= welfareSpot ;
  option clear= d_sp        ;
  option clear= g_sp        ;
  option clear= ig_sp       ;
  option clear= f_sp        ;
$offtext

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

*  SOLVE Redispatch USING LP MINIMIZE costRedispatch ;
  SOLVE Redispatch USING LP MAXIMIZE welfareRedispatch;

  RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) = g_rd.l(G,T,S_co2,S_dloc,S_dlev,S_lcost)  ;
  RD_CAP_B(B)     = ib_rd.l(B)     ;
  RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost) = gb_rd.l(B,T,S_co2,S_dloc,S_dlev,S_lcost) ;
  VAR_RD_FIX = VAR_rd.l;
  ETA_RD_FIX(S_co2,S_dloc,S_dlev,S_lcost) = eta_rd.l(S_co2,S_dloc,S_dlev,S_lcost);


$ontext
  option clear = costRedispatch ;
  option clear = f_rd   ;
  option clear = angle  ;
  option clear = d_rd   ;
  option clear = g_rd   ;
  option clear = gb_rd  ;
  option clear = ib_rd  ;
  option clear = g_n_rd ;
  option clear = g_p_rd ;
$offtext

***--------------------------------------------------------------------------***
***                        CALCULATION OF RESULTS                            ***
***--------------------------------------------------------------------------***


* Welfare after redispatch

  wf_all = (1-weight_rd)
            * (sum((S_co2,S_dloc,S_dlev,S_lcost),prob_co2(S_co2)*prob_dloc(S_dloc)*prob_dlev(S_dlev)*prob_lcost(S_lcost)
            * (( sum((D,T),(consObjA(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)
            - 0.5 * consObjB(D,T,S_dloc,S_dlev) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost)) * periodScale(T))
            - sum((G,T), genVarInv(G,S_co2) * RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))
            - sum((B,T), buVarInv(S_co2) * RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost) * periodScale(T))) * Year
            - sum(L$SP_CAP_L(L), lineFixInv(L,S_lcost))))
            - sum(G,genFixInv(G)* SP_CAP_G(G))
            - sum(B,buFixInv * RD_CAP_B(B)))
            + weight_rd
            * (VAR_RD_FIX - (1/(1-percentile)
            * sum((S_co2,S_dloc,S_dlev,S_lcost),prob_co2(S_co2)*prob_dloc(S_dloc)*prob_dlev(S_dlev)*prob_lcost(S_lcost)
            * ETA_RD_FIX(S_co2,S_dloc,S_dlev,S_lcost))));

  total_generation(S_co2,S_dloc,S_dlev,S_lcost) = sum((G,T), RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost));
  total_bu_generation(S_co2,S_dloc,S_dlev,S_lcost) = sum((B,T),RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost));
  total_spot_generation(S_co2,S_dloc,S_dlev,S_lcost) = sum((G,T),SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost));
  priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost)$(prob_co2(S_co2) and prob_dloc(S_dloc) and prob_dlev(S_dlev) and prob_lcost(S_lcost)) = (consObjA(D,T,S_dloc,S_dlev) - consObjB(D,T,S_dloc,S_dlev) * SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost));
  priceSpotAvg(S_co2,S_dloc,S_dlev,S_lcost)$(prob_co2(S_co2) and prob_dloc(S_dloc) and prob_dlev(S_dlev) and prob_lcost(S_lcost) and sum((D,T),SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)*periodScale(T))) = sum((D,T),priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost)*SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)*periodScale(T))/sum((D,T),SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)*periodScale(T));
  expPriceSpot = sum((S_co2,S_dloc,S_dlev,S_lcost),prob_co2(S_co2)*prob_dloc(S_dloc)*prob_dlev(S_dlev)*prob_lcost(S_lcost) * priceSpotAvg(S_co2,S_dloc,S_dlev,S_lcost));


$ontext
  consumerSurplus(D,S_co2,S_dloc,S_dlev,S_lcost) =(sum((T), (consObjA(D,T,S_dloc,S_dlev) * SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)
                                                - 0.5 * consObjB(D,T,S_dloc,S_dlev) * SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost) * SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost) )
                                                * periodScale(T) )
                                                - sum((T),(priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost) * SP_dem(D,T,S_co2,S_dloc,S_dlev,S_lcost))*periodScale(T)))*YEAR ;
  totalConsSurpl(S_co2,S_dloc,S_dlev,S_lcost) = sum(D,consumerSurplus(D,S_co2,S_dloc,S_dlev,S_lcost));
  expConsSurpl = sum((S_co2,S_dloc,S_dlev,S_lcost),prob_co2(S_co2)*prob_dloc(S_dloc)*prob_dlev(S_dlev)*prob_lcost(S_lcost) * totalConsSurpl(S_co2,S_dloc,S_dlev,S_lcost));
$offtext



***--------------------------------------------------------------------------***
***                       RESULTS to LOOP-PARAMETER                          ***
***--------------------------------------------------------------------------***

  Loop_welfare_all(Weight,LineInvest)           = wf_all        ;
  Loop_genInv(Weight,LineInvest, G)             = SP_CAP_G(G)   ;
  Loop_buInv(Weight, LineInvest, B)             = RD_CAP_B(B)  ;
  Loop_lineInv(Weight,LineInvest)               = sum(l, SP_CAP_L(L) ) ;
  Loop_expPriceSpot(Weight,LineInvest)          = expPriceSpot ;
*  Loop_expConsSurpl(Weight, LineInvest)         = expConsSurpl;

***--------------------------------------------------------------------------***
***                     CLEAR PARAMETERs OF MODEL RUN                        ***
***--------------------------------------------------------------------------***

* Clear Spot Resuls
  option clear= SP_DEM           ;
  option clear= SP_GEN_G         ;
  option clear= SP_CAP_G         ;
  option clear= SP_FLOW          ;
  option clear= SP_CAP_L         ;
  option clear= wf_all           ;

  );
);

***--------------------------------------------------------------------------***
***                            END OF MODEL LOOP                             ***
***--------------------------------------------------------------------------***

***--------------------------------------------------------------------------***
***                 OUTPUT WITH RESULTS FOR BEST LINE INVEST                 ***
***--------------------------------------------------------------------------***

  Parameter
  Results_genInv(Weight,G)
  Results_buInv(Weight,B)
  Results_lineInv(Weight)
  maxWelfare(Weight)
  Results_welfare_all(Weight)
  Results_totalInv(Weight)
  Results_expPriceSpot(Weight)
*  Results_expConsSurpl(Weight)
  ;


  Loop(LineInvest,

    maxWelfare(Weight)$(Loop_welfare_all(Weight,LineInvest)=smax(LineInvest2, Loop_welfare_all(Weight,LineInvest2) )) = LineInvest.val             ;

  );

  Results_genInv(Weight,G)                     = sum(LineInvest$(ord(LineInvest)=maxWelfare(Weight)), Loop_genInv(Weight,LineInvest, G) )         ;
  Results_buInv(Weight,B)                      = sum(LineInvest$(ord(LineInvest)=maxWelfare(Weight)), Loop_buInv(Weight,LineInvest, B) )         ;
  Results_lineInv(Weight)                      = sum(LineInvest$(ord(LineInvest)=maxWelfare(Weight)), Loop_lineInv(Weight,LineInvest) )           ;
  Results_welfare_all(Weight)                  = sum(LineInvest$(ord(LineInvest)=maxWelfare(Weight)), Loop_welfare_all(Weight,LineInvest) )        ;
  Results_totalInv(Weight)                     = sum(G,Results_genInv(Weight,G)) +  sum(B, Results_buInv(Weight,B));
  Results_expPriceSpot(Weight)                 = sum(LineInvest$(ord(LineInvest)=maxWelfare(Weight)), Loop_expPriceSpot(Weight,LineInvest) )        ;
*  Results_expConsSurpl(Weight)                 = sum(LineInvest$(ord(LineInvest)=maxWelfare(Weight)), Loop_expConsSurpl(Weight,LineInvest) )        ;


$include output_writer_ra.gms
