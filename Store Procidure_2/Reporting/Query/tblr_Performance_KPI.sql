SELECT A.distributionid                  AS DB_id, 
       '2018-07-06'                      AS BatchDate, 
       A.id                              AS PerformerId, 
       A.NAME                            AS PerformerName, 
       A.emp_type                        AS PerformerType, 
       Isnull(B.salesschedulecall, 0)    AS SalesScheduleCall, 
       Isnull(C.salesmemo, 0)            AS SalesMemo, 
       Isnull(D.totallinesold, 0)        AS TotalLineSold, 
       Isnull(E.totalsoldinvolume, 0)    AS TotalSoldInVolume, 
       Isnull(F.totalsoldincase, 0)      AS TotalSoldInCase, 
       Isnull(G.totalsoldinvalue, 0)     AS TotalSoldInValue, 
       Isnull(H.totalorderedinvolume, 0) AS TotalOrderedInVolume, 
       Isnull(I.totalorderedincase, 0)   AS TotalOrderedInCase, 
       Isnull(J.totalorderedinvalue, 0)  AS TotalOrderedInValue 
FROM   tbld_distribution_employee AS A 
       LEFT JOIN (SELECT t1.dbid, 
                         t1.db_emp_id, 
                         Count(t2.outletid) AS SalesScheduleCall 
                  FROM   tbld_route_plan_detail AS t1 
                         INNER JOIN tbld_outlet AS t2 
                                 ON t1.route_id = t2.parentid 
                  WHERE  planned_visit_date = '2018-07-06' 
                         AND isactive = 1 
                  GROUP  BY t1.db_emp_id, 
                            t1.dbid) AS B 
              ON A.distributionid = B.dbid 
                 AND A.id = B.db_emp_id 
       LEFT JOIN (SELECT db_id, 
                         psr_id, 
                         Count(orderid) AS SalesMemo 
                  FROM   tblt_order 
                  WHERE  planned_order_date = '2018-07-06' 
                         AND so_status != 9 
                  GROUP  BY db_id, 
                            psr_id) AS C 
              ON A.distributionid = C.db_id 
                 AND A.id = C.psr_id 
       LEFT JOIN (SELECT t1.db_id, 
                         t1.psr_id, 
                         Sum(lpec) AS TotalLineSold 
                  FROM   tblt_order AS t1 
                         INNER JOIN tblt_order_line AS t2 
                                 ON t1.orderid = t2.orderid 
                  WHERE  ( t1.planned_order_date = '2018-07-06' ) 
                         AND ( t1.so_status <> 9 ) 
                         AND t2.sku_order_type_id = 1 
                  GROUP  BY t1.db_id, 
                            t1.psr_id)AS D 
              ON A.distributionid = D.db_id 
                 AND A.id = D.psr_id 
       LEFT JOIN (SELECT t1.db_id, 
                         t1.psr_id, 
                         Sum(Cast(t2.quantity_delivered AS FLOAT) * Cast( 
                             t3.skuvolume_8oz AS FLOAT)) AS 
                         TotalSoldInVolume 
                  FROM   tblt_order AS t1 
                         INNER JOIN tblt_order_line AS t2 
                                 ON t1.orderid = t2.orderid 
                         INNER JOIN tbld_sku AS t3 
                                 ON t2.sku_id = t3.sku_id 
                  WHERE  ( t1.delivery_date = '2018-07-07' ) 
                         AND ( t1.so_status <> 9 ) 
                  GROUP  BY t1.db_id, 
                            t1.psr_id)AS E 
              ON A.distributionid = E.db_id 
                 AND A.id = E.psr_id 
       LEFT JOIN (SELECT t1.db_id, 
                         t1.psr_id, 
                         Sum(Cast(t2.quantity_delivered AS FLOAT) / Cast( 
                             pack_size AS FLOAT)) AS 
                         TotalSoldInCase 
                  FROM   tblt_order AS t1 
                         INNER JOIN tblt_order_line AS t2 
                                 ON t1.orderid = t2.orderid 
                  WHERE  ( t1.delivery_date = '2018-07-07' ) 
                         AND ( t1.so_status <> 9 ) 
                  GROUP  BY t1.db_id, 
                            t1.psr_id)AS F 
              ON A.distributionid = F.db_id 
                 AND A.id = F.psr_id 
       LEFT JOIN (SELECT t1.db_id, 
                         t1.psr_id, 
                         Sum(Cast(t2.quantity_delivered AS FLOAT) * Cast( 
                             t2.unit_sale_price AS FLOAT)) AS 
                         TotalSoldInValue 
                  FROM   tblt_order AS t1 
                         INNER JOIN tblt_order_line AS t2 
                                 ON t1.orderid = t2.orderid 
                  WHERE  ( t1.delivery_date = '2018-07-07' ) 
                         AND ( t1.so_status <> 9 ) 
                         AND t2.sku_order_type_id = 1 
                  GROUP  BY t1.db_id, 
                            t1.psr_id)AS G 
              ON A.distributionid = G.db_id 
                 AND A.id = G.psr_id 
       LEFT JOIN (SELECT t1.db_id, 
                         t1.psr_id, 
                         Sum(Cast(t2.quantity_confirmed AS FLOAT) * Cast( 
                             t3.skuvolume_8oz AS FLOAT)) AS 
                         TotalOrderedInVolume 
                  FROM   tblt_order AS t1 
                         INNER JOIN tblt_order_line AS t2 
                                 ON t1.orderid = t2.orderid 
                         INNER JOIN tbld_sku AS t3 
                                 ON t2.sku_id = t3.sku_id 
                  WHERE  ( t1.delivery_date = '2018-07-07' ) 
                         AND ( t1.so_status <> 9 ) 
                  GROUP  BY t1.db_id, 
                            t1.psr_id)AS H 
              ON A.distributionid = H.db_id 
                 AND A.id = H.psr_id 
       LEFT JOIN (SELECT t1.db_id, 
                         t1.psr_id, 
                         Sum(Cast(t2.quantity_confirmed AS FLOAT) / Cast( 
                             pack_size AS FLOAT)) AS 
                         TotalOrderedInCase 
                  FROM   tblt_order AS t1 
                         INNER JOIN tblt_order_line AS t2 
                                 ON t1.orderid = t2.orderid 
                  WHERE  ( t1.delivery_date = '2018-07-07' ) 
                         AND ( t1.so_status <> 9 ) 
                  GROUP  BY t1.db_id, 
                            t1.psr_id)AS I 
              ON A.distributionid = I.db_id 
                 AND A.id = I.psr_id 
       LEFT JOIN (SELECT t1.db_id, 
                         t1.psr_id, 
                         Sum(Cast(t2.quantity_confirmed AS FLOAT) * Cast( 
                             t2.unit_sale_price AS FLOAT)) AS 
                         TotalOrderedInValue 
                  FROM   tblt_order AS t1 
                         INNER JOIN tblt_order_line AS t2 
                                 ON t1.orderid = t2.orderid 
                  WHERE  ( t1.delivery_date = '2018-07-07' ) 
                         AND ( t1.so_status <> 9 ) 
                         AND t2.sku_order_type_id = 1 
                  GROUP  BY t1.db_id, 
                            t1.psr_id)AS J 
              ON A.distributionid = J.db_id 
                 AND A.id = J.psr_id 
WHERE  A.active = 1 AND A.emp_type = 2 AND A.distributionid = 1 