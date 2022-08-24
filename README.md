# diveapi
Public API service for the  e-shape DIVE application.

To install the DIVE API service 
```
cd diveapi
docker-compose up
```
The docker-compose.yml and supporting configuration files should work with no alterations. 

You should change the passwords once the server is installed. You can change the PostgreSQL passwords using the psql CLI if you have it installed or with the adminer web interface (http://localhost:8080/?pgsql=db&username=postgres&db=dive). The password in [dive-frontend/config/dive.ini](https://github.com/pmlrsg/diveapi/blob/992bfb9bc8e4db4818a9d81059e30bec0ee49a1c/dive-frontend/config/dive.ini) must be updated to match.
