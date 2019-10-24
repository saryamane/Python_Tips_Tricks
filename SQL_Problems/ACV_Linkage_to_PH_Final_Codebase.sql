-- TODO #: Recreate the new RAW Orders with the newly discovered filter conditions as listed below. Persisting the ORD_ITM_ID and Quote_Line_Id.

-- Let us form the Orders part with the new filters that have been identified.
-- New Filters added: Contract_Type <> 'Re-seller'
-- Order_Type not in ('Overage', 'Standard')
-- Order create date Year >= 2016 [Count drops to 3.1M, I don't think we can ignore the accounts created before that.]
-- Removing the date filter from the Orders.

drop table PI_DM.RAW_ORDERS_ACV_LINK;

create table PI_DM.RAW_ORDERS_ACV_LINK as
    (SELECT MAIN.ORD_ITM_ID
          , MAIN.ACCOUNT_ID
          , MAIN.PRICEBOOK_NAME
          , MAIN.FINAL_SKU
          , MAIN.CONTRACT_NUMBER
          , MAIN.CONTRACT_TYPE
          , MAIN.CONTRACT_ACTVTD_TS_GMT
          , MAIN.CONTRACT_ACTVTD_TS_PST
          , MAIN.CONTRACT_START_DATE
          , MAIN.CONTRACT_END_DATE
          , MAIN.ORDER_START_DATE
          , MAIN.ORDER_END_DATE
          , MAIN.ORDER_TYPE
          , MAIN.ORDER_SUB_TYPE
          , MAIN.CURRENCY_CODE
          , MAIN.BILLING_FREQUENCY
          , MAIN.CONTRACT_STATE
          , MAIN.ORDER_CRTD_YEAR
          , MAIN.ORDER_CRTD_MTH_ID
          , MAIN.ORDER_CRTD_QTR_ID
          , MAIN.ORDER_CREATED_TS_PST
          , MAIN.ORDER_CREATE_DT
          , MAIN.ORDER_TYPE_POS_NEG
          , CASE
                WHEN GMV_PROD.GMV_SKU IS NOT NULL THEN
                        MAIN.QUANTITY * (MAIN.TOTAL_PRICE_USD / MAIN.TOTAL_PRICE) * 10000 * 12 /
                        ceil(months_between(MAIN.ORDER_END_DATE, MAIN.ORDER_START_DATE))
                ELSE MAIN.QUANTITY
            END                                                                 AS QUANTITY
          , CASE
                WHEN GMV_PROD.GMV_SKU IS NOT NULL THEN MAIN.TOTAL_PRICE * 12 /
                                                       ceil(months_between(MAIN.ORDER_END_DATE, MAIN.ORDER_START_DATE)) -- 12/Term
                ELSE MAIN.TOTAL_PRICE
            END                                                                 AS TOTAL_PRICE
          , CASE
                WHEN GMV_PROD.GMV_SKU IS NOT NULL THEN MAIN.TOTAL_PRICE_USD * 12 /
                                                       ceil(months_between(MAIN.ORDER_END_DATE, MAIN.ORDER_START_DATE)) -- 12/Term
                ELSE MAIN.TOTAL_PRICE_USD
            END                                                                 AS TOTAL_PRICE_USD
          , MAIN.LIST_PRICE
          , MAIN.LIST_PRICE_USD
          , CASE
                WHEN GMV_PROD.GMV_SKU IS NOT NULL THEN MAIN.TOTAL_PRICE * 12 /
                                                       ceil(months_between(MAIN.ORDER_END_DATE, MAIN.ORDER_START_DATE)) -- 12/Term
                ELSE MAIN.TOTAL_ANNUAL_PRICE_LOCAL
            END                                                                 AS TOTAL_ANNUAL_PRICE_LOCAL
          , CASE
                WHEN GMV_PROD.GMV_SKU IS NOT NULL THEN MAIN.TOTAL_PRICE_USD * 12 /
                                                       ceil(months_between(MAIN.ORDER_END_DATE, MAIN.ORDER_START_DATE)) -- 12/Term
                ELSE MAIN.TOTAL_ANNUAL_PRICE_USD
            END                                                                 AS TOTAL_ANNUAL_PRICE_USD
          , CASE WHEN RCT.RUL_CONTRACT_NUMBER IS NOT NULL THEN 'Y' ELSE 'N' END AS IS_RUL_FLAG
          , MAIN.RELATED_QUOTE_LINE_ID
          , MAIN.ORDER_ITEM_ETL_INS_TS
          , MAIN.ORDER_ITEM_ETL_UPD_TS
     FROM (
         SELECT FOI.ORD_ITM_ID
              , DA.ACCT_ID                                                                       AS ACCOUNT_ID
              , DPE.PRCBK_NM                                                                     AS PRICEBOOK_NAME
              , COALESCE(DP.RPLC_SKU_CD, DP.SKU_CD)                                              AS FINAL_SKU
              , DP.PROD_NM                                                                       AS PRODUCT_NAME
              , DC.CNTR_NUM                                                                      AS CONTRACT_NUMBER
              , DC.CNTR_TYP_CD                                                                   AS CONTRACT_TYPE
              , DC.CNTR_ACTVTD_DT                                                                AS CONTRACT_ACTVTD_TS_GMT
              , Cast(From_tz(Cast(To_date(To_char(DC.CNTR_ACTVTD_DT, 'MM/DD/YYYY HH:MI:SS PM'),
                                          'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                     'US/Pacific' AS DATE)                                                       AS CONTRACT_ACTVTD_TS_PST
              , DC.CNTR_STRT_DT                                                                  AS CONTRACT_START_DATE
              , DC.CNTR_END_DT                                                                   AS CONTRACT_END_DATE
              , DOR.ORD_STRT_DT                                                                  AS ORDER_START_DATE
              , CASE
                    WHEN FOI.QTY < 0 AND FOI.ORD_ITM_END_DT IS NOT NULL THEN FOI.ORD_ITM_END_DT
                    ELSE DOR.ORD_END_DT END                                                      AS ORDER_END_DATE
              , FOI.CRNCY_ISO_CD                                                                 AS CURRENCY_CODE
              , CASE WHEN DPE.BILL_FREQ = 0 THEN 12 ELSE DPE.BILL_FREQ END                       AS BILLING_FREQUENCY
              , CASE
                    WHEN DC.RVN_REGN_NM <> 'UNITED STATES of America' THEN 'No State Value'
                    WHEN Length(Trim(Upper(DC.SHPPNG_ST_NM))) = 0 THEN 'No State Value'
                    WHEN Length(Upper(DC.SHPPNG_ST_NM)) <> 2 THEN 'No State Value'
                    WHEN DC.SHPPNG_ST_NM IS NULL THEN 'No State Value'
                    ELSE Upper(DC.SHPPNG_ST_NM)
             END                                                                                 AS CONTRACT_STATE
              , Extract(YEAR FROM
                        Cast(From_tz(Cast(To_date(To_char(DOR.CRTD_DT, 'MM/DD/YYYY HH:MI:SS PM'),
                                                  'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                             'US/Pacific' AS DATE))                                              AS ORDER_CRTD_YEAR
              , ((Extract(YEAR FROM Cast(From_tz(Cast(To_date(To_char(DOR.CRTD_DT, 'MM/DD/YYYY HH:MI:SS PM'),
                                                              'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                 'GMT') AT TIME ZONE 'US/Pacific' AS DATE)) - 1900) *
                 12 + (Extract(MONTH FROM Cast(
                     From_tz(Cast(To_date(To_char(DOR.CRTD_DT, 'MM/DD/YYYY HH:MI:SS PM'),
                                          'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                     'US/Pacific' AS DATE))))                                                    AS ORDER_CRTD_MTH_ID
              , CASE
                    WHEN (Extract(MONTH FROM
                                  Cast(From_tz(Cast(To_date(To_char(DOR.CRTD_DT, 'MM/DD/YYYY HH:MI:SS PM'),
                                                            'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                                       'US/Pacific' AS DATE))) = 1 THEN
                                (Extract(YEAR FROM
                                         Cast(From_tz(Cast(To_date(To_char(DOR.CRTD_DT, 'MM/DD/YYYY HH:MI:SS PM'),
                                                                   'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                      'GMT') AT TIME ZONE 'US/Pacific' AS DATE)) -
                                 1900) * 4 + 4
                    ELSE (Extract(YEAR FROM Cast(From_tz(Cast(To_date(To_char(DOR.CRTD_DT, 'MM/DD/YYYY HH:MI:SS PM'),
                                                                      'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                         'GMT') AT TIME ZONE 'US/Pacific' AS DATE)) -
                          1900 + 1) * 4 + (Ceil((Extract(MONTH FROM Cast(From_tz(Cast(To_date(
                            To_char(DOR.CRTD_DT, 'MM/DD/YYYY HH:MI:SS PM'), 'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                                                 'GMT') AT TIME ZONE
                                                                         'US/Pacific' AS DATE)) - 1) / 3))
             END                                                                                 AS ORDER_CRTD_QTR_ID
              , Cast(From_tz(Cast(To_date(To_char(DOR.CRTD_DT, 'MM/DD/YYYY HH:MI:SS PM'),
                                          'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                     'US/Pacific' AS DATE)                                                       AS ORDER_CREATED_TS_PST
              , DOR.CRTD_DT                                                                      AS ORDER_CREATE_DT
              , DOR.ORD_TYP                                                                      AS ORDER_TYPE
              , DOR.ORD_SUB_TYP                                                                  AS ORDER_SUB_TYPE
              , CASE WHEN FOI.QTY >= 0 THEN 'POSITIVE' ELSE 'NEGATIVE' END                       AS ORDER_TYPE_POS_NEG
              , FOI.QTY                                                                          AS QUANTITY
              , FOI.QTY * FOI.UNIT_PRC_AMT                                                       AS TOTAL_PRICE
              , (FOI.QTY * (FOI.UNIT_PRC_AMT * DER.CONV_RT))                                     AS TOTAL_PRICE_USD
              , FOI.LIST_PRC_AMT                                                                 AS LIST_PRICE
              , FOI.LIST_PRC_AMT * DER.CONV_RT                                                   AS LIST_PRICE_USD
              , CASE
                    WHEN FOI.BILL_FREQ = 0 THEN (FOI.QTY * FOI.UNIT_PRC_AMT)
                    ELSE ((FOI.QTY * FOI.UNIT_PRC_AMT) / FOI.BILL_FREQ) * 12 END                 AS TOTAL_ANNUAL_PRICE_LOCAL
              , CASE
                    WHEN FOI.BILL_FREQ = 0 THEN (FOI.QTY * (FOI.UNIT_PRC_AMT * DER.CONV_RT))
                    ELSE ((FOI.QTY * (FOI.UNIT_PRC_AMT * DER.CONV_RT)) / FOI.BILL_FREQ) * 12 END AS TOTAL_ANNUAL_PRICE_USD
              , FOI.relatedquoteline__C                                                          as RELATED_QUOTE_LINE_ID
              , FOI.AUDIT_ETL_JOB_INS_TS                                                         AS ORDER_ITEM_ETL_INS_TS
              , FOI.AUDIT_ETL_JOB_INS_TS                                                         AS ORDER_ITEM_ETL_UPD_TS
         FROM DM.FACT_ORDER_ITEM FOI
            , DM.DIM_ORDER DOR
            , DM.DIM_ACCOUNT DA
            , DM.DIM_PRODUCT DP
            , DM.DIM_PRICEBOOK_ENTRY DPE
            , DM.DIM_CONTRACT DC
            , DM.DIM_EXCHANGE_RATE DER
            , (
             SELECT DISTINCT A.RPLC_SKU_CD AS REPLACED_SKU
                           , B.PROD_NM     AS REPLACED_PRODUCT_NAME
             FROM DM.DIM_PRODUCT A
                      LEFT OUTER JOIN DM.DIM_PRODUCT B ON A.RPLC_SKU_CD = B.SKU_CD (+)
             WHERE A.RPLC_SKU_CD IS NOT NULL
               AND A.DEL_FLG = 'N'
               AND B.DEL_FLG = 'N'
               AND B.ACT_FLG = 'Y'
         ) REPLACE

         WHERE FOI.DEL_FLG = 'N'
           AND FOI.UNIT_PRC_AMT <> 0
           AND FOI.DIM_CNTR_KY = DC.DIM_CNTR_KY(+)
           AND FOI.DIM_ACCT_KY = DA.DIM_ACCT_KY(+)
           AND FOI.DIM_PROD_KY = DP.DIM_PROD_KY(+)
           AND FOI.DIM_PRCBK_ENT_KY = DPE.DIM_PRCBK_ENT_KY(+)
           AND FOI.CRNCY_ISO_CD = DER.FM_CRNCY_CD
           AND DER.TO_CRNCY_CD = 'USD'
           AND DER.CONV_TYP = 'Corporate'
           AND Trunc(Cast(From_tz(Cast(To_date(To_char(DOR.CRTD_DT, 'MM/DD/YYYY HH:MI:SS PM'),
                                               'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                          'US/Pacific' AS DATE)) = DER.CONV_DT
           AND DC.CNTR_TYP_CD not in ('Courtesy Contract', 'Re-seller')
           AND FOI.DIM_ORD_KY = DOR.DIM_ORD_KY(+)
           AND DA.ACCT_NM NOT LIKE '%Sanity%Test%'
           AND DOR.ORD_TYP NOT IN ('Courtesy Renew', 'Courtesy', 'Trial', 'Draft', 'Overage', 'Standard')
           AND DOR.STAT_TXT NOT IN ('Draft')
           AND DP.RPLC_SKU_CD = REPLACE.REPLACED_SKU (+)
           AND (FOI.QTY >= 0 OR
                (FOI.QTY < 0 AND Nvl(DOR.ORD_SUB_TYP, 'Null') NOT IN ('Account Transfer', 'License Transfer')))
     ) MAIN
        , PI_DM.RUL_CONTRACTS_TBR RCT
        , (SELECT DISTINCT nvl(DP.RPLC_SKU_CD, DP.SKU_CD) AS GMV_SKU
           FROM DM.DIM_PRODUCT DP
           WHERE DP.PROD_NM LIKE 'B2C%GMV%'
             AND DP.PROD_NM NOT LIKE '%Overages%'
             AND DP.DEL_FLG = 'N') GMV_PROD
     WHERE MAIN.CONTRACT_NUMBER = RCT.RUL_CONTRACT_NUMBER (+)
       AND MAIN.FINAL_SKU = RCT.SKU_NUM (+)
       AND MAIN.FINAL_SKU = GMV_PROD.GMV_SKU (+)
       -- AND MAIN.ORDER_CRTD_YEAR >= 2016
    );


-- TODO #: Then work on the creation of the Opportunity ACV object, which brings in the Quote Line Id.

drop table PI_DM.RAW_OPPORTUNITIES_NEW;

create table PI_DM.RAW_OPPORTUNITIES_NEW as
(select fol.QT_LIN_NUM,
        fol.OPTY_LN_ID,
        do.OPTY_ID_15,
        do.OPTY_NM,
        do.OPTY_TYP,
        do.DRVD_OPTY_TYP,
        fol.OPTY_KY,
        fol.ACCT_KY,
        fol.PRCBK_ENT_KY,
        fol.CRNCY_CD,
        fol.SVC_DT,
        do.CLSD_DT,
        fol.QT_LIN_END_DT,
        fol.BILL_FREQ,
        fol.QTY,
        Round(fol.UNIT_PRC * DER.CONV_RT,2) as Unit_Price_USD,
        Round(fol.LIST_PRC * DER.CONV_RT,2) as List_Price_USD,
        CASE
           WHEN fol.BILL_FREQ = 0 THEN ROUND((fol.QTY * fol.UNIT_PRC),2)
           ELSE ROUND(((fol.QTY * fol.UNIT_PRC) / fol.BILL_FREQ) * 12,2) END AS TOTAL_ANNUAL_PRICE_LOCAL,
        CASE
           WHEN fol.BILL_FREQ = 0 THEN ROUND((fol.QTY * (fol.UNIT_PRC * DER.CONV_RT)),2)
           ELSE ROUND(((fol.QTY * (fol.UNIT_PRC * DER.CONV_RT)) / fol.BILL_FREQ) * 12,2) END AS TOTAL_ANNUAL_PRICE_USD,
        fol.TOT_LIST_PRC as TOT_LIST_PRC_LOCAL,
        ROUND(fol.TOT_LIST_PRC * DER.CONV_RT,2) as TOT_LIST_PRC_USD,
        fol.TOT_PRC as TOT_PRC_LOCAL,
        ROUND(fol.TOT_PRC * DER.CONV_RT,2) as TOT_PRC_USD,
        fol.DISC_PCT,
        fol.PRCBK_ENT_ID,
        fol.PROD_ID,
        fol.BKNG_TRTMNT
 from DM.FACT_OPPORTUNITY_LINE fol,
      DM.DIM_OPPORTUNITY do,
      DM.DIM_EXCHANGE_RATE DER
 where fol.OPTY_KY = do.DIM_OPTY_KY
   and fol.QT_LIN_NUM is not null --> If you remove this, there will be Closed Oppty's without quote line id.
   and fol.del_flg = 'N'
   and fol.curr_rec_flg = 'Y'
   and do.forcst_cat_nm <> 'Omitted'
   and do.won_flg = 'Y'
   and do.opty_stg_nm in ('08 -  Closed', '08 - Closed', '05 Closed')
   and UPPER(do.OPTY_NM) NOT like '%SELA%'
   and do.SFQUOTE_QUOTE_EXIST_FLG = 'Y' -- This linkage identifies the true QL and ignores the shell monthly opptys
   -- The QL below are some erroneous duplicates seen in the dataset for a couple of accounts. Filtering them out.
   and fol.QT_LIN_NUM not in ('aJQ0M000002OD5xWAG', 'aJQ0M000001DTfjWAG', 'aJQ0M000002OD5yWAG', 'aJQ0M000002OD5zWAG')
   AND fol.CRNCY_CD = DER.FM_CRNCY_CD
           AND DER.TO_CRNCY_CD = 'USD'
           AND DER.CONV_TYP = 'Corporate'
           AND Trunc(Cast(From_tz(Cast(To_date(To_char(do.CLSD_DT, 'MM/DD/YYYY HH:MI:SS PM'),
                                               'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                          'US/Pacific' AS DATE)) = DER.CONV_DT
);


-- # TODO: Join the Orders + Oppty's and Swap dataset to create a categorization field (Order_Item_Category_Type) on the Final_RAW_Orders_ACV_New dataset.

drop table PI_DM.FINAL_RAW_ORDERS_ACV_NEW;

create table PI_DM.FINAL_RAW_ORDERS_ACV_NEW as
select main.*,
opty.QT_LIN_NUM,
opty.OPTY_LN_ID,
opty.OPTY_ID_15,
opty.OPTY_NM,
opty.OPTY_TYP,
opty.OPTY_ACCT_KY,
opty.OPTY_CLSD_DT,
opty.OPTY_QTY,
opty.OPTY_UNIT_PRC_USD,
opty.OPTY_TOT_LIST_PRC_USD,
opty.OPTY_TOT_ANNUAL_PRICE_USD,
opty.OPTY_DISC_PCT,
opty.OPTY_BILL_FREQ,
case when opty.QT_LIN_NUM is not null then 'New/Add-on'
    else 'Other' end as Order_Item_Category_Type
from RAW_ORDERS_ACV_LINK main
LEFT OUTER JOIN (select distinct QT_LIN_NUM, OPTY_LN_ID, OPTY_ID_15, OPTY_NM,
                                 OPTY_TYP,
                                 ACCT_KY as OPTY_ACCT_KY,
                                 CLSD_DT as OPTY_CLSD_DT,
                                 QTY as OPTY_QTY,
                                 BILL_FREQ as OPTY_BILL_FREQ,
                                 Unit_Price_USD as OPTY_UNIT_PRC_USD,
                                 TOT_LIST_PRC_USD as OPTY_TOT_LIST_PRC_USD,
                                 TOTAL_ANNUAL_PRICE_USD as OPTY_TOT_ANNUAL_PRICE_USD,
                                 DISC_PCT as OPTY_DISC_PCT
                from RAW_OPPORTUNITIES_NEW) opty
ON main.RELATED_QUOTE_LINE_ID = opty.QT_LIN_NUM;


-- # TODO: Compute the Exit lines of the Order with ACV information. Persisting the new category flag all the way down.

drop table pi_dm.exit_calc_raw_acv;

rename exit_calc_raw_acv to exit_calc_raw_acv_102119;

CREATE TABLE pi_dm.exit_calc_raw_acv AS
SELECT
    account_id,
    pricebook_name,
    final_sku,
    contract_number,
    contract_type,
    ORDER_ITEM_CATEGORY_TYPE,
    contract_actvtd_ts_gmt,
    contract_actvtd_ts_pst,
    contract_start_date,
    contract_end_date,
    order_end_date,
    currency_code,
    billing_frequency,
    contract_state,
    is_rul_flag,
    Extract(YEAR FROM Cast(From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                      'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                      'US/Pacific' AS DATE)) as order_crtd_year,
    ((Extract(YEAR FROM Cast(From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                                                              'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                 'GMT') AT TIME ZONE 'US/Pacific' AS DATE)) - 1900) *
                 12 + (Extract(MONTH FROM Cast(
                     From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                                          'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                     'US/Pacific' AS DATE))))                                                    AS order_crtd_mth_id,
    CASE
                    WHEN (Extract(MONTH FROM
                                  Cast(From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                                                            'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                                       'US/Pacific' AS DATE))) = 1 THEN
                                (Extract(YEAR FROM
                                         Cast(From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                                                                   'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                      'GMT') AT TIME ZONE 'US/Pacific' AS DATE)) -
                                 1900) * 4 + 4
                    ELSE (Extract(YEAR FROM Cast(From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                                                                      'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                         'GMT') AT TIME ZONE 'US/Pacific' AS DATE)) -
                          1900 + 1) * 4 + (Ceil((Extract(MONTH FROM Cast(From_tz(Cast(To_date(
                            To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'), 'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                                                 'GMT') AT TIME ZONE
                                                                         'US/Pacific' AS DATE)) - 1) / 3))
             END                                                                                 AS ORDER_CRTD_QTR_ID,
    order_create_date,
    order_type_pos_neg,
    max_order_end_date,
    opty_bill_freq,
    SUM(quantity)                 AS exit_quantity,
    SUM(total_price)              AS exit_total_price,
    SUM(total_price_usd)          AS exit_total_price_usd,
    SUM(total_annual_price_local) AS exit_total_annual_price_local,
    SUM(total_annual_price_usd)   AS exit_total_annual_price_usd,
    SUM(OPTY_QTY) AS opty_qty,
    SUM(Opty_Unit_Prc_USD) as Opty_Unit_price_USD,
    SUM(OPTY_TOT_ANNUAL_PRICE_USD) as Opty_Tot_Annual_Price_USD,
    CASE
      WHEN SUM(quantity) <> 0 THEN SUM(total_price) / SUM(quantity)
      ELSE 0
    END                           AS Exit_ASP
    FROM
    (
      SELECT
        main.*,
        NVL(main.OPTY_CLSD_DT, main.order_created_ts_pst) AS Order_Create_Date,
        lef.max_order_end_date
        FROM
          pi_dm.FINAL_RAW_ORDERS_ACV_NEW main
          left join
          (
            SELECT
              c.final_sku,
              c.contract_number,
              c.order_create_date,
              c.order_type_pos_neg,
              c.pricebook_name,
              c.billing_frequency,
              Max(c.order_end_date) AS max_order_end_date
              FROM
                (
                  SELECT
                    a.*,
                    Trunc(NVL(a.OPTY_CLSD_DT, a.order_created_ts_pst)) AS
                    ORDER_CREATE_DATE
                 FROM
                  pi_dm.FINAL_RAW_ORDERS_ACV_NEW a
                ) c
                GROUP BY
                  c.final_sku,
                  c.contract_number,
                  c.order_create_date,
                  c.order_type_pos_neg,
                  c.pricebook_name,
                  c.billing_frequency
              ) lef
            ON
              main.final_sku = lef.final_sku
              AND main.contract_number = lef.contract_number
              AND main.pricebook_name = lef.pricebook_name
              AND main.billing_frequency = lef.billing_frequency
              AND Trunc(NVL(main.OPTY_CLSD_DT, main.order_created_ts_pst)) = lef.order_create_date
              and main.order_type_pos_neg = lef.order_type_pos_neg
      )
    WHERE
      max_order_end_date = order_end_date
    GROUP BY
      account_id,
      pricebook_name,
      final_sku,
      contract_number,
      contract_type,
      contract_actvtd_ts_gmt,
      contract_actvtd_ts_pst,
      contract_start_date,
      contract_end_date,
      order_end_date,
      currency_code,
      billing_frequency,
      contract_state,
      is_rul_flag,
      Extract(YEAR FROM Cast(From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                      'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                      'US/Pacific' AS DATE)),
      ((Extract(YEAR FROM Cast(From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                                                              'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                 'GMT') AT TIME ZONE 'US/Pacific' AS DATE)) - 1900) *
                 12 + (Extract(MONTH FROM Cast(
                     From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                                          'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                     'US/Pacific' AS DATE)))),
      CASE
                    WHEN (Extract(MONTH FROM
                                  Cast(From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                                                            'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP), 'GMT') AT TIME ZONE
                                       'US/Pacific' AS DATE))) = 1 THEN
                                (Extract(YEAR FROM
                                         Cast(From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                                                                   'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                      'GMT') AT TIME ZONE 'US/Pacific' AS DATE)) -
                                 1900) * 4 + 4
                    ELSE (Extract(YEAR FROM Cast(From_tz(Cast(To_date(To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'),
                                                                      'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                         'GMT') AT TIME ZONE 'US/Pacific' AS DATE)) -
                          1900 + 1) * 4 + (Ceil((Extract(MONTH FROM Cast(From_tz(Cast(To_date(
                            To_char(order_create_date, 'MM/DD/YYYY HH:MI:SS PM'), 'MM/DD/YYYY HH:MI:SS PM') AS TIMESTAMP),
                                                                                 'GMT') AT TIME ZONE
                                                                         'US/Pacific' AS DATE)) - 1) / 3))
             END,
      order_create_date,
      order_type_pos_neg,
      max_order_end_date,
      ORDER_ITEM_CATEGORY_TYPE,
      OPTY_BILL_FREQ
;


-- # TODO: Perform pre-snapping operation on the Quarterly level.

DROP TABLE pi_dm.quarterly_exit_amount_calc_acv;

rename quarterly_exit_amount_calc_acv to qtr_exit_amt_calc_acv_102119;

CREATE TABLE quarterly_exit_amount_calc_acv AS
  (SELECT
  account_id,
  pricebook_name          AS pricebook_name,
  final_sku                     AS product_sku,
  contract_number,
  contract_type,
  contract_actvtd_ts_gmt,
  contract_actvtd_ts_pst,
  contract_start_date,
  contract_end_date,
  ORDER_ITEM_CATEGORY_TYPE,
  Q_exit_quantity               AS exit_quantity,
  Q_exit_total_price            AS exit_total_price,
  Q_exit_total_price_usd        AS exit_total_price_usd,
  Q_exit_total_annl_price_local AS exit_total_annual_price_local,
  Q_exit_total_annual_price_usd AS exit_total_annual_price_usd,
  Q_exit_asp                    AS Exit_ASP,
  Q_exit_asp_usd                AS Exit_ASP_USD,
  Q_opty_qty                    AS Oppty_Qty,
  Q_Opty_Unit_price_USD       AS Opty_Unit_Price_USD,
  Q_Opty_Tot_Annual_Price_USD AS Opty_Tot_Annual_Price_USD,
  order_end_date,
  currency_code,
  billing_frequency,
  contract_state,
  is_rul_flag,
  order_crtd_qtr_id,
  order_crtd_year,
  order_create_date,
  max_order_end_date
   FROM   (SELECT a.*,
                  qtr.q_exit_quantity,
                  qtr.Q_exit_total_price,
                  qtr.Q_exit_total_price_usd,
                  qtr.Q_exit_total_annl_price_local,
                  qtr.Q_exit_total_annual_price_usd,
                  qtr.Q_Exit_ASP,
                  qtr.Q_exit_asp_usd,
                  qtr.Q_opty_qty,
                  qtr.Q_Opty_Unit_price_USD,
                  qtr.Q_Opty_Tot_Annual_Price_USD
           FROM   exit_calc_raw_acv a,
                  (SELECT order_crtd_qtr_id,
                          contract_number,
                          final_sku,
                          billing_frequency,
                          pricebook_name,
                          order_end_date,
                          SUM(exit_quantity)                 AS Q_exit_quantity,
                          SUM(exit_total_price)              AS
                          Q_exit_total_price
                          ,
                          SUM(exit_total_price_usd)
                          AS Q_exit_total_price_usd,
                          SUM(exit_total_annual_price_local) AS
                          Q_exit_total_annl_price_local,
                          SUM(exit_total_annual_price_usd)   AS
                          Q_exit_total_annual_price_usd,
                          CASE
                            WHEN SUM(exit_quantity) <> 0 THEN
                            SUM(exit_total_price) / SUM(exit_quantity)
                            ELSE 0
                          END                                AS Q_Exit_ASP,
                          CASE
                            WHEN SUM(exit_quantity) <> 0 THEN
                            SUM(exit_total_price_usd) / SUM(exit_quantity)
                            ELSE 0
                          END                                AS Q_Exit_ASP_USD,
                          SUM(OPTY_QTY) AS Q_opty_qty,
                          SUM(Opty_Unit_price_USD) as Q_Opty_Unit_price_USD,
                          SUM(Opty_Tot_Annual_Price_USD) as Q_Opty_Tot_Annual_Price_USD,
                          Max(order_create_date) AS Q_max_order_ctdt
                   FROM   exit_calc_raw_acv
                   GROUP  BY order_crtd_qtr_id,
                             contract_number,
                             final_sku,
                             billing_frequency,
                             pricebook_name,
                             order_end_date) qtr
           WHERE  a.order_crtd_qtr_id = qtr.order_crtd_qtr_id (+)
                  AND a.contract_number = qtr.contract_number (+)
                  AND a.final_sku = qtr.final_sku (+)
                  AND a.pricebook_name = qtr.pricebook_name (+)
                  AND a.billing_frequency = qtr.billing_frequency (+)
                  AND a.order_end_date = qtr.order_end_date (+)
                  AND a.order_create_date = qtr.q_max_order_ctdt (+))
   WHERE  q_exit_asp IS NOT NULL);


  -- # TODO: Perform the snapping operation along the Acct + Oppty to generate the RIV and ACV information on Quarterly level.

DROP TABLE pi_dm.qtr_snap_exit_amounts_acv;

rename qtr_snap_exit_amounts_acv to qtr_snap_exit_amt_acv_102119;

CREATE TABLE pi_dm.qtr_snap_exit_amounts_acv AS
  (SELECT dat.*,
          main.*
   FROM   (SELECT a.*,
                  CASE
                    WHEN To_char(a.order_create_date, 'MM') BETWEEN 2 AND 4 THEN
                    Concat(
                    To_char(a.order_create_date, 'YYYY') + 1, '1')
                    WHEN To_char(a.order_create_date, 'MM') BETWEEN 5 AND 7 THEN
                    Concat(
                    To_char(a.order_create_date, 'YYYY') + 1, '2')
                    WHEN To_char(a.order_create_date, 'MM') BETWEEN 8 AND 10 THEN
                    Concat(
                    To_char(a.order_create_date, 'YYYY') + 1, '3')
                    WHEN To_char(a.order_create_date, 'MM') IN ( 11, 12 ) THEN
                    Concat(
                    To_char(a.order_create_date, 'YYYY') + 1,
                    '4')
                    WHEN To_char(a.order_create_date, 'MM') IN ( 1 ) THEN Concat(
                    To_char(a.order_create_date, 'YYYY'), '4')
                  END                                             AS
                  order_create_qtr,
                  CASE
                    WHEN To_char(a.order_end_date, 'MM') BETWEEN 2 AND 4 THEN
                    Concat(
                    To_char(a.order_end_date, 'YYYY') + 1,
                    '1')
                    WHEN To_char(a.order_end_date, 'MM') BETWEEN 5 AND 7 THEN
                    Concat(
                    To_char(a.order_end_date, 'YYYY') + 1,
                    '2')
                    WHEN To_char(a.order_end_date, 'MM') BETWEEN 8 AND 10 THEN
                    Concat(
                    To_char(a.order_end_date, 'YYYY') + 1, '3')
                    WHEN To_char(a.order_end_date, 'MM') IN ( 11, 12 ) THEN
                    Concat
                    (
                    To_char(a.order_end_date, 'YYYY') + 1,
                    '4')
                    WHEN To_char(a.order_end_date, 'MM') IN ( 1 ) THEN Concat(
                    To_char(a.order_end_date, 'YYYY'), '4')
                  END                                             AS
                  order_end_qtr
           FROM   quarterly_exit_amount_calc_acv a) main,
          (SELECT ROWNUM AS qtr_join_id,
                  fiscal_yr_qtr_num
           FROM   (SELECT DISTINCT To_number(Concat(fiscal_yr_num,
                                             fiscal_qtr_of_yr_num))
                                   AS
                                           fiscal_yr_qtr_num
                   FROM   dm.dim_date
                   ORDER  BY 1)) dat
   WHERE  main.order_create_qtr <= dat.fiscal_yr_qtr_num
          AND main.order_end_qtr > dat.fiscal_yr_qtr_num);


  -- # TODO: Perform the RIV and other ACV specific calculations from the Snapped Quarterly Table.


DROP TABLE final_quarterly_asp_acv;

CREATE TABLE final_quarterly_asp_acv AS
select
--account_id, product_sku, pricebook_name, is_rul_flag,
--billing_frequency, currency_code, Order_Item_Category_Type,
 --fiscal_yr_qtr_nm,qtr_id,exit_quantity,delta_exit_quantity,Qtr_Snap_Sum_Footprint,Delta_Footprint,
final.*,

  CASE WHEN Exit_Quantity < 0 then 0
      WHEN (Qtr_Snap_Sum_Footprint - exit_quantity) = Delta_Footprint AND PArtition_count = 1
          THEN 0
      WHEN (Qtr_Snap_Sum_Footprint - exit_quantity) = Delta_Footprint AND PArtition_count > 1
          THEN least(Delta_Footprint,delta_exit_quantity)
      WHEN (Delta_Footprint = exit_quantity) THEN exit_quantity
      WHEN (Qtr_Snap_Sum_Footprint - exit_quantity) <> Delta_Footprint and Partition_Count = 1
          THEN Delta_Footprint
      WHEN (Qtr_Snap_Sum_Footprint - exit_quantity) < 0 and Partition_Count = 2
          THEN Delta_Footprint
 ELSE LEAST(Delta_Footprint, decode(sign(delta_exit_quantity),-1,0,delta_exit_quantity))
      END delta_exit_quantity_new,

--exit_total_price_usd,delta_exit_total_price_usd,Ftprint_ext_total_prc_usd,dlt_Ftprint_ext_total_prc_usd,

  CASE WHEN exit_total_price_usd < 0 then 0
      WHEN (Ftprint_ext_total_prc_usd - exit_total_price_usd) = dlt_Ftprint_ext_total_prc_usd AND PArtition_count = 1
          THEN 0
      WHEN (Ftprint_ext_total_prc_usd - exit_total_price_usd) = dlt_Ftprint_ext_total_prc_usd AND PArtition_count > 1
          THEN least(dlt_Ftprint_ext_total_prc_usd,delta_exit_total_price_usd)
      WHEN (dlt_Ftprint_ext_total_prc_usd = exit_total_price_usd) THEN exit_total_price_usd
      WHEN (Ftprint_ext_total_prc_usd - exit_total_price_usd) <> dlt_Ftprint_ext_total_prc_usd and Partition_Count = 1
          THEN dlt_Ftprint_ext_total_prc_usd
      WHEN (Ftprint_ext_total_prc_usd - exit_total_price_usd) < 0 and Partition_Count = 2
          THEN dlt_Ftprint_ext_total_prc_usd
 ELSE LEAST(dlt_Ftprint_ext_total_prc_usd, decode(sign(delta_exit_total_price_usd),-1,0,delta_exit_total_price_usd))
      END dlt_ext_tot_price_usd_new,

  CASE WHEN exit_total_price < 0 then 0
      WHEN (Ftprint_ext_total_prc - exit_total_price) = dlt_Ftprint_ext_total_prc AND PArtition_count = 1
          THEN 0
      WHEN (Ftprint_ext_total_prc - exit_total_price) = dlt_Ftprint_ext_total_prc AND PArtition_count > 1
          THEN least(dlt_Ftprint_ext_total_prc,delta_exit_total_price)
      WHEN (dlt_Ftprint_ext_total_prc = exit_total_price) THEN exit_total_price
      WHEN (Ftprint_ext_total_prc - exit_total_price) <> dlt_Ftprint_ext_total_prc and Partition_Count = 1
          THEN dlt_Ftprint_ext_total_prc
      WHEN (Ftprint_ext_total_prc - exit_total_price) < 0 and Partition_Count = 2
          THEN dlt_Ftprint_ext_total_prc
 ELSE LEAST(dlt_Ftprint_ext_total_prc, decode(sign(delta_exit_total_price),-1,0,delta_exit_total_price))
      END dlt_ext_tot_price_new   ,


        CASE WHEN ACV_Opty_Unit_Price_USD < 0 then 0
      WHEN (Ftprint_ACV_Unit_Prc_USD - ACV_Opty_Unit_Price_USD) = dlt_Ftprint_ACV_Unit_Prc_USD AND PArtition_count = 1
          THEN 0
      WHEN (Ftprint_ACV_Unit_Prc_USD - ACV_Opty_Unit_Price_USD) = dlt_Ftprint_ACV_Unit_Prc_USD AND PArtition_count > 1
          THEN least(dlt_Ftprint_ACV_Unit_Prc_USD,delta_opty_acv_unt_prc_USD)
      WHEN (dlt_Ftprint_ACV_Unit_Prc_USD = ACV_Opty_Unit_Price_USD) THEN ACV_Opty_Unit_Price_USD
      WHEN (Ftprint_ACV_Unit_Prc_USD - ACV_Opty_Unit_Price_USD) <> dlt_Ftprint_ACV_Unit_Prc_USD and Partition_Count = 1
          THEN dlt_Ftprint_ACV_Unit_Prc_USD
      WHEN (Ftprint_ACV_Unit_Prc_USD - ACV_Opty_Unit_Price_USD) < 0 and Partition_Count = 2
          THEN dlt_Ftprint_ACV_Unit_Prc_USD
 ELSE LEAST(dlt_Ftprint_ACV_Unit_Prc_USD, decode(sign(delta_opty_acv_unt_prc_USD),-1,0,delta_opty_acv_unt_prc_USD))
      END dlt_opty_acv_unt_prc_usd_new  ,

        CASE WHEN Total_ACV_Amount_USD < 0 then 0
      WHEN (Ftprint_Total_ACV_Amount_USD - Total_ACV_Amount_USD) = dlt_Ftprint_Tot_ACV_Amt_USD AND PArtition_count = 1
          THEN 0
      WHEN (Ftprint_Total_ACV_Amount_USD - Total_ACV_Amount_USD) = dlt_Ftprint_Tot_ACV_Amt_USD AND PArtition_count > 1
          THEN least(dlt_Ftprint_Tot_ACV_Amt_USD,delta_Total_ACV_Amount_USD)
      WHEN (dlt_Ftprint_Tot_ACV_Amt_USD = Total_ACV_Amount_USD) THEN Total_ACV_Amount_USD
      WHEN (Ftprint_Total_ACV_Amount_USD - Total_ACV_Amount_USD) <> dlt_Ftprint_Tot_ACV_Amt_USD and Partition_Count = 1
          THEN dlt_Ftprint_Tot_ACV_Amt_USD
      WHEN (Ftprint_Total_ACV_Amount_USD - Total_ACV_Amount_USD) < 0 and Partition_Count = 2
          THEN dlt_Ftprint_Tot_ACV_Amt_USD
 ELSE LEAST(dlt_Ftprint_Tot_ACV_Amt_USD, decode(sign(delta_Total_ACV_Amount_USD),-1,0,delta_Total_ACV_Amount_USD))
      END dlt_Total_ACV_Amount_usd_new

from
(
select
main.*,
case when PArtition_count = 2 and Order_Item_Category_Type = 'Other' then
          decode(sign(Qtr_Snap_Sum_Footprint), -1, 0, Qtr_Snap_Sum_Footprint) - decode(sign(Lag(Qtr_Snap_Sum_Footprint, 2, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)), -1, 0, Lag(Qtr_Snap_Sum_Footprint, 2, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type))
else
decode(sign(Qtr_Snap_Sum_Footprint), -1, 0, Qtr_Snap_Sum_Footprint) - decode(sign(Lag(Qtr_Snap_Sum_Footprint, 1, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)), -1, 0, Lag(Qtr_Snap_Sum_Footprint, 1, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)) end AS delta_Footprint,


case when PArtition_count = 2 and Order_Item_Category_Type = 'Other' then
          decode(sign(Ftprint_ext_total_prc_usd), -1, 0, Ftprint_ext_total_prc_usd) - decode(sign(Lag(Ftprint_ext_total_prc_usd, 2, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)), -1, 0, Lag(Ftprint_ext_total_prc_usd, 2, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type))
else
decode(sign(Ftprint_ext_total_prc_usd), -1, 0, Ftprint_ext_total_prc_usd) - decode(sign(Lag(Ftprint_ext_total_prc_usd, 1, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)), -1, 0, Lag(Ftprint_ext_total_prc_usd, 1, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)) end AS dlt_Ftprint_ext_total_prc_usd,


case when PArtition_count = 2 and Order_Item_Category_Type = 'Other' then
          decode(sign(Ftprint_ext_total_prc), -1, 0, Ftprint_ext_total_prc) - decode(sign(Lag(Ftprint_ext_total_prc, 2, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)), -1, 0, Lag(Ftprint_ext_total_prc, 2, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type))
else
decode(sign(Ftprint_ext_total_prc), -1, 0, Ftprint_ext_total_prc) - decode(sign(Lag(Ftprint_ext_total_prc, 1, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)), -1, 0, Lag(Ftprint_ext_total_prc, 1, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)) end AS dlt_Ftprint_ext_total_prc,



case when PArtition_count = 2 and Order_Item_Category_Type = 'Other' then
          decode(sign(Ftprint_ACV_Unit_Prc_USD), -1, 0, Ftprint_ACV_Unit_Prc_USD) - decode(sign(Lag(Ftprint_ACV_Unit_Prc_USD, 2, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)), -1, 0, Lag(Ftprint_ACV_Unit_Prc_USD, 2, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type))
else
decode(sign(Ftprint_ACV_Unit_Prc_USD), -1, 0, Ftprint_ACV_Unit_Prc_USD) - decode(sign(Lag(Ftprint_ACV_Unit_Prc_USD, 1, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)), -1, 0, Lag(Ftprint_ACV_Unit_Prc_USD, 1, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)) end AS dlt_Ftprint_ACV_Unit_Prc_USD,

case when PArtition_count = 2 and Order_Item_Category_Type = 'Other' then
          decode(sign(Ftprint_Total_ACV_Amount_USD), -1, 0, Ftprint_Total_ACV_Amount_USD) - decode(sign(Lag(Ftprint_Total_ACV_Amount_USD, 2, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)), -1, 0, Lag(Ftprint_Total_ACV_Amount_USD, 2, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type))
else
decode(sign(Ftprint_Total_ACV_Amount_USD), -1, 0, Ftprint_Total_ACV_Amount_USD) - decode(sign(Lag(Ftprint_Total_ACV_Amount_USD, 1, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)), -1, 0, Lag(Ftprint_Total_ACV_Amount_USD, 1, 0)
                              over (
                                PARTITION BY account_id, product_sku,
                              pricebook_name, is_rul_flag,
                              billing_frequency, currency_code
                                ORDER BY qtr_id,Order_Item_Category_Type)) end AS dlt_Ftprint_Tot_ACV_Amt_USD

  from
  (
  SELECT
  a.qtr_join_id                                                 AS qtr_id,
          To_number(a.fiscal_yr_qtr_num)                                    AS
  fiscal_yr_qtr_nm
  ,
          To_number(Substr(a.fiscal_yr_qtr_num, 1, 4))                      AS
  fiscal_yr,
          To_number(Substr(a.fiscal_yr_qtr_num, 5, 1))                      AS
  fiscal_qtr,
          a.account_id,
          c.account_name,
          c.account_owner,
          c.Organization_Id,
          c.Organization_Status,
          a.pricebook_name,
          a.Order_Item_Category_Type,
          a.product_sku,
          d.product_name,
          d.product_name as latest_product_name,
          coalesce(f.grouped_product_name, d.product_name, 'None') as RolledUp_Product_Name,
          c.market_segment,
          c.region,
          c.acct_locked_industry_name,
          c.sector_name,
          coalesce(c.Global_Company_360_Nm, c.Global_Company_Name, c.account_name) as Global_Company360_Name,
          NVL(c.Global_Company_Name, c.account_name) as Global_Company_Name,
          NVL(c.Global_Company_ID, c.account_id) as Global_Company_ID,
          Case when c.Global_Company_Name is null then 'N' else 'Y' end as Has_Global_Company,
          c.Bill_Country_Name,
          c.Global_Company_Emp_Cnt,
          c.Account_Employee_Count,
          c.Edition_Name,
          case when e.Product_based_Edition is not null then e.Product_based_Edition else c.Edition_Name end as Product_Edition_name,
          a.exit_quantity,
          decode(sign(a.exit_quantity), -1, 0, a.exit_quantity) - decode(sign(Lag(a.exit_quantity, 1, 0)
                              over (
                                PARTITION BY a.account_id, a.product_sku,
                              a.pricebook_name, a.is_rul_flag,
                              a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                ORDER BY a.qtr_join_id)), -1, 0, Lag(a.exit_quantity, 1, 0)
                              over (
                                PARTITION BY a.account_id, a.product_sku,
                              a.pricebook_name, a.is_rul_flag,
                              a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                ORDER BY a.qtr_join_id)) AS delta_exit_quantity,
      sum(a.exit_quantity) over (partition by a.account_id, a.product_sku,
                  a.pricebook_name, a.is_rul_flag,
                  a.billing_frequency, a.currency_code, a.qtr_join_id)  as Qtr_Snap_Sum_Footprint,

          count(*) over (partition by a.account_id, a.product_sku,
                              a.pricebook_name, a.is_rul_flag,
                              a.billing_frequency, a.currency_code, a.qtr_join_id) as partition_count,

          a.exit_total_price,
          decode(sign(a.exit_total_price), -1, 0, a.exit_total_price) - decode(sign(Lag(a.exit_total_price, 1, 0)
                                 over (
                                   PARTITION BY a.account_id, a.product_sku,
                                 a.pricebook_name, a.is_rul_flag,
                                 a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                   ORDER BY a.qtr_join_id)), -1, 0, Lag(a.exit_total_price, 1, 0)
                                 over (
                                   PARTITION BY a.account_id, a.product_sku,
                                 a.pricebook_name, a.is_rul_flag,
                                 a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                   ORDER BY a.qtr_join_id)) AS delta_exit_total_price,

      sum(a.exit_total_price) over (partition by a.account_id, a.product_sku,
                  a.pricebook_name, a.is_rul_flag,
                  a.billing_frequency, a.currency_code, a.qtr_join_id)  as Ftprint_ext_total_prc,


          a.exit_total_price_usd,
          decode(sign(a.exit_total_price_usd), -1, 0, a.exit_total_price_usd) - decode(sign(Lag(a.exit_total_price_usd, 1, 0)
                                     over (
                                       PARTITION BY a.account_id, a.product_sku,
                                     a.pricebook_name, a.is_rul_flag,
                                     a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                       ORDER BY a.qtr_join_id)), -1, 0, Lag(a.exit_total_price_usd, 1, 0)
                                     over (
                                       PARTITION BY a.account_id, a.product_sku,
                                     a.pricebook_name, a.is_rul_flag,
                                     a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                       ORDER BY a.qtr_join_id)) AS delta_exit_total_price_usd,

      sum(a.exit_total_price_usd) over (partition by a.account_id, a.product_sku,
                  a.pricebook_name, a.is_rul_flag,
                  a.billing_frequency, a.currency_code, a.qtr_join_id)  as Ftprint_ext_total_prc_usd,

          a.ACV_Opty_Unit_Price_USD,

          decode(sign(NVL(a.ACV_Opty_Unit_Price_USD,0)), -1, 0, NVL(a.ACV_Opty_Unit_Price_USD,0)) - decode(sign(Lag(NVL(a.ACV_Opty_Unit_Price_USD,0), 1, 0)
                                     over (
                                       PARTITION BY a.account_id, a.product_sku,
                                     a.pricebook_name, a.is_rul_flag,
                                     a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                       ORDER BY a.qtr_join_id)), -1, 0, Lag(NVL(a.ACV_Opty_Unit_Price_USD,0), 1, 0)
                                     over (
                                       PARTITION BY a.account_id, a.product_sku,
                                     a.pricebook_name, a.is_rul_flag,
                                     a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                       ORDER BY a.qtr_join_id)) AS delta_opty_acv_unt_prc_usd,

                sum(a.ACV_Opty_Unit_Price_USD) over (partition by a.account_id, a.product_sku,
                  a.pricebook_name, a.is_rul_flag,
                  a.billing_frequency, a.currency_code, a.qtr_join_id)  as Ftprint_ACV_Unit_Prc_USD,

    a.Total_ACV_Amount_USD,

              decode(sign(NVL(a.Total_ACV_Amount_USD,0)), -1, 0, NVL(a.Total_ACV_Amount_USD,0)) - decode(sign(Lag(NVL(a.Total_ACV_Amount_USD,0), 1, 0)
                                     over (
                                       PARTITION BY a.account_id, a.product_sku,
                                     a.pricebook_name, a.is_rul_flag,
                                     a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                       ORDER BY a.qtr_join_id)), -1, 0, Lag(NVL(a.Total_ACV_Amount_USD,0), 1, 0)
                                     over (
                                       PARTITION BY a.account_id, a.product_sku,
                                     a.pricebook_name, a.is_rul_flag,
                                     a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                       ORDER BY a.qtr_join_id)) AS delta_Total_ACV_Amount_USD,

                sum(a.Total_ACV_Amount_USD) over (partition by a.account_id, a.product_sku,
                  a.pricebook_name, a.is_rul_flag,
                  a.billing_frequency, a.currency_code, a.qtr_join_id)  as Ftprint_Total_ACV_Amount_USD,


          a.exit_total_annual_price_local,
          decode(sign(a.exit_total_annual_price_local), -1, 0, a.exit_total_annual_price_local) - decode(sign(Lag(a.exit_total_annual_price_local,
                                            1
                                            , 0)
          over (
            PARTITION BY a.account_id, a.product_sku,
          a.pricebook_name, a.is_rul_flag,
          a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
            ORDER BY a.qtr_join_id)), -1, 0, Lag(a.exit_total_annual_price_local,
                                            1
                                            , 0)
          over (
            PARTITION BY a.account_id, a.product_sku,
          a.pricebook_name, a.is_rul_flag,
          a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
            ORDER BY a.qtr_join_id)) AS del_exit_total_annual_local,
          a.exit_total_annual_price_usd,
          decode(sign(a.exit_total_annual_price_usd), -1, 0, a.exit_total_annual_price_usd) - decode(sign(Lag(a.exit_total_annual_price_usd, 1,
                                          0)
          over (
            PARTITION BY a.account_id, a.product_sku,
          a.pricebook_name, a.is_rul_flag,
          a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
            ORDER BY a.qtr_join_id)), -1, 0, Lag(a.exit_total_annual_price_usd, 1,
                                          0)
          over (
            PARTITION BY a.account_id, a.product_sku,
          a.pricebook_name, a.is_rul_flag,
          a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
            ORDER BY a.qtr_join_id)) AS del_exit_total_annual_usd,
          a.exit_asp                                                      AS
  WAAUP_Monthly_Local,
          a.exit_asp_usd                                                  AS
  WAAUP_Monthly_USD,
          a.exit_asp * ( 12.0 / a.billing_frequency )                     AS
  WAAUP_Annual_Local,
          a.exit_asp_usd * ( 12.0 / a.billing_frequency )                 AS
  WAAUP_Annual_USD,
          a.exit_asp * ( decode(sign(a.exit_quantity), -1, 0, a.exit_quantity) - decode(sign(Lag(a.exit_quantity, 1, 0)
                              over (
                                PARTITION BY a.account_id, a.product_sku,
                              a.pricebook_name, a.is_rul_flag,
                              a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                ORDER BY a.qtr_join_id)), -1, 0, Lag(a.exit_quantity, 1, 0)
                              over (
                                PARTITION BY a.account_id, a.product_sku,
                              a.pricebook_name, a.is_rul_flag,
                              a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                ORDER BY a.qtr_join_id)) ) *
          ( 12.0 / a.billing_frequency )                                  AS
  Delta_WAAUP_Annual_Local,
          a.exit_asp_usd * ( decode(sign(a.exit_quantity), -1, 0, a.exit_quantity) - decode(sign(Lag(a.exit_quantity, 1, 0)
                              over (
                                PARTITION BY a.account_id, a.product_sku,
                              a.pricebook_name, a.is_rul_flag,
                              a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                ORDER BY a.qtr_join_id)), -1, 0, Lag(a.exit_quantity, 1, 0)
                              over (
                                PARTITION BY a.account_id, a.product_sku,
                              a.pricebook_name, a.is_rul_flag,
                              a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                ORDER BY a.qtr_join_id)) ) * (
          12.0 /
          a.billing_frequency )                                           AS
  Delta_WAAUP_Annual_USD,
          CASE
            WHEN b.eaio_annual_local_price IS NULL THEN 0
            ELSE b.eaio_annual_local_price
          END                                                             AS
  EAIO_Annual_Local_Price,
          CASE
            WHEN b.eaio_annual_usd_price IS NULL THEN 0
            ELSE b.eaio_annual_usd_price
          END                                                             AS
  EAIO_Annual_USD_Price,
          ( CASE
              WHEN b.eaio_annual_local_price IS NULL THEN 0
              ELSE b.eaio_annual_local_price
            END ) * ( decode(sign(a.exit_quantity), -1, 0, a.exit_quantity) - decode(sign(Lag(a.exit_quantity, 1, 0)
                              over (
                                PARTITION BY a.account_id, a.product_sku,
                              a.pricebook_name, a.is_rul_flag,
                              a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                ORDER BY a.qtr_join_id)), -1, 0, Lag(a.exit_quantity, 1, 0)
                              over (
                                PARTITION BY a.account_id, a.product_sku,
                              a.pricebook_name, a.is_rul_flag,
                              a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                ORDER BY a.qtr_join_id)) )   AS
          RIV_Annual_Local,
          a.ACV_Opty_Qty,

          ( CASE
              WHEN b.eaio_annual_usd_price IS NULL THEN 0
              ELSE b.eaio_annual_usd_price
            END ) * ( decode(sign(a.exit_quantity), -1, 0, a.exit_quantity) - decode(sign(Lag(a.exit_quantity, 1, 0)
                              over (
                                PARTITION BY a.account_id, a.product_sku,
                              a.pricebook_name, a.is_rul_flag,
                              a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                ORDER BY a.qtr_join_id)), -1, 0, Lag(a.exit_quantity, 1, 0)
                              over (
                                PARTITION BY a.account_id, a.product_sku,
                              a.pricebook_name, a.is_rul_flag,
                              a.billing_frequency, a.currency_code, a.Order_Item_Category_Type
                                ORDER BY a.qtr_join_id)) )   AS
  RIV_Annual_USD,
          a.currency_code,
          a.billing_frequency,
          a.is_rul_flag,
          case when lag(a.exit_quantity,1,-9999)  over (partition by a.account_id, a.product_sku, a.pricebook_name order by a.qtr_join_id) = -9999 then 'New Product' else 'Existing Product' end as New_vs_Existing_Product,
case when lag(a.exit_quantity,1,-9999)  over (partition by a.account_id order by a.qtr_join_id) = -9999 then 'New Customer' else 'Existing Customer' end as New_vs_Existing_Customer,
       c.user_role_name,
       c.Lvl_1_Usr_Nm,
       c.Lvl_2_Usr_Nm,
       c.Lvl_3_Usr_Nm,
       c.Lvl_4_Usr_Nm,
       c.Lvl_5_Usr_Nm,
       c.Lvl_6_Usr_Nm,
       c.Lvl_7_Usr_Nm,
       c.Lvl_8_Usr_Nm,
       c.Lvl_9_Usr_Nm,
       c.Lvl_10_Usr_Nm,
       c.Lvl_11_Usr_Nm,
       c.Lvl_12_Usr_Nm,
       c.Lvl_13_Usr_Nm,
       c.Lvl_14_Usr_Nm,
       c.Lvl_15_Usr_Nm,
       c.Account_Region,
       c.Biz_Unit,
       c.Data_Storage_Limit_Number,
       c.File_Storage_Limit_Number
   FROM   (SELECT qtr_join_id,
                  fiscal_yr_qtr_num,
                  account_id,
                  pricebook_name,
                  product_sku,
                  order_item_category_type,
                  SUM(exit_quantity)                 AS Exit_Quantity,
                  SUM(exit_total_price)              AS Exit_Total_Price,
                  SUM(exit_total_price_usd)          AS Exit_Total_Price_USD,
                  SUM(exit_total_annual_price_local) AS
                  Exit_Total_Annual_Price_Local,
                  SUM(exit_total_annual_price_usd)   AS
                  Exit_Total_Annual_Price_USD,
                  CASE
                    WHEN SUM(exit_quantity) <> 0 THEN
                    SUM(exit_total_price) / SUM(exit_quantity)
                    ELSE 0
                  END                                AS Exit_ASP,
                  CASE
                    WHEN SUM(exit_quantity) <> 0 THEN
                    SUM(exit_total_price_usd) / SUM(exit_quantity)
                    ELSE 0
                  END                                AS Exit_ASP_USD,
                  SUM(OPPTY_QTY) AS ACV_Opty_Qty,
                  SUM(OPTY_UNIT_PRICE_USD) AS ACV_Opty_Unit_Price_USD,
                  SUM(Opty_Tot_Annual_Price_USD) AS Total_ACV_Amount_USD,
                  currency_code,
                  billing_frequency,
                  is_rul_flag
           FROM   qtr_snap_exit_amounts_acv a
           GROUP  BY qtr_join_id,
                     fiscal_yr_qtr_num,
                     account_id,
                     pricebook_name,
                     product_sku,
                     currency_code,
                     billing_frequency,
                     is_rul_flag,
                     order_item_category_type
           ORDER  BY qtr_join_id ASC) a,
          (SELECT product_sku,
                  account_id,
                  pricebook_name,
                  billing_frequency,
                  order_create_qtr,
                  currency_code,
                  is_rul_flag,
                  CASE
                    WHEN SUM(exit_quantity) <> 0 THEN SUM(
                    exit_total_annual_price_local) /
                                                      SUM(
                                                      exit_quantity)
                    ELSE 0
                  END AS EAIO_Annual_Local_Price,
                  CASE
                    WHEN SUM(exit_quantity) <> 0 THEN SUM(
                    exit_total_annual_price_usd) /
                                                      SUM(
                                                      exit_quantity)
                    ELSE 0
                  END AS EAIO_Annual_USD_Price
           FROM   (SELECT product_sku,
                          account_id,
                          pricebook_name,
                          billing_frequency,
                          currency_code,
                          is_rul_flag,
                          CASE
                            WHEN To_char(a.order_create_date, 'MM') BETWEEN 2 AND
                                 4
                          THEN
  To_number(Concat(To_char(a.order_create_date, 'YYYY') + 1, '1'))
  WHEN To_char(a.order_create_date, 'MM') BETWEEN 5 AND 7 THEN
  To_number(Concat(To_char(a.order_create_date, 'YYYY') + 1, '2'))
  WHEN To_char(a.order_create_date, 'MM') BETWEEN 8 AND 10 THEN
  To_number(Concat(To_char(a.order_create_date, 'YYYY') + 1, '3'))
  WHEN To_char(a.order_create_date, 'MM') IN ( 11, 12 ) THEN
  To_number(Concat(To_char(a.order_create_date, 'YYYY') + 1, '4'))
  WHEN To_char(a.order_create_date, 'MM') IN ( 1 ) THEN
  To_number(Concat(
  To_char(a.order_create_date, 'YYYY'), '4'))
  END AS order_create_qtr,
  case when exit_quantity < 0 then 0 else exit_quantity end as exit_quantity,
  case when exit_total_annual_price_local < 0 then 0 else exit_total_annual_price_local end as exit_total_annual_price_local,
  case when exit_total_annual_price_usd < 0 then 0 else exit_total_annual_price_usd end as exit_total_annual_price_usd
  FROM   quarterly_exit_amount_calc_acv a)
  GROUP  BY product_sku,
  account_id,
  pricebook_name,
  billing_frequency,
  order_create_qtr,
  currency_code,
  is_rul_flag) b, ACCT_ATTRIBUTES_TBR c, PROD_SKU_MAP_TBR d,  PRODUCT_BASED_EDITION_TBR e, product_rollups_tbr f, pi_dm.ASP_PRODUCT_LIST e
   WHERE  a.product_sku = b.product_sku (+)
          AND a.account_id = b.account_id (+)
          AND a.pricebook_name = b.pricebook_name (+)
          AND a.billing_frequency = b.billing_frequency (+)
          AND a.fiscal_yr_qtr_num = b.order_create_qtr (+)
          AND a.currency_code = b.currency_code (+)
          AND a.is_rul_flag = b.is_rul_flag (+)
          AND a.account_id = c.account_id (+)
          AND a.product_sku = d.product_sku (+)
          AND a.account_id = e.account_id(+)
          and d.product_name = f.original_product_name (+)
          and d.PRODUCT_NAME = e.LONG_PRODUCT_NAME
          and e.PRODUCT_NAME not like 'MC %'
          and e.PRODUCT_NAME not like 'ExactTarget %'
          and a.Exit_Quantity <> 0

        -- and a.Account_Id = '0013000000hIXMl'  ------poolsure
      -- and a.PRODUCT_SKU = '200000011' ----Validar/poolsure
       -- and a.Account_Id = '0010000000000aP'  ------Validar

      -- and a.PRODUCT_SKU = '200000036' ------Krex
       -- and a.Account_Id = '00100000001DTqE' -----Krex

       --   and   c.account_name = 'Stripe' and a.product_sku = '8200005037'
  --  and  c.account_name = 'Hach Company' and a.product_sku = '200000436'
 -- and  c.account_name = 'Brex Inc.' and a.product_sku = '200000000'
      -- and  c.account_name = 'Stripe' and a.product_sku = '8200005037'
 ) main

 ) final
where fiscal_yr_qtr_nm between 20191 and 20201 -- CHANGED CONDITION
order by fiscal_yr_qtr_nm
;

-- TODO: Bring in the flag to tag the records as Deltas not matched in PH.

drop table PH_ACV_MISMATCH;

create table PH_ACV_MISMATCH as
select * from (select distinct b.*, a.new_delta_exit_qty
                      from (select fiscal_yr_qtr_nm,
                                   account_id,
                                   product_sku,
                                   pricebook_name,
                                   billing_frequency,
                                   currency_code,
                                   is_rul_flag,
                                   sum(delta_exit_quantity_new) as new_delta_exit_qty
                            from final_quarterly_asp_acv
                            where fiscal_yr_qtr_nm between 20191 and 20202
                            group by fiscal_yr_qtr_nm, account_id, product_sku, pricebook_name, billing_frequency,
                                     currency_code, is_rul_flag
                           ) a,
                           final_quarterly_asp_new b, ASP_PRODUCT_LIST c
                      where b.fiscal_yr_qtr_num = a.FISCAL_YR_QTR_NM (+)
                        and b.account_id = a.ACCOUNT_ID (+)
                        and b.product_sku = a.PRODUCT_SKU (+)
                        and b.pricebook_name = a.PRICEBOOK_NAME (+)
                        and b.billing_frequency = a.BILLING_FREQUENCY (+)
                        and b.currency_code = a.CURRENCY_CODE (+)
                        and b.is_rul_flag = a.IS_RUL_FLAG (+)
                        and b.FISCAL_YR_QTR_NUM between 20191 and 20202
                        and b.product_name = c.long_product_name
                        and c.product_name not like 'MC %'
                        and c.product_name not like 'ExactTarget %'
                     ) where DELTA_EXIT_QUANTITY <> new_delta_exit_qty;

drop table PH_ACV_MATCH;

create table PH_ACV_MATCH as
select * from (select distinct b.*, a.new_delta_exit_qty
                      from (select fiscal_yr_qtr_nm,
                                   account_id,
                                   product_sku,
                                   pricebook_name,
                                   billing_frequency,
                                   currency_code,
                                   is_rul_flag,
                                   sum(delta_exit_quantity_new) as new_delta_exit_qty
                            from final_quarterly_asp_acv
                            where fiscal_yr_qtr_nm between 20191 and 20202
                            group by fiscal_yr_qtr_nm, account_id, product_sku, pricebook_name, billing_frequency,
                                     currency_code, is_rul_flag
                           ) a,
                           final_quarterly_asp_new b, ASP_PRODUCT_LIST c
                      where b.fiscal_yr_qtr_num = a.FISCAL_YR_QTR_NM (+)
                        and b.account_id = a.ACCOUNT_ID (+)
                        and b.product_sku = a.PRODUCT_SKU (+)
                        and b.pricebook_name = a.PRICEBOOK_NAME (+)
                        and b.billing_frequency = a.BILLING_FREQUENCY (+)
                        and b.currency_code = a.CURRENCY_CODE (+)
                        and b.is_rul_flag = a.IS_RUL_FLAG (+)
                        and b.FISCAL_YR_QTR_NUM between 20191 and 20202
                        and b.product_name = c.long_product_name
                        and c.product_name not like 'MC %'
                        and c.product_name not like 'ExactTarget %'
                     ) where DELTA_EXIT_QUANTITY = new_delta_exit_qty;

alter table final_quarterly_asp_acv add (Delta_Qty_Does_Match_PH_flg Varchar(50) DEFAULT 'Unknown');

merge into final_quarterly_asp_acv a using PH_ACV_MISMATCH b on (b.FISCAL_YR_QTR_NUM = a.fiscal_yr_qtr_nm
    and b.Account_id = a.account_id
    and b.product_sku = a.product_sku
    and b.pricebook_name = a.pricebook_name
    and b.billing_frequency = a.billing_frequency
    and b.currency_code = a.currency_code
    and b.is_rul_flag = a.is_rul_flag)
when matched then
update set Delta_Qty_Does_Match_PH_flg = 'No';


merge into final_quarterly_asp_acv a using PH_ACV_MATCH b on (b.FISCAL_YR_QTR_NUM = a.fiscal_yr_qtr_nm
    and b.Account_id = a.account_id
    and b.product_sku = a.product_sku
    and b.pricebook_name = a.pricebook_name
    and b.billing_frequency = a.billing_frequency
    and b.currency_code = a.currency_code
    and b.is_rul_flag = a.is_rul_flag)
when matched then
update set Delta_Qty_Does_Match_PH_flg = 'Yes';

commit;

-- # TODO: Price amounts validations mistmatch flag creation logic.

drop table PH_ACV_PRICE_MISMATCH;

create table PH_ACV_PRICE_MISMATCH as
select * from (select distinct a.*, b.DELTA_EXIT_TOTAL_PRICE_USD
                      from (select fiscal_yr_qtr_nm,
                                   account_id,
                                   product_sku,
                                   pricebook_name,
                                   billing_frequency,
                                   currency_code,
                                   is_rul_flag,
                                   sum(dlt_Total_ACV_Amount_usd_new) as dlt_Total_ACV_Amount_usd_new
                            from final_quarterly_asp_acv
                            group by fiscal_yr_qtr_nm, account_id, product_sku, pricebook_name, billing_frequency,
                                     currency_code, is_rul_flag
                           ) a,
                           final_quarterly_asp_new b
                      where a.fiscal_yr_qtr_nm = b.FISCAL_YR_QTR_NUM
                        and a.account_id = b.ACCOUNT_ID
                        and a.product_sku = b.PRODUCT_SKU
                        and a.pricebook_name = b.PRICEBOOK_NAME
                        and a.billing_frequency = b.BILLING_FREQUENCY
                        and a.currency_code = b.CURRENCY_CODE
                        and a.is_rul_flag = b.IS_RUL_FLAG
                        and a.fiscal_yr_qtr_nm between 20191 and 20202
                     ) where ROUND((ABS(DELTA_EXIT_TOTAL_PRICE_USD - dlt_Total_ACV_Amount_usd_new)/DECODE(DELTA_EXIT_TOTAL_PRICE_USD,0,1,DELTA_EXIT_TOTAL_PRICE_USD))*100,0) > 5;

drop table PH_ACV_PRICE_MATCH;

create table PH_ACV_PRICE_MATCH as
select * from (select distinct a.*, b.DELTA_EXIT_TOTAL_PRICE_USD
                      from (select fiscal_yr_qtr_nm,
                                   account_id,
                                   product_sku,
                                   pricebook_name,
                                   billing_frequency,
                                   currency_code,
                                   is_rul_flag,
                                   sum(dlt_Total_ACV_Amount_usd_new) as dlt_Total_ACV_Amount_usd_new
                            from final_quarterly_asp_acv
                            group by fiscal_yr_qtr_nm, account_id, product_sku, pricebook_name, billing_frequency,
                                     currency_code, is_rul_flag
                           ) a,
                           final_quarterly_asp_new b
                      where a.fiscal_yr_qtr_nm = b.FISCAL_YR_QTR_NUM
                        and a.account_id = b.ACCOUNT_ID
                        and a.product_sku = b.PRODUCT_SKU
                        and a.pricebook_name = b.PRICEBOOK_NAME
                        and a.billing_frequency = b.BILLING_FREQUENCY
                        and a.currency_code = b.CURRENCY_CODE
                        and a.is_rul_flag = b.IS_RUL_FLAG
                        and a.fiscal_yr_qtr_nm between 20191 and 20202
                     ) where ROUND((ABS(DELTA_EXIT_TOTAL_PRICE_USD - dlt_Total_ACV_Amount_usd_new)/DECODE(DELTA_EXIT_TOTAL_PRICE_USD,0,1,DELTA_EXIT_TOTAL_PRICE_USD))*100,0) <= 5;

alter table final_quarterly_asp_acv add (AOV_ACV_Does_Match_PH_flg Varchar(50) DEFAULT 'Unknown');

merge into final_quarterly_asp_acv a using PH_ACV_PRICE_MISMATCH b on (b.fiscal_yr_qtr_nm = a.fiscal_yr_qtr_nm
    and b.Account_id = a.account_id
    and b.product_sku = a.product_sku
    and b.pricebook_name = a.pricebook_name
    and b.billing_frequency = a.billing_frequency
    and b.currency_code = a.currency_code
    and b.is_rul_flag = a.is_rul_flag)
when matched then
update set AOV_ACV_Does_Match_PH_flg = 'No';


merge into final_quarterly_asp_acv a using PH_ACV_PRICE_MATCH b on (b.fiscal_yr_qtr_nm = a.fiscal_yr_qtr_nm
    and b.Account_id = a.account_id
    and b.product_sku = a.product_sku
    and b.pricebook_name = a.pricebook_name
    and b.billing_frequency = a.billing_frequency
    and b.currency_code = a.currency_code
    and b.is_rul_flag = a.is_rul_flag)
when matched then
update set AOV_ACV_Does_Match_PH_flg = 'Yes';

commit;

-- # TODO: Create the unique line record where we sum across quantities and USD amounts before joining with PH table.

drop table final_quarterly_asp_acv_new;

create table final_quarterly_asp_acv_new as
( select fiscal_yr_qtr_nm, account_id,
         product_sku,
         pricebook_name,
         billing_frequency,
         currency_code,
         is_rul_flag,
         AOV_ACV_Does_Match_PH_flg,
         Delta_Qty_Does_Match_PH_flg,
         sum(DLT_EXT_TOT_PRICE_USD_NEW) as ACV_Amount_USD,
         sum(delta_exit_quantity_new) as ACV_Delta_Qty
         from final_quarterly_asp_acv
--  where fiscal_yr_qtr_nm = 20191 and account_id = '0013000001NXn95' and product_sku = '200012628'
--                                         and pricebook_name = 'CPQ - Direct - Commercial - Ohana - WW - USD' and billing_frequency = 1
-- and currency_code = 'USD' and is_rul_flag ='N'
    group by fiscal_yr_qtr_nm, account_id,
                                   product_sku,
                                   pricebook_name,
                                   billing_frequency,
                                   currency_code,
                                   is_rul_flag,
             AOV_ACV_Does_Match_PH_flg,
         Delta_Qty_Does_Match_PH_flg
);


-- # TODO: Join this final_quarterly_asp_acv_new to the final_quarterly_asp_new table and re-create the new table.

drop table final_acv_aov_quarterly;

create table final_acv_aov_quarterly as (
    select a.*,
           b.AOV_ACV_Does_Match_PH_flg,
           b.Delta_Qty_Does_Match_PH_flg,
           b.ACV_Amount_USD,
           b.ACV_Delta_Qty
    from final_quarterly_asp_new a, final_quarterly_asp_acv_new b
where a.fiscal_yr_qtr_num = b.fiscal_yr_qtr_nm (+)
    and a.Account_id = b.account_id (+)
    and a.product_sku = b.product_sku (+)
    and a.pricebook_name = b.pricebook_name (+)
    and a.billing_frequency = b.billing_frequency (+)
    and a.currency_code = b.currency_code (+)
    and a.is_rul_flag = b.is_rul_flag (+)
);
