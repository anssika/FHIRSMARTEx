echo
echo "============================================================"
echo "Removing existing containers (if any) ..."
echo
docker compose down

echo
echo "============================================================"
echo "Creating and copying certificates ..."
echo
./gen-certs.sh

echo
echo "============================================================"
echo "Building and starting containers ..."
echo
docker compose up -d

echo
echo "============================================================"
echo "Setting up IRIS ..."
echo
#docker exec -it fhir sh -c "iris session iris < /shared/setup.objectscript"

echo
echo "============================================================"
echo "Thats all - Wait until the containers are up"
echo


