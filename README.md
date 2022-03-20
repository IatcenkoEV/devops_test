Firstly, 
#Create multistage Dockerfile
#Dockerfile in this repository
Secondly,
#Create docker-compose
#docker-compose in this repository
Third,
#Add metrics to code
#Add metrics function in main.go
#Add monitoring with Prometheus below:
Prometheus in Minikube
# Install Minikube
brew install minikube
which minikube
minikube start --vm-driver=docker
minikube status
minikube kubectl -- get pods -A
kubectl get nodes
#install Helm 3
brew install helm
#Deploy Prometheus with Helm
#Before that some changes in values file
#Change admin password, option adminPassword: prom-operator
helm inspect values prometheus-community/kube-prometheus-stack >prometheus-values.yaml
helm install prometheus prometheus-community/kube-prometheus-stack --namespace=prometheus --create-namespace --wait
helm inspect values prometheus-community/prometheus-blackbox-exporter > blackbox-prom-values.yaml 
#Add valid_status_codes: ["200", "403"]
helm upgrade -i prometheus-blackbox-exporter prometheus-community/prometheus-blackbox-exporter --namespace=prometheus --values=blackbox-prom-values.yaml 

kubectl --namespace prometheus get pods -l "release=prometheus"
kubectl get svc -n prometheus
#Open three terminals
kubectl port-forward service/prometheus-prometheus-node-exporter 9100 --namespace=prometheus
kubectl port-forward service/prometheus-operated 9090 --namespace=prometheus
kubectl port-forward deployment/prometheus-grafana 3000 --namespace=prometheus
#Check connection to docker-compose webapplication
ifconfig
kubectl exec -it -n prometheus prometheus-prometheus-kube-prometheus-prometheus-0 -- sh
wget <en0ipaddr>:8080
exit
#Add Scrapers to Prometheus Server config
    additionalScrapeConfigs:
      - job_name: 'webapp-scrape'
        scrape_interval: 1m
        metrics_path: '/metrics'
        static_configs:
          - targets: ['192.168.1.45:8080']
      - job_name: 'blackbox'
        metrics_path: /probe
        params:
          module: [http_2xx]  # Look for a HTTP 200 response.
        static_configs:
          - targets:
            - http://192.168.1.45:8080
        relabel_configs:
          - source_labels: [__address__]
            target_label: __param_target
          - source_labels: [__param_target]
            target_label: instance
          - target_label: __address__
            replacement: 'prometheus-blackbox-exporter.prometheus:9115' 
helm upgrade -i prometheus prometheus-community/kube-prometheus-stack --namespace=prometheus --values=prometheus-values.yaml
#
http://127.0.0.1:9090/targets
# Go to Grafana,
# Import 7587 dashboard
# Check the webapp is UP
http://127.0.0.1:3000/d/xtkCtBkiz/prometheus-blackbox-exporter?orgId=1