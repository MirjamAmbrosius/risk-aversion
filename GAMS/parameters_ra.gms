  Parameters

*welfare
  wf_sp                  "spot market welfare"
*Welfare after redispatch and investment costs in scenario S
  wf_sc_all(S_co2,S_dloc,S_dlev,S_lcost)      "welfare in each scenario"
  wf_all                 "final welfare"
  
*generation and demand
  SP_DEM(D,T,S_co2,S_dloc,S_dlev,S_lcost)          "demand Spot"
  SP_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost)        "generation amount Spot"
  RD_GEN_G(G,T,S_co2,S_dloc,S_dlev,S_lcost)        "generation after Redispatch"
  RD_GEN_B(B,T,S_co2,S_dloc,S_dlev,S_lcost)        "generation of backup capacity b in scenario s and time t"
  lineB(L)
  SP_FLOW(L,T,S_co2,S_dloc,S_dlev,S_lcost)
  SP_CAP_L(L)
  SP_CAP_G(G)
  RD_CAP_B(B)
  Loop_welfare_all(Weight,LineInvest)          "total welfare"
  Loop_genInv(Weight,LineInvest, G)           "generation investment"
  Loop_buInv(Weight, LineInvest, B)            "investment in backup capacity"
  Loop_lineInv(Weight,LineInvest)              "cost of line investement"
  Loop_expPriceSpot(Weight,LineInvest)          "expected spot price"
  Loop_expConsSurpl(Weight, LineInvest)         "expected consumer surplus"
  total_generation(S_co2,S_dloc,S_dlev,S_lcost)               "total generation by private firms"
  total_bu_generation(S_co2,S_dloc,S_dlev,S_lcost)            "total bu generation"
  total_spot_generation(S_co2,S_dloc,S_dlev,S_lcost)          "total spot generation"
  priceSpot(D,T,S_co2,S_dloc,S_dlev,S_lcost)                  "spot price per node and time step"
  priceSpotAvg(S_co2,S_dloc,S_dlev,S_lcost)                   "weighted average spot price"
  expPriceSpot                                                "expected weighted average spot market price"
  consumerSurplus(D,S_co2,S_dloc,S_dlev,S_lcost)                "Consumer surplus in scenario s"
  totalConsSurpl(S_co2,S_dloc,S_dlev,S_lcost)                   "total consumer surplus in scenario s"
  expConsSurpl                                  "expected total consumer surplus"
  
* Risk Aversion
  VAR_RD_FIX        "value at risk redispatch (cutoff point for tale)"
  ETA_RD_FIX(S_co2,S_dloc,S_dlev,S_lcost)   "eta redispatch stage"
;