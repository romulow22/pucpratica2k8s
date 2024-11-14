# IEC_DCSE_O3_T1_Online: Conteinerização e Orquestração

## Trabalho Prático Unidade 2 : *Kubernetes*

- Nome: Rômulo Alves
- E-mail: 1545593@sga.pucminas.br
- Matricula: 212457


## Sumário

1. [Descrição](#descrição)
2. [Arquitetura da Solução](#arquitetura-da-solução)
3. [Detalhes da Implementação](#detalhes-da-implementação)
4. [Requisitos](#requisitos)
5. [Configuração Inicial](#configuração-inicial)
6. [Instruções de Instalação e Execução](#instruções-de-instalação-e-execução)
7. [Como Jogar](#como-jogar)
8. [Remoção do Ambiente](#remoção-do-ambiente)
9. [Considerações de Segurança](#considerações-de-segurança)
10. [Contribuição](#contribuição)
11. [Licença](#licença)

## Descrição

Este projeto implementa uma versão conteinerizada do jogo de adivinhação disponível no [Guess Game](https://github.com/fams/guess_game), utilizando Kubernetes e Helm. A solução demonstra boas práticas de conteinerização, orquestração e arquitetura de microserviços, proporcionando um ambiente escalável e eficiente para o jogo.

## Arquitetura da Solução

A solução é composta por três serviços principais:

1. **backend-app**: Aplicação Python (Flask) que executa a lógica do jogo de adivinhação.
2. **frontend-app**: Servidor Nginx servindo as páginas do frontend React.
3. **postgresdb**: Banco de dados PostgreSQL para persistência de dados.

Cada serviço é empacotado em um contêiner Docker e orquestrado usando Kubernetes, garantindo alta disponibilidade e escalabilidade.

## Detalhes da Implementação

1. **Dockerfiles Otimizados**:
   - Utilização de imagens base Alpine para backend e frontend, priorizando eficiência e portabilidade.
   - [backend.dockerfile](dockerfiles/backend.dockerfile)
   - [frontend.dockerfile](dockerfiles/frontend.dockerfile)

2. **Docker Compose**:
   - Utilizado para construir as imagens e publicá-las no Docker Hub.
   - Arquivo de configuração: [docker-compose.yml](docker-compose.yml)
  
3. **Implementação de Helm Charts**:
   - Criação de Charts específicos para cada componente da aplicação.
   - Padronização de nomenclatura e organização dos recursos.
   - Manifestos de Kubernetes segregados por tipo de recurso.
   - Utilização das melhores práticas de Kubernetes com ConfigMaps, HPAs, Secrets, etc.
   - Diretório de Charts: [my-app-k8s/charts](my-app-k8s/charts)

4. **Ingress**:
    - Utilização de Ingress Nginx para roteamento de tráfego HTTP para os serviços.
    - Configuração de regras de roteamento para backend e frontend.
    - Arquivo de configuração: [nginx.conf](apps/frontend/nginx.conf) e [ingress.yaml](my-app-k8s/charts/frontendapp/templates/ingress.yaml)


## Requisitos

- [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

> **Nota**: Este ambiente foi testado no Windows 11 com [Docker Desktop](https://docs.docker.com/desktop/)

## Configuração Inicial

### 1. Ativação do Kubernetes

No painel do Docker Desktop ir em Settings > Kubernetes

Habilitar o 'Enable Kubernetes' e clicar em 'Apply & Restart'

### 2. Verificar se o kubectl e o contexto estão corretos

Execute o comando 'kubectl get nodes' e verifique se o node do docker-desktop é listado conforme exemplo abaixo:

```shell
kubectl get nodes

NAME                 STATUS    ROLES            AGE       VERSION
docker-desktop       Ready     control-plane    3h        v1.29.1
```

Caso dê erro ao não encontrar o kubectl, verifique se o path está configurado corretamente.

Caso o erro seja referente a nao encontrar o node, é preciso reconfigurar o contexto. Portanto execute os seguintes comandos:

```shell
 kubectl config get-contexts
 kubectl config use-context docker-desktop
```

## Instruções de Instalação e Execução

### 1. Clonar o repositório e entre nele

```shell
git clone https://github.com/romulow22/pucpratica2k8s.git
cd pucpratica2k8s
```

### 2. (OPCIONAL) Construir as imagens e publicá-las no docker hub

> **Nota**: Neste projeto as imagens já estão disponíveis no Docker Hub, portanto este passo é opcional.

Crie uma conta no docker hub e um repositório público.

Atualize as imagens e tags dos containeres nos arquivos com o seu novo repositório:

- [docker-compose.yml](docker-compose.yml)
- [backendapp/values.yaml](my-app-k8s/charts/backendapp/values.yaml)
- [frontendapp/values.yaml](my-app-k8s/charts/frontendapp/values.yaml)
- [postgresdb/values.yaml](my-app-k8s/charts/postgresdb/values.yaml)

Logue-se no seu registry:

```shell
docker login -u [inclua seu username] -p [inclua seu password]
```

Construa e envie as imagens para o registry:

```shell
docker compose build --no-cache --push
```

### 3. Preparação do ambiente

No Docker Desktop, por padrão o metrics-server utilizado pelo HPA e o Ingress não vêm instalados.

### 3.1 Metrics Server

Instalação padrão do metrics-server:

```shell
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

helm repo update

helm install metrics-server metrics-server/metrics-server --namespace kube-system
```

Inclua no args do deployment a flag "--kubelet-insecure-tls" para que a API não utilize o TLS.

```shell
kubectl edit deployment -n kube-system metrics-server
```

Após salvar o deployment é necessário restartá-lo, para isso execute o comando:

```shell
kubectl rollout restart deployment -n kube-system metrics-server
```

Agora verifique se o metrics-server está instalado corretamente

```shell
kubectl top pods -A
```

### 3.2 Ingress Controller

Instalação padrão do Ingress:

```shell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
```

Verificando o status do serviço:

```shell
kubectl get service --namespace ingress-nginx 
```

### 3.3 Inclusão de entrada no arquivo Hosts para o localhost

```shell
127.0.0.1 pucpratica2k8s.com
```

### 4. Instalar os Charts no Kubernetes

```shell
helm install k8srelease ./my-app-k8s --namespace my-app-ns --create-namespace
```

### 5. Verificar saúde da infra da aplicação

```shell
kubectl get all -n my-app-ns

NAME                                                   READY   STATUS    RESTARTS   AGE
pod/k8srelease-backendapp-backend-7746db4bf8-6dqt5     1/1     Running   0          62m
pod/k8srelease-frontendapp-frontend-786856bcdc-lkpjc   1/1     Running   0          62m
pod/k8srelease-postgresdb-database-f66f9d899-qx5p5     1/1     Running   0          62m

NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/k8srelease-backendapp-backend     ClusterIP   10.108.63.22     <none>        5000/TCP   62m
service/k8srelease-frontendapp-frontend   ClusterIP   10.98.81.42      <none>        8080/TCP   62m
service/k8srelease-postgresdb-database    ClusterIP   10.108.104.171   <none>        5432/TCP   62m

NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/k8srelease-backendapp-backend     1/1     1            1           62m
deployment.apps/k8srelease-frontendapp-frontend   1/1     1            1           62m
deployment.apps/k8srelease-postgresdb-database    1/1     1            1           62m

NAME                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/k8srelease-backendapp-backend-7746db4bf8     1         1         1       62m
replicaset.apps/k8srelease-frontendapp-frontend-786856bcdc   1         1         1       62m
replicaset.apps/k8srelease-postgresdb-database-f66f9d899     1         1         1       62m

NAME                                                                    REFERENCE                                  TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/k8srelease-backendapp-backend-hpa   Deployment/k8srelease-backendapp-backend   cpu: 0%/80%   1         5         1          62m

```

> **Nota**: Pode levar até 30 segundos para que todos os pods fiquem com o status "Ready" e até 60 segundos para que o metrics-server comece a coletar a métrica de CPU para o HPA

Caso haja algum contêiner com erro, por exemplo, Crashloopbackoff, podemos realizar uma análise para identificar possíveis erros em eventos e logs, como:

```shell
kubectl get events -A --sort-by='.metadata.creationTimestamp'

kubectl logs deployment.apps/k8srelease-backendapp-backend -n my-app-ns -f --all-containers=true
```

## Como Jogar

1. Acesse [http://pucpratica2k8s.com/](http://pucpratica2k8s.com/) em seu navegador.
2. Na página 'Maker', crie um novo jogo inserindo uma frase secreta e anote o Game ID gerado.
3. Na página 'Breaker', insira o Game ID e tente adivinhar a frase secreta.

## Remoção do Ambiente

Para remover completamente o ambiente:

```shell
helm uninstall k8srelease -n my-app-ns
cd ..
rm pucpratica2k8s -r -force
```  

Desabilite o Kubernetes no Docker Desktop.

## Considerações de Segurança

1. Considere implementar HTTPS para produção.
2. Utilize secrets para armazenar informações sensíveis.
3. Monitore e limite o acesso aos recursos do Kubernetes.

## Contribuição

Contribuições são bem-vindas! Por favor, abra uma issue ou pull request para sugestões ou melhorias.

## Licença

Este projeto está licenciado sob a MIT License.