echo
echo "============================================================"
echo "Removing existing containers (if any) ..."
echo
docker compose down

echo
echo "============================================================"
echo "Creating and copying certificates ..."
echo
./gen_certs.sh

echo
echo "============================================================"
echo "Changing file permissions ..."
echo
chmod 755 durablefhir/configure.sh

echo
echo "============================================================"
echo "Building and starting containers ..."
echo
docker compose up -d

echo
echo "============================================================"
echo "Done !"
echo


