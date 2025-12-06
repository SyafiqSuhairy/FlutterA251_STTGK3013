<?php
	header("Access-Control-Allow-Origin: *");
	include 'dbconnect.php';

	if ($_SERVER['REQUEST_METHOD'] != 'POST') {
		http_response_code(405);
		echo json_encode(array('success' => false, 'message' => 'Method Not Allowed'));
		exit();
	}
    
    // Check if required fields are sent
	if (!isset($_POST['email']) || !isset($_POST['password']) || !isset($_POST['name']) || !isset($_POST['phone'])) {
		http_response_code(400);
		echo json_encode(array('success' => false, 'message' => 'Please fill in all fields'));
		exit();
	}

	$email = $_POST['email'];
	$name = $_POST['name'];
	$phone = $_POST['phone'];
	$password = $_POST['password'];
	$hashedpassword = sha1($password); 
    
	// Check if email already exists
	$sqlcheckmail = "SELECT * FROM `tbl_users` WHERE `email` = '$email'";
	$result = $conn->query($sqlcheckmail);
    
	if ($result->num_rows > 0){
		$response = array('success' => false, 'message' => 'Email already registered');
		sendJsonResponse($response);
		exit();
	}
    
	// Insert new user into database
    // Columns: name, email, password, phone
	$sqlregister = "INSERT INTO `tbl_users`(`name`, `email`, `password`, `phone`) VALUES ('$name','$email','$hashedpassword', '$phone')";
	
    try{
		if ($conn->query($sqlregister) === TRUE){
			$response = array('success' => true, 'message' => 'Registration successful');
			sendJsonResponse($response);
		}else{
			$response = array('success' => false, 'message' => 'Registration failed');
			sendJsonResponse($response);
		}
	}catch(Exception $e){
		$response = array('success' => false, 'message' => $e->getMessage());
		sendJsonResponse($response);
	}


    // Function to send json response	
    function sendJsonResponse($sentArray)
    {
        header('Content-Type: application/json');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type');
        echo json_encode($sentArray);
    }
?>