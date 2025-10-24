DOCKER_UP=docker compose up -d 
DOCKER_DOWN=docker compose down 

PG_URL=PGPASSWORD='edutechpass' psql -h localhost -p 5433 -U edutech_admin -d edutech -v ON_ERROR_STOP=1

up:
	$(DOCKER_UP)

down:
	$(DOCKER_DOWN)

db.clean:
	$(PG_URL) -c "DROP SCHEMA IF EXISTS edutech CASCADE;"

db.reset:
	$(PG_URL) -c "DROP SCHEMA IF EXISTS edutech CASCADE;"
	$(PG_URL) -f sql/deploy.sql

db.apply:
	$(PG_URL) -f sql/deploy.sql

db.info:
	psql_edutech -c "\dn"
	psql_edutech -c "\dt edutech.*"
	psql_edutech -c "\di edutech.*"
