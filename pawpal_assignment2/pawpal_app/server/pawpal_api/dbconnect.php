<?php
    $servername = "localhost";
    $username = "root";
    $password = "admin123";
    $dbname = "pawpal_db";
    $port = 3307; 

    $conn = new mysqli($servername, $username, $password, $dbname, $port);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
?>