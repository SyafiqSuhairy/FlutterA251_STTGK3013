<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    $response = array('status' => 'failed', 'message' => 'Method Not Allowed');
    sendJsonResponse($response);
    exit();
}

// Check if required fields are provided
if (!isset($_POST['user_id']) || !isset($_POST['name']) || !isset($_POST['phone'])) {
    $response = array('status' => 'failed', 'message' => 'Please fill in all required fields');
    sendJsonResponse($response);
    exit();
}

$user_id = $_POST['user_id'];
$name = addslashes($_POST['name']);
$phone = $_POST['phone'];
$profile_image = null;

// Handle image upload if provided
if (isset($_POST['image_data']) && !empty($_POST['image_data'])) {
    $encoded_string = $_POST['image_data'];
    
    // Generate unique filename: profile_USERID_TIMESTAMP.png
    $filename = "profile_" . $user_id . "_" . time() . ".png";
    $path = "uploads/" . $filename;
    
    // Decode and save image
    $decoded_string = base64_decode($encoded_string);
    if ($decoded_string !== false) {
        if (file_put_contents($path, $decoded_string)) {
            $profile_image = $filename;
        } else {
            $response = array('status' => 'failed', 'message' => 'Failed to save image');
            sendJsonResponse($response);
            exit();
        }
    } else {
        $response = array('status' => 'failed', 'message' => 'Invalid image data');
        sendJsonResponse($response);
        exit();
    }
}

// Update user profile
if ($profile_image !== null) {
    // Update with new image
    $sqlupdate = "UPDATE `tbl_users` SET `name`='$name', `phone`='$phone', `profile_image`='$profile_image' WHERE `user_id`='$user_id'";
} else {
    // Update without changing image
    $sqlupdate = "UPDATE `tbl_users` SET `name`='$name', `phone`='$phone' WHERE `user_id`='$user_id'";
}

if ($conn->query($sqlupdate) === TRUE) {
    // Fetch updated user data
    $sqlfetch = "SELECT * FROM `tbl_users` WHERE `user_id`='$user_id'";
    $result = $conn->query($sqlfetch);
    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        $response = array(
            'status' => 'success', 
            'message' => 'Profile updated successfully',
            'data' => $user
        );
    } else {
        $response = array('status' => 'success', 'message' => 'Profile updated successfully');
    }
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'message' => 'Failed to update profile: ' . $conn->error);
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
