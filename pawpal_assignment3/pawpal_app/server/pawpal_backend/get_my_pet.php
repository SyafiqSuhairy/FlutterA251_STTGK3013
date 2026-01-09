<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

// Check if 'userid' parameter is provided in the URL
if (!isset($_GET['userid'])) {
    $response = array('status' => 'failed', 'message' => 'User ID is missing');
    sendJsonResponse($response);
    exit();
}

$userid = $_GET['userid'];

// Query the database (Pets ID Match with User ID)
$sql = "SELECT * FROM tbl_pets WHERE user_id = '$userid' ORDER BY date_reg DESC";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // If data exists, loop through and store in an array
    $rows = array();
    while ($r = $result->fetch_assoc()) {
        $rows[] = $r;
    }
    
    sendJsonResponse(array('status' => 'success', 'data' => $rows));
} else {
    // If no pets found, still return 'success' but with empty data
    sendJsonResponse(array('status' => 'success', 'data' => null)); 
}

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
    echo json_encode($sentArray);
}
?>