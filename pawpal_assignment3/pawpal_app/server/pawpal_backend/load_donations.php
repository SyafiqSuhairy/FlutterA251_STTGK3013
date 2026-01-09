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

// Query to get donations joined with pets
$sql = "SELECT 
    d.donation_id,
    d.user_id,
    d.pet_id,
    d.donation_type,
    d.amount,
    d.description,
    d.donation_date,
    p.pet_name,
    p.image_paths,
    SUBSTRING_INDEX(p.image_paths, ',', 1) as pet_image
FROM tbl_donations d
INNER JOIN tbl_pets p ON d.pet_id = p.pet_id
WHERE d.user_id = '$userid'
ORDER BY d.donation_date DESC";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $rows = array();
    while ($r = $result->fetch_assoc()) {
        $rows[] = $r;
    }
    sendJsonResponse(array('status' => 'success', 'data' => $rows));
} else {
    sendJsonResponse(array('status' => 'success', 'data' => []));
}

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
    echo json_encode($sentArray);
}
?>
