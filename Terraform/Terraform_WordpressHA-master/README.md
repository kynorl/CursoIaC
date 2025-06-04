Cambios realizados:
 - Un NAT GWY para cada subred privada
 - RDS multiAZ
 - ASG: parámetros cambiados (min 2, max 4, desired 2).
 - ASG: Política de escalado con utitilización de CPU al 60%
 - Gestión de passwords con Secret Manager (el secreto debe estar creado previamente)
 - Target Group del ALB: Peticiones de la misma sesión de un cliente van a la misma EC2 (stickiness = true)
 - User data: DOMAIN_NAME cambiado a "aws_lb.app_lb.dns_name". La url utiliza http. De esta manera no hace falta Route 53
 - TO_DO: Route 53 + CloudFront + HTTPS

