

REGION="europe-west1"
ZONE="europe-west1-b"
TEMPLATE_ID="load_exponea_table_gzip"

dev_dataproc_assets_bucket=gs://dataproc-assets/exponea_gzip
dev_project=ABC-BI-dev

upload_assets:
	gsutil cp main.py ${dev_dataproc_assets_bucket} --region ${REGION} --project ${dev_project}

upload_template:
	gcloud dataproc workflow-templates import ${TEMPLATE_ID} --region ${REGION} --source workflow-tmpl.yaml