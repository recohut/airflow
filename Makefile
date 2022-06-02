install:
# Install Airflow using the constraints file
	$(eval AIRFLOW_VERSION := 2.3.1)
	$(eval PYTHON_VERSION := $(shell python --version | cut -d " " -f 2 | cut -d "." -f 1-2))
	$(eval CONSTRAINT_URL := "https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt")
	pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

setup:
# Airflow needs a home. We are using current directory as default,\
but you can put it somewhere else if you prefer (optional)
	$(shell export AIRFLOW_HOME=${PWD})
	$(shell export AIRFLOW__CORE__DAGS_FOLDER AIRFLOW_HOME=${PWD}/dags)
	airflow config get-value core dags_folder

standalone:
# The Standalone command will initialise the database, make a user,\
and start all components for you.
	airflow standalone
# Visit localhost:8080 in the browser and use the admin account details\
shown on the terminal to login.
# Enable the example_bash_operator dag in the home page

not-standalone:
	airflow db init
	airflow users create \
		--username admin \
		--password admin \
		--firstname Sparsh \
		--lastname Agarwal \
		--role Admin \
		--email sparsh@example.com
	airflow webserver --port 8080
	airflow scheduler

list:
# List all available DAGs
	airflow dags list

docker:
#!/bin/bash
# Note: this script is a bit of a "hack" to run Airflow in a single container.
# This is obviously not ideal, but convenient for demonstration purposes.
# In a production setting, run Airflow in separate containers, as explained in Chapter 10.
	set -x
	SCRIPT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
	docker run \
	-ti \
	-p 8080:8080 \
	-v ${SCRIPT_DIR}/../dags/download_rocket_launches.py:/opt/airflow/dags/download_rocket_launches.py \
	--name airflow
	--entrypoint=/bin/bash \
	apache/airflow:2.0.0-python3.8 \
	-c '( \
	airflow db init && \
	airflow users create --username admin --password admin --firstname Anonymous --lastname Admin --role Admin --email admin@example.org \
	); \
	airflow webserver & \
	airflow scheduler \
	'