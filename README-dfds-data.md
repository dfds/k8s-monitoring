# Grafana dashboards

This repository contains dashboards for monitoring our running solutions, as well as the pipeline to
deploy more dashboards. Whenever this repository falls behind the upstream repository, make sure to
fetch it.

## Deploying Grafana

Grafana has been deployed manually using the powershell script referenced in
[the main readme](./README.md).

## Using Grafana

You must log in with the shared credentials. They are found
[here](https://eu-west-1.console.aws.amazon.com/systems-manager/parameters/grafana_admin_credentials/description?region=eu-west-1).

## Adding and deploying dashboards

Dashboards should be created/modified in the UI, then saved as JSON and put in the dashboards folder
(/grafana/dashboards). You can save the dashboard configuration as JSON in the UI by going to
settings and copying the "JSON Model" text into a file. The pipeline will convert them to configmaps
and they should be persisted in k8s this way. The JSON dashboards are converted to configmaps with a
[powershell script](./grafana/Convert-JSONToConfigmap.ps1), and deployed using
[azure pipelines](./azure-pipelines.yml).

## Adding Data Source connection for postgres

To include a data source connection to a postgres database in the grafana deployment you should
include the datasource in [datasource.yaml](./grafana/configmaps/datasource.yaml). See
`Postgres-Overdue` as inspiration. The connection requires the postgres database url and the
username and password (read-only user recommended) which are defined in the ADO library
`grafana-postgres-datasource`. More information can be found in https://grafana.com/docs/grafana/latest/datasources/postgres/

### Naming conventions

Please name your dashboard `dashboard-<name>.json`, where `<name>` is some name you come up with (no
spaces, special characters or numbers).

## More documentation

Please refer to the
[internal docs](https://dfds.visualstudio.com/DefaultCollection/Smart%20Data/_wiki/wikis/Smart-Data.wiki/3226/Grafana-Dashboards).
