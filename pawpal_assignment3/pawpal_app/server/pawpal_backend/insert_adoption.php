<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    $response = array('status' => 'failed', 'message' => 'Method Not Allowed');
    sendJsonResponse($response);
    exit();
}

// Check if required fields are provided
if (!isset($_POST['user_id']) || !isset($_POST['pet_id']) || !isset($_POST['motivation'])) {
    $response = array('status' => 'failed', 'message' => 'Please fill in all fields');
    sendJsonResponse($response);
    exit();
}

$user_id = $_POST['user_id'];
$pet_id = $_POST['pet_id'];
$motivation_message = addslashes($_POST['motivation']);

// Insert into tbl_adoptions
$sqlinsert = "INSERT INTO `tbl_adoptions`(`user_id`, `pet_id`, `motivation_message`, `status`, `request_date`) 
VALUES ('$user_id','$pet_id','$motivation_message','Pending', NOW())";

if ($conn->query($sqlinsert) === TRUE) {
    $response = array('status' => 'success', 'message' => 'Adoption request submitted successfully');
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'message' => 'Failed to submit adoption request: ' . $conn->error);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
    echo json_encode($sentArray);
}
?>
