# CSYE7125 - Advanced Cloud Computing
# istio-helm-chart
This helm chart installs all the necessary kubernetes objects required to run the Istio in the kubernetes cluster.
##
Chart dependencies:
- base
- gateway
- istiod
- kiali-server
##
To install the helm chart, run the following command:
```
helm install [release_name] [./chart_folder] -n [namespace_name]
```
##
To Uninstall the chart, try
```
helm uninstall [release_name] -n [namespace_name]
```