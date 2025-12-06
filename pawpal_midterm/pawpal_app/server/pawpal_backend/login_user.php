<?php
header("Access-Control-Allow-Origin: *");

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    $response = array('success' => false, 'message' => 'Method Not Allowed');
    sendJsonResponse($response);
    exit();
}

// Check if email and password are provided
if (!isset($_POST['email']) || !isset($_POST['password'])) {
    $response = array('success' => false, 'message' => 'Please fill in email and password');
    sendJsonResponse($response);
    exit();
}

include 'dbconnect.php';

$email = $_POST['email'];
$password = $_POST['password'];
$hashedpassword = sha1($password); 

// Query to find the user
$sqllogin = "SELECT * FROM `tbl_users` WHERE `email` = '$email' AND `password` = '$hashedpassword'";
$result = $conn->query($sqllogin);

if ($result->num_rows > 0) {
    $userlist = array();
    while ($row = $result->fetch_assoc()) {
        $userlist[] = $row;
    }
    // Return success: true and the user data
    $response = array('success' => true, 'message' => 'Login successful', 'data' => $userlist);
    sendJsonResponse($response);
} else {
    $response = array('success' => false, 'message' => 'Invalid email or password');
    sendJsonResponse($response);
}

// Helper function to send JSON
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
    echo json_encode($sentArray);
}
?>