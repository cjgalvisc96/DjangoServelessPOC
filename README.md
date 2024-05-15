# How to deploy
```bash
    [ROOT]$ make deploy ENV=name # First create the ECS
    [ROOT]$ make push-docker-image-in-ecs
```


# RealExamples
```bash
    [ROOT]$ docker build -t 947134793474.dkr.ecr.us-east-1.amazonaws.com/django_serveless_poc_ecr_image:latest .
    [ROOT]$ aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 947134793474.dkr.ecr.us-east-1.amazonaws.coma
    [ROOT]$ docker push 947134793474.dkr.ecr.us-east-2.amazonaws.com/dev_django_serveless_poc_ecr_repository:latest
```