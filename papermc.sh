#!/bin/bash

# Enter server directory
cd papermc

# Set nullstrings back to 'latest'
: ${MC_VERSION:='latest'}
: ${PAPER_BUILD:='latest'}

# Lowercase these to avoid 404 errors on wget
MC_VERSION="${MC_VERSION,,}"
PAPER_BUILD="${PAPER_BUILD,,}"

# Get version information and build download URL and jar name
URL='https://api.papermc.io/v2/projects/paper'
if [[ $MC_VERSION == latest ]]
then
  # Get the latest MC version
  MC_VERSION=$(wget -qO - "$URL" | jq -r '.versions[-1]') # "-r" is needed because the output has quotes otherwise
fi
URL="${URL}/versions/${MC_VERSION}"
if [[ $PAPER_BUILD == latest ]]
then
  # Get the latest build
  PAPER_BUILD=$(wget -qO - "$URL" | jq '.builds[-1]')
fi
JAR_NAME="paper-${MC_VERSION}-${PAPER_BUILD}.jar"
URL="${URL}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}"

# Update if necessary
if [[ ! -e $JAR_NAME ]]
then
  # Remove old server jar(s)
  rm -f *.jar
  # Download new server jar
  wget "$URL" 
fi

# Update eula.txt with current setting
echo "eula=${EULA:-false}" > eula.txt

# Add RAM options to Java options if necessary
if [[ -n $MC_RAM ]]
then
  JAVA_OPTS="-Xms1G -Xmx${MC_RAM} $JAVA_OPTS"
fi

# Start server
exec java -server $JAVA_OPTS -jar "$JAR_NAME" nogui
