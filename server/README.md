# massage-server

Massage Planner server

## Prerequisites

You will need [Leiningen][] 2.0.0 or above installed.

[leiningen]: https://github.com/technomancy/leiningen

## Initial set up

Set up the MySQL database:

    CREATE DATABASE massages;
    CREATE USER 'massages'@'localhost' IDENTIFIED BY 'massages';
    GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON massages.* TO 'massages'@'localhost' IDENTIFIED BY 'massages';
    USE massages;

Create the tables and initial data set by copy/pasting the migration (note to self: ragtime!)


## Running

To start a web server for the application, run:

    lein ring server-headless

Open ```http://localhost:3000/index.html``` in a browser.


## License

Copyright © 2015 Alexander Curtis

