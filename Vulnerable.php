<?php
// Vulnerability 1: Command Injection
$command = $_GET['cmd'];
system($command);

// Vulnerability 2: SQL Injection
$unsafe_variable = $_POST['user_input'];
mysql_query("INSERT INTO `table` (`column`) VALUES ('$unsafe_variable')");

// Vulnerability 3: Cross-Site Scripting (XSS)
echo "<div>$_GET[username]</div>";

// Vulnerability 4: File Inclusion Vulnerability
include($_GET['file']);

// Vulnerability 5: Insecure Direct Object References (IDOR)
$user_file = $_GET['file'];
readfile('/var/www/private_files/' . $user_file);

// Vulnerability 6: Arbitrary File Upload
move_uploaded_file($_FILES['file']['tmp_name'], '/var/www/uploads/' . $_FILES['file']['name']);

// Vulnerability 7: Weak Hashing Algorithm
$hashed_password = md5($_POST['password']);

// Vulnerability 8: Missing Authorization Check
$admin_action = $_GET['admin_action'];
if ($admin_action == "delete_all_users") {
    deleteAllUsers();
}

// Vulnerability 9: Information Leakage
phpinfo();

// Vulnerability 10: Cross-Site Request Forgery (CSRF)
$cookie = $_GET['cookie'];
setcookie("sessionId", $cookie, time()+3600);
?>
