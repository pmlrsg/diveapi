# diveapi
Public API service for the  e-shape DIVE application.

To install the DIVE API service 
```
cd diveapi
docker-compose up
```
The docker-compose.yml and supporting configuration files should work with no alterations. 

You will probably want to change the passwords once the server is installed. You can change the postgres passwords using the CLI if you have it installed or the provided adminer web interface. The password in dive.ini must be updated to match.
