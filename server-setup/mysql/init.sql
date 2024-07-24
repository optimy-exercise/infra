CREATE DATABASE IF NOT EXISTS app;
USE app;
CREATE USER IF NOT EXISTS 'user'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON app.* TO 'user'@'%';
FLUSH PRIVILEGES;

CREATE TABLE IF NOT EXISTS test (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    value VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS test (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    value VARCHAR(50)
);

INSERT INTO test (name, value) VALUES ('SampleName1', 'SampleValue1');
INSERT INTO test (name, value) VALUES ('SampleName2', 'SampleValue2');
INSERT INTO test (name, value) VALUES ('SampleName3', 'SampleValue3');
