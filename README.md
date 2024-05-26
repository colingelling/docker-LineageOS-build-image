# docker-lineage-builder
Repository contains a setup for building Lineage OS custom Android ROM for mobile phones

## Status as of may 26th 2024
Currently importing proprietary blobs is not yet supported, starting the build automatically after repo sync completes need to be both fixed and improved. 

## How to deploy
Check the volumes.yml first and make sure that the volumes suite to your expectations, then execute the 'scripts/deploy-container.sh' followed by editing the .env file that should be in your host volume after deployment. To stop and remove the container, execute 'scripts/remove-container.sh'

You can follow logs by executing 'docker logs -f docker-LineageOS-builder'
