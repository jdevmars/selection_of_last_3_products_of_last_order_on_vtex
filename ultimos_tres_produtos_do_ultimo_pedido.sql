-- seleciona os 3 últimos produtos comprados (traz repetições do mesmo)

SELECT TOP 3 SK.ProductName, SK.ImageUrlBig, CONCAT('https://www.bisturi.com.br', SK.DetailUrl) AS DetailUrl, CreationDate
FROM dt_Order AS O
INNER JOIN dt_OrderItem OI 
ON CONCAT('00-',O.OrderId) = OI.OrderId
INNER JOIN dt_Sku SK 
ON OI.SkuId = SK.Id
WHERE O.Email = @email
ORDER BY O.CreationDate DESC

-- seleciona os 3 últimos produtos comprados (elimina as repetições, porém esteve trazendo produtos de compras diferentes)

SELECT TOP 3 SK.ProductName, SK.ImageUrlBig, CONCAT('https://www.bisturi.com.br', SK.DetailUrl) AS DetailUrl, MAX(O.CreationDate) AS LastPurchaseDate
FROM dt_Order AS O
INNER JOIN dt_OrderItem OI 
ON CONCAT('00-', O.OrderId) = OI.OrderId
INNER JOIN dt_Sku SK 
ON OI.SkuId = SK.Id
WHERE O.Email = @email
GROUP BY SK.ProductName, SK.ImageUrlBig, SK.DetailUrl
ORDER BY LastPurchaseDate DESC;

-- seleciona o último produto comprado (desta vez foca apenas nos produtos da última compra)
-- a plataforma não aceita WITH e DISTINCT

WITH LastOrder AS (
    -- Get the last order placed by the customer
    SELECT TOP 1 O.OrderId
    FROM dt_Order AS O
    WHERE O.Email = @email
    ORDER BY O.CreationDate DESC
)
SELECT DISTINCT 
    SK.ProductName, 
    SK.ImageUrlBig, 
    CONCAT('https://www.bisturi.com.br', SK.DetailUrl) AS DetailUrl
FROM dt_OrderItem OI
INNER JOIN dt_Sku SK 
ON OI.SkuId = SK.Id
WHERE OI.OrderId IN (SELECT CONCAT('00-', OrderId) FROM LastOrder);

-- seleciona o último produto comprado (desta vez foca apenas nos produtos da última compra, mas não traz ainda os 3 últimos)
-- trabalho apenas com subqueries, o que a plataforma aceita

SELECT SK.ProductName, SK.ImageUrlBig, CONCAT('https://www.bisturi.com.br', SK.DetailUrl) AS DetailUrl
FROM dt_OrderItem O
INNER JOIN dt_Sku SK 
ON O.SkuId = SK.Id
WHERE O.OrderId = (
    -- Subquery to get the last OrderId for the email
    SELECT TOP 1 CONCAT('00-', ORD.OrderId)
    FROM dt_Order AS ORD
    WHERE ORD.Email = @email
    ORDER BY ORD.CreationDate DESC
)
GROUP BY SK.ProductName, SK.ImageUrlBig, SK.DetailUrl

-- seleciona os 3 últimos produtos adquiridos na última compra
-- trabalho apenas com subqueries, o que a plataforma aceita
-- poderia ter sido feito com 2 modelos (getLatestOrderId & getTheThreeLastProductsOfTheLatestOrderId)

SELECT TOP 3 SK.ProductName, SK.ImageUrlBig, CONCAT('https://www.bisturi.com.br', SK.DetailUrl) AS DetailUrl
FROM dt_OrderItem O
INNER JOIN dt_Sku SK 
ON O.SkuId = SK.Id
INNER JOIN dt_Order ORD
ON CONCAT('00-', ORD.OrderId) = O.OrderId
WHERE ORD.OrderId = (
    SELECT TOP 1 ORD2.OrderId
    FROM dt_Order AS ORD2
    WHERE ORD2.Email = @email
    ORDER BY ORD2.CreationDate DESC
)
GROUP BY SK.ProductName, SK.ImageUrlBig, SK.DetailUrl, O.SkuId
ORDER BY MAX(ORD.CreationDate) DESC
