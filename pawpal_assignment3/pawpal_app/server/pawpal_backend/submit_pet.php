<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    $response = array('status' => 'failed', 'message' => 'Method Not Allowed');
    sendJsonResponse($response);
    exit();
}

// Receive Text Data from Flutter
$userid = $_POST['userid'];
$pet_name = addslashes($_POST['pet_name']); 
$pet_type = $_POST['pet_type'];
$category = $_POST['category'];
$description = addslashes($_POST['description']);
$lat = $_POST['lat'];
$lng = $_POST['lng'];

// 'image_count' tells us how many images the user selected (0, 1, 2, or 3)
$image_count = (int)$_POST['image_count']; 

$saved_filenames = array();

// Loop to process Images (Max 3)
for ($i = 0; $i < $image_count; $i++) {
    // Check if the specific image key exists
    if (isset($_POST['image_data_' . $i])) {
        $encoded_string = $_POST['image_data_' . $i];
        
        // Generate Unique Filename: pet_USERID_TIMESTAMP_INDEX.png
        // Example: pet_291214_170123456_0.png
        $filename = "pet_" . $userid . "_" . time() . "_" . $i . ".png";
        
        $path = "uploads/" . $filename; 

        // 5. Save Image using file_put_contents 
        file_put_contents($path, base64_decode($encoded_string));
        
        // Add valid filename to our list
        $saved_filenames[] = $filename;
    }
}

// Convert array of filenames to a comma-separated string
$image_paths_str = implode(",", $saved_filenames);

// Insert into Database
$sqlinsert = "INSERT INTO `tbl_pets`(`user_id`, `pet_name`, `pet_type`, `category`, `description`, `image_paths`, `lat`, `lng`) 
VALUES ('$userid','$pet_name','$pet_type','$category','$description','$image_paths_str','$lat','$lng')";

if ($conn->query($sqlinsert) === TRUE) {
    $response = array('status' => 'success', 'message' => 'Pet submitted successfully');
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'message' => 'Database Error: ' . $conn->error);
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