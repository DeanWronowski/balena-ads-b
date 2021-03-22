#!/usr/bin/env bash
set -e

# Check if service has been disabled through the DISABLED_SERVICES environment variable.

if [[ ",$(echo -e "${DISABLED_SERVICES}" | tr -d '[:space:]')," = *",$BALENA_SERVICE_NAME,"* ]]; then
        echo "$BALENA_SERVICE_NAME is manually disabled."
        sleep infinity
fi

# Verify that all the required varibles are set before starting up the application.

echo "Verifying settings..."
echo " "
sleep 2

missing_variables=false
        
# Begin defining all the required configuration variables.

[ -z "$LAT" ] && echo "Receiver latitude is missing, will abort startup." && missing_variables=true || echo "Receiver latitude is set: $LAT"
[ -z "$LON" ] && echo "Receiver longitude is missing, will abort startup." && missing_variables=true || echo "Receiver longitude is set: $LON"
[ -z "$ALT" ] && echo "Receiver altitude is missing, will abort startup." && missing_variables=true || echo "Receiver altitude is set: $ALT"
[ -z "$RECEIVER_HOST" ] && echo "Receiver host is missing, will abort startup." && missing_variables=true || echo "Receiver host is set: $RECEIVER_HOST"
[ -z "$RECEIVER_PORT" ] && echo "Receiver port is missing, will abort startup." && missing_variables=true || echo "Receiver port is set: $RECEIVER_PORT"
[ -z "$ADSBEXCHANGE_RECEIVER_NAME" ] && echo "ADSBEXCHANGE Receiver port is missing, will abort startup." && missing_variables=true || echo "ADSBEXCHANGE Receiver port is set: $ADSBEXCHANGE_RECEIVER_NAME"

# End defining all the required configuration variables.

echo " "

if [ "$missing_variables" = true ]
then
        echo "Settings missing, aborting..."
        echo " "
        sleep infinity
fi

echo "Settings verified, proceeding with startup."
echo " "

# Variables are verified – continue with startup procedure.

while sleep 30
do
	if ping -q -c 2 -W 5 feed.adsbexchange.com >/dev/null 2>&1
	then
		echo Connected to feed.adsbexchange.com:31090
                echo Feeding from "${RECEIVER_HOST}:${RECEIVER_PORT}" with MLAT results at "${RECEIVER_HOST}:3104"
		mlat-client --input-type dump1090 --input-connect ${RECEIVER_HOST}:${RECEIVER_PORT} --lat ${LAT} --lon ${LON} --alt ${ALT} --user ${ADSBEXCHANGE_RECEIVER_NAME} --server feed.adsbexchange.com:31090
		echo Disconnected
	else
		echo Unable to connect to feed.adsbexchange.com, trying again in 30 seconds!
	fi
done