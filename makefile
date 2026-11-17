dev_composer_env="liszt"
dev_composer_bucket="gs://europe-west1-liszt-fe4ea4da-bucket/dags/dependencies"
dev_project=ABC-BI-dev

prod_composer_env="bach"
prod_composer_bucket="gs://europe-west1-bach-75b05860-bucket/dags/dependencies"
prod_project=ABC-BI-prod

upload_dag:
	gcloud composer environments storage dags import --environment ${dev_composer_env} --location europe-west1 --source ${DAG} --project ${dev_project}

upload_all_dags:
	for dag in *_dag.py; do \
		echo "Uploading $$dag.."; \
		gcloud composer environments storage dags import --environment ${dev_composer_env} --location europe-west1 --source $$dag --project ${dev_project}; \
	done; \
	echo "Sucess!"

upload_all_dependencies:
	gsutil -m rsync -d -r dependencies "${dev_composer_bucket}"

# upload_depency:
# 	gsutil cp ${FILE} "${dev_composer_bucket}" 

add-todos-to-readme:
	echo "\n\n## Files with TODOs\n" >> README.md;
	find . -type f -print0 | xargs -0 grep -l "TODO:" >> README.md

# PRODUCTION
prod_upload_dag:
	gcloud composer environments storage dags import --environment ${prod_composer_env} --location europe-west1 --source ${DAG} --project ${prod_project}

prod_upload_all_dags:
	for dag in *_dag.py; do \
		echo "Uploading $$dag.."; \
		gcloud composer environments storage dags import --environment ${prod_composer_env} --location europe-west1 --source $$dag --project ${prod_project}; \
	done; \
	echo "Success!"

prod_upload_all_dependencies:
	gsutil -m rsync -d -r dependencies "${prod_composer_bucket}"