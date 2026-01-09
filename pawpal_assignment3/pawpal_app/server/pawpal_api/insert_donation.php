<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    $response = array('status' => 'failed', 'message' => 'Method Not Allowed');
    sendJsonResponse($response);
    exit();
}

// Check if required fields are provided
if (!isset($_POST['user_id']) || !isset($_POST['pet_id']) || !isset($_POST['donation_type'])) {
    $response = array('status' => 'failed', 'message' => 'Please fill in all required fields');
    sendJsonResponse($response);
    exit();
}

$user_id = $_POST['user_id'];
$pet_id = $_POST['pet_id'];
$donation_type = $_POST['donation_type'];
$amount = isset($_POST['amount']) ? $_POST['amount'] : '0.00';
$description = isset($_POST['description']) ? addslashes($_POST['description']) : '';

// Validate based on donation type
if ($donation_type == 'Money') {
    if (!isset($_POST['amount']) || empty($_POST['amount']) || floatval($_POST['amount']) <= 0) {
        $response = array('status' => 'failed', 'message' => 'Please enter a valid amount for money donation');
        sendJsonResponse($response);
        exit();
    }
} else {
    // For Food or Medical, description is required
    if (empty($description)) {
        $response = array('status' => 'failed', 'message' => 'Please provide a description for ' . $donation_type . ' donation');
        sendJsonResponse($response);
        exit();
    }
    // Set amount to 0 for non-money donations
    $amount = '0.00';
}

// Insert into tbl_donations
$sqlinsert = "INSERT INTO `tbl_donations`(`user_id`, `pet_id`, `donation_type`, `amount`, `description`, `donation_date`) 
VALUES ('$user_id','$pet_id','$donation_type','$amount','$description', NOW())";

if ($conn->query($sqlinsert) === TRUE) {
    $response = array('status' => 'success', 'message' => 'Donation submitted successfully');
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'message' => 'Failed to submit donation: ' . $conn->error);
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
