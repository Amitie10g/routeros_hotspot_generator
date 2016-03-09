#!/usr/bin/php
<?php

// Simple script to generate randon numbers and store in a DB using SQLite

$mikrotik_ip = '192.168.123.1';
$mikrotik_user = 'admin';
$mikrotik_password = '';

$hotspot_users = 100;

$hotspot_server = '';
$hotspot_profile = '';

// Delete the existing DB file
unlink('users.db');

require_once('routeros_api.class.php');

$ros = new RouterosAPI();

// Try to connect
if ($ros->connect($mikrotik_ip, $mikrotik_user, $mikrotik_password)){

	// Run the script to clean the Hotspot users, stored in the RouterBoard
	$ros->comm('/system/script/run', array('number'=>'0'));
	
	// Create the DB file
	$db = new SQLite3('users.db');
	
	// Create the table with the fields
	$db->exec('CREATE TABLE users (id INTEGER,pin INTEGER,used BOOL);');

	// Iterate the number of desired Hotspot users
	if(!is_int($hotspot_users)) $hotspot_users = 100;
	for($num = 0; $num < $hotspot_users; $num++){
		
		// Generate a randon PIN between consistent numbers
		$pin = mt_rand(124871,932569);
		
		// Insert the PIN into the DB
		$db->exec("INSERT INTO users (id,pin,used) VALUES ($num,$pin,0);");
		
		// Add the new Hotspot user into the RouterBoard
		$ros->comm('/ip/hotspot/user/add',array('name'=>$pin,'profile'=>$hotspot_profile,'server'=>$hotspot_server));
	}
	$ros->disconnect();
}
?>