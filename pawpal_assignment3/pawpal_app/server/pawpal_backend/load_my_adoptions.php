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

// Query to get adoptions joined with pets
// Extract first image from image_paths for display
$sql = "SELECT 
    a.adoption_id,
    a.user_id,
    a.pet_id,
    a.motivation_message,
    a.status,
    a.request_date,
    p.pet_name,
    p.image_paths,
    SUBSTRING_INDEX(p.image_paths, ',', 1) as pet_image
FROM tbl_adoptions a
INNER JOIN tbl_pets p ON a.pet_id = p.pet_id
WHERE a.user_id = '$userid'
ORDER BY a.request_date DESC";

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
