<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

// Get search and filter parameters
$search = isset($_GET['search']) ? $_GET['search'] : '';
$type = isset($_GET['type']) ? $_GET['type'] : '';

// Build query with filters - explicitly select needs_donation
$sql = "SELECT 
    p.pet_id,
    p.user_id,
    p.pet_name,
    p.pet_type,
    p.category,
    p.description,
    p.image_paths,
    p.pet_status,
    p.needs_donation,
    p.lat,
    p.lng,
    p.date_reg,
    u.name as user_name,
    u.phone as user_phone,
    u.profile_image
FROM tbl_pets p
INNER JOIN tbl_users u ON p.user_id = u.user_id
WHERE 1=1";

// Add search filter (by pet name)
if (!empty($search)) {
    $search = addslashes($search);
    $sql .= " AND p.pet_name LIKE '%$search%'";
}

// Add type filter
if (!empty($type) && $type != 'All') {
    $type = addslashes($type);
    $sql .= " AND p.pet_type = '$type'";
}

$sql .= " ORDER BY p.date_reg DESC";

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
