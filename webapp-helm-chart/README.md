# CSYE7125 - Advanced Cloud Computing
# webapp-helm-chart
This helm chart installs all the necessary kubernetes objects required to run the webapp API.
##
Chart dependencies:
- PostgreSql
##
To install the helm chart, run the following command:
```
helm install [release_name] [./chart_folder]
```
##
To Uninstall the chart, try
```
helm uninstall [release_name]
```
##
This Webapp Chart also installs a Load Balancer Service using which the users can access the Webapp API.
```
http://$SERVICE_IP/[API_ROUTE]
```
NOTE: It may take a few minutes for the LoadBalancer IP to be available.